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
use std.textio.all;

entity ByteRAM is
	port (
		clk: in std_logic;		
		address : in unsigned(11 downto 0);	
		datawrite: in unsigned(7 downto 0);	
		dataread: out unsigned(7 downto 0);	
		we: in std_logic 
	);
end entity;

architecture rtl of ByteRAM is
	constant size : integer := 4096;
	type data_t is array(0 to size-1) of unsigned(7 downto 0);	 
	
--		function decodeHEX(digit:in character) return integer is
--		begin
--			case digit is
--			when '0' => return 0;
--			when '1' => return 1;
--			when '2' => return 2;
--			when '3' => return 3;
--			when '4' => return 4;
--			when '5' => return 5;
--			when '6' => return 6;
--			when '7' => return 7;
--			when '8' => return 8;
--			when '9' => return 9;
--			when 'A' => return 10;
--			when 'B' => return 11;
--			when 'C' => return 12;
--			when 'D' => return 13;
--			when 'E' => return 14;
--			when 'F' => return 15;
--			when others => return 0;
--			end case;
--		end function;	
--		function loadHEXFile (filename : in string) return data_t is
--			variable ram : data_t;
--			variable l : line;
--			variable d0,d1 : character;
--	--		variable p : integer range 0 to size-1 ;
--			FILE f : text is in filename;
--		begin
--			report "reading HEX file " & filename;
--			
--			for p in 0 to 999 loop
--				readline(f, l);
--	
--				report "line: " & l;
--				
--				for i in 1 to 9 loop
--					read (l,d0);
--				end loop;
--				read(l,d0);
--				read(l,d1);
--				ram(p) := to_unsigned(16*decodeHEX(d0)+decodeHex(d1), 8);
--				ram(p) := to_unsigned(41,8);
--			end loop;
--			return ram;
--		end function;

	signal data: data_t; -- := loadHEXFile("TestProgram.hex");
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




