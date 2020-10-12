
// test program for the SPI to UART bridge 

#include <SPI.h>



void setup() 
{
    SPI.begin();
    pinMode(10, OUTPUT);
}

void loop() 
{
    char buffer[10];
    buffer[0] = 'S';
    buffer[1] = 'H';
    buffer[2] = 'e';
    buffer[3] = 'l';
    buffer[4] = 'l';
    buffer[5] = 'o';

    digitalWrite(10, LOW);
    SPI.beginTransaction(SPISettings(100000, MSBFIRST, SPI_MODE0));
    SPI.transfer(buffer,6);
    SPI.endTransaction();
    digitalWrite(10, HIGH);

    delay(100);
}
