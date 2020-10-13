
// test program for the SPI to UART bridge 
// this implements a simple 'echo' program

#include <SPI.h>

#define FREQUENCY 1000000 
#define DELAY 5


void setup() 
{
    SPI.begin();
    pinMode(10, OUTPUT);
}

void loop() 
{
    byte i;
    byte buffer[10];

    for (i=0; i<200; i++)
    {
        int r = receive();
        if (r>=32)
        {
            buffer[0] = 'H';
            buffer[1] = 'i';
            buffer[2] = ',';
            buffer[3] = (byte) r;
            buffer[4] = '\n';
            send(buffer,5);
        }
        delay(10);
    }
    char* txt = "This is a longer line and will need to be sent in multiple junks and will block operation a bit\n";
    send (txt,strlen(txt));
}

int receive()
{
    byte buffer[1];
    int result;
    byte i;
    
    for (i=0; i<DELAY; i++) { digitalWrite(10, LOW);}
    SPI.beginTransaction(SPISettings(FREQUENCY, MSBFIRST, SPI_MODE0));
    buffer[0] = 'R';
    SPI.transfer(buffer,1);
    byte available = buffer[0] & 15;
    if (available==0)
    {
        result = -1;
    }    
    else
    {
        for (i=0; i<DELAY; i++) { digitalWrite(10, LOW);}
        SPI.transfer(buffer,1);
        result = buffer[0];
    }
    SPI.endTransaction();
    for (i=0; i<DELAY; i++) { digitalWrite(10, LOW);}
    for (i=0; i<DELAY; i++) { digitalWrite(10, HIGH);}

    return result;
}

void send(byte* data, int len)
{
    byte buffer[1];
    byte i;

    while (len>0)
    {
        for (i=0; i<DELAY; i++) { digitalWrite(10, LOW);}
        SPI.beginTransaction(SPISettings(FREQUENCY, MSBFIRST, SPI_MODE0));
        buffer[0] = 'S';
        SPI.transfer(buffer,1);
        byte maysend = buffer[0] >> 4;
        while (maysend>0 && len>0)
        {
            buffer[0] = data[0];
            data++;
            len--;
            maysend--;
        
            for (i=0; i<DELAY; i++) { digitalWrite(10, LOW);}
            SPI.transfer(buffer,1);
        }
        SPI.endTransaction();
        for (i=0; i<DELAY; i++) { digitalWrite(10, LOW);}
        for (i=0; i<DELAY; i++) { digitalWrite(10, HIGH);}
    }
}
