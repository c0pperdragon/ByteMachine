package bytemachine;
import java.io.UnsupportedEncodingException;

// Small test program to implement an MD5 in a way which 
// can be easily ported to an 8bit CPU.

public class MD5WithBytes 
{

	public static void main(String[] args) throws UnsupportedEncodingException
	{
		String test = "Mary had a little lamb, His fleece was white as snow, And everywhere that Mary went, The lamb was sure to go.";
		byte[] data = test.getBytes("UTF-8");

		MD5INIT();
		for (int i=0; i<data.length; i++)
		{	MD5APPEND(data[i]);
		}
		MD5FINISH();
		MD5PRINT();
		
		System.out.println();		
	}

	// simulate a small ram with enough space for the operation
	static byte[] ram = new byte[256];
	// locations of variables inside the ram
	static int A0 = 0;         // 32 bit
  	static int B0 = 4;         // 32 bit
	static int C0 = 8;         // 32 bit
	static int D0 = 12;        // 32 bit	   	 
	static int M  = 16;        // 16x32 bit blocks of message data
	static int BITLENGTH = 80; // 32 bit
	static int A = 84;		   // 32 bit
	static int B = 88;         // 32 bit
	static int C = 92;         // 32 bit
	static int D = 96;         // 32 bit
	static int K = 100;        // 32 bit
	static int F = 104;        // 32 bit
	static int LENGTH = 108;   // 8 bit  (length currently collect in block)
	// static tables that reside in instruction memory
    static byte[] s = { 7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
                        5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
                        4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
                        6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21 };
	static int[] k = { 0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
					   0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501, 
                       0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
                       0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
                       0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
                       0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
                       0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
                       0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
                       0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
                       0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
                       0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
                       0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
                       0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
                       0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
                       0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
                       0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391 };
	
	public static void MD5INIT()
	{
		CONST32(0x67452301, A0);
		CONST32(0xEFCDAB89, B0);
		CONST32(0x98BADCFE, C0);
		CONST32(0x10325476, D0);
		CONST32(0, BITLENGTH);
		ram[LENGTH] = 0;
	}
	
	public static void MD5APPEND(byte b)
	{
		MD5APPEND(b,true);
	}
	
	public static void MD5FINISH()
	{			
		MD5APPEND((byte)128, false);		                  // append a 1-bit 
		while (ram[LENGTH]!=56)
		{	 MD5APPEND((byte)0,false); // fill up until 8 bytes free in last block
		}
		COPY32(BITLENGTH, M+56);					      // inject bit length in last block
		CONST32(0x00000000, M+60);
		MD5COMPUTEBLOCK();				 
	}
	
	public static void MD5PRINT()
	{
		PRINTHEXBUFFER(A0,16);
	}
		
	private static void MD5APPEND(byte b, boolean increasecounter)
	{
		if (increasecounter) 
		{	CONST32(8, F);
			ADD32(F,BITLENGTH);
		}
		ram[M+ram[LENGTH]] = b;
		ram[LENGTH]++;
		if (ram[LENGTH]==64)
		{	MD5COMPUTEBLOCK();
			ram[LENGTH] = 0;
		}
	}
		
	private static void MD5COMPUTEBLOCK()
	{
		COPY32(A0,A);
		COPY32(B0,B);
		COPY32(C0,C);
		COPY32(D0,D);
		
		for (int i=0; i<=15; i++)
		{	COPY32(C,F);

PRINTHEXBUFFER(A,16);PRINTNEWLINE();

			XOR32(D,F);
			AND32(B,F);
			XOR32(D,F);
			MD5ROUND(i, i);
		}	
		for (int i=16; i<=31; i++)
		{	COPY32(B,F);		
			XOR32(C,F);			
			AND32(D,F);
			XOR32(C,F);
			MD5ROUND(i, (5*i+1)%16);
		}	
		for (int i=32; i<=47; i++)
		{
			COPY32(B,F);
			XOR32(C,F);
			XOR32(D,F);
			MD5ROUND(i, (3*i+5)%16);
		}
		for (int i=48; i<=63; i++)
		{	
			CONST32(0xffffffff, F);
			XOR32(D,F);
			OR32(B,F);
			XOR32(C,F);
			MD5ROUND(i, (7*i)%16);
		}		
		ADD32(A,A0);
		ADD32(B,B0);
		ADD32(C,C0);
		ADD32(D,D0);
	}
	
	private static void MD5ROUND(int i, int g)
	{
		CONST32(k[i],K);
		ADD32(A,F);
		ADD32(K,F);
		ADD32(M+4*g, F);
		ROL32(s[i], F);
		COPY32(D,A);
		COPY32(C,D);
		COPY32(B,C);
		ADD32(F,B);
	}
	
		
	private static void COPY32(int sourceaddr, int targetaddr)
	{
		for (int i=0; i<4; i++)
		{	ram[targetaddr+i] = ram[sourceaddr+i];
		}	
	}
	
	private static void CONST32(int value, int targetaddr)
	{
		i2b(value,targetaddr);
	}
	
	private static void AND32(int sourceaddr, int targetaddr)
	{
		i2b(b2i(sourceaddr) & b2i(targetaddr), targetaddr);
	}
	private static void OR32(int sourceaddr, int targetaddr)
	{
		i2b(b2i(sourceaddr) | b2i(targetaddr), targetaddr);
	}
	private static void XOR32(int sourceaddr, int targetaddr)
	{
		i2b(b2i(sourceaddr) ^ b2i(targetaddr), targetaddr);
	}
	private static void ADD32(int sourceaddr, int targetaddr)
	{
		i2b(b2i(sourceaddr) + b2i(targetaddr), targetaddr);
	}
	
	private static void ROL32(byte distance, int addr)
	{
		int v = b2i(addr);
		i2b ( (v<<distance) | (v>>>(32-distance)), addr); 
	}	
	
	private static void PRINTHEXBUFFER(int address, int length)
	{
		for (int i=0; i<length; i++)
		{	PRINTHEX(ram[address+i]);
		}
	}
	
	private static void PRINTHEX(byte b)
	{
		PRINTHEXDIGIT((byte)((b>>4)&0x0f));
		PRINTHEXDIGIT((byte)(b&0x0f));
	}

	private static void PRINTHEXDIGIT(byte d)
	{
		System.out.print( "0123456789ABCDEF".charAt(d));
	}
	
	private static void PRINTNEWLINE()
	{
		System.out.println();
	}
	
	
	private static void i2b(int value, int address)
	{
		ram[address+0] = (byte) (value);
		ram[address+1] = (byte) (value>>8);
		ram[address+2] = (byte) (value>>16);
		ram[address+3] = (byte) (value>>24);	
	} 

	private static int b2i(int address)
	{
		int b0 = ram[address+0] & 0xff;
		int b1 = ram[address+1] & 0xff;
		int b2 = ram[address+2] & 0xff;
		int b3 = ram[address+3] & 0xff;
		return b0 | (b1<<8) | (b2<<16) | (b3<<24);
	}



}
