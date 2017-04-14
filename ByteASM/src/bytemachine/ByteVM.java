package bytemachine;

import java.io.IOException;

public class ByteVM 
{
	public static void main(String args[]) throws IOException
	{
		(new ByteVM()).loadAndExecute("C:/Users/Reinhard/Documents/GitHub/ByteMachine/samples/pushpop.basm");	
	}

	byte rom[];
	byte M[];
	
	int PC;
	int SP;
	byte A;
	int OUT;

	public ByteVM()
	{	
	}
	
	public void loadAndExecute(String filename) throws IOException
	{
		rom = ByteASM.assemble(filename, System.out);
		ByteASM.generateSimpleDump(rom, System.out);
		if (rom==null) return;	
		
		M = new byte[1024];
		PC = 0;
		SP = 255;
		A = 0;
		OUT = 0;
		for (int i=0; i<40; i++) 
		{	 
			printstate();
			if (!step()) break;
		}
	}
	
	private boolean step()
	{
		byte command = PC>=rom.length ? 0 : rom[PC];
		int p = command & 0x0f;
		byte TMP;
		
		switch (command & 0xf0)
		{	case 0x00:              // high bits
				A |= ((command&0x0f)<<4);
				PC = (PC+1) & 0xffff;
				break;		
			case 0x10:              // push constant
			    SP = (SP+1) & 0x3ff; 
			    M[SP] = (byte) A;
			    A = (byte) (command & 0x0f);
				PC = (PC+1) & 0xffff;
				break;				
			case 0x20:				// operation with popping the stack
			    A = alu(command & 0x0f, M[SP], A);
			    SP = (SP-1) & 0x3ff;
				PC = (PC+1) & 0xffff;
				break;
			case 0x30:				// operation with pushing the stack
				TMP = alu(command & 0x0f, M[SP], A);
				SP = (SP+1) & 0x3ff;
				M[SP] = A;
				A = TMP;
				PC = (PC+1) & 0xffff;
				break;
			case 0x40:              // >GET p	
				TMP = M[(SP-1-p)&0x3ff];
				SP = (SP+1) & 0x3ff;
				M[SP] = A;
				A = TMP;
				PC = (PC+1) & 0xffff;
				break;
			case 0x50:              // <SET p
				M[(SP-1-p)&0x3ff] = A;
				A = M[SP];
				SP = (SP-1) & 0x3ff;
				PC = (PC+1) & 0xffff;
				break;
			case 0x60:              // >LOAD o
				A = M[(A+p) & 0xff];
				PC = (PC+1) & 0xffff;
				break;
			case 0x70:              // <STORE o
				TMP = M[SP];
				M[(A+p)&0xff] = TMP;
            	SP = (SP-1) & 0x3ff;
            	A = TMP;
				PC = (PC+1) & 0xffff;
            	break;
			case 0x80:              // >READBIT p
				break;
			case 0x90:              // WRITEBIT
				break;
			case 0xA0:              // JZ
				break;
			case 0xB0:              // JNZ
				break;
			case 0xC0:              // JMP
				break;
			case 0xD0:              // SUB
				break;
			case 0xE0:			    // POP		
			    SP = (SP-p) & 0x3ff;
            	A = M[SP];
            	SP = (SP-1) & 0x3ff;
				PC = (PC+1) & 0xffff;
				break;
			default:
				return false;
		}
		return true;
	}

	
	private void printstate()
	{
		System.out.print(String.format("%04X ", Integer.valueOf(PC)));
		System.out.print(String.format("%02X  ", Integer.valueOf(rom[PC] & 0xff)));
		
		for (int i=256; i<SP; i++)
		{	System.out.print(String.format(" %02X", Integer.valueOf(M[i] & 0xff)));
		}
		if (SP>255) System.out.print(String.format(" %02X", Integer.valueOf(A & 0xff)));
		System.out.println();
	}

	
	
	private static byte alu(int operation, byte x, byte y)
	{
        switch (operation)
        {	case 0x00:	return x;              	  				// FIRST
        	case 0x01:	return y;              	  				// SECOND
        	case 0x02:  return (byte)(x+y);         			// ADD
        	case 0x03:  return (byte)(x-y);						// SUB
        	case 0x04:  return (byte)(x & y);				    // AND
        	case 0x05:  return (byte)(x|y);						// OR
        	case 0x06:  return (byte)(x^y);						// XOR
        	case 0x07:  return (byte)((x<<1)|(y>>7));   		// SHL	
        	case 0x08:  return (byte)((x>>1)|(y<<7));			// SHR
        	case 0x09:  return (byte)((x&0xff)<(y&0xff)?1:0);	// LT
        	case 0x0A:  return (byte)((x&0xff)>(y&0xff)?1:0);	// GT
        	case 0x0B:  return (byte)(((x&0xff)+(y&0xff)>255)?1:0);	// OVFL
			default:	return 0;	
        }
	}





}
