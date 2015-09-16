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
		-- simple wishbone master interface
		adr_o: out unsigned(3 downto 0);
		ack_i: in std_logic;
		dat_o: out unsigned(7 downto 0);
		dat_i: in unsigned(7 downto 0);
		we_o: out std_logic;
		cyc_o: out std_logic;
		stb_o: out std_logic;
		
		-- test output
		test_state : out integer;
		test_pc    : out unsigned(11 downto 0);
		test_command : out unsigned(7 downto 0);	
		test_operand0 : out unsigned(7 downto 0);
		test_operand1 : out unsigned(7 downto 0);
		test_operand2 : out unsigned(7 downto 0);
		test_operand3 : out unsigned(7 downto 0)
	);

	-- opcodes for the instructions
	constant opcode_op1       : unsigned(3 downto 0) := "0000";  -- $0 operation with 1 operand, replace operand 0 with result
	constant opcode_op2       : unsigned(3 downto 0) := "0001";  -- $1 operation with 2 operands, both are replaced by result
	constant opcode_literal   : unsigned(3 downto 0) := "0010";  -- $2 Push a 4-bit literal onto the stack
	constant opcode_highbits  : unsigned(3 downto 0) := "0011";  -- $3 Fill in 4 bits into the higher bit of operand 0
	constant opcode_get       : unsigned(3 downto 0) := "0100";  -- $4 Get operand <par> and put on top of stack
	constant opcode_set       : unsigned(3 downto 0) := "0101";  -- $5 Take operand 0 from stack in put in position <par> in stack
	constant opcode_read      : unsigned(3 downto 0) := "0110";  -- $6
	constant opcode_write     : unsigned(3 downto 0) := "0111";  -- $7	
	constant opcode_load      : unsigned(3 downto 0) := "1000";  -- &8
	constant opcode_store     : unsigned(3 downto 0) := "1001";  -- $9
	constant opcode_loadx     : unsigned(3 downto 0) := "1010";  -- &A
	constant opcode_storex    : unsigned(3 downto 0) := "1011";  -- $B
	constant opcode_jmp       : unsigned(3 downto 0) := "1100";  -- $C use <par> has lower 4 bit, and the next command byte as higher 8 bit
																 --    of address and jump 
	constant opcode_jz        : unsigned(3 downto 0) := "1101";  -- $D pop element0 and do a jump (address resolution like jmp) if zero 
	constant opcode_jnz       : unsigned(3 downto 0) := "1110";  -- $E pop element0 and do a jump (address resolution like jmp) if not zero
	constant opcode_jsr       : unsigned(3 downto 0) := "1111";  -- $F perform a jump, and push the return address on the return stack
		
end entity;

architecture rtl of ByteMachine is

	component ByteALU
	port (
		operation: in unsigned (3 downto 0);
		a: in unsigned (7 downto 0);	
		b: in unsigned (7 downto 0);	
		op1: out unsigned(7 downto 0);
		op2: out unsigned(7 downto 0)
	);
	end component;		
	signal aluoperation: unsigned (3 downto 0);	
	signal alua, alub, aluop1, aluop2 : unsigned (7 downto 0);	

begin		
	ALU: ByteALU port map (aluoperation, alua,alub,aluop1,aluop2);
	
	process (clk)		
	
		-- machine states
		type state_t is (state_command, state_jump, state_load, state_store, 
							state_waitload, state_waitstore, state_write, state_read);
	
		-- various registers of the machine 
		variable state : state_t := state_command;
		variable pc : unsigned(11 downto 0) := (others=>'0');
		variable command : unsigned(7 downto 0) := (others=>'0');
		
		variable lowaddressbits : unsigned(3 downto 0) := (others=>'0');
		variable addressoffset : unsigned(4 downto 0);
		
		-- operand stack and address stack
		type operands_t is  array(0 to operandstacksize-1) of unsigned(7 downto 0);
		variable operands : operands_t;
		type addresses_t is  array(0 to addressstacksize-1) of unsigned(11 downto 0);
		variable addresses : addresses_t;
						
		-- temporary variables - will be completely implemented in logic only
		variable tmp9 : unsigned (8 downto 0);
		variable tmp12 : unsigned (11 downto 0);
		variable tmp16 : unsigned(15 downto 0);
		variable parameter : unsigned(3 downto 0);	
		variable operand0,operand1,operandn : unsigned(7 downto 0);
	begin			
	
		if rising_edge (clk) then
						
			-- decode current command
			parameter := command(3 downto 0);				
						
			-- memorize the topmost operands and the operand selected by parameter 
			-- (for the possiblity it will be used)
			operand0 := operands(0);
			operand1 := operands(1);
			operandn := operands(to_integer(parameter));
									
			-- a reset forces program to start from begin
			if reset='1' then
				pc := (others=>'0');
				command := (others=>'0');
				state := state_command;
			else			
				-- main state machine of the processor
				case state is
				
				-- state for instruction decoding and execution - some instructions need additional states
				when state_command =>
												
					-- command processing
					case command(7 downto 4) is
					
					-- operations with a single operand
					when opcode_op1 => 	
						operands(0) := aluop1;
						
						-- because there was no free opcode, the RET instruction is squeezed into this place
						if parameter="1111" then
							-- pop return address off the address stack
							pc := addresses(0);			
							addresses(0 to addressstacksize-2) := addresses(1 to addressstacksize-1);
							addresses(addressstacksize-1) := (others=>'0');
							command := (others=>'0');  -- insert a NOP into the command stream 
						else
							command := ramread;
							pc := pc+1;
						end if;
						
					-- operations with two operands
					when opcode_op2 => 	
						operands(1 to operandstacksize-2) := operands(2 to operandstacksize-1);
						operands(operandstacksize-1) := (others=>'0');
						operands(0) := aluop2;
						command := ramread;
						pc := pc+1;
	
					-- Push a 4-bit literal on stack
					when opcode_literal =>
						operands(1 to operandstacksize-1) := operands(0 to operandstacksize-2);
						operands(0) := "0000" & parameter;					
						command := ramread;
						pc := pc+1;
					
					-- Overwrite the higher 4 bits of operand 0
					when opcode_highbits =>
						operands(0) := parameter & operand0(3 downto 0);
						command := ramread;
						pc := pc+1;
						
					-- Get stack element <par> and put on top of stack
					when opcode_get =>
						operands(1 to operandstacksize-1) := operands(0 to operandstacksize-2);				
						operands(0) := operandn;
						command := ramread;
						pc := pc+1;
					
					-- Take element0 from stack and put in position 'parameter' in stack		
					when opcode_set =>
						if parameter/="0000" then
							operands(0) := operand1;				
						end if;
						for i in 1 to operandstacksize-1 loop
							if i=to_integer(parameter) then
								operands(i) := operand0;
							elsif i<operandstacksize-1 then
								operands(i) := operands(i+1);
							else
								operands(i) := (others=>'0');
							end if;
						end loop;
						command := ramread;
						pc := pc+1;
					
					-- receive a byte from a <parameter> slave address on the wishbone bus.
					-- this command blocks until received data and ack from slave
					-- and then the data will be pushed on the stack
					when opcode_read =>
						lowaddressbits := parameter;
						state := state_read;
						command := ramread;     
						pc := pc;              -- do not increase PC, because the command after the next must be re-requested
						
					-- write operand 0 to the <parameter> slave address on the wishbone bus.
					-- this command blocks until received an ack from the slave and then
					-- the operand will be popped of the stack
					when opcode_write =>					
						lowaddressbits := parameter;
						state := state_write;
						command := ramread;     
						pc := pc;              -- do not increase PC, because the command after the next must be re-requested
						
					when opcode_jmp =>
						lowaddressbits := parameter;
						state := state_jump;
						command := ramread;
				
					when opcode_jz =>
						operands(1 to operandstacksize-2) := operands(2 to operandstacksize-1);
						operands(operandstacksize-1) := (others=>'0');				
						operands(0) := operand1;				
						
						if operand0=0 then
							lowaddressbits := parameter;
							state := state_jump;
							command := ramread;
						else
							command := (others=>'0');  -- inject a NOP into the command stream to skip address part
							pc := pc+1;
						end if;
	
					when opcode_jnz =>
						operands(1 to operandstacksize-2) := operands(2 to operandstacksize-1);
						operands(operandstacksize-1) := (others=>'0');				
						operands(0) := operand1;				
						
						if operand0/=0 then
							lowaddressbits := parameter;
							state := state_jump;
							command := ramread;
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
						command := ramread;
					
					-- load byte from absolute address. this operation is implemented by the same
					-- means as loading with index, so an offset 0 is prepared
					when opcode_load =>
						lowaddressbits := parameter;
						addressoffset := (others=>'0');
						state := state_load;
						command := ramread;
						pc := pc+1;
						
					-- write byte to absolute address. this operation is implemented by the same
					-- means as storing with index, so an offset 0 is prepared
					when opcode_store =>
						lowaddressbits := parameter;
						addressoffset := (others=>'0');
						state := state_store;
						command := ramread;
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
						state := state_load;
						command := ramread;
						pc := pc+1;
	
						operands(1 to operandstacksize-2) := operands(2 to operandstacksize-1);
						operands(operandstacksize-1) := (others=>'0');				
						operands(0) := operand1;				
	
					
					-- write byte to address + operand0. until the second part of the address arrives,
					-- the lower 4 bits of the address can be combined with operand 0 to
					-- get the lower 4 bit of the total address. 
					-- the other 8 bits can only be computed later, using the 5-bit addressoffset
					when opcode_storex =>
						tmp9(8) := '0';
						tmp9(7 downto 0) := operands(0);
						tmp9 := tmp9 + parameter;					
						lowaddressbits := tmp9(3 downto 0);
						addressoffset := tmp9(8 downto 4);
						state := state_store;
						command := ramread;
						pc := pc+1;
	
						operands(1 to operandstacksize-2) := operands(2 to operandstacksize-1);
						operands(operandstacksize-1) := (others=>'0');				
						operands(0) := operand1;				
					
					end case;
									
				-- state to perform a jump. the jump address is already fully available.
				when state_jump =>
					tmp12(11 downto 4) := command;			
					tmp12(3 downto 0) := lowaddressbits;
					pc := tmp12+1;
					
					state := state_command;
					command := (others=>'0');    -- command at destination is not yet available, so insert NOP				
					
				-- in this state, it was detected that a load instruction needs to be done,
				-- and the complete base address is now already available to be combined with an offset			
				when state_load =>
					pc := pc;					  		   -- do not increase program counter to allow time 
																-- for the memory access
					command := ramread;              -- already receive the next instruction (must not be executed now)
	
					state := state_waitload;

				-- in this state, it was detected that a store instruction needs to be done,
				-- and the complete base address was already available to be combined with an offset			
				when state_store =>
					pc := pc;					  		   -- do not increase program counter to allow time 
																-- for the memory access
					command := ramread;              -- already receive the next instruction (must not be executed now)
	
					state := state_waitstore;
						
				-- in this state, the read or write was issued and the next instruction is available.
				-- nevertheless we must not execute it before the data arrives or is stored to avoid
				-- ordering conflicst. 
				-- when data is expected, we already prepare the stack to push the data 
				-- which will then be available
				-- the command that has alreay been retrieved must not be overwritten 
				when state_waitload =>
					operands(1 to operandstacksize-1) := operands(0 to operandstacksize-2);
					operands(0) := ramread;	
	
					command := command;     -- keep the command that was already read
					pc := pc+1;             -- continue normal execution
					state := state_command;
					
				when state_waitstore =>
					operands(1 to operandstacksize-2) := operands(2 to operandstacksize-1);
					operands(operandstacksize-1) := (others=>'0');				
					operands(0) := operand1;				
	
					command := command;     -- keep the command that was already read
					pc := pc+1;             -- continue normal execution
					state := state_command;
					
					
				when state_read =>			
					-- when ack from slave arives, push data and continue operation
					if ack_i='1' then				
						operands(1 to operandstacksize-1) := operands(0 to operandstacksize-2);
						operands(0) := dat_i;

						command := command;    -- keep the command previously read  
						pc := pc+1;            -- continue with PC
						state := state_command;
					end if;

				when state_write =>			
					-- when ack from slave arives, pop data and continue operation
					if ack_i='1' then				
						operands(1 to operandstacksize-2) := operands(2 to operandstacksize-1);
						operands(operandstacksize-1) := (others=>'0');				
						operands(0) := operand1;									
		
						command := command;    -- keep the command previously read  
						pc := pc+1;            -- continue with PC
						state := state_command;
					end if;
					
				end case;		
			end if;
				
		end if;	-- rising_edge
		
	
		-- static logic to create pin values from internal state
		-- ram access
		case state is
		when state_jump =>
			tmp12(11 downto 4) := command;
			tmp12(3 downto 0) := lowaddressbits;
			ramaddress <= tmp12;
			ramwe <= '0';
		when state_load =>
			tmp12(11 downto 4) := command + addressoffset;
			tmp12(3 downto 0) := lowaddressbits; 
			ramaddress <= tmp12;
			ramwe <= '0';
		when state_store =>
			tmp12(11 downto 4) := command + addressoffset;
			tmp12(3 downto 0) := lowaddressbits; 
			ramaddress <= tmp12;
			ramwe <= '1';
		when others =>
			ramaddress <= pc;
			ramwe <= '0';
		end case;
		ramwrite <= operands(0);
		-- feed the alu with current data to have results at next clock
		aluoperation <= command(3 downto 0);
		alua <= operands(1);
		alub <= operands(0);
		-- wishbone interface
		case state is
		when state_read =>
			adr_o <= lowaddressbits;
			dat_o <= (others => '0');
			we_o <= '0';
			cyc_o <= '1';
			stb_o <= '1';
		when state_write =>
			adr_o <= lowaddressbits;
			dat_o <= operands(0);
			we_o <= '1';
			cyc_o <= '1';
			stb_o <= '1';
		when others =>
			adr_o <= (others => '0');
			dat_o <= (others => '0');
			we_o <= '0';
			cyc_o <= '0';
			stb_o <= '0';
		end case;
								
		-- test output
		case state is
			when state_command =>        test_state <= 0;
			when state_jump =>           test_state <= 1;
			when state_load =>           test_state <= 2;
			when state_store =>          test_state <= 3;
			when state_waitload =>       test_state <= 4;
			when state_waitstore =>      test_state <= 5;
			when state_read =>           test_state <= 6;
			when state_write =>          test_state <= 7;
		end case;
		test_pc <= pc;
		test_command <= command;
		test_operand0 <= operands(0);
		test_operand1 <= operands(1);
		test_operand2 <= operands(2);
		test_operand3 <= operands(3);
	end process;
end rtl;




