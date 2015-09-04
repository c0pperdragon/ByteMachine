-- ByteRAM 
-- A standard synchron static RAM containing bytes.
-- At a rising edge of the clock, the data from the position 'address' will be
-- taken and provided on the 'dataread' port until the next clock.
-- When WE is '1' at rising clock, the provided value will be transfered into the memory.
-- Nevertheless, in his case the 'dataread' will show the old value for the
-- rest of the clock cycle ("read before write").
-- This entity was specifically designed in a way that the vhdl synthesis will map it 
-- directly to built-in memory blocks on FPGAs (works at least for altera devices).

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity ByteRAM is
	generic ( addressbits : integer := 12 );  

	port (
		clk: in std_logic;		
		address : in unsigned(addressbits-1 downto 0);	
		datawrite: in unsigned(7 downto 0);	
		dataread: out unsigned(7 downto 0);	
		we: in std_logic 
	);
end entity;

architecture rtl of ByteRAM is
	constant size: integer := 2**addressbits;
	type data_t is array(0 to size-1) of unsigned(7 downto 0);	 
	signal data: data_t := (others => "00000000");
begin	
	process (clk)
		variable a : integer range 0 to size-1 := 0;
	begin					
		if rising_edge(clk) then
			a := to_integer(address);
			if we='1' then
				data(a) <= datawrite;
			end if;			
			dataread <= data(a);	  -- VHDL semantics imply that old data(a) value will be taken
		end if;					
	end process;
end rtl;




