-- ByteALU
-- Building block for the stack machine that performs the logic 
-- and arithmetic operations.
-- This entity is not clocked, but changes its output at every
-- change of the input values.

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.Globals.all;

entity ByteALU is	
	port (
		operation: in integer range 0 to 15;		
		a: in unsigned(7 downto 0);	
		b: in unsigned(7 downto 0);	
		x: out unsigned(7 downto 0)
	);
end entity;

architecture immediate of ByteALU is
begin		
	process (operation,a,b)				
		variable tmp: unsigned (15 downto 0);
	begin					
		case operation is
			when operation_b => 	
				x <= b;
			when operation_a => 	
				x <= a;
			when operation_add => 	
				x <= a+b;
			when operation_sub => 	
				x <= a-b;
			when operation_mul =>
				tmp := a*b;
				x <= tmp (7 downto 0);
			when operation_sll =>
				x <= a sll to_integer(signed(b));
			when operation_srl =>
				x <= a srl to_integer(signed(b));				
--			when operation_sra =>
--				x <= a sra to_integer(signed(b));
			when operation_and =>
				x <= a and b;
			when operation_or =>
				x <= a or b;
			when operation_xor =>
				x <= a xor b;
			when operation_not_b =>
				x <= not b;
			when operation_eq =>
				if a=b then
					x <= "11111111";
				else	
					x <= "00000000";
				end if;
			when operation_lt =>
				if a<b then
					x <= "11111111";
				else	
					x <= "00000000";
				end if;
			when operation_gt =>
				if a>b then
					x <= "11111111";
				else	
					x <= "00000000";
				end if;
			when others =>
				x <= "00000000";
		end case;
	end process;
end immediate;




