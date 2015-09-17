package bytemachine;

import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.util.HashMap;

public class ByteASM 
{
	public static void main(String[] args) throws IOException
	{			
		String srcfilename = "C:/Users/Reinhard/Documents/GitHub/ByteMachine/samples/writeport.basm";		
		String dstfilename = "C:/Users/Reinhard/Documents/GitHub/ByteMachine/quartus/TestProgram.hex";

		PrintStream dest = new PrintStream(new FileOutputStream(dstfilename));
		ByteASM.assemble(srcfilename,dest,System.out);
		dest.close();					
	}
	
	private static String[] unaryoperations = { 
		"NOP", "INC", "DEC", "NEG", "LSL1", "LSR1", "ASL1", "INV", "NOT"
	};	 
	private static String[] binaryoperations = { 
		"POP", "ADD", "SUB", "LSL", "LSR", "ASR","AND","OR","XOR","EQ","LT","GT","LTS","GTS","CARRY" 
	};	 
	private static String[] operationswithoperand =
	{	"GET", "SET", "LOAD", "STORE" 
	}; 	
	private static String[] jumpoperations = { 
		"JMP", "JZ", "JNZ", "JSR" 
	};	 

	
	public static byte[] assemble(String srcfilename, PrintStream hexfile, PrintStream logfile) throws IOException
	{
		ByteArrayOutputStream code = new ByteArrayOutputStream();			
		HashMap<String,Integer> labels = new HashMap<String,Integer>(); 			
		for (int phase=0; phase<2; phase++)
		{
			int address = 0;
			
			ByteParser parser = new ByteParser(new FileInputStream(srcfilename));
			while (parser.nextLine())
			{
				if (parser.getLabel()!=null)
				{	labels.put(parser.getLabel(), Integer.valueOf(address));
				}
			
				byte[] data = assembleLine(parser.getOperation(), parser.getParameter(), phase==1?labels:null);
						
				if (phase==1 && hexfile!=null)
				{	
					for (int i=0; i<data.length; i++)
					{	int checksum = 0;
						hexfile.print(":");
						hexfile.print(toHex(1,2));
						checksum += 1;
						hexfile.print(toHex(address+i,4));
						checksum += (address+i) & 0xff;
						checksum += ((address+i)>>8) & 0xff;
						hexfile.print(toHex(0,2));
						checksum += 0;
						hexfile.print(toHex(data[i]&0xff,2));
						checksum += data[i] & 0xff;
						hexfile.println(toHex(((~checksum)+1)&0xff,2));
					}
				}
				if (phase==1 && logfile!=null)
				{
					logfile.print(toHex(address,4));
					for (int i=0; i<data.length; i++)
					{	logfile.print(" ");
						logfile.print(toHex(data[i]&0xff,2));					
					}				
					for (int i=data.length; i<4; i++)
					{	logfile.print("   ");
					}
					logfile.println(parser.getLine());
				}	
				if (phase==1)
				{
					code.write(data);				
				}	
			
				address += data.length;
			}
					
			if (phase==1 && hexfile!=null)
			{	hexfile.println(":00000001FF");
			}
		}		
		
		return code.toByteArray();
	}
	
	private static byte[] assembleLine(String operation, String parameter, HashMap<String,Integer> labels) 
	{
		if (operation==null || operation.length()<1)
		{	return new byte[0];
		}
		
		// trim away leading "-", because these are only a hint, how deep the stack currently is
		// and memorize the number of minuses
		int stackdepth=0;
		while (operation.startsWith("-"))
		{	stackdepth++;
			operation = operation.substring(1);
		}
		
		for (int i=0; i<unaryoperations.length; i++)
		{
			if (operation.equals(unaryoperations[i]))
			{	return new byte[] { (byte) (0x00 | i) };
			}		
		}
		for (int i=0; i<binaryoperations.length; i++)
		{
			if (operation.equals(binaryoperations[i]))
			{	return new byte[] { (byte) (0x10 | i) };
			}		
		}
		if (operation.equals("PUSH"))
		{
			int v = resolveInt(parameter);
			if (v>=0 && v<=15)
			{	return new byte[] { (byte) (0x20 | v) };
			}
			else
			{	return new byte[] { (byte) (0x20 | (v&0x0f)), (byte) (0x30 | ((v>>4)&0x0f)) };
			}				
		}
		if (operation.equals("DUP"))        // a short form for GET 0
		{	return new byte[] { (byte) 0x40 };		
		}
		for (int i=0; i<operationswithoperand.length; i++)
		{
			if (operation.equals(operationswithoperand[i]))
			{	int pos = resolveInt(parameter) + stackdepth;
				return new byte[] { (byte) (((0x4+i)<<4) + (pos&0x0f)) };
			}		
		}
		if (operation.equals("READ"))
		{	return new byte[] { (byte) (0x80 | (resolveInt(parameter)&0x0f)) };
		}
		if (operation.equals("WRITE"))
		{	return new byte[] { (byte) (0x90 | (resolveInt(parameter)&0x0f)) };
		}
		if (operation.equals("LOADX"))
		{	int target = resolveIdentifier(parameter, labels);
				return new byte[] { (byte) (0xA0 + (target&0x0f)), (byte) ((target>>4) & 0xff) };
		}
		for (int i=0; i<jumpoperations.length; i++)
		{
			if (operation.equals(jumpoperations[i]))
			{	int target = resolveIdentifier(parameter, labels);
				return new byte[] { (byte) (((0xB+i)<<4) + (target&0x0f)), (byte) ((target>>4) & 0xff) };
			}					
		}
		if (operation.equals("RET"))
		{
			return new byte[]{ (byte) 0xF0 };
		}
		if (operation.equals("DATA"))
		{
			return parseData(parameter);
		}
				
		if (labels!=null)
		{	System.err.println("Unknown operation: "+operation);
		}
		return new byte[0];
	}				
		
	private static int resolveInt(String o)
	{
		try
		{	return Integer.parseInt(o);
		}
		catch (Exception e) {}		
		System.err.println("Can not read number: "+o);
		return 0;
	}		
		
	private static int resolveIdentifier(String l, HashMap<String,Integer> labels)
	{
		if (labels==null)
		{	return 0;
		}
		Integer i = labels.get(l);
		if (i==null)
		{	System.err.println("Unresolved identifier: "+l);			
			return 0;		
		}
		return i.intValue();
	}	
	
	private static byte[] parseData(String parameter)
	{
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		
		while (parameter.length()>0)
		{	if (parameter.charAt(0)=='"')
			{	int idx = parameter.indexOf('"',1);
				if (idx<0)
				{	System.err.println("Unterminated string");
					break;
				}
				for (int i=1; i<idx; i++)
				{	bos.write ( (byte) (parameter.charAt(i) & 0xff) );
				}
				parameter = parameter.substring(idx+1,parameter.length()).trim();
			}
			else
			{	int idx = parameter.indexOf(" ");
				if (idx<0)
				{	bos.write ( (byte) resolveInt(parameter) );
					break;
				}
				else
				{	bos.write ( (byte) resolveInt(parameter.substring(0,idx)) );
					parameter=parameter.substring(idx).trim();
				}
			}
		}
		
		return bos.toByteArray();
	}
		
	private static String toHex(int n, int digits)
	{
		String h = "";
		for (int i=0; i<digits; i++)
		{
			int d = n&15;
			if (d<10)
			{	h = ((char)('0'+d))+h;
			}
			else
			{	h = ((char)('A'+d-10))+h;
			}
			n = n>>4;
		}
		return h;
	}
	
	
	
}


