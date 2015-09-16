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
		op1: out unsigned(7 downto 0);
		op2: out unsigned(7 downto 0)
	);
	
	-- unary operations 
	constant operation1_nop    : unsigned(3 downto 0) := "0000";   -- $0	unchanged
	-- arithmetic
	constant operation1_inc    : unsigned(3 downto 0) := "0001";   -- $1
	constant operation1_dec    : unsigned(3 downto 0) := "0010";   -- $2
	constant operation1_neg    : unsigned(3 downto 0) := "0011";   -- $3
	constant operation1_double : unsigned(3 downto 0) := "0100";   -- $4
	-- bit-logic and boolean
	constant operation1_inv    : unsigned(3 downto 0) := "0101";   -- $5
	constant operation1_not    : unsigned(3 downto 0) := "0110";   -- $6
	constant operation1_negate : unsigned(3 downto 0) := "0111";   -- $7
	
	constant operation1_ret    : unsigned(3 downto 0) := "1111";   -- $F pop top address from return stack and jump there
																			
	-- binary operations 
	constant operation2_a      : unsigned(3 downto 0) := "0000";   -- $0
	-- arithmetic
	constant operation2_add    : unsigned(3 downto 0) := "0001";   -- $1
	constant operation2_sub    : unsigned(3 downto 0) := "0010";   -- $2
	-- shifting     (first operand will be shifted by second operands signed value)	
	constant operation2_lsl    : unsigned(3 downto 0) := "0011";   -- $3
	constant operation2_lsr    : unsigned(3 downto 0) := "0100";   -- $4
	constant operation2_asr    : unsigned(3 downto 0) := "0101";   -- $5
	-- bits-logic and boolean
	constant operation2_and    : unsigned(3 downto 0) := "0110";   -- $6
	constant operation2_or     : unsigned(3 downto 0) := "0111";   -- $7
	constant operation2_xor    : unsigned(3 downto 0) := "1000";   -- $8
	-- comparisions
	constant operation2_eq     : unsigned(3 downto 0) := "1001";   -- $9
	constant operation2_lt     : unsigned(3 downto 0) := "1010";   -- $A
	constant operation2_gt     : unsigned(3 downto 0) := "1011";   -- $B
	constant operation2_lts    : unsigned(3 downto 0) := "1100";   -- $C
	constant operation2_gts    : unsigned(3 downto 0) := "1101";   -- $D
	-- carry computation (replaces use of a carry flag)
	constant operation2_carries: unsigned(3 downto 0) := "1110";   -- $E
	constant operation2_borrows: unsigned(3 downto 0) := "1111";   -- $F
	
end entity;

architecture immediate of ByteALU is
begin		
	process (operation,a,b)				
	variable tmp : unsigned (8 downto 0);
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
			when operation1_inv =>
				op1 <= not b;
			when operation1_not =>
				if b="00000000" then
					op1 <= "00000001";
				else
					op1 <= "00000000";
				end if;
			when operation1_negate =>
				op1 <= unsigned(-signed(b));							
			when others => 
				op1 <= b;				
		end case;
	
		-- compute results of binary operation
		case operation is
			when operation2_a => 	
				op2 <= a;
			when operation2_add => 	
				op2 <= a+b;
			when operation2_sub => 	
				op2 <= a-b;
			when operation2_lsl =>
				op2 <= shift_left(a,to_integer(b));
			when operation2_lsr =>
				op2 <= shift_right(a,to_integer(b));
			when operation2_asr =>
				op2 <= unsigned(shift_right(signed(a), to_integer(b)));
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
			when operation2_lts =>
				if signed(a)<signed(b) then
					op2 <= "00000001";
				else	
					op2 <= "00000000";
				end if;
			when operation2_gts =>
				if signed(a)>signed(b) then
					op2 <= "00000001";
				else	
					op2 <= "00000000";
				end if;

			when operation2_carries =>
				tmp:=(others=>'0');
				tmp(7 downto 0) := a;
				tmp := tmp + b;
				op2 <= "00000000";
				op2(0) <= tmp(8);
			when operation2_borrows =>
				tmp:=(others=>'0');
				tmp(7 downto 0) := a;
				tmp := tmp - b;
				op2 <= "00000000";
				op2(0) <= tmp(8);
				
		end case;
	end process;
end immediate;




