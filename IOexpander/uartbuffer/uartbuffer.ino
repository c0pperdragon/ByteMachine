// Receive buffer program for the microcontroller that sits on the
// IO Expander Board for the ByteMachine.

// The program is intended to run on an ATTINY44 with approximate 
// 8 MHz (internal clock) and uses the following IO pins:

// Signal  Arduino pin  ATTINY pin
//   RX             10     PB0 = 2         incomming UART data
//   TX              9     PB1 = 3         outgoing UART data
//   SS                                    SPI device select (active low)
//   SCLK                                  SPI clock
//   MOSI                                  SPI master out / slave in 
//   MISO                                  SPI master in / slave out
//
// Serial transmission dedaults to 9600 baud, 1 start, 1 stop, no parity 
// Incomming data from RX will be buffered until received by the SPI master. Outgoing data from the
// SPI master is buffered before transmitting to the UART.

#define RX   10
#define TX    9
#define SS   A3
#define SCLK A4
#define MOSI A6
#define MISO A5

// communication between ISR and the main program
volatile byte txdata;            
volatile boolean txdatapresent;  // will be set by main program, cleared by ISR
volatile byte rxdata;
volatile boolean rxdatapresent;  // will be set by ISR, cleared by main program

#define BUFFERSIZE 10
volatile byte transferbuffer[BUFFERSIZE];
volatile byte receivecursor;
volatile byte transmitcursor;

void setup() 
{              
    noInterrupts(); 
     
    // global communication variables
    txdatapresent = false;
    rxdatapresent = false;

    // pin setup
    digitalWrite(TX, HIGH);
    pinMode(TX, OUTPUT);
    pinMode(RX, INPUT);

    pinMode(SS, INPUT);
    pinMode(SCLK, INPUT);
    pinMode(MOSI, INPUT);
    digitalWrite(TX, HIGH);
    pinMode(MISO, INPUT);

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

    interrupts(); 
}


// main loop to handle the SPI protocol and control the ISR via the interface bytes. 
void loop() 
{
//  if (txdatapresent);  // wait until outgoing data is consumed
//  txdata = 'H';
//  txdatapresent = true;    
  
    byte d;

    while (!rxdatapresent); // wait for incomming data
    d = rxdata;
    rxdatapresent = false;

    while (txdatapresent);  // wait until outgoing data is consumed
    txdata = d;
    txdatapresent = true;    
    while (txdatapresent);  // wait until outgoing data is consumed
    txdata = '!';
    txdatapresent = true;    
}


// internal variables exclusively for the ISR: 
byte outsequence = 99;  
byte outbyte = 0;
byte insequence = 99;
byte inbyte = 0;

// interrupt routine for handling the UART side of things (polled at 4*9600 Hz)
ISR(TIM1_COMPA_vect)
{
    // read data at correct point in time
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
    else if (txdatapresent)
    {
        outbyte = txdata;
        txdatapresent = false;
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
                rxdata = inbyte;
                rxdatapresent = true;
            }
        }
        insequence++;
    }
    // check if encountered new start bit
    else if ( (inport & B00000001) == 0)
    {
        insequence = 0;      
    }

//    PORTB = B0000010;
//    PORTB = B0000000;  
//    digitalWrite(TX, HIGH);
//    digitalWrite(TX, LOW);
}
