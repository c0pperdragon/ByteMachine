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
		operation: in nibble;
		a: in byte;	
		b: in byte;	
		op1: out byte;
		op2: out byte
	);
end entity;

architecture immediate of ByteALU is
begin		
	process (operation,a,b)				
	variable tmp : unsigned (15 downto 0);
	begin					
		-- compute results of unary operations
		case operation is
			when operation1_nop =>
				op1 <= b;
			when operation1_inc =>
				op1 <= b+1;
			when operation1_dec =>
				op1 <= b-1;
			when operation1_neg =>
				op1 <= 0-b;
			when operation1_double =>
				op1 <= b+b;
			when operation1_not =>
				op1 <= not b;
			when operation1_bnot =>
				if b="00000000" then
					op1 <= "00000001";
				else
					op1 <= "00000000";
				end if;
			when others => 
				op1 <= "00000000";
		end case;
	
		-- compute results of binary operation
		case operation is
			when operation2_a => 	
				op2 <= a;
			when operation2_add => 	
				op2 <= a+b;
			when operation2_sub => 	
				op2 <= a-b;
			when operation2_mul => 	
				tmp := a*b;
				op2 <= tmp(7 downto 0);
				op2 <= "00000000";    -- disable mul
			when operation2_sll =>
				op2 <= a sll to_integer(unsigned(b));
			when operation2_srl =>
				op2 <= a srl to_integer(unsigned(b));				
--			when operation_sra =>
--				x <= a sra to_integer(signed(b));
			when operation2_and =>
				op2 <= a and b;
			when operation2_or =>
				op2 <= a or b;
			when operation2_xor =>
				op2 <= a xor b;
			when operation2_eq =>
				if a=b then
					op2 <= "00000001";
				else	
					op2 <= "00000000";
				end if;
			when operation2_lt =>
				if a<b then
					op2 <= "00000001";
				else	
					op2 <= "00000000";
				end if;
			when operation2_gt =>
				if a>b then
					op2 <= "00000001";
				else	
					op2 <= "00000000";
				end if;
				
			when others =>
				op2 <= "00000000";
		end case;
	end process;
end immediate;




