-- ByteRAM 
-- A synchronous RAM containing 1024 bytes with independent read port and write port 
-- (each port only works in its designed direction)
-- At a rising edge of the clock, the data from the position 'readaddress' will be
-- taken and provided on the 'readdata' port until the next clock.
-- When WE is '1' at rising clock, the value provided at 'writedata' will be transfered 
-- into the memory at position 'writeaddress'.  
-- Read During Write behaviour: For the case that readaddress and writeaddress refence the
-- same location, the old value is provided on the dataread output for the duration of the cycle. 
-- This entity was specifically designed in a way that the vhdl synthesis will map it 
-- most naturally to built-in memory blocks on FPGAs (tested with a cyclone v).

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity ByteRAM is
	port (
		clk: in std_logic;		
		readaddress : in unsigned(9 downto 0);	
		readdata: out unsigned(7 downto 0);	
		writeaddress : in unsigned(9 downto 0);	
		writedata: in unsigned(7 downto 0);	
		we: in std_logic );
end entity;

architecture oldvalue of ByteRAM is
	type data_t is array(0 to 1023) of unsigned(7 downto 0);	 	
	signal data: data_t; 
begin	
	process (clk)
	begin					
		if rising_edge(clk) then
			if we='1' then
				data(to_integer(writeaddress)) <= writedata;
			end if;			
			readdata <= data(to_integer(readaddress));
		end if;					
	end process;
end oldvalue;

