-- ByteMachine

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.Globals.all;

entity ByteMachine is	
	generic ( outports : integer := 1; inports : integer := 1 );  

	port (
		clk: in std_logic;		
		reset: in std_logic;
		
		-- output ports
		outdata : out bytearray (outports-1 downto 0); 
		outwe : out std_logic_vector (outports-1 downto 0);
		outrdy : in std_logic_vector (outports-1 downto 0);
		indata : in bytearray (inports-1 downto 0);
		inwe : in std_logic_vector (inports-1 downto 0);
		inrdy : out std_logic_vector (inports-1 downto 0);
		
		-- test output
		test_pc    : out twelvebit;
		test_state : out integer range 0 to 7;
		test_command : out byte;	
		test_element0 : out byte;
		test_element1 : out byte
	);
end entity;

architecture rtl of ByteMachine is
	-- components to use
	component InitializedRAM
	port (
		clk: in std_logic;		
		address : in unsigned(11 downto 0);	
		datawrite: in unsigned(7 downto 0);	
		dataread: out unsigned(7 downto 0);	
		we: in std_logic 
	);
	end component;
	component ByteALU
	port (
		operation: in nibble;
		a: in byte;	
		b: in byte;	
		op1: out byte;
		op2: out byte
	);	
	end component;
	component ByteStack
	port (
		clk: in std_logic;				
		stackaddress: in nibble;

		stackoperation: in twobit;
		element0_next: in byte;
		
		element0: out byte;
		element1: out byte;
		elementn: out byte
	);
	end component;	
	component AddressStack
	port (
		clk: in std_logic;				
		
		addressstackenable: in std_logic;
		popaddress: in std_logic;		
		newaddress: in twelvebit;
		
		address0: out twelvebit
	);
	end component;
	
	-- signals to communicate with components
	signal address : unsigned(11 downto 0);	
	signal datawrite: unsigned(7 downto 0);	
	signal dataread: unsigned(7 downto 0);	
	signal we: std_logic;
	
	signal aluoperation : nibble;
	signal alua : byte;
	signal alub : byte;
	signal aluop1 : byte;
	signal aluop2 : byte;
	
	signal stackaddress: nibble;		
	signal stackoperation : twobit;
	signal element0_next : byte;
	signal element0 : byte;
	signal element1 : byte;
	signal elementn : byte;
	
	signal addressstackenable : std_logic;
	signal popaddress : std_logic;
	signal newaddress : twelvebit;
	signal address0 : twelvebit;

	-- internal signals that specify how the registers should change at next clock
	signal pc_next : twelvebit;
	signal state_next : integer range 0 to 6;
	signal retrieve_command : std_logic;
	signal outwait_next : std_logic_vector(outports-1 downto 0);
		
begin		
	-- instantiate components
	RAM : InitializedRAM port map(
		clk => clk,
		address => address,
		datawrite => datawrite,
		dataread => dataread,
		we => we		
	);
	ALU : ByteALU port map(
		operation => aluoperation,
		a => alua,	
		b => alub,
		op1 => aluop1,
		op2 => aluop2
	);
	Stack : ByteStack port map(
		clk => clk,
		stackaddress => stackaddress,
		stackoperation => stackoperation,
		element0_next => element0_next,
		element0 => element0,
		element1 => element1,
		elementn => elementn
	);
	AStack : AddressStack port map(
		clk => clk,
		addressstackenable => addressstackenable,
		popaddress => popaddress,
		newaddress => newaddress,		
		address0 => address0
	);
	

	-- process to create internal and external signals to drive the whole machine
	-- all variables defined here are temporary and will be completely implemented by logic 
	-- instead of registers
	process (clk,element0,element1,elementn,aluop1,aluop2,dataread,address0)		

		-- various registers of the machine 
		variable pc : twelvebit;
		variable state : integer range 0 to 6;
		variable command : byte;
		variable prevparam : nibble;
		
		-- registers for the ports
		variable outrdy_var : std_logic_vector(outports-1 downto 0);
		variable outwait : std_logic_vector(outports-1 downto 0);
		
		-- temporary variables - will be completely implemented in registerless logic 
		variable opcode: nibble;
		variable parameter: nibble;		
		variable jumptarget: twelvebit;
		variable tmp16 : std_logic_vector(15 downto 0);
	begin				
		-- clocked logic that takes new values into registers
		if rising_edge (clk) then
			pc := pc_next;
			state := state_next;
			if retrieve_command='1' then
				prevparam := command(3 downto 0);
				command := dataread;
			end if;				

			-- latch in data from the ports and internal signals
			outrdy_var := outrdy;
			outwait := outwait_next;
			
			-- low input on reset forces CPU to reset state
			if reset='0' then			
				state := state_reset;
			end if;		
		end if;
		
	
		-- combinational logic to drive all wires and to determine
		-- followup register states 
		
		opcode := command(7 downto 4);
		parameter := command(3 downto 0);
		
		-- alu directly to use element0, element1 and lower nibble from command
		aluoperation <= parameter;  -- independent of opcode, the ALU operation is always found here
		alua <= element1;
		alub <= element0;
		-- more hard-wiring
		stackaddress <= parameter;  -- when using this feature, it can only take this parameter
		datawrite <= element1;      -- for the case of a write, the data will be taken from there
		newaddress <= pc;           -- when pushing addresses, this is the only possible value
		
		-- some default values (will be overwritten depending on the opcode and other circumstances)
		stackoperation <= stackoperation_nop; -- by default no action on the stack
		element0_next <= element0;      -- by default the top stack element stays the same       
		we <= '0';                      -- by default only read from RAM
		retrieve_command <= '1';        -- by default the value from RAM should be retrieved as command
		address <= pc;			           -- by default request the followup command to be read
		addressstackenable <= '0';
		popaddress <= '-';              -- don't care when not using the address stack at all
		outwe <= (others=>'0');
		outwait_next <= (others=>'0');
		for i in outports-1 downto 0 loop
			outdata(i) <= (others=>'0');   
		end loop;
		inrdy <= (others=>'0');
		
		case state is
			when state_reset =>
				state_next <= state_reset2;
				pc_next <= (others=>'0');
				retrieve_command <= '0';
				
			-- state to reliably get the first memory instruction
			when state_reset2 =>
				state_next <= state_waitinstruction;
				pc_next <= pc + 1;		
				retrieve_command <= '0';
				
			-- in this state, the CPU must wait until the command (which was requested in previous step) finally
			-- arrives. can not to much, but must also request the command after the next.
			-- here the PC is 1 byte ahead of the address of the command to be waited for
			when state_waitinstruction =>
				state_next <= state_run;
				pc_next <= pc + 1;			
			
			-- state for normal instruction decoding. depending on command, different actions will be taken.
			-- here the PC is 2 bytes ahead of the current commands address
			when state_run =>
				state_next <= state_run;
				pc_next <= pc+1;     -- increase address counter
				
				case opcode is
					-- ALU operation with 2 operands, but only pop 1 element
					when opcode_op1 => 	
						element0_next <= aluop1;
					-- ALU operation with 2 operands, both are replaced by result				
					when opcode_op2 => 	
						stackoperation <= stackoperation_pop; -- stack will be popped by 1 element
						element0_next <= aluop2;
					-- Push a 4-bit literal on stack
					when opcode_literal =>
						stackoperation <= stackoperation_push;
						element0_next(7 downto 4) <= "0000";
						element0_next(3 downto 0) <= parameter;
					-- Fill in 4 bits into the higher bit of stack element 0						
					when opcode_highbits =>
						element0_next(7 downto 4) <= parameter;
					-- Get stack element <par+1> and put on top of stack
					when opcode_get =>
						stackoperation <= stackoperation_push;
						element0_next <= elementn;
					-- Take element0 from stack and put in position <par+1> in stack		
					when opcode_set =>
						stackoperation <= stackoperation_popandset;
						if parameter="0000" then
							element0_next <= element0;
						else
							element0_next <= element1;
						end if;
					-- use element0 as lower 8-bit and <par> as higher 4 address bit, and 
	            -- overwrite element0 with data from RAM
					when opcode_load =>	
						element0_next <= "--------";  -- don't care. will be overwritten anyway.
						address(11 downto 8) <= command (3 downto 0);
						address(7 downto 0) <= element0;
						pc_next <= pc;
						state_next <= state_waitread;					
					-- use element0 as lower 8-bit and <par> has higher 4 address bit, and store
	            -- element1 into RAM, popping both elements						
					when opcode_store =>
						stackoperation <= stackoperation_pop;
						element0_next <= "--------";  -- don't care. will be overwritten anyway
						address(11 downto 8) <= command (3 downto 0);
						address(7 downto 0) <= element0;
						we <= '1';
						pc_next <= pc;
						state_next <= state_waitwrite;

					when opcode_read =>
					when opcode_write =>
						tmp16 := (others=>'1');
						tmp16(outports-1 downto 0) := outrdy_var and not outwait;
						if tmp16(to_integer(parameter))='1' then
							for i in 0 to outports-1 loop
								if i=to_integer(parameter) then
									outwe (i) <= '1';
									outwait_next(i) <= '1';
									outdata(i) <= element0;								 
								end if;
							end loop;
							stackoperation <= stackoperation_pop;
							element0_next <= element1;							
						else
							pc_next <= pc;
							address <= pc-1;
							retrieve_command <= '0';
							state_next <= state_run;
						end if;
						
					-- use <par> has higher 4 bit, and the next command byte as lower 8 bit
	            -- of address and jump 
					when opcode_jmp =>
							address <= (others=>'-');    -- do not know yet what address is needed - don't care what to request
							state_next <= state_waitjumptarget;

					-- pop element0 and do a jump (address resolution like jmp) if zero 
					when opcode_jz => 			
						if element0 = 0 then	             -- jump taken
							-- remove operand from stack
							stackoperation <= stackoperation_pop;
							element0_next <= element1;
							
							address <= (others=>'-');    -- do not know yet what address is needed - don't care what to request
							state_next <= state_waitjumptarget;
						else                              -- jump not taken							
							-- remove operand from stack
							stackoperation <= stackoperation_pop;
							element0_next <= element1;
							-- skip next byte of instruction
							state_next <= state_waitinstruction;
						end if;
						
					-- pop element0 and do a jump (address resolution like jmp) if not zero 
					when opcode_jnz => 					
						element0_next <= element1;
						if element0 /= 0 then	             -- jump taken
							-- remove operand from stack
							stackoperation <= stackoperation_pop;
							element0_next <= element1;

							address <= (others=>'-');    -- do not know yet what address is needed - don't care what to request
							state_next <= state_waitjumptarget;
						else                              -- jump not taken							
							-- remove operand from stack
							stackoperation <= stackoperation_pop;
							element0_next <= element1;
							-- skip next byte of instruction
							state_next <= state_waitinstruction;
						end if;
							
					-- use <par> has higher 4 bit, and the next command byte as lower 8 bit
	            -- of address and jump, storing the return address on the address stack
					when opcode_jsr =>
							addressstackenable <= '1';
							popaddress <= '0';         -- do a push of the return address
							
							address <= (others=>'-');    -- do not know yet what address is needed - don't care what to request
							state_next <= state_waitjumptarget;
			
					-- take the return address from the address stack
					when opcode_ret =>
							addressstackenable <= '1';
							popaddress <= '1';         -- do a pop of the address stack
							address <= address0;       -- initiate command fetch
							pc_next <= address0+1;
							state_next <= state_waitinstruction;  -- must insert wait to retrieve the command
			
					when others =>
					
				end case;
			
			-- in this state, the read was issued and the next instruction is available.
			-- nevertheless we must not execute it before the data arrives to avoid
			-- ordering conflicst. 
			-- because data will arrive before end of this state, we already prepare the
			-- stack to push the data which will be availabe on its data2 source
			-- in this state, the PC is 2 bytes ahead of the command that caused the wait
			when state_waitread =>
				element0_next <= dataread;
				retrieve_command <= '0';  -- must not destroy command, it will be executed in next step
				pc_next <= pc + 1;
				state_next <= state_run;						
				
			-- in this state, the write was issued, and the next instruction is already
			-- available. but to keep the prefetch buffer filled, we must isue a new 
			-- instruction read before executing this next instruction.
			-- this also gives us the time to pop the second operand of the write instructions
			-- off the stack
			-- in this state, the PC is 2 bytes ahead of the command that caused the wait
			when state_waitwrite =>
				stackoperation <= stackoperation_pop;
				element0_next <= element1;
				retrieve_command <= '0';  -- must not destroy command, it will be executed in next step				
				pc_next <= pc + 1;
				state_next <= state_run;						
							
			when state_waitjumptarget =>
				jumptarget(11 downto 8) := prevparam;
				jumptarget(7 downto 0) := command;
					
				address <= jumptarget;
				pc_next <= jumptarget + 1;
				state_next <= state_waitinstruction;
			
		end case;
		
		
		-- test output#
		test_pc <= pc;
		test_state <= state;
		test_command <= command;
		test_element0 <= element0;
		test_element1 <= element1;
	end process;
end rtl;




