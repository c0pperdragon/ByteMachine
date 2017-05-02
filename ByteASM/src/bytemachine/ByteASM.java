package bytemachine;

import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.util.HashMap;
import java.util.HashSet;
import java.util.StringTokenizer;

public class ByteASM 
{
	public static void main(String[] args) throws IOException
	{			
		String srcfilename = "C:/Users/Reinhard/Documents/GitHub/ByteMachine/samples/fibonacci.basm";		
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
		
		if (operation==null || operation.length()<1)
		{	throw new Exception("Instruction expected");
		}
		
		// trim stack depth hints
		int stackbase = -1;
		int pops = 0;
		while (operation.length()>0) {
			char c = operation.charAt(0);
			if (!(c=='<' || c=='>' || c=='-')) break;
			if (c=='-') stackbase++;
			if (c=='<') pops++;
			operation = operation.substring(1);
		}
		
		// create opcodes
		if (operation.equals("EXT"))
		{	code.write( 0x00 | resolveInt(parameter, constants, 0,15, stackbase));
		}
		else if (operation.equals("DAT"))
		{	code.write( 0x10 | resolveInt(parameter, constants, 0,15, stackbase));
		}
		else if (operation.equals("OP")) 
		{	code.write( 0x20 | resolveOperator(parameter));
		}
		else if (operation.equals("OPP")) 
		{	code.write( 0x30 | resolveOperator(parameter));
		}
		else if (operation.equals("GET")) 
		{	int p = resolveInt(parameter, constants, 0,15, stackbase);
			code.write( 0x40 | p);
		}
		else if (operation.equals("SET")) 
		{	int p = resolveInt(parameter, constants, 0,15, stackbase);
			code.write( 0x50 | p);
		}
		else if (operation.equals("LOD")) 
		{	code.write( 0x60 | resolveInt(parameter, constants, 0,15, stackbase));
		}
		else if (operation.equals("STO")) 
		{	code.write( 0x70 | resolveInt(parameter, constants, 0,15, stackbase));
		}
		else if (operation.equals("IN")) 
		{	code.write( 0x80 | resolveInt(parameter, constants, 0,15, stackbase));
		}
		else if (operation.equals("OUT")) 
		{	code.write( 0x90 | resolveInt(parameter, constants, 0,15, stackbase));
		}
		else if (operation.equals("JZ") || operation.equals("JNZ")) 
		{	int a = resolveLabel(parameter, labels, subsequentpass);
			int rel = (a<0) ? 2 : a-pc;
			if (rel<2 || rel>2+15) throw new Exception("Jump target out of range");
			code.write( (operation.equals("JZ")?0xB0:0xC0) | (rel-2));
		}
		else if (operation.equals("RET")) {	
			code.write( 0xE0 | resolveInt(parameter, constants, 0,15, stackbase));	
		}
		else if (operation.equals("ADR")) 		
		{	code.write( 0xF0 | resolveInt(parameter, constants, 0,15, stackbase));
		}		

		else if (operation.equals("JUMP")) 
		{	int a = resolveLabel(parameter, labels, subsequentpass);
			int rel = (a<0) ? 10 : a-(pc+2);
			if (rel<-2045 || rel>2045) throw new Exception("Jump target out of range");
			code.write( 0x10 | ((rel>>4)&0xf) );
			code.write( 0x00 | ((rel>>8)&0xf) );
			code.write( 0xA0 | ((rel>>0)&0xf) );
		}
		else if (operation.equals("CALL")) 
		{	int a = resolveLabel(parameter, labels, subsequentpass);
			if (a<0) a=0;
			code.write( 0x10 | ((a>>0)&0xf) );
			code.write( 0x10 | ((a>>8)&0xf) );
			code.write( 0x00 | ((a>>12)&0xf) );
			code.write( 0xD0 | ((a>>4)&0xf) );
			code.write( 0x20 );
		}
		else if (operation.equals("RETURN")) 
		{	if (pops<1) throw new Exception("Too little pops on RETURN"); 
			if (pops>16) throw new Exception("Too many pops on RETURN");
			code.write( 0xE0 | (pops-1) );
		}
		else if (operation.equals("HALT")) 
		{	int a = pc+4;
			code.write( 0x10 | ((a>>0)&0xf) );
			code.write( 0x00 | ((a>>4)&0xf) );
			code.write( 0x10 | ((a>>8)&0xf) );
			code.write( 0x00 | ((a>>12)&0xf) );
			code.write( 0xE0 );
		}
		else if (operation.equals("DATA"))
		{	StringTokenizer tok = new StringTokenizer(parameter.trim());
			while (tok.hasMoreTokens()) {		
				int v = resolveInt(tok.nextToken(), constants, 0,255, stackbase);
				if (v<=15) 
				{	code.write( 0x10 | v);
				}
				else
				{	code.write( 0x10 | (v & 0xf));
					code.write( 0x00 | (v >> 4) );
				}
			}
		}
		else if (operation.equals("DATA32"))
		{	StringTokenizer tok = new StringTokenizer(parameter.trim());
			while (tok.hasMoreTokens()) {		
				int v = resolveInt(tok.nextToken(), constants, Integer.MIN_VALUE, Integer.MAX_VALUE, stackbase);
				code.write( 0x10 | ((v >>  0) & 0x0f) );
				code.write( 0x00 | ((v >>  4) & 0x0f) );				
				code.write( 0x10 | ((v >>  8) & 0x0f) );
				code.write( 0x00 | ((v >> 12) & 0x0f) );				
				code.write( 0x10 | ((v >> 16) & 0x0f) );
				code.write( 0x00 | ((v >> 20) & 0x0f) );				
				code.write( 0x10 | ((v >> 24) & 0x0f) );
				code.write( 0x00 | ((v >> 28) & 0x0f) );				
			}
		}
		else 
		{	throw new Exception("Unknown command: "+operation);
		}		
	}				


	private static int resolveInt(String o, HashMap<String,Integer> constants, 
		int minvalue, int maxvalue, int stackbase) throws Exception
	{
		int value;
		boolean isrelativetostackbase=false;
				
		if (o==null || o.length()<1)
		{	throw new Exception("Parameter expected");
		}
		
		if (o.startsWith("!")) {
			o=o.substring(1).trim();
			isrelativetostackbase = true;
		}

		int idx = o.lastIndexOf("+");
		if (idx>0)
		{
			int b = resolveInt(o.substring(idx+1).trim(), constants, Integer.MIN_VALUE, Integer.MAX_VALUE, stackbase);
			int a = resolveInt(o.substring(0,idx).trim(), constants, Integer.MIN_VALUE, Integer.MAX_VALUE, stackbase);
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
		
		if (isrelativetostackbase) {
			value = stackbase - value;
		}
		
		if (value<minvalue || value>maxvalue) 
		{	throw new Exception("Number out of range: "+value);			
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

	static int resolveOperator(String parameter) throws Exception {
		if (parameter.equals("POP")) return 0;
		if (parameter.equals("ADD")) return 1;
		if (parameter.equals("SUB")) return 2;
		if (parameter.equals("AND")) return 3;
		if (parameter.equals("OR"))  return 4;
		if (parameter.equals("XOR")) return 5;
		if (parameter.equals("LT"))  return 6;
		if (parameter.equals("GT"))  return 7;
		if (parameter.equals("SHL")) return 8;
		if (parameter.equals("SHR")) return 9;
		throw new Exception("Unknown operator: "+parameter);
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


