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

entity ByteStack is
	generic ( depth : integer := 20 );  
	
	port (
		clk: in std_logic;				
		stackaddress: in nibble;

		stackoperation: in twobit;
		element0_next: in byte;
		
		element0: out byte;
		element1: out byte;
		elementn: out byte
	);
end entity;

architecture rtl of ByteStack is
begin	
	
	process (clk,stackaddress)		
		type elements_t is  array(0 to depth-1) of byte;
		variable elements: elements_t;
	begin					
		if rising_edge(clk) then	
			-- perform requested stackoperation
			case stackoperation is
				when stackoperation_nop =>
				when stackoperation_push =>
					for i in depth-1 downto 1 loop
						elements(i) := elements(i-1);
					end loop;					
				when stackoperation_pop =>
					for i in 1 to depth-2 loop
						elements(i) := elements(i+1);
					end loop;
					elements(depth-1) := "00000000";
				when stackoperation_popandset =>
					for i in 1 to depth-2 loop
						if i = to_integer(stackaddress) then
							elements(i) := elements(0);
						else
							elements(i) := elements(i+1);
						end if;
					end loop;
					elements(depth-1) := "00000000";
			end case;
						
			-- element0 will always be set
			elements(0) := element0_next;
		end if;		
		
		-- always provide the topmost elements as output
		element0 <= elements(0);
		element1 <= elements(1);
		-- provide the selected element (selection can be done asynchroniuosly)
		elementn <= elements(to_integer(stackaddress));
	end process;
end rtl;




