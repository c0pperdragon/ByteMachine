package bytemachine;

import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.util.HashMap;
import java.util.StringTokenizer;
import java.util.Vector;

public class ByteASM 
{
	public static void main(String[] args) throws IOException
	{			
		String srcfilename = "C:/Users/Reinhard/Documents/GitHub/ByteMachine/samples/cputest.basm";		
		String dstfilename = "C:/Users/Reinhard/Documents/GitHub/ByteMachine/quartus/TestProgram.hex";

		PrintStream dest = new PrintStream(new FileOutputStream(dstfilename));
		ByteASM.assemble(srcfilename,dest,System.out);
		dest.close();					
	}
	
	private static String[] opnostackmove = { 
		"NOP", "CLONE", "ADD", "SUB", "LSL", "LSR", "ASR", "AND", "OR", 
		"XOR", "LT", "GT", "INC", "DEC"
	};	 
	private static String[] opstackpop = { 
		"<SQEEZE", "<POP", "<ADD", "<SUB", "<LSL", "<LSR", "<ASR", "<AND", "<OR", 
		"<XOR", "<LT", "<GT", "<INC", "<DEC",
	};	 
	private static String[] opstackpush = { 
		">DUP", ">OVER", ">ADD", ">SUB", ">LSL", ">LSR", ">ASR", ">AND", ">OR", 
		">XOR", ">LT", ">GT", ">INC", ">DEC"
	};	 
	private static String[] stackactions =
	{	">GET", "<SET", "SET"
	};
	private static String[] operationswithaddress = { 
		"JMP", "<JZ", "<JNZ", "JSR", "LOADX"
	};	 
	private static String[] parameterlessactions = {
		"LOAD", ">LOAD", "<STORE", "<<STORE", "READ", ">READ", "<WRITE", "<<WRITE" 
	};
	
	public static byte[] assemble(String srcfilename, PrintStream hexfile, PrintStream logfile) throws IOException
	{
		int counterrors = 0;
		ByteArrayOutputStream code = new ByteArrayOutputStream();			
		HashMap<String,Integer> labels = new HashMap<String,Integer>(); 	
		
		for (int phase=0; phase<2; phase++)
		{
			Vector<String[]> stacklayout = new Vector<String[]>();
			HashMap<String,Integer> constants = new HashMap<String,Integer>();
			int address = 0;
			
			ByteParser parser = new ByteParser(new FileInputStream(srcfilename));
			while (parser.nextLine())
			{
				HashMap<String,Integer> phaselabels = new HashMap<String,Integer>();
				 	
				String l = parser.getLabel();
				if (l!=null)
				{	labels.put(l, Integer.valueOf(address));
					if (phaselabels.containsKey(l))
					{	System.err.println("Douplicate label: "+l);
						counterrors++;
					}
					phaselabels.put(l, 0);
				}								

				String[] error = new String[1];		
				if (parser.getAssignmentTarget()!=null)
				{	
					parser.getParameter();
					try 
					{	constants.put(parser.getAssignmentTarget(), Integer.valueOf(parser.getParameter()));
					} catch (Exception e)
					{	error[0] = e.getMessage();
					}
				}
				 								
				byte[] data = assembleLine(parser.getOperation(), parser.getParameter(), 
					phase==1?labels:null, stacklayout, constants, error);
						
				if (phase==1)
				{	
					if (hexfile!=null)
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
					if (logfile!=null)
					{
						logfile.print(toHex(address,4));						
						for (int i=0; i<data.length; i++)
						{	logfile.print(" ");
							logfile.print(toHex(data[i]&0xff,2));					
						}				
						for (int i=data.length; i<4; i++)
						{	logfile.print("   ");
						}
						logfile.print(" ");
						logfile.println(parser.getLine());
					}	
					code.write(data);				

					if (error[0]!=null)
					{
						System.out.println("ERROR: "+error[0]);		
						counterrors++;	
					}
				}	
			
				address += data.length;
				
			}
					
			if (phase==1 && hexfile!=null)
			{	hexfile.println(":00000001FF");
			}
		}		
		
		if (counterrors>0)
		{	System.err.println("Error during compilation: "+counterrors);
			return null;
		}
		return code.toByteArray();
	}
	
	private static byte[] assembleLine(String operation, String parameter, 
		HashMap<String,Integer> labels, Vector<String[]> stacklayout,
		HashMap<String,Integer> constants, String[] error)
	{
		if (operation==null || operation.length()<1)
		{	return new byte[0];
		}
		
		if (operation.equals("!"))
		{		
			parseStackLayout(stacklayout, parameter, error);
			return new byte[0];
		}		
		
		int stackdepth = 0;
		while (operation.startsWith("-"))
		{	if (operation.startsWith("-")) stackdepth++;
			operation=operation.substring(1);
		}
		while ((operation.startsWith("<") || operation.startsWith(">")) && operation.endsWith("JSR"))
		{	operation = operation.substring(1);
		}
		
		if (operation.equals(">PUSH"))
		{
			int v = resolveInt(parameter, constants, error);
			if (v>=0 && v<=15)
			{	return new byte[] { (byte) (0x30 | v) };
			}
			else
			{	return new byte[] { (byte) (0x30 | (v&0x0f)), (byte) (0x40 | ((v>>4)&0x0f)) };
			}				
		}		
		for (int i=0; i<opnostackmove.length; i++)
		{
			if (operation.equals(opnostackmove[i]))
			{	return new byte[] { (byte) (0x00 | i) };
			}		
		}
		for (int i=0; i<opstackpop.length; i++)
		{
			if (operation.equals(opstackpop[i]))
			{	return new byte[] { (byte) (0x10 | i) };
			}		
		}
		for (int i=0; i<opstackpush.length; i++)
		{
			if (operation.equals(opstackpush[i]))
			{	return new byte[] { (byte) (0x20 | i) };
			}		
		}
		for (int i=0; i<stackactions.length; i++)
		{
			if (operation.equals(stackactions[i]))
			{	int pos = stackdepth + resolveStackOperand(stacklayout, parameter, error);
				if (pos<0 || pos>16) error[0] = "Can not address stack position: "+pos;
				if (pos!=0)
				{	return new byte[] { (byte) (((0x5+i)<<4) + ((pos-1)&0x0f)) };
				}
				else 
				{	if (i==0) return new byte[] { (byte) 0x20 } ;  // >GET 0   =  DUP 	
					if (i==1) return new byte[] { (byte) 0x10 } ;  // <SET 0   =  SQUEEZE													
					if (i==2) return new byte[] { } ;              // SET 0   =  NOP													
				}							
			}		
		}
		for (int i=0; i<parameterlessactions.length; i++)
		{
			if (operation.equals(parameterlessactions[i]))
			{	return new byte[] { (byte) (0xF0 | i) };
			}		
		}
		for (int i=0; i<operationswithaddress.length; i++)
		{
			if (operation.equals(operationswithaddress[i]))
			{	int target = resolveIdentifier(parameter, labels, constants, error);
				return new byte[] { (byte) (((0x8+i)<<4) + (target&0x0f)), (byte) ((target>>4) & 0xff) };
			}					
		}
		if (operation.equals("RET"))
		{
			return new byte[]{(byte)(0xD0)};
		}
		if (operation.equals("RETURN"))
		{
			int keep = resolveInt(parameter,null,error);
			int pop = stacklayout.size() - keep;
			return new byte[]{(byte)(0xD0 | pop)};
		}
		
		if (operation.equals("DATA"))
		{
			return parseData(1, parameter,constants,error);
		}
		if (operation.equals("DATA32"))
		{
			return parseData(4, parameter,constants,error);
		}
				
		error[0] = "Unknown operation: "+operation;		
		return new byte[0];
	}				

	private static void parseStackLayout(Vector<String[]> stacklayout, String parameter, String[] error)
	{
		stacklayout.clear();
		if (parameter!=null) 		
		{	for (StringTokenizer tok = new StringTokenizer(parameter); tok.hasMoreTokens(); )
			{	
				String s = tok.nextToken();
				if (s.indexOf("/")<0)
				{	stacklayout.insertElementAt( new String[]{s}, 0 );
				}
				else
				{
					StringTokenizer t2 = new StringTokenizer(s,"/");
					String[] sa = new String[t2.countTokens()];
					for (int i=0; i<sa.length; i++)
					{	sa[i] = t2.nextToken();
					}
					stacklayout.insertElementAt(sa,0);
				}
			}
	}
//		System.out.print("Stacklayout: ");
//		for (String[] sa: stacklayout)
//		{
//			for (String s:sa)
//			{	System.out.print(s+"|");
//			}
//			System.out.print(" ");
//		}
//		System.out.println();
	}
	
	private static int resolveStackOperand(Vector<String[]> stacklayout, String parameter, String[] error)
	{
		for (int i=0; i<stacklayout.size(); i++)		
		{	String[] s = stacklayout.elementAt(i);
			for (int j=0; j<s.length; j++)
			{	if (s[j].equals(parameter))
				{	return i;
				}
			}			
		}
		error[0] = "Unknown stack position: "+parameter;
		return 0;
	}	
		
	private static int resolveInt(String o, HashMap<String,Integer> constants, String[] error)
	{
		int idx = o.lastIndexOf("+");
		if (idx>0)
		{
			int b = resolveInt(o.substring(idx+1).trim(), constants, error);
			int a = resolveInt(o.substring(0,idx).trim(), constants, error);
			return a+b;
		}
	
	
		if (constants!=null && constants.containsKey(o))
		{	return constants.get(o).intValue();
		}
		try
		{	if (o.startsWith("0x") || o.startsWith("0X"))
			{	return (int) Long.parseLong(o.substring(2),16);		
			}
			return (int) Long.parseLong(o);
		}
		catch (Exception e) {}		
		error[0] = "Can not read number: "+o;
		return 0;
	}		
		
	private static int resolveIdentifier(String l, HashMap<String,Integer> labels, HashMap<String,Integer> constants, String[] error)
	{
		if (labels==null)
		{	return 0;
		}
		int idx = l.indexOf("+");
		if (idx>0)
		{
			int a = resolveIdentifier(l.substring(0,idx).trim(), labels, constants, error);
			int b = resolveInt(l.substring(idx+1).trim(), constants, error);			
			return a+b;
		}
		
		Integer i = labels.get(l);
		if (i==null)
		{	error[0] = "Unresolved identifier: "+l;			
			return 0;		
		}
		return i.intValue();
	}	
	
	private static byte[] parseData(int datawidth, String parameter, HashMap<String,Integer> constants, String[] error)
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
				{	int v = resolveInt(parameter, constants,error);
					for (int i=0; i<datawidth; i++)
					{	bos.write(v&0xff);
						v = v>>>8;
					} 
					break;
				}
				else
				{	int v = resolveInt(parameter.substring(0,idx), constants, error);
					for (int i=0; i<datawidth; i++)
					{	bos.write(v&0xff);
						v = v>>>8;
					} 
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


