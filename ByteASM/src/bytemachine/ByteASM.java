package bytemachine;

import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.util.HashMap;
import java.util.HashSet;

public class ByteASM 
{
	public static void main(String[] args) throws IOException
	{			
		String srcfilename = "C:/Users/Reinhard/Documents/GitHub/ByteMachine/samples/pushpop.basm";		
//		String dstfilename = "C:/Users/Reinhard/Documents/GitHub/ByteMachine/quartus/TestProgram.hex";

		byte[] code = ByteASM.assemble(srcfilename,System.out);
		if (code!=null) {
			ByteASM.generateSimpleDump(code, System.out);
//			 dest = new PrintStream(new FileOutputStream(dstfilename));		
//			dest.close();					
		}
	}
	
	public static byte[] assemble(String srcfilename, PrintStream logfile) throws IOException
	{
		HashMap<String,Integer> labels = new HashMap<String,Integer>(); 	
		HashMap<String,Integer> constants = new HashMap<String,Integer>();
		ByteArrayOutputStream code = new ByteArrayOutputStream();
		
		for (int phase=0; ; phase++)
		{
			if (logfile!=null) logfile.println("Phase "+phase);

			code.reset();		
				
			constants.clear();
			constants.put ("FIRST", Integer.valueOf(0));
			constants.put ("SECOND", Integer.valueOf(1));
			constants.put ("ADD", Integer.valueOf(2));
			constants.put ("SUB", Integer.valueOf(3));
			constants.put ("AND", Integer.valueOf(4));
			constants.put ("OR", Integer.valueOf(5));
			constants.put ("XOR", Integer.valueOf(6));
			constants.put ("SHL", Integer.valueOf(7));
			constants.put ("SHR", Integer.valueOf(8));
			constants.put ("LT", Integer.valueOf(9));
			constants.put ("GT", Integer.valueOf(10));
			constants.put ("OVFL", Integer.valueOf(11));
			
			boolean anylabelchanged = false;
			int counterrors = 0;
					
			HashSet<String> phaselabels = new HashSet<String>();			
			ByteParser parser = new ByteParser(new FileInputStream(srcfilename));
			while (parser.nextLine())
			{
				String error = null;
			
				String t = parser.getAssignmentTarget();
				String l = parser.getLabel();
				String o = parser.getOperation();
				String p = parser.getParameter();
				
				// handle constant definitions
				if (t!=null)
				{	
					parser.getParameter();
					try 
					{	constants.put(t, Integer.valueOf(parser.getParameter()));
					} catch (Exception e)
					{	error = e.getMessage();
					}
				}
				// handle labels
				else if (l!=null)
				{	Integer a = Integer.valueOf(code.size());
					if (!a.equals(labels.get(l))) { 
						anylabelchanged=true; 
						labels.put(l,a);
					}
					if (phaselabels.contains(l))
					{	error = "Doublicate label: "+l;
					}
					phaselabels.add(l);
				}					
				// handle code line
				else if (o!=null && o.length()>0)
				{	try 
					{	assembleLine(labels,constants,code, o, p, phase>0);
					}
					catch (Exception e) 
					{	error = e.getMessage();
					}	
				}
				
				// print and count detected errors
				if (error!=null) 
				{	if (logfile!=null) 
					{	logfile.println("Line: "+parser.getLine()+" Error: "+error);
					}
					counterrors++;
				}				
			}

			parser.close();	
			
			if (counterrors>0)
			{	System.err.println("Errors during compilation: "+counterrors);
				return null;
			}
			
			// test if this phase is the last one (no unstable labels anymore)
			if (!anylabelchanged) break;		
		}
	
		return code.toByteArray();
	}
	
	private static void assembleLine(
		HashMap<String,Integer> labels,
		HashMap<String,Integer> constants,
		ByteArrayOutputStream code, 
		String operation, String parameter, boolean subsequentpass)
		throws Exception
	{
		int pc = code.size();
		int stackbase = -3;
		
		if (operation==null || operation.length()<1)
		{	throw new Exception("Instruction expected");
		}
		
		// trim stack depth hints
		while (operation.length()>0) {
			char c = operation.charAt(0);
			if (!(c=='<' || c=='>' || c=='-')) break;
			if (c=='-' || c=='<') stackbase++;
			operation = operation.substring(1);
		}
		
		// create opcodes
		if (operation.equals("HIGH"))
		{	code.write( 0x00 | resolveInt(parameter, constants, 0,15));
		}
		else if (operation.equals("PUSH"))
		{	code.write( 0x10 | resolveInt(parameter, constants, 0,15));
		}
		else if (operation.equals("CONST"))
		{	int v = resolveInt(parameter, constants, 0,255);
			if (v<=15) 
			{	code.write( 0x10 | v);
			}
			else
			{	code.write( 0x10 | (v & 0xf));
				code.write( 0x00 | (v >> 4) );
			}
		}
		else if (operation.equals("OP")) 
		{	code.write( 0x20 | resolveInt(parameter, constants, 0,15));
		}
		else if (operation.equals("OP2")) 
		{	code.write( 0x30 | resolveInt(parameter, constants, 0,15));
		}
		else if (operation.equals("GET")) 
		{	int p = stackbase-resolveInt(parameter, constants, stackbase-15,stackbase+2);
			if (p==-2) {
				code.write( 0x31 ); // OP2 SECOND
			} else if (p==-1) {
				code.write( 0x30 ); // OP2 FIRST
			} else {
				code.write( 0x40 | p);
			}
		}
		else if (operation.equals("SET")) 
		{	int p = stackbase-resolveInt(parameter, constants, stackbase-15,stackbase+1);
			if (p==-1) {
				code.write( 0x21 ); // OP SECOND
			} else {
				code.write( 0x50 | p);
			}
		}
		else if (operation.equals("LOAD")) 
		{	code.write( 0x60 | resolveInt(parameter, constants, 0,15));
		}
		else if (operation.equals("STORE")) 
		{	code.write( 0x70 | resolveInt(parameter, constants, 0,15));
		}
		else if (operation.equals("READBIT")) 
		{	code.write( 0x80 | resolveInt(parameter, constants, 0,15));
		}
		else if (operation.equals("WRITEBIT")) 
		{	code.write( 0x90 | resolveInt(parameter, constants, 0,15));
		}
		else if (operation.equals("JZ") || operation.equals("JNZ")) 
		{	int a = resolveLabel(parameter, labels, subsequentpass);
			int rel = (a<0) ? 0 : a-pc;
			if (rel<2 || rel>2+15) throw new Exception("Jump target out of range");
			code.write( (operation.equals("JZ")?0xA0:0xB0) | (rel-2));
		}
		else if (operation.equals("JMP")) 
		{	int a = resolveLabel(parameter, labels, subsequentpass);
			int rel = (a<0) ? 0 : a-(pc+2);
			if (rel<-2045 || rel>2045) throw new Exception("Jump target out of range");
			int x = (rel>=0) ? (rel*2) : ((-rel)*2 + 1);
			code.write( 0x10 | ((x>>4)&0xf) );
			code.write( 0x00 | ((x>>8)&0xf) );
			code.write( 0xC0 | ((x>>0)&0xf) );
		}
		else if (operation.equals("SUB")) 
		{	int a = resolveLabel(parameter, labels, subsequentpass);
			if (a<0) a=0;
			code.write( 0x10 | ((a>>8)&0xf) );
			code.write( 0x00 | ((a>>12)&0xf) );
			code.write( 0x10 | ((a>>0)&0xf) );
			code.write( 0xD0 | ((a>>4)&0xf) );
		}
		else if (operation.equals("RET")) {		
			code.write( 0xD0 );
		}
		else if (operation.equals("POP")) 		
		{	code.write( 0xE0 | (resolveInt(parameter, constants, 1,16)-1));
		}
		else {
			throw new Exception("Unknown command: "+operation);
		}		
	}				


	private static int resolveInt(String o, HashMap<String,Integer> constants, int minvalue, int maxvalue) throws Exception
	{
		int value;
		
		if (o==null || o.length()<1)
		{	throw new Exception("Parameter expected");
		}

		int idx = o.lastIndexOf("+");
		if (idx>0)
		{
			int b = resolveInt(o.substring(idx+1).trim(), constants, Integer.MIN_VALUE, Integer.MAX_VALUE);
			int a = resolveInt(o.substring(0,idx).trim(), constants, Integer.MIN_VALUE, Integer.MAX_VALUE);
			value = a+b;
		}
		else if (o.startsWith("0x") || o.startsWith("0X"))
		{	value = (int) Long.parseLong(o.substring(2),16);		
		}
		else if (o.charAt(0)>='0' && o.charAt(0)<='9') 
		{	value = (int) Long.parseLong(o);
		}
		else if (constants!=null && constants.containsKey(o))
		{	value = constants.get(o).intValue();
		}
		else 
		{	throw new Exception("Unknown constant: "+o);
		}
		
		if (value<minvalue || value>maxvalue) 
		{	throw new Exception("Number out of range");			
		}
		return value;
	}		
		
	private static int resolveLabel(String l, HashMap<String,Integer> labels, boolean required) throws Exception
	{
		if (l==null || l.length()<1)
		{	throw new Exception("Label expected");
		}
				
		Integer i = labels.get(l);
		if (i==null)
		{	if (!required) return -1;			
			throw new Exception("Unresolved label: l");
		} 
		else 
		{	return i.intValue();
		}
	}	

	static void generateSimpleDump(byte[] data, PrintStream outfile) 
	{
		for (int address=0; address<data.length; address+=16) {
			int n = Math.min(data.length-address, 16);
			for (int i=0; i<n; i++) {
				outfile.print(toHex(data[address+i]&0xff,2));
				outfile.print(" ");
			}
			outfile.println();
		}
	}


	static void generateIntelHexFormat(byte[] data, PrintStream hexfile) 
	{
		for (int address=0; address<data.length; address+=16) {
			int n = Math.min(data.length-address, 16);
			int checksum = 0;
			hexfile.print(":");
			hexfile.print(toHex(n,2));
			checksum += n;
			hexfile.print(toHex(address,4));
			checksum += (address) & 0xff;
			checksum += ((address)>>8) & 0xff;
			hexfile.print(toHex(0,2));
			checksum += 0;
			for (int i=0; i<n; i++) {
				hexfile.print(toHex(data[address+i]&0xff,2));
				checksum += data[i] & 0xff;
			}
			hexfile.println(toHex(((~checksum)+1)&0xff,2));
		}
		hexfile.println(":00000001FF");
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


