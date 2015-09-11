-- ByteStack
-- Building block for the stack machine that holds the internal
-- operand stack. Every stack element is a byte and instead of having
-- the data in a memory with a stack pointer, every push and pop moves
-- the whole content of the stack around. This allows direct access to the 
-- topmost elements.

-- This entity is optimized for lowest I/O-latency:
--   Outputs are directly connected to the registers with no additional logic. 



library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.Globals.all;

entity AddressStack is
	generic ( depth : integer := 10 );  
	
	port (
		clk: in std_logic;				
		
		addressstackenable: in std_logic;
		popaddress: in std_logic;		
		newaddress: in twelvebit;
		
		address0: out twelvebit
	);
end entity;

architecture rtl of AddressStack is
begin	
	process (clk)		
		type addresses_t is  array(0 to depth-1) of twelvebit;
		variable addresses: addresses_t;	
		variable tmp: addresses_t;
	begin					
		if rising_edge(clk) then	
			tmp := addresses;
			if addressstackenable='1' then	
				if popaddress='1' then
					addresses(0 to depth-2) := tmp(1 to depth-1);
					addresses(depth-1) := (others=>'0');
				else
					addresses(1 to depth-1) := tmp(0 to depth-2);
					addresses(0) := newaddress;
				end if;
			end if;
		end if;

		address0 <= addresses(0);
	end process;
end rtl;




