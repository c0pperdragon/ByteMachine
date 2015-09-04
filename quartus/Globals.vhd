package Globals is   
	-- operations to perform on the stack
	constant stackoperation_nop       : integer := 0;
	constant stackoperation_push      : integer := 1;
	constant stackoperation_pop       : integer := 2;
	constant stackoperation_popandset : integer := 3;
	constant datasource_none:   integer := 0;
	constant datasource_data1 : integer := 1;
	constant datasource_data2 : integer := 2;
	constant datasource_data3 : integer := 3;
		
	-- operations to perform with the ALU
	-- selection (to do operations like nop,pop,swap,etc.)
	constant operation_b          : integer := 0;
	constant operation_a          : integer := 1;	
	-- arithmetic
	constant operation_add        : integer := 2;
	constant operation_sub        : integer := 3;
	constant operation_mul        : integer := 4;
	-- shifting     (first operand will be shifted by second operands signed value)
	constant operation_sll        : integer := 5;
	constant operation_srl        : integer := 6;
	constant operation_sra        : integer := 7;  
	-- bit-logic
	constant operation_and        : integer := 8;  
	constant operation_or         : integer := 9;
	constant operation_xor        : integer := 10;
	-- unary bit-inversion
	constant operation_not_b      : integer := 11;  -- only uses second parameter
	-- comparisions
	constant operation_eq         : integer := 12;
	constant operation_lt         : integer := 13;
	constant operation_gt         : integer := 14;
		
	-- states of the CPU core
	constant state_reset           : integer := 0;
	constant state_reset2          : integer := 1;
	constant state_waitinstruction : integer := 2;
	constant state_run             : integer := 3;
	constant state_waitread        : integer := 4;
	constant state_waitwrite       : integer := 5;
	
	-- opcodes for the instructions
	constant opcode_op1            : integer := 0;	-- ALU operation with 2 operands, but only pop 1 element
	constant opcode_op2            : integer := 1;  -- ALU operation with 2 operands, both are replaced by result
	constant opcode_literal        : integer := 2;  -- Push a 4-bit literal on stack
	constant opcode_highbits       : integer := 3;  -- Fill in 4 bits into the higher bit of stack element 0
	constant opcode_get            : integer := 4;  -- Get stack element <par> and put on top of stack
	constant opcode_put            : integer := 5;  -- Take element0 from stack in put in position <par> in stack
	constant opcode_load           : integer := 6;  -- use element0 as lower 8-bit and <par> as higher 4 bit, and 
	                                                -- overwrite element0 with data from RAM
	constant opcode_store          : integer := 7;  -- use element1 as lower 8-bit and <par> has higher 4 bit, and store
	                                                -- element0 into RAM, popping both elements
	constant opcode_read           : integer := 8;
	constant opcode_write          : integer := 9;	
	constant opcode_jmp            : integer := 10;
	constant opcode_jsr            : integer := 11;

	constant opcode_bz_fwd         : integer := 12; -- pop element0 and branch forward if it is zero
	constant opcode_bz_bwd         : integer := 13; -- pop element0 and branch backward if it is zero
	constant opcode_nbz_fwd        : integer := 14; -- pop element0 and branch forward if it is not zero
	constant opcode_nbz_bwd        : integer := 15; -- pop element0 and branch backward if it is not zero
	
   -- (optional) useful tools
--   function to_slv (e : my_enum_type) return std_logic_vector;
--   function to_enum (s : std_logic_vector(my_enum'length downto 0)) 
--                    return my_enum_type;

end Globals;

package body Globals is
   -- subprogram bodies here
end Globals;
