-- ByteALU
-- Building block for the byte machine that performs the logic 
-- and arithmetic operations.
-- This entity is not clocked, but changes its output at every
-- change of the input values.

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity ByteALU is	
	port (
		OP: in unsigned (3 downto 0);
		A: in unsigned (7 downto 0);	
		B: in unsigned (7 downto 0);	
		X: out unsigned(7 downto 0)
	);	
end entity;

architecture immediate of ByteALU is
begin		
	process (OP,A,B)		
	begin										
		-- compute result according to operation 
		case to_integer(OP) is
		when 1 => X <= A + B;
		when 2 => X <= A - B;
		when 3 => X <= A and B;
		when 4 => X <= A or B;
		when 5 => X <= A xor B;
		when 6 => if A < B then X <= "00000001"; else X <= "00000000"; end if;
		when 7 => if A > B then X <= "00000001"; else X <= "00000000"; end if;
		when 8 => X <= A(7 downto 1) & B(7 downto 7); 
		when 9 => X <= B(0 downto 0) & A(6 downto 0); 
		when others => X <= A;
		end case;
	end process;
end immediate;


