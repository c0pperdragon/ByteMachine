package bytemachine;

import java.io.IOException;

public class ByteVM 
{
	public static void main(String args[]) throws IOException
	{
//		(new ByteVM()).loadAndExecute("../samples/fibonacci.basm", false);
//		(new ByteVM()).loadAndExecute("../samples/fibonacci32.basm", false);	
		(new ByteVM()).loadAndExecute("../samples/md5calc.basm", false);	
	}

	byte rom[];
	byte M[];
	int PC;
	int SP;

	public ByteVM()
	{	
	}
	
	public void loadAndExecute(String filename, boolean trace) throws IOException
	{
		rom = ByteASM.assemble(filename, System.out);
		if (rom==null) return;	
		ByteASM.generateSimpleDump(rom, System.out);
		
		M = new byte[256];
		PC = 0;
		SP = 255;
		for (int i=0; i<1000; i+=(trace?1:0)) 
		{	 
			if (trace) printstate();
			if (!step()) break;
		}
	}
	
	private boolean step()
	{
		byte command = PC>=rom.length ? 0 : rom[PC];
		int x = command & 0x0f;
		int SPm1 = (SP-1) & 0xff;
		int SPp1 = (SP+1) & 0xff;
		int PCp1 = (PC+1) & 0xffff;
		
		switch (command & 0xf0)
		{	case 0x00:              // high bits
				M[SP] |= (x<<4);
				PC = PCp1;
				break;		
			case 0x10:              // push constant
			    M[SPp1] = (byte) x;
			    SP = SPp1;
				PC = PCp1;
				break;				
			case 0x20:				// operation with popping the stack
			    M[SPm1] = alu(x, M[SPm1], M[SP]);
			    SP = SPm1;
				PC = PCp1;
				break;
			case 0x30:				// operation with pushing the stack
				M[SPp1] = alu(x, M[SPm1], M[SP]);
				SP = SPp1;
				PC = PCp1;
				break;
			case 0x40:              // GET p	
				M[SPp1] = M[(SP-x)&0xff];
				SP = SPp1;
				PC = PCp1;
				break;
			case 0x50:              // SET p
            	M[(SP-x-1)&0xff] = M[SP];
            	SP = SPm1;
				PC = PCp1;
				break;
			case 0x60:              // LOD o
				M[SP] = M[(M[SP]+x)&0xff];
				PC = PCp1;
				break;
			case 0x70:              // STO o
  				M[(M[SP]+x)&0xff] = M[SPm1];
            	SP = SPm1;
				PC = PCp1;
               	break;
			case 0x80:              // IN x
				M[SP] = 0;
				SP = SPp1;
				PC = PCp1;
				break;
			case 0x90:              // OUT x
				{	int b = M[SP]&0xff;
					if (x==15) {	// text output
						System.out.print((char)b);
					} else if (x==14) { // binary output
						System.out.print(b+" ");
					}
					SP = SPm1;
					PC = PCp1;
				}
				break;
			case 0xA0:              // JMP
				{	int dist = ((M[SP]&0xff) << 4) | x;
					if (dist>0x7ff) dist = dist - 0x1000;
					SP = SPm1;
					PC = (PC + dist) & 0xffff;
				}				
				break;
			case 0xB0:              // JZ
				if (M[SP]==0) PC = (PC + 2 + x) & 0xffff;
				else          PC = PCp1;
				SP = SPm1;
				break;
			case 0xC0:              // JNZ
				if (M[SP]!=0) PC = (PC + 2 + x) & 0xffff;
				else          PC = PCp1;
				SP = SPm1;
				break;
			case 0xD0:              // JSR
				{	int target = ( (M[SPm1]&0xff) | (x<<4) ) + M[SP]*256;
					M[SPm1] = (byte) (PCp1%256);
					M[SP] = (byte) (PCp1/256);
					PC = target;
				}
				break;
			case 0xE0:			    // RET		
				{	int adr = (M[SPm1]&0xff) + (M[SP]&0xff)*256;
					if (adr==PC && x==0) return false;  // detect HALT condition
					PC = adr;
	            	SP = (SP-x) & 0xff;
	            	M[SP] = (byte) (PC/256);
				}
				break;
			case 0xF0:			    // ADR		
				M[SPp1] = (byte) ((SP-x)&0xff);
				SP = SPp1;
				PC = PCp1;				
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

		System.out.print(String.format("%02X  ", Integer.valueOf(SP & 0xff)));
		
		for (int i=0; SP!=255 && i<=SP; i++)
		{	System.out.print(String.format(" %02X", Integer.valueOf(M[i] & 0xff)));
		}
		System.out.println();
	}

	
	
	private static byte alu(int operation, byte x, byte y)
	{
        switch (operation)
        {	case 0x0:	return x;              	  				    // POP
        	case 0x1:   return (byte)(x+y);         			    // ADD
        	case 0x2:   return (byte)(x-y);						    // SUB
        	case 0x3:   return (byte)(x & y);				        // AND
        	case 0x4:   return (byte)(x|y);						    // OR
        	case 0x5:   return (byte)(x^y);						    // XOR
        	case 0x6:   return (byte)((x&0xff)<(y&0xff)?1:0);	    // LT
        	case 0x7:   return (byte)((x&0xff)>(y&0xff)?1:0);	    // GT
        	case 0x8:   return (byte)(((x&0xff)<<1)|((y&0xff)>>7)); // SHL	
        	case 0x9:   return (byte)(((x&0xff)>>1)|((y&0xff)<<7)); // SHR
			default:	return 0;	
        }
	}

}
