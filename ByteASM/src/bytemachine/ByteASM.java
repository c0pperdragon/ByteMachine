package bytemachine;

import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.util.HashMap;

public class ByteASM 
{
	public static void main(String[] args) throws IOException
	{		
		String filename = "C:/Users/Reinhard/Documents/GitHub/ByteMachine/samples/writeport.basm";		

		ByteASM asm = new ByteASM();		
		for (int pass=0; pass<2; pass++)
		{		
			ByteParser parser = new ByteParser(new FileInputStream(filename));	
			asm.assemble(parser,System.out,pass>0);					
			parser.close();
		}
	}
	
	HashMap<String,Integer> labels = null; 		

	public ByteASM()
	{
		labels = new HashMap<String,Integer>();
	}
	
	public void assemble(ByteParser parser, PrintStream output, boolean generateoutput)
	{
		int address = 0;
	
		while (parser.nextLine())
		{
			if (parser.getLabel()!=null)
			{	labels.put(parser.getLabel(), Integer.valueOf(address));
			}
			
			byte[] data = assembleLine(parser.getOperation(), parser.getParameter(), generateoutput);
						
			if (generateoutput)
			{	
				int checksum = 0;
				
				output.print(":");
				output.print(toHex(data.length,2));
				output.print(toHex(address,4));
				output.print(toHex(0,2));
				for (int i=0; i<data.length; i++)
				{	output.print(toHex(data[i]&0xff,2));
				}
				output.print(toHex(checksum,2));
				
				for (int i=data.length; i<4; i++)
				{	output.print("  ");
				}
				output.println(parser.getLine());
			}
			
			address += data.length;
		}		
	}
	
	private static String[] unaryoperations = { 
		"NOP", "", "INC", "DEC", "NEG", "DOUBLE", "NOT", "BNOT"
	};	 
	private static String[] binaryoperations = { 
		"POP", "", "ADD", "SUB", "MUL", "SLL", "SRL", "SRA","AND","OR","XOR","EQ","LT","GT" 
	};	 
	private static String[] parameterizedoperations = 
	{	"GET", "SET", "LOAD", "STORE", "READ", "WRITE"
	};	
	private static String[] jumpoperations = { 
		"JMP", "JZ", "JNZ", "JSR" 
	};	 
		
	private byte[] assembleLine(String operation, String parameter, boolean generateoutput) 
	{
		if (operation==null || operation.length()<1)
		{	return new byte[0];
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
			try
			{	int v = Integer.parseInt(parameter);
				if (v>=0 && v<=15)
				{	return new byte[] { (byte) (0x20 | v) };
				}
				else
				{	return new byte[] { (byte) (0x20 | (v&0x0f)), (byte) (0x30 | ((v>>4)&0x0f)) };
				}				
			}	catch (Exception e) {}
			int v = resolveIdentifier(parameter, generateoutput);
			return new byte[] { (byte) (0x20 | (v&0xf)), (byte) (0x30 | ((v>>4)&0xf)) };
		}
		if (operation.equals("DUP"))        // a short form for GET 0
		{	return new byte[] { (byte) 0x40 };		
		}
		for (int i=0; i<parameterizedoperations.length; i++)
		{
			if (operation.equals(parameterizedoperations[i]))
			{	return new byte[] { (byte) (((0x4+i)<<4) | (resolveInt(parameter)&0x0f)) };
			}		
		}
		for (int i=0; i<jumpoperations.length; i++)
		{
			if (operation.equals(jumpoperations[i]))
			{	int target = resolveIdentifier(parameter, generateoutput);
				return new byte[] { (byte) (((0xA+i)<<4) + ((target>>8)&0x0f)), (byte) (target & 0xff) };
			}		
		}
		if (operation.equals("RET"))
		{	return new byte[] { (byte) 0xe0 };
		}
		if (operation.equals("DATA"))
		{
			return parseData(parameter);
		}
				
		if (generateoutput)
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
		
	private int resolveIdentifier(String l, boolean mustresolve)
	{
		Integer i = labels.get(l);
		if (i==null)
		{	if (mustresolve)
			{	System.err.println("Unresolved identifier: "+l);
			}
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


