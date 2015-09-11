package bytemachine;

import java.io.IOException;
import java.util.Arrays;

public class ByteVM 
{
	public static void main(String args[]) throws IOException
	{
		(new ByteVM()).loadAndExecute("C:/Users/Reinhard/Documents/GitHub/ByteMachine/samples/writeport.basm");	
	}

	byte ram[];

	public ByteVM()
	{	
		ram = new byte[4096];
	}
	
	public void loadAndExecute(String filename) throws IOException
	{
		byte[] c = ByteASM.assemble(filename, null, System.out);
		Arrays.fill(c,(byte)0);
		System.arraycopy (c,0, ram,0, c.length);		
	}





}
