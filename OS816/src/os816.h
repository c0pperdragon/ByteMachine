
typedef unsigned int word;
typedef unsigned char byte;

void portset(byte bits);
void portclear(byte bits);
byte portin(void); 

void sleep(word kiloclocks);

