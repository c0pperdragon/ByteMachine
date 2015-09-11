library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

package Globals is   
	subtype twobit is unsigned(1 downto 0);
	subtype nibble is unsigned(3 downto 0);
	subtype byte is unsigned(7 downto 0);
	subtype twelvebit is unsigned(11 downto 0);
	
	constant state_reset	          : integer := 0;
	constant state_reset2          : integer := 1;
	constant state_waitinstruction : integer := 2;
	constant state_run             : integer := 3;
	constant state_waitread        : integer := 4;
	constant state_waitwrite       : integer := 5;
	constant state_waitjumptarget  : integer := 6;
	
	-- for operations to perform on the stack
	constant stackoperation_nop       : twobit := "00";
	constant stackoperation_push      : twobit := "01";
	constant stackoperation_pop       : twobit := "10";
	constant stackoperation_popandset : twobit := "11";

	-- unary operations to perform with the ALU
	constant operation1_nop    : nibble := "0000";   -- $0	unchanged
	-- arithmetic
	constant operation1_inc    : nibble := "0010";   -- $2
	constant operation1_dec    : nibble := "0011";   -- $3
	constant operation1_neg    : nibble := "0100";   -- $4
	constant operation1_double : nibble := "0101";   -- $5
	-- bit-logic and boolean
	constant operation1_not    : nibble := "0110";   -- $6
	constant operation1_bnot   : nibble := "0111";   -- $7
			
	-- binary operations to perform with the ALU
	-- select second operand (for doing a POP)
	constant operation2_a      : nibble := "0000";   -- $0
	-- arithmetic
	constant operation2_add    : nibble := "0010";   -- $2
	constant operation2_sub    : nibble := "0011";   -- $3
	constant operation2_mul    : nibble := "0100";   -- $4
	-- shifting     (first operand will be shifted by second operands signed value)	
	constant operation2_sll    : nibble := "0101";   -- $5
	constant operation2_srl    : nibble := "0110";   -- $6
	constant operation2_sra    : nibble := "0111";   -- $7
	-- bits-logic and boolean
	constant operation2_and    : nibble := "1000";   -- $8
	constant operation2_or     : nibble := "1001";   -- $9
	constant operation2_xor    : nibble := "1010";   -- $A
	-- comparisions
	constant operation2_eq     : nibble := "1100";   -- $C
	constant operation2_lt     : nibble := "1101";   -- $D
	constant operation2_gt     : nibble := "1110";   -- $E
				
	-- opcodes for the instructions
	constant opcode_op1       : nibble := "0000";  -- $0 ALU operation with 2 operands, replace element0 with result
	constant opcode_op2       : nibble := "0001";  -- $1 ALU operation with 2 operands, both are replaced by result
	constant opcode_literal   : nibble := "0010";  -- $2 Push a 4-bit literal onto the stack
	constant opcode_highbits  : nibble := "0011";  -- $3 Fill in 4 bits into the higher bit of stack element 0
	constant opcode_get       : nibble := "0100";  -- $4 Get stack element <par> and put on top of stack
	constant opcode_set       : nibble := "0101";  -- $5 Take element0 from stack in put in position <par> in stack
	constant opcode_load      : nibble := "0110";  -- &6 use element0 as lower 8-bit and <par> as higher 4 bit of address, 
	                                               --    and  overwrite element0 with data from RAM
	constant opcode_store     : nibble := "0111";  -- $7 use element0 as lower 8-bit and <par> has higher 4 bit of address, 
	                                               --    and store element1 into RAM, popping both elements
	constant opcode_read      : nibble := "1000";  -- $8
	constant opcode_write     : nibble := "1001";  -- $9
	constant opcode_jmp       : nibble := "1010";  -- $A use <par> has higher 4 bit, and the next command byte as lower 8 bit
	                                               --    of address and jump 
	constant opcode_jz        : nibble := "1011";  -- $B pop element0 and do a jump (address resolution like jmp) if zero 
	constant opcode_jnz       : nibble := "1100";  -- $C pop element0 and do a jump (address resolution like jmp) if not zero
	constant opcode_jsr       : nibble := "1101";  -- $D perform a jump, and push the return address on the return stack
	constant opcode_ret       : nibble := "1110";  -- $E pop top address from return stack and jump there (not using <par>)
	
   -- (optional) useful tools
--   function to_slv (e : my_enum_type) return std_logic_vector;
--   function to_enum (s : std_logic_vector(my_enum'length downto 0)) 
--                    return my_enum_type;

	-- declarations for types that go into ports of entities
	type bytearray is array(natural range <>) of byte;
		
end Globals;

package body Globals is
   -- subprogram bodies here
end Globals;
