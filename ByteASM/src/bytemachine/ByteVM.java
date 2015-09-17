package bytemachine;

import java.io.IOException;

public class ByteVM 
{
	public static void main(String args[]) throws IOException
	{
		(new ByteVM()).loadAndExecute("C:/Users/Reinhard/Documents/GitHub/ByteMachine/samples/writeport.basm");	
	}

	byte rom[];
	byte ram[];
	byte operands[];
	int pc;

	public ByteVM()
	{	
		rom = new byte[4096];
		ram = new byte[256];
		operands = new byte[50];
		for (int i=0; i<operands.length; i++) operands[i]=(byte)0xff;
	}
	
	public void loadAndExecute(String filename) throws IOException
	{
		byte[] c = ByteASM.assemble(filename, null, System.out);
		System.arraycopy (c,0, rom,0, c.length);		
		
		pc = 0;
		while (step()) 
		{	// printstate();
		}
	}
	
	private boolean step()
	{
		byte command = rom[pc];
		byte tmp;
		int addr;
		switch (command & 0xf0)
		{	case 0x00:	
				operands[0] = op1(command&0x0f, operands[0]);
				pc++;
				break;
			case 0x10:
				tmp = op2(command&0x0f,operands[1],operands[0]);
				pop();
				operands[0]=tmp;
				pc++;
				break;
			case 0x20:
				push ((byte)(command & 0x0f));
				pc++;
				break;		
			case 0x30:
				operands[0] = (byte)((operands[0]&0x0f) | ((command<<4)&0xf0));
				pc++;
				break;		
			case 0x40:
				push(operands[command & 0x0f]);
				pc++;
				break;
			case 0x50:
				tmp = pop();
				operands[command & 0x0f] = tmp;
				pc++;
				break;
			case 0x60:
				tmp = operands[command & 0x0f];
				push(ram[tmp&0xff]);
				pc++;
				break;
			case 0x70:
				tmp = operands[command & 0x0f];
				ram[tmp&0xff] = pop();
				pc++;
				break;
			case 0x80:
				push(ioread(command & 0x0f));
				pc++;
				break;
			case 0x90:
				iowrite(command & 0x0f, pop());
				pc++;
				break;
			case 0xA0:
				pc++;
				addr = (command&0x0f) | ((rom[pc]<<4)&0xff0);
				tmp = pop();
				push(rom[addr+(tmp&0xff)]);
				pc++;
				break;
			case 0xB0:
				addr = pc;				
				pc++;
				pc = (command&0x0f) | ((rom[pc]<<4)&0xff0);				
				return addr != pc;  // can terminate VM when on tight endless loop
			case 0xC0:
				tmp = pop();
				pc++;
				if (tmp==0)
				{	pc = (command&0x0f) | ((rom[pc]<<4)&0xff0);
				}
				else
				{	pc++;
				}
				break;
			case 0xD0:
				tmp = pop();
				pc++;
				if (tmp!=0)
				{	pc = (command&0x0f) | ((rom[pc]<<4)&0xff0);
				}
				else
				{	pc++;
				}
				break;
			case 0xE0:
				addr = pc+2;
				push((byte)(addr>>>8));
				push((byte)addr);
				pc++;
				pc = (command&0x0f) | ((rom[pc]<<4)&0xff0);
				break;
			case 0xF0:
				addr = pop() & 0xff;
				addr = addr | ((pop()&0xff)<<8);
				pc = addr;				
				break;				
		}
		return true;
	}

	private void push(byte o)
	{
		System.arraycopy(operands,0, operands,1, operands.length-2);
		operands[0] = o;	
	}
	private byte pop()
	{	
		int l = operands.length;
		byte tmp = operands[0];
		System.arraycopy(operands,1, operands,0, l-1);
		operands[l-1] = 0;
		return tmp;
	}	
	
	private void printstate()
	{
		System.out.print(String.format("%03X", Integer.valueOf(pc)));
		for (int i=0; i<50; i++)
		{	System.out.print(String.format(" %02X", Integer.valueOf(operands[i] & 0xff)));
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
	
	
	private static byte op1(int operation, byte b)
	{
		switch (operation)
		{	case 0x00:  return b; 
			case 0x01:  return (byte)(b+1);
			case 0x02:  return (byte)(b-1);
			case 0x03:	return (byte)(-b);
			case 0x04:  return (byte)(b<<1);
			case 0x05:  return (byte)(b>>>1);
			case 0x06:  return (byte)(b>>1);
			case 0x07:  return (byte)(~b);
			case 0x08:  return (b==0)?((byte)1):((byte)0);
			default: return b;
		}
	}	
	private static byte op2(int operation, byte a, byte b)
	{
        switch (operation)
        {	case 0x00:	return a;
        	case 0x01:  return (byte)(a+b);
        	case 0x02:  return (byte)(a-b);
        	case 0x03:  return (byte)(a<<(b&0xff));
        	case 0x04:  return (byte)(a>>>(b&0xff));
        	case 0x05:  return (byte)(a>>(b&0xff));
        	case 0x06:  return (byte)(a&b);
        	case 0x07:  return (byte)(a|b);
        	case 0x08:  return (byte)(a^b);
        	case 0x09:	return (byte)(a==b?1:0);
        	case 0x0A:  return (byte)((a&0xff)<(b&0xff)?1:0);
        	case 0x0B:  return (byte)((a&0xff)>(b&0xff)?1:0);
        	case 0x0C:	return (byte)(a<b?1:0);
        	case 0x0D:	return (byte)(a>b?1:0);
        	case 0x0E:	return (byte)((a&0xff)+(b&0xff)>255 ? 1:0);
			default:	return a;	
        }
	}





}
