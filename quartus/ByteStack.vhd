-- ByteStack
-- Building block for the stack machine that holds the internal
-- operand stack. Every stack element is a byte and instead of having
-- the data in a memory with a stack pointer, every push and pop moves
-- the whole content of the stack around. This allows direct access to the 
-- topmost elements.
--
-- At every clock, the stack will perform one of the following operations:
--    nop   -  do not move elements.
--    push  -  move content from lower number elements to higher number elements.
--             on position 0, a copy of the element will be inserted whose address is supplied.
--    pop   -  move content from higher numbers elements to lower number elements.
--             at the bottom of the stack, a 0 is created.
--    popandset - like pop, but place the value of element(0) into the element whose addresse
--                is supplied (the address _after_ the pop was performed)
--
-- Additionally (and conceptionally afterwards), the element at postion 0 may be overwritten
-- by one of the three data inputs. This feature is triggered by 'datasource' having a value 
-- different from datasource_none and this value directly selects the input from where to
-- take the data.
--
-- This entity is optimized for lowest I/O-latency:
--   Outputs are directly connected to the registers with no additional logic. 
--   The three input lines are fed into the registers only via one single 4-way MUX
--   (which will fit into a single LUT on modern FPGAs)


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.Globals.all;

entity ByteStack is
	generic ( depth : integer := 20 );  
	
	port (
		clk: in std_logic;		
		stackoperation: in integer range 0 to 3;	
		stackaddress: in integer range 0 to 15;
		
		datasource : in integer range 0 to 3;
		data1: in unsigned(7 downto 0);	
		data2: in unsigned(7 downto 0);	
		data3: in unsigned(7 downto 0);	
		
		element0: out unsigned(7 downto 0);
		element1: out unsigned(7 downto 0)
	);
end entity;

architecture rtl of ByteStack is
begin	
	
	process (clk)		
		-- variables to store data persistently
		type elements_t is array(0 to depth-1) of unsigned(7 downto 0);
		variable elements: elements_t;
		
		-- temporary variables are completely converted to combinational logic		
		variable tmp: elements_t;  
		variable elementoperation : integer range 0 to 3;
	begin					
		if rising_edge(clk) then	
			-- create virtual copy of the whole stack
			tmp := elements;
						
			-- creating new contents of lower elements 
			for i in 1 to depth-1 loop
				-- check for each element how the operation affects it 
				elementoperation := stackoperation;			
				-- modify behaviour of non-affected elements to do simple pop 
				if stackoperation=stackoperation_popandset then
					if i>15 or i/=stackaddress then
						elementoperation := stackoperation_pop;
					end if;				
				end if;
				
				-- for each element decide from where to take new content
				case elementoperation is
					when stackoperation_nop => 
						elements(i) := tmp(i);
					when stackoperation_push => 
						elements(i) := tmp(i-1);
					when stackoperation_pop =>
						if i<depth-1 then
							elements(i) := tmp(i+1);
						else   -- when popping bottom-most element, fill with 0
							elements(i) := "00000000";
						end if;
					when stackoperation_popandset =>
						elements(i) := tmp(0);
				end case;
			end loop;
			
			-- calculate new content of topmost element
			case datasource is
				when datasource_data1 =>
					elements(0) := data1;
				when datasource_data2 =>
					elements(0) := data2;
				when datasource_data3 =>
					elements(0) := data3;			
				when datasource_none =>
					case stackoperation is
						when stackoperation_nop =>
							elements(0) := tmp(0);
						when stackoperation_push =>
							elements(0) := tmp(stackaddress);
						when stackoperation_pop =>
							elements(0) := tmp(1);
						when stackoperation_popandset =>
							if stackaddress=0 then
								elements(0) := tmp(0);
							else
								elements(0) := tmp(1);
							end if;
					end case;
			end case;
		end if;		
		
		-- always provide the topmost elements as output
		element0 <= elements(0);
		element1 <= elements(1);
	end process;
end rtl;




