package bytemachine;

import java.io.IOException;

public class ByteVM 
{
	public static void main(String args[]) throws IOException
	{
		(new ByteVM()).loadAndExecute("C:/Users/Reinhard/Documents/GitHub/ByteMachine/samples/md5calc.basm");	
	}

	byte rom[];
	byte ram[];
	byte stack[];
	short returnstack[];
	
	int pc;
	int sp;
	int rsp;	

	public ByteVM()
	{	
		rom = new byte[4096];
		ram = new byte[256];
		stack = new byte[256];
		returnstack = new short[30];
	}
	
	public void loadAndExecute(String filename) throws IOException
	{
		byte[] c = ByteASM.assemble(filename, null, System.out);
		if (c==null) return;
		System.arraycopy (c,0, rom,0, c.length);		
		
		pc = 0;
		stack[0] = 0;
		sp = 1;
		rsp = 0;
		while (step()) 
		{	// printstate();
		}
	}
	
	private boolean step()
	{
		byte command = rom[pc];
		byte tmp,tmp2;
		int addr;
		switch (command & 0xf0)
		{	case 0x00:				// not moving stack
				tmp = pop();				
				push(alu(command&0x0f, peek(),tmp, 0));
				pc++;
				break;
			case 0x10:				// popping the stack
				tmp = pop();
				push(alu(command&0x0f, pop(),tmp, 0));
				pc++;
				break;
			case 0x20:				// pushing the stack
				tmp = pop();
				tmp2 = pop();
				push(tmp2);
				push(tmp);
				push (alu(command & 0x0f, tmp2,tmp, 0));
				pc++;
				break;		
			case 0x30:              // push
				push((byte)(command&0x0f));
				pc++;
				break;
			case 0x40:              // high bits
				push ((byte)((pop()&0x0f)|(command<<4)));
				pc++;
				break;		
			case 0x50:              // >GET p				
				push( stack[sp-2-(command & 0x0f)] );
				pc++;
				break;
			case 0x60:              // <SET p
				tmp = pop();
				stack[sp-2-(command & 0x0f)] = tmp;
				pc++;
				break;
			case 0x70:              // SET p
				tmp = peek();
				stack[sp-2-(command & 0x0f)] = tmp;
				pc++;
				break;
			case 0x80:            // JMP
				addr = pc;				
				pc++;
				pc = ((command&0x0f)<<8) | (rom[pc]&0xff);
				if (addr==pc)
				{	return false;  // can terminate VM when on tight endless loop
				}
				break;
			case 0x90:            // JZ
				pc++;
				if (pop()==0)
				{	pc = ((command&0x0f)<<8) | (rom[pc]&0xff);
				}
				else
				{	pc++;
				}
				break;
			case 0xA0:           // JNZ
				pc++;
				if (pop()!=0)
				{	pc = ((command&0x0f)<<8) | (rom[pc]&0xff);
				}
				else
				{	pc++;
				}
				break;
			case 0xB0:           // JSR
				returnstack[rsp] = (short) (pc+2);
				rsp++;
				pc++;
				pc = ((command&0x0f)<<8) | (rom[pc]&0xff);
				break;
			case 0xC0:            // LOADX
				pc++;
				addr = ((command&0x0f)<<8) | (rom[pc]&0xff);
				push ( rom[addr+(pop()&0xff)] );
				pc++;				
				break;
			case 0xD0:			// RET
				for (int i=(command&0x0f); i>0; i--) pop();
				rsp--;
				pc = returnstack[rsp];
				break;
								
			case 0xF0:
				switch (command&0x0F)
				{	
					case 0x00:              // LOAD
						addr = pop()&0xff;
						push (ram[addr]);
						pc++;
						break;
					case 0x01:              // >LOAD
						addr = peek()&0xff;
						push (ram[addr]);
						pc++;
						break;
					case 0x02:              // STORE
						tmp = pop();
						ram[peek() & 0xff] = tmp;
						push(tmp);						
						pc++;
						break;
					case 0x03:              // <STORE
						tmp = pop();
						ram[peek() & 0xff] = tmp;
						pc++;
						break;
					case 0x04:              // READ
						tmp = pop();
						push(ioread(tmp));
						pc++;
						break;
					case 0x05:              // >READ
						push(ioread(peek()));
						pc++;
						break;
					case 0x06:              // WRITE
						tmp = pop();
						iowrite(tmp, peek());
						push(tmp);
						pc++;
						break;
					case 0x07:              // <WRITE
						tmp = pop();
						iowrite(tmp, peek());
						pc++;
						break;
				}
				break;
		}
		return true;
	}

	private void push(byte o)
	{
		stack[sp] = o;
		sp++;	
	}
	private byte pop()
	{	
		sp--;
		return stack[sp];	
	}	
	private byte peek()
	{
		if (sp>0) return stack[sp-1];
		else      return 0;
	}
	
	
	private void printstate()
	{
		System.out.print(rsp+" ");
		System.out.print(String.format("%03X ", Integer.valueOf(pc)));
		for (int i=0; i<sp; i++)
		{	System.out.print(String.format(" %02X", Integer.valueOf(stack[i] & 0xff)));
		}
		System.out.println();
	}
	
	private void iowrite(int port, byte x)
	{
		if (port==0)
		{	// System.out.println(String.format("OUT: %02X", Integer.valueOf(x&0xff)));
			System.out.print((char)(x&0xff));
		}	
	}
	private byte ioread(int port)
	{
		return 0;	
	}
	
	
	private static byte alu(int operation, byte a, byte b, int k)
	{
        switch (operation)
        {	case 0x00:	return b;              	  				// NOP
        	case 0x01:	return a;              	  				// CLONE
        	case 0x02:  return (byte)(a+b);         			// ADD
        	case 0x03:  return (byte)(a-b);						// SUB
        	case 0x04:  return (byte)(a<<(b&0x07));				// LSL	
        	case 0x05:  return (byte)((a&0xff)>>(b&0x07));			// LSR	
        	case 0x06:  return (byte)(a>>(b&0xff));				// ASR
        	case 0x07:  return (byte)(a&b);						// AND
        	case 0x08:  return (byte)(a|b);						// OR
        	case 0x09:  return (byte)(a^b);						// XOR
        	case 0x0A:  return (byte)((a&0xff)<(b&0xff)?1:0);	// LT
        	case 0x0B:  return (byte)((a&0xff)>(b&0xff)?1:0);	// GT
        	case 0x0C:  return (byte)(b+1);                     // INC
        	case 0x0D:  return (byte)(b-1);                     // DEC
			default:	return 0;	
        }
	}





}
