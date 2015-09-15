-- ByteMachine

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity ByteMachine is	
	generic ( operandstacksize : integer := 20; addressstacksize : integer := 10;
	          outports : integer := 1; inports : integer := 1 );  

	port (
		clk: in std_logic;		
		reset: in std_logic;
		
		-- ram access
		ramaddress : out unsigned(11 downto 0);
		ramwrite: out unsigned(7 downto 0);
		ramread: in unsigned(7 downto 0);
		ramwe: out std_logic; 		
		-- output ports
		outdata : out unsigned(8*outports-1 downto 0); 
		outwe : out std_logic_vector (outports-1 downto 0);
		outrdy : in std_logic_vector (outports-1 downto 0);
		-- input ports
		indata : in unsigned (8*inports-1 downto 0);
		inwe : in std_logic_vector (inports-1 downto 0);
		inrdy : out std_logic_vector (inports-1 downto 0);
		
		-- test output
		test_state : out integer;
		test_pc    : out unsigned(11 downto 0);
		test_we : out std_logic;
		test_command : out unsigned(7 downto 0);	
		test_operand0 : out unsigned(7 downto 0);
		test_operand1 : out unsigned(7 downto 0);
		test_operand2 : out unsigned(7 downto 0);
		test_operand3 : out unsigned(7 downto 0)
	);

		subtype nibble is unsigned(3 downto 0);
	
		-- opcodes for the instructions
		constant opcode_op1       : nibble := "0000";  -- $0 operation with 1 operand, replace operand 0 with result
		constant opcode_op2       : nibble := "0001";  -- $1 operation with 2 operands, both are replaced by result
		constant opcode_literal   : nibble := "0010";  -- $2 Push a 4-bit literal onto the stack
		constant opcode_highbits  : nibble := "0011";  -- $3 Fill in 4 bits into the higher bit of operand 0
		constant opcode_get       : nibble := "0100";  -- $4 Get operand <par> and put on top of stack
		constant opcode_set       : nibble := "0101";  -- $5 Take operand 0 from stack in put in position <par> in stack
		constant opcode_read      : nibble := "0110";  -- $6
		constant opcode_write     : nibble := "0111";  -- $7	
		constant opcode_load      : nibble := "1000";  -- &8
		constant opcode_store     : nibble := "1001";  -- $9
		constant opcode_loadx     : nibble := "1010";  -- &A
		constant opcode_storex    : nibble := "1011";  -- $B
		constant opcode_jmp       : nibble := "1100";  -- $C use <par> has lower 4 bit, and the next command byte as higher 8 bit
																	 --    of address and jump 
		constant opcode_jz        : nibble := "1101";  -- $D pop element0 and do a jump (address resolution like jmp) if zero 
		constant opcode_jnz       : nibble := "1110";  -- $E pop element0 and do a jump (address resolution like jmp) if not zero
		constant opcode_jsr       : nibble := "1111";  -- $F perform a jump, and push the return address on the return stack
		
		-- unary operations 
		constant operation1_nop    : nibble := "0000";   -- $0	unchanged
		-- arithmetic
		constant operation1_inc    : nibble := "0001";   -- $1
		constant operation1_dec    : nibble := "0010";   -- $2
		constant operation1_neg    : nibble := "0011";   -- $3
		constant operation1_double : nibble := "0100";   -- $4
		-- bit-logic and boolean
		constant operation1_inv    : nibble := "0101";   -- $5
		constant operation1_not    : nibble := "0110";   -- $6
		constant operation1_negate : nibble := "0111";   -- $7
		
		constant operation1_ret    : nibble := "1111";   -- $F pop top address from return stack and jump there (not using <par>)
																		 --    and store element1 into RAM, popping both elements			
		-- binary operations 
		constant operation2_a      : nibble := "0000";   -- $0
		-- arithmetic
		constant operation2_add    : nibble := "0001";   -- $1
		constant operation2_sub    : nibble := "0010";   -- $2
		-- shifting     (first operand will be shifted by second operands signed value)	
		constant operation2_lsl    : nibble := "0011";   -- $3
		constant operation2_lsr    : nibble := "0100";   -- $4
		constant operation2_asr    : nibble := "0101";   -- $5
		-- bits-logic and boolean
		constant operation2_and    : nibble := "0110";   -- $6
		constant operation2_or     : nibble := "0111";   -- $7
		constant operation2_xor    : nibble := "1000";   -- $8
		-- comparisions
		constant operation2_eq     : nibble := "1001";   -- $9
		constant operation2_lt     : nibble := "1010";   -- $A
		constant operation2_gt     : nibble := "1011";   -- $B
		constant operation2_lts    : nibble := "1100";   -- $C
		constant operation2_gts    : nibble := "1101";   -- $D
		-- carry computation (replaces use of a carry flag)
		constant operation2_carries: nibble := "1110";   -- $E
		constant operation2_borrows: nibble := "1111";   -- $F
end entity;

architecture rtl of ByteMachine is		
begin			
	process (clk)		
	
		-- machine states
		subtype state_t is integer range 0 to 3;
		constant state_command : state_t := 0;
		constant state_jump : state_t := 1;
		constant state_loadstore : state_t := 2;
		constant state_waitloadstore : state_t := 3;
	
		-- various registers of the machine 
		variable state : state_t := state_command;
		variable pc : unsigned(11 downto 0) := (others=>'0');
		variable we : std_logic := '0';
		variable we_prev : std_logic := '0';
		variable command : unsigned(7 downto 0) := (others=>'0');
		
		variable lowaddressbits : unsigned(3 downto 0) := (others=>'0');
		variable addressoffset : unsigned(4 downto 0);
		
		-- operand stack and address stack
		type operands_t is  array(0 to operandstacksize-1) of unsigned(7 downto 0);
		variable operands : operands_t;
		type addresses_t is  array(0 to addressstacksize-1) of unsigned(11 downto 0);
		variable addresses : addresses_t;
		
		-- registers for the ports
		variable outvalue : unsigned(7 downto 0);
		variable outtarget : integer range 0 to outports-1;
		variable outsending : boolean;
				
		-- temporary variables - will be completely implemented in logic only
		variable tmp9 : unsigned (8 downto 0);
		variable tmp12 : unsigned (11 downto 0);
		variable tmp16 : unsigned(15 downto 0);
		variable opcode : unsigned(3 downto 0);
		variable parameter : unsigned(3 downto 0);	
		variable a,b,n,x : unsigned(7 downto 0);
		variable outsending_next : boolean;
		
		-- possibilities from where operand 0 will take its next value
		type operand0source_t is (operand0source_keep, operand0source_op1,operand0source_op2,
					operand0source_literal,	operand0source_highbits,operand0source_n,operand0source_a,
					operand0source_readbuffer,operand0source_ram);
		variable operand0source : operand0source_t;
	begin			
	
		if rising_edge (clk) then
			
			-- memorize some previous states for the next iteration
			we_prev := we;
			we := '0';                       -- stop writing to ram 
			
			-- decode current command
			opcode := command(7 downto 4);
			parameter := command(3 downto 0);				

			-- prepare the flags which will later decide from where to retrieve new value of operand0
			operand0source := operand0source_keep;  -- do not change 
						
			-- memorize the topmost operands and the operand selected by parameter 
			-- (for the possiblity it will be used)
			a := operands(1);
			b := operands(0);
			n := operands(to_integer(parameter));
			
			-- prepare next value for the outsending flag
			outsending_next := false;
			
			-- a reset forces program to start from begin
			if reset='0' then
				pc := (others=>'0');
				command := (others=>'0');
				state := state_command;
			else
			
				-- main state machine of the processor
				case state is
				
				-- state for instruction decoding and execution - some instructions need additional states
				when state_command =>
					
					-- already receive followup command from ram - but depending on instructions, 
					-- this could be overwritten 
					command := ramread;
								
					-- command processing
					case opcode is
					
					-- operations with a single operand
					when opcode_op1 => 	
						operand0source := operand0source_op1;
						
						-- because there was no free opcode, the RET instruction is squeezed into this place
						if parameter=operation1_ret then
							-- pop return address off the address stack
							pc := addresses(0);			
							addresses(0 to addressstacksize-2) := addresses(1 to addressstacksize-1);
							addresses(addressstacksize-1) := (others=>'0');
							command := (others=>'0');  -- insert a NOP into the command stream 
						else
							pc := pc+1;
						end if;
						
					-- operations with two operands
					when opcode_op2 => 	
						operands(1 to operandstacksize-2) := operands(2 to operandstacksize-1);
						operands(operandstacksize-1) := (others=>'0');
						operand0source := operand0source_op2;
						pc := pc+1;
	
					-- Push a 4-bit literal on stack
					when opcode_literal =>
						operands(1 to operandstacksize-1) := operands(0 to operandstacksize-2);
						operand0source := operand0source_literal;
						pc := pc+1;
					
					-- Overwrite the higher 4 bits of operand 0
					when opcode_highbits =>
						operand0source := operand0source_highbits;
						
					-- Get stack element <par> and put on top of stack
					when opcode_get =>
						operands(1 to operandstacksize-1) := operands(0 to operandstacksize-2);				
						operand0source := operand0source_n;
						pc := pc+1;
					
					-- Take element0 from stack and put in position 'parameter' in stack		
					when opcode_set =>
						if parameter/="0000" then
							operand0source := operand0source_a;
						end if;
						for i in 1 to operandstacksize-1 loop
							if i=to_integer(parameter) then
								operands(i) := b;
							elsif i<operandstacksize-1 then
								operands(i) := operands(i+1);
							else
								operands(i) := (others=>'0');
							end if;
						end loop;
						pc := pc+1;
					
					when opcode_read =>
						operands(1 to operandstacksize-1) := operands(0 to operandstacksize-2);
						operand0source := operand0source_readbuffer;
						pc := pc+1;
						
					when opcode_write =>
						-- test if the requested port is currently busy
						if to_integer(parameter)<outports and (outsending or outrdy(to_integer(parameter))='0') then
							-- can not proceed - must repeat current command until port becomes ready
							command(7 downto 4) := opcode;
							command(3 downto 0) := parameter;						
						else
							-- pop off top value and take to output buffer
							operands(1 to operandstacksize-2) := operands(2 to operandstacksize-1);
							operands(operandstacksize-1) := (others=>'0');				
							operand0source := operand0source_a;
	
							outvalue := b;	
							outsending_next := true;
							outtarget := to_integer(parameter);
													
							pc := pc+1;
						end if;
						
					when opcode_jmp =>
						lowaddressbits := parameter;
						state := state_jump;
				
					when opcode_jz =>
						operands(1 to operandstacksize-2) := operands(2 to operandstacksize-1);
						operands(operandstacksize-1) := (others=>'0');				
						operand0source := operand0source_a;
						
						if b=0 then
							lowaddressbits := parameter;
							state := state_jump;
						else
							command := (others=>'0');  -- inject a NOP into the command stream to skip address part
							pc := pc+1;
						end if;
	
					when opcode_jnz =>
						operands(1 to operandstacksize-2) := operands(2 to operandstacksize-1);
						operands(operandstacksize-1) := (others=>'0');				
						operand0source := operand0source_a;
						
						if b/=0 then
							lowaddressbits := parameter;
							state := state_jump;
						else
							command := (others=>'0');  -- inject a NOP into the command stream to skip address part
							pc := pc+1;
						end if;
						
					-- push current program counter to address stack and perform a jump
					when opcode_jsr =>
						addresses(1 to addressstacksize-1) := addresses(0 to addressstacksize-2);
						addresses(0) := pc;
						
						lowaddressbits := parameter;
						state := state_jump;
					
					-- load byte from absolute address. this operation is implemented by the same
					-- means as loading with index, so an offset 0 is prepared
					when opcode_load =>
						lowaddressbits := parameter;
						addressoffset := (others=>'0');
						state := state_loadstore;
						pc := pc+1;
						
					-- write byte to absolute address. this operation is implemented by the same
					-- means as storing with index, so an offset 0 is prepared
					when opcode_store =>
						we := '1';
						lowaddressbits := parameter;
						addressoffset := (others=>'0');
						state := state_loadstore;
						pc := pc+1;
					
					-- load byte from address + element0. until the second part of the address arrives,
					-- the lower 4 bits of the address can be combined with operand 0 to
					-- get the lower 4 bit of the total address. 
					-- the other 8 bits can only be computed later, using the 5-bit addressoffset
					when opcode_loadx =>
						tmp9(8) := '0';
						tmp9(7 downto 0) := operands(0);
						tmp9 := tmp9 + parameter;					
						lowaddressbits := tmp9(3 downto 0);
						addressoffset := tmp9(8 downto 4);
						state := state_loadstore;
						pc := pc+1;
	
						operands(1 to operandstacksize-2) := operands(2 to operandstacksize-1);
						operands(operandstacksize-1) := (others=>'0');				
						operand0source := operand0source_a;
	
					
					-- write byte to address + element0. until the second part of the address arrives,
					-- the lower 4 bits of the address can be combined with operand 0 to
					-- get the lower 4 bit of the total address. 
					-- the other 8 bits can only be computed later, using the 5-bit addressoffset
					when opcode_storex =>
						tmp9(8) := '0';
						tmp9(7 downto 0) := operands(0);
						tmp9 := tmp9 + parameter;					
						lowaddressbits := tmp9(3 downto 0);
						addressoffset := tmp9(8 downto 4);
						state := state_loadstore;
						we := '1';
						pc := pc+1;
	
						operands(1 to operandstacksize-2) := operands(2 to operandstacksize-1);
						operands(operandstacksize-1) := (others=>'0');				
						operand0source := operand0source_a;
					
					end case;
									
				-- state to perform a jump. the jump address is already fully available.
				when state_jump =>
					tmp12(11 downto 4) := command;			
					tmp12(3 downto 0) := lowaddressbits;
					pc := tmp12+1;
					
					state := state_command;
					command := (others=>'0');    -- command at destination is not yet available, so insert NOP				
					
				-- in this state, it was detected that a load/store instruction needs to be done,
				-- and the complete base address was already available to be combined with an offset			
				when state_loadstore =>
					pc := pc;					  		   -- do not increase program counter to allow time 
																-- for the memory access
					command := ramread;              -- already receive the next instruction (must not be executed now)
	
					state := state_waitloadstore;
						
				-- in this state, the read or write was issued and the next instruction is available.
				-- nevertheless we must not execute it before the data arrives or is stored to avoid
				-- ordering conflicst. 
				-- when data is expected, we already prepare the stack to push the data 
				-- which will then be available
				-- the command that has alreay been retrieved must not be overwritten 
				when state_waitloadstore =>
					if we_prev='1' then		-- it was a write
						operands(1 to operandstacksize-2) := operands(2 to operandstacksize-1);
						operands(operandstacksize-1) := (others=>'0');				
						operand0source := operand0source_a;
					else							-- it was a read
						operands(1 to operandstacksize-1) := operands(0 to operandstacksize-2);
						operand0source := operand0source_ram;
					end if;		
	
					command := command;     -- keep the command that was already read
					pc := pc+1;             -- continue normal execution
					state := state_command;
					
				end case;		
			end if;
		
			-- determine new value for the operand 0 (this also defines the whole ALU)
			if operand0source/=operand0source_keep then
				case operand0source is
					when operand0source_op1 =>
						case parameter is
						when operation1_nop =>		x := b;
						when operation1_inc =>		x := b+1;
						when operation1_dec =>		x := b-1;
						when operation1_neg =>		x := 0-b;
						when operation1_double =>  
							x(7 downto 1) := b(6 downto 0);
							x(0) := '0';
						when operation1_inv =>		x := not b;
						when operation1_not =>	
							if b="00000000" then
								x := "00000001";
							else
								x := "00000000";
							end if;
						when operation1_negate =>	x := unsigned(-signed(b));
						when others => 				x := b;
						end case;
					when operand0source_op2 =>
						case parameter is
						when operation2_a => 			x := a;
						when operation2_add => 			x := a+b;
						when operation2_sub => 			x := a-b;
						when operation2_lsl =>			x := shift_left(a,to_integer(b));
						when operation2_lsr =>        x := shift_right(a,to_integer(b));
						when operation2_asr =>			x := unsigned(shift_right(signed(a), to_integer(b)));
						when operation2_and =>			x := a and b;
						when operation2_or =>         x := a or b;
						when operation2_xor =>			x := a xor b;
						when operation2_eq =>
							if a=b then
								x := "00000001";
							else	
								x := "00000000";
							end if;
						when operation2_lt =>
							if a<b then
								x := "00000001";
							else	
								x := "00000000";
							end if;
						when operation2_gt =>
							if a>b then
								x := "00000001";
							else	
								x := "00000000";
							end if;
						when operation2_lts =>
							if signed(a)<signed(b) then
								x := "00000001";
							else	
								x := "00000000";
							end if;
						when operation2_gts =>
							if signed(a)>signed(b) then
								x := "00000001";
							else	
								x := "00000000";
							end if;
						when operation2_carries =>
							tmp9:=(others=>'0');
							tmp9(7 downto 0) := a;
							tmp9 := tmp9 + b;
							x := "00000000";
							x(0) := tmp9(8);
						when operation2_borrows =>
							tmp9:=(others=>'0');
							tmp9(7 downto 0) := a;
							tmp9 := tmp9 - b;
							x := "00000000";
							x(0) := tmp9(8);
						end case;
					when operand0source_literal =>
							x(7 downto 4) := "0000";
							x(3 downto 0) := parameter;					
					when operand0source_highbits =>
							x(7 downto 4) := parameter;
							x(3 downto 0) := b(3 downto 0);
					when operand0source_n =>
							x := n;
					when operand0source_a | operand0source_keep =>
							x := a;				
					when operand0source_readbuffer =>
							x := (others=>'0');  -- TODO
					when operand0source_ram =>
							x:= ramread;	
				end case;
				operands(0) := x;		
			end if;
					
			-- write prepared values to registers
			outsending := outsending_next;
				
		end if;	-- rising_edge
		
	
		-- static logic to create pin values from internal state
		-- ram access
		case state is
		when state_jump =>
			tmp12(11 downto 4) := command;
			tmp12(3 downto 0) := lowaddressbits;
			ramaddress <= tmp12;
		when state_loadstore =>
			tmp12(11 downto 4) := command + addressoffset;
			tmp12(3 downto 0) := lowaddressbits; 
			ramaddress <= tmp12;
		when others =>
			ramaddress <= pc;
		end case;
		ramwrite <= operands(0);
		ramwe <= we;
		-- port access
		for i in 0 to outports-1 loop
			outdata(8*i+7 downto 8*i) <= outvalue;
			if outsending and i=outtarget then
				outwe(i) <= '1';
			else
				outwe(i) <= '0';
			end if;
		end loop;
		
		inrdy <= (others=>'0');
								
		-- test output
		case state is
			when state_command =>        test_state <= 0;
			when state_jump =>           test_state <= 1;
			when state_loadstore =>      test_state <= 2;
			when state_waitloadstore =>  test_state <= 3;
		end case;
		test_pc <= pc;
		test_we <= we;
		test_command <= command;
		test_operand0 <= operands(0);
		test_operand1 <= operands(1);
		test_operand2 <= operands(2);
		test_operand3 <= operands(3);
	end process;
end rtl;




