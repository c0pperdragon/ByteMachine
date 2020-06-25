// test calling conventions of the 65c816 C-compiler


int inc(int x)
{
	return x+1;
}

int get()
{
	return inc(1);
}

void put(int x)
{
		inc(x);
}

void put2(int x, int y)
{
	inc(x);
	inc(y);
}

void rcv(int * p)
{
	*p = get();
}

int *ptr(int* p)
{
	return p;
}

void fill(char* c)
{
	unsigned int i;
	for (i=0; i<10; i++) { c[i] = 7; }
}

long int l()
{
	return 524343211;
}

void main()
{
	int x;
	char b[10];
	x = get();
	put(x);
	rcv(ptr(&x));
	fill(b);
	l();
}

