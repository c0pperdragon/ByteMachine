
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity ByteSerializer is
	generic ( clockdivider : integer := 5208 );    -- 9600 baud on 50Mhz

	port (
		clk: in std_logic;		
		reset : in std_logic;
		
		-- simple wishbone slave interface
		adr_i: in unsigned(3 downto 0);
		ack_o: out std_logic;
		dat_o: out unsigned(7 downto 0);
		dat_i: in unsigned(7 downto 0);
		we_i: in std_logic;
		cyc_i: in std_logic;
		stb_i: in std_logic;
		
		tx : out std_logic
	);
end entity;

architecture rtl of ByteSerializer is
begin	
	process (clk)
		variable bitstowrite : integer range 11 downto 0 := 0;

		variable outbits : std_logic_vector (10 downto 0);		
		variable holdcounter : integer range clockdivider downto 0;
		
		variable ack : boolean := false;
	begin					
		-- state changes 
		if rising_edge(clk) then
			-- act according to wishbone master 
			if cyc_i='1' and stb_i='1' then			
				if we_i='1' then
					-- check if can accept data
					if bitstowrite=0 then
						outbits(0) := '0';	-- start bit
						outbits(8 downto 1) := std_logic_vector(dat_i);
						outbits(9) := '1';   -- stop bit
						outbits(10) := '1';  -- idle time
						bitstowrite := 11;
						holdcounter := clockdivider-1;
						ack := true;      
					else
						ack := false;    -- block ack until data is transmitted
					end if;
				else
					ack := true;  -- always ack to read
				end if;
			else
				ack := false;
			end if;
						
			-- transmitting data to tx
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
			end if;
			
		end if;					
		
		-- generate outputs only depending on state
		dat_o <= (others=>'0');
		if ack then
			ack_o <= '1';
		else	
			ack_o <= '0';
		end if;
		
		if bitstowrite=0 then	
			tx <= '1';
		else
			tx <= outbits(0);
		end if;
		
	end process;
end rtl;




