// short program for the OS816 environment
// simple LED animation in C

unsigned const char pattern[] = 
{ 
    0x80, 0xc0, 0x60, 0x30, 0x18, 0x0c, 0x06, 0x03, 
    0x01, 0x03, 0x06, 0x0c, 0x18, 0x30, 0x60, 0xc0
};

void sleep()
{
    unsigned int i;
    for (i=0; i<30000; i++) {}
}

void main()
{

    for (;;)
    {
        unsigned int i;
        for (i=0; i<16; i++)
        {
            portout(pattern[i]);
            sleep();
        }
    }
}
