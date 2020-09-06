// Receive buffer program for the microcontroller that sits on the
// IO Expander Board for the ByteMachine.

// The program is intended to run on an ATTINY44 with 8 Mhz (internal clock) 
// and uses the following IO pins:
// Signal  Arduino pin  ATTINY pin
//   RX              4           9
//   RX2             2          11
//   RTS             7           6
//
// Serial transmission is at 9600 baud, 1 start, 1 stop, no parity 
// Incomming data from RX will be buffered until the RTS input signal is low and then sent via RX2.
// The receiver is required to wait one additional millisecond after seting RTS to high for data to
// arrive.

#include <avr/interrupt.h>


#define RX 4
#define RX2 2
#define RTS 7
#define DEBUG 6

#define BUFFERSIZE 10
volatile byte transferbuffer[BUFFERSIZE];
volatile byte receivecursor;
volatile byte transmitcursor;


void setup() 
{              
    noInterrupts(); 
     
    // global variables
    receivecursor=0;
    transmitcursor=0;

    // pin setup
    pinMode(RX, INPUT_PULLUP);
    pinMode(RTS, INPUT_PULLUP);
    pinMode(RX2, OUTPUT);
    pinMode(DEBUG, OUTPUT);

    // -- TIMER 1 register setup for CTC mode
    TCCR1A = 
      0x00    // B00000000      // WGM1:0=0
//    | 0x80    // B10000000    // COM1A : set on bottom, clear at match
//    | 0x30    // B00110000 ;  // COM1B : clear on bottom, set at match
      ;
    TCCR1B = 
      0x08    // B00001000    // WGM3:2=1
    | 0x01;   // B00000001 ;  // clock source = full speed

    // timer compare register to get approximately 9600 Hz
    OCR1AH = 3;     // prepare high byte 
    OCR1AL = 43;    // write to 16-bit register  
 
    // enable timer 1 compare A interrupt 
    TIMSK1 = 0x02;  // B00000002;     
    // disable other timer interrupts
    TIMSK0 = 0x00;

    interrupts(); 
}

void loop() 
{
  digitalWrite(DEBUG,LOW);
  digitalWrite(DEBUG,HIGH);
  /*
    int c = mySerial.read();
    // if anything received, put data in buffer
    if (c>=0) 
    {
        byte nextcursor = (receivecursor+1 < BUFFERSIZE) ? (receivecursor+1) : 0;
        // can only accept data if buffer is not full
        if (nextcursor!=transmitcursor) 
        {
            transferbuffer[receivecursor] = (byte) c;
            receivecursor=nextcursor;    
        }
    }
    
    // check if there is something to transmit and if we are allowed to send now
    if (receivecursor!=transmitcursor
    &&  digitalRead(RTS)==LOW)
    {
        mySerial.write(transferbuffer[transmitcursor]);
        transmitcursor = (transmitcursor+1 < BUFFERSIZE) ? (transmitcursor+1) : 0;
    }
    */
    
}


// interrupt routine for sending bits (9600 Hz)
//ISR(TIM1_OVF_vect)
ISR(TIM1_COMPA_vect)
{
    digitalWrite(RX2, HIGH);
    digitalWrite(RX2, LOW);
}
