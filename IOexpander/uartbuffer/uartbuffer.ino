// Receive buffer program for the microcontroller that sits on the
// IO Expander Board for the ByteMachine.

// The program is intended to run on an ATTINY44 with approximate 
// 8 MHz (internal clock) and uses the following IO pins:

// Signal  Arduino pin   ATTINY port & pin
//   RX             10     PB0 = 2         incomming UART data
//   TX              9     PB1 = 3         outgoing UART data
//   SS              3     PA3 = 10        SPI slave select (active low)
//   SCK             4     PA4 = 9         SPI clock
//   MISO            5     PA6 = 8         SPI master in / slave out
//   MOSI            6     PA5 = 7         SPI master out / slave in 
//
// Serial transmission dedaults to 9600 baud, 1 start, 1 stop, no parity 
// Incomming data from RX will be buffered until received by the SPI master. Outgoing data from the
// SPI master is buffered before transmitting to the UART.

#define RX   10
#define TX    9
#define SS    3
#define SCK   4
#define MISO  5
#define MOSI  6

#define DEBUG

// utility class to implement a first-in-first-out buffer
class FIFO
{
private:
    volatile byte buffer[64];
    volatile byte writecursor;
    volatile byte readcursor;
public:
    FIFO() 
    { 
        writecursor=0; 
        readcursor=0; 
    }      
    byte size()
    {
        return (writecursor-readcursor) & 63;
    }
    byte space()
    {
        return 63 - size();
    }
    void append(byte x)
    {
        buffer[writecursor] = x;
        writecursor = (writecursor+1) & 63;
    }
    byte first()
    {
        return buffer[readcursor];
    }
    void pop()
    {
        readcursor = (readcursor+1) & 63;
    }
};

// communciation buffers between the ISR and the main program
FIFO txbuffer;
FIFO rxbuffer;


// interrupts, timers and stuff
void setup() 
{              
    noInterrupts(); 
     
    // pin setup
    digitalWrite(TX, HIGH);
    pinMode(TX, OUTPUT);
    pinMode(RX, INPUT);

    pinMode(SS, INPUT);
    pinMode(SCK, INPUT);
    pinMode(MOSI, INPUT);
    digitalWrite(MISO, HIGH);
    pinMode(MISO, OUTPUT);

    // -- TIMER 1 register setup for CTC mode
    TCCR1A = 
      0x00    // B00000000      // WGM1:0=0
//    | 0x80    // B10000000    // COM1A : set on bottom, clear at match
//    | 0x30    // B00110000 ;  // COM1B : clear on bottom, set at match
      ;
    TCCR1B = 
      0x08    // B00001000    // WGM3:2=1
    | 0x01;   // B00000001 ;  // clock source = full speed

    // timer compare register to get approximately 4x9600 Hz
    OCR1AH = 0;     // prepare high byte 
    OCR1AL = 207;    // write to 16-bit register  
 
    // enable timer 1 compare A interrupt 
    TIMSK1 = 0x02;  // B00000002;     
    // disable other timer interrupts
    TIMSK0 = 0x00;

    // configure universal serial interface
    USICR = B00010000   // three-wire mode
        |   B00001000;  // sample on positive clock edge

    interrupts(); 
}

#define CHIP_IDLE ((PINA & B00001000) != 0)

// main loop to handle the SPI protocol and communicate with the ISR via the transmission buffers. 
void loop() 
{
    byte d;
    
    // wait for SS to become active 
    while (CHIP_IDLE); 
    
    // compute how much data is available and how much can be accepted
    byte canaccept = txbuffer.space();
    if (canaccept>15) { canaccept = 15; }
    byte cansend = rxbuffer.size();
    if (cansend>15) { cansend=15; }

    // prepare first SPI answer byte  and reset shift register status
    USIDR = (canaccept<<4) | cansend;
    USISR = B01000000;  
    
    // wait until a whole byte is transmitted, but terminate if SS is released
    while ((USISR & B01000000) == 0) { if (CHIP_IDLE) return; }            

    // fetch command byte 
    d = USIDR;
    
    // process command    
    if (d=='R')   // master wants to receive
    {
        USIDR = rxbuffer.first();
        USISR = B01000000;
        for (;;)
        {
            // we don't known how many bytes (if any) the master wants to receive, so do not delete data yet 
            // wait until a whole byte is transmitted, but terminate if SS was released in the meantime
            while ((USISR & B01000000) == 0) { if (CHIP_IDLE) return; }            

            // quickyl re-charge the USI facility
            USIDR = rxbuffer.first();
            USISR = B01000000;
                        
            // the server has consumed the byte - so can discard it
            if (rxbuffer.size()>0)
            { 
                rxbuffer.pop();
            }
        }
    }
    else if (d=='S')  // master wants to send
    {
        USIDR = 0;
        USISR = B01000000;
        for (;;)
        {
            // wait until a whole byte is transmitted, but terminate if SS was released in the meantime
            while ((USISR & B01000000) == 0) { if (CHIP_IDLE) return; }            
            
            // fetch the byte to transmit and re-charge the shift register
            d = USIDR;
            USIDR = 0;  
            USISR = B01000000;
            
            if (txbuffer.space()>0)
            {
                txbuffer.append(d);
            }
        }
    }  

    // unknown command - wait until SS is de-asserted
    while (!CHIP_IDLE);            
}

// internal variables exclusively for the ISR: 
byte outsequence = 99;  
byte outbyte = 0;
byte insequence = 99;
byte inbyte = 0;

// interrupt routine for handling the UART side of things (polled at 4*9600 Hz)
ISR(TIM1_COMPA_vect)
{ 
    // read data at precise point in time
    byte inport = PINB;
    
    // sequencing outgoing data including stop bit
    if (outsequence<42)
    {
        if ((outsequence & 0x03) == 3)
        {
            if ( (outbyte&1) == 0)
            {
                PORTB = B0000000;
            }
            else
            {
                PORTB = B0000010;              
            }
            outbyte = (outbyte>>1 ) | B10000000;
        }
        outsequence++;
    }
    // check if new outgoing data is present
    else if (txbuffer.size()>0)
    {
        outbyte = txbuffer.first();
        txbuffer.pop();
        outsequence = 0;
        PORTB = B00000000;   // start bit
    }

    // sequencing incomming data 
    if (insequence<36)
    {
        if ((insequence & 0x03) == 0)
        {
            if ((inport & B00000001) != 0)
            {
                inbyte = (inbyte >> 1) | B10000000;
            }
            else {
                inbyte = (inbyte >> 1);
            }
            if (insequence==32)
            {
                if (rxbuffer.space()>0)
                {
                    rxbuffer.append(inbyte);
                }
            }
        }
        insequence++;
    }
    // check if encountered new start bit
    else if ( (inport & B00000001) == 0)
    {
        insequence = 0;      
    }
}
