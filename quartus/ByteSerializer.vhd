
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity ByteSerializer is
	generic ( clockdivider : integer := 5208 );    -- 9600 baud on 50Mhz

	port (
		clk: in std_logic;		
		
		outdata : in unsigned(7 downto 0); 
		outwe : in std_logic;
		outrdy : out std_logic;
		
		tx : out std_logic
	);
end entity;

architecture rtl of ByteSerializer is
begin	
	process (clk)
		variable bitstowrite : integer range 11 downto 0 := 0;

		variable outbits : std_logic_vector (10 downto 0);		
		variable holdcounter : integer range clockdivider downto 0;
	begin					
		-- state changes
		if rising_edge(clk) then
			if bitstowrite/=0 then
				if holdcounter/=0 then
					holdcounter := holdcounter-1;
				else
					holdcounter := clockdivider-1;
					bitstowrite := bitstowrite-1;
					for i in 0 to 9 loop
						outbits(i) := outbits(i+1);	
					end loop;					
				end if;		
			elsif outwe='1' then			
				outbits(0) := '0';	-- start bit
				outbits(8 downto 1) := std_logic_vector(outdata);
				outbits(9) := '1';   -- stop bit
				outbits(10) := '1';  -- idle time
				bitstowrite := 11;
				holdcounter := clockdivider-1;
			end if;
		end if;					
		
		-- generate outputs only depending on state
		if bitstowrite=0 then
			outrdy <= '1';
			tx <= '1';
		else
			outrdy <= '0';
			tx <= outbits(0);
		end if;
		
	end process;
end rtl;




