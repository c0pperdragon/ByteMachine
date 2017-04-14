package bytemachine;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class ByteParser 
{
	private BufferedReader reader;

	private int currentLineNumber = 0;
	private String currentLine = "";
	private String currentOperation = null;
	private String currentParameter = null;
	private String currentLabel = null;
	private String currentAssignmentTarget = null;
	
	public ByteParser(InputStream is)
	{
		reader = new BufferedReader(new InputStreamReader(is));
	}
	
	public void close() throws IOException
	{
		reader.close();
	}
	
	public int getLine()
	{		
		return currentLineNumber;
	}
	public String getOperation()
	{
		return currentOperation;
	}
	public String getParameter()
	{
		return currentParameter;
	}
	public String getLabel()
	{
		return currentLabel;
	}
	public String getAssignmentTarget()
	{
		return currentAssignmentTarget;
	}
	
	
	
	public boolean nextLine()
	{
		currentOperation = null;
		currentParameter = null;
		currentLabel = null;
		currentAssignmentTarget = null;
		
		try
		{	currentLine = reader.readLine();
		} 
		catch (IOException e) 
		{	return false;
		}
		if (currentLine==null)
		{	return false;
		}
		
		currentLineNumber++;
		String l = currentLine;
		// trim away comment and leading/trailing empty spaces
		int idx = l.indexOf(';');   
		if (idx>=0)
		{	l = l.substring(0,idx);			
		}
		l = l.trim();
		
		// check if this is an assignment
		idx = l.indexOf('=');
		if (idx>0)
		{	currentAssignmentTarget = l.substring(0,idx).trim();
			currentParameter = l.substring(idx+1).trim();
			return true;		
		}
		
		// find and extract instruction label
		idx = l.indexOf(':');
		if (idx>=0)
		{
			currentLabel = l.substring(0,idx).trim();
			l = l.substring(idx+1);
		}

		l = l.trim();
		
		// check if there is a parameter
		idx = l.indexOf(' ');
		if (idx<0) idx = l.indexOf('\t');
		if (idx>=0)
		{
			currentOperation = l.substring(0,idx).trim();
			currentParameter = l.substring(idx).trim();
		}
		else
		{
			currentOperation = l.trim();
		}		

		return true;
	}
	

}
