-- ByteALU
-- Building block for the stack machine that performs the logic 
-- and arithmetic operations.
-- This entity is not clocked, but changes its output at every
-- change of the input values.

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity ByteALU is	
	port (
		operation: in unsigned (3 downto 0);
		a: in unsigned (7 downto 0);	
		b: in unsigned (7 downto 0);	
		c: in unsigned (7 downto 0);	
		x0: out unsigned(7 downto 0);
		x1: out unsigned(7 downto 0)
	);	
end entity;

architecture immediate of ByteALU is
begin		
	process (operation,a,b,c)		
		variable x:unsigned(7 downto 0);
	begin										
		-- select outputs according to operation 
		case operation is
		when "0000" =>	x := b;                                                            -- use B
							x0 <= x; x1 <= x;
		when "0001" => x := a;                                                            -- use A
							x0 <= x; x1 <= x;
      when "0010" => x := a + b;                                                        -- ADD
							x0 <= x; x1 <= x;
      when "0011" => x := a - b;		                                                    -- SUB
							x0 <= x; x1 <= x;
      when "0100" => x := shift_left(a,to_integer(b(2 downto 0)));                      -- LSL
							x0 <= x; x1 <= x;
      when "0101" => x := shift_right(a,to_integer(b(2 downto 0)));                     -- LSR
							x0 <= x; x1 <= x;
      when "0110" => x := unsigned(shift_right(signed(a), to_integer(b(2 downto 0))));  -- ASR
							x0 <= x; x1 <= x;
      when "0111" => x := a AND b;                                                      -- AND
							x0 <= x; x1 <= x;
      when "1000" => x := a OR b;                                                       -- OR
							x0 <= x; x1 <= x;
      when "1001" => x := a XOR b;                                                      -- XOR
							x0 <= x; x1 <= x;
      when "1010" => if a<b then                                                        -- LT
								x := "00000001";
							else	
								x := "00000000";
							end if;
							x0 <= x; x1 <= x;
      when "1011" => if a>b then                                                        -- GT
								x := "00000001";
							else	
								x := "00000000";
							end if;
							x0 <= x; x1 <= x;
      when "1100" => x := "00000000";
							x0 <= x; x1 <= x;
      when "1101" => x := "00000000";
							x0 <= x; x1 <= x;
		when "1110" => x := c;                                                             -- use C
							x0 <= x; x1 <= x;
		when "1111" => x0 <= b;                                                            -- cross over A and B 
							x1 <= a;
		end case;				
	end process;
end immediate;


