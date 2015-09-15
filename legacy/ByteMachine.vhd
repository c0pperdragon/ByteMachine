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
		test_state : out integer;
		test_we : out std_logic;
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
	
	-- internal machine states 
	type state_t is (state_command,state_waitjumptarget,state_waitaddress,state_waitloadstore );
	type fetchmode_t is (fetchmode_keep, fetchmode_data, fetchmode_nop );
	
	-- signals to communicate with components
	signal address : unsigned(11 downto 0);	
	signal datawrite: unsigned(7 downto 0);	
	signal dataread: unsigned(7 downto 0);	
	signal weout: std_logic;
	
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
	signal state_next : state_t;
	signal pc_next : twelvebit;
	signal we_next : std_logic;	
	signal fetchmode : fetchmode_t;	
	signal outwait_next : std_logic_vector(outports-1 downto 0);
		
begin		
	-- instantiate components
	RAM : InitializedRAM port map(
		clk => clk,
		address => address,
		datawrite => datawrite,
		dataread => dataread,
		we => weout
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
		variable state : state_t;
		variable pc : twelvebit;
		variable we : std_logic;
		variable we_prev : std_logic;
		variable command : byte;
		variable command_prev : byte;
		
		-- registers for the ports
		variable outrdy_var : std_logic_vector(outports-1 downto 0);
		variable outwait : std_logic_vector(outports-1 downto 0);
		
		-- temporary variable - will be completely implemented in logic only
		variable tmpaddr : twelvebit;
		variable tmp16 : std_logic_vector(15 downto 0);
		variable parameter : nibble;		
		variable element0mux : byte_4;
		variable element0sel : integer range 0 to 3;
		variable addressmux : twelvebit_4;
		variable addresssel : integer range 0 to 3;
	begin				
		-- clocked logic that takes new values into registers
		if rising_edge (clk) then
			-- memorize some previous register values 
			command_prev := command;
			we_prev := we;
			
			-- low input on reset forces CPU to reset state
			if reset='0' then			
				state_next <= state_command;
				pc := (others=>'0');
				we := '0';
			-- set registers to new values
			else
				pc := pc_next;
				state := state_next;
				we := we_next;	
			end if;
			
			if reset/='0' and fetchmode=fetchmode_keep then
				command := command;
			elsif reset/='0' and fetchmode=fetchmode_data then
				command := dataread;
			else	
				command := (others=>'0');
			end if;

			-- latch in data from the ports and internal signals
			outrdy_var := outrdy;
			outwait := outwait_next;						
		end if;
		
		-- immediate logic that is in use all the time between clocks
					
		-- wire alu directly to use element0, element1 and lower nibble from command
		aluoperation <= command(3 downto 0);  -- independent of opcode, the ALU operation is always found here
		alua <= element1;
		alub <= element0;
		-- more hard-wiring
		stackaddress <= command(3 downto 0);  -- when using this feature, it can only take this parameter
		newaddress <= pc;           -- when pushing addresses, this is the only possible value
		weout <= we;		  
		datawrite <= element1;      -- when using ram write, the data is taken from here
		for i in outports-1 downto 0 loop
			outdata(i) <= element0;   -- outputs directly receive element0 (listener only takes when outwe is active)
		end loop;

		-- for the case that an address is encoded in the command, decode it immediately
		tmpaddr(11 downto 8) := command_prev(3 downto 0);
		tmpaddr(7 downto 0) := command;
		
		-- force synthesis to create MUXes for some output values
		element0mux(0) := element0;
		element0mux(1) := dataread;
		element0mux(2) := aluop1;
		element0mux(3) := aluop2;
		element0sel := 0;
		addressmux(0) := pc;
		addressmux(1) := pc-1;
		addressmux(2) := address0;
		addressmux(3) := tmpaddr + element0;
		addresssel := 0;
		
		-- default values (will be overwritten depending on the opcode and other circumstances)
		state_next <= state_command;
		pc_next <= pc+1;
		we_next <= '0';                 -- by default only read from RAM
		fetchmode <= fetchmode_data;    -- by default the value from RAM should be retrieved as command
		stackoperation <= stackoperation_nop; -- by default no action on the stack
		addressstackenable <= '0';      -- by default do nothing with the address stack
		popaddress <= '-';              -- don't care when not using the address stack at all
		outwe <= (others=>'0');         -- by default don't send anything to output ports
		outwait_next <= (others=>'0');  -- clear wait state signals of output ports
		inrdy <= (others=>'0');         -- not using input ports yet
		
		
		-- determine actions depending on state and current command
		case state is
			
			-- state for normal instruction decoding. depending on command, different actions will be taken.
			-- here the PC is 2 bytes ahead of the current command's address
			when state_command =>
				parameter := command(3 downto 0);
				
				case command(7 downto 4) is
					-- ALU operation with 2 operands, but only pop 1 element
					when opcode_op1 => 	
						element0sel := 2;  -- aluop1;
						-- because there was no free opcode, the RET instruction is squeezed into this place
						if parameter=operation1_ret then
							addressstackenable <= '1';
							popaddress <= '1';         -- do a pop of the address stack
							addresssel := 2;   -- address0    -- initiate command fetch
							pc_next <= address0+1;
							fetchmode <= fetchmode_nop;   -- insert a NOP because the already requested command will be discarded
							state_next <= state_command;  -- must insert wait to retrieve the command
						end if;						
					-- ALU operation with 2 operands, both are replaced by result				
					when opcode_op2 => 	
						stackoperation <= stackoperation_pop; -- stack will be popped by 1 element
						element0sel := 3; -- aluop2;
					-- Push a 4-bit literal on stack
					when opcode_literal =>
						stackoperation <= stackoperation_push;
						element0mux(0)(7 downto 4) := "0000";
						element0mux(0)(3 downto 0) := parameter;
					-- Fill in 4 bits into the higher bit of stack element 0						
					when opcode_highbits =>
						element0mux(0)(7 downto 4) := parameter;
					-- Get stack element <par+1> and put on top of stack
					when opcode_get =>
						stackoperation <= stackoperation_push;
--						element0_next <= elementn;
					-- Take element0 from stack and put in position <par+1> in stack		
					when opcode_set =>
						stackoperation <= stackoperation_popandset;
						if parameter/="0000" then
							element0mux(0) := element1;
						end if;
					when opcode_read =>
					-- write element0 to output port. if port is busy, retry with same instruction
					when opcode_write =>
						tmp16 := (others=>'1');
						tmp16(outports-1 downto 0) := outrdy_var and not outwait;
						if tmp16(to_integer(parameter))='1' then
							for i in 0 to outports-1 loop
								if i=to_integer(parameter) then
									outwe (i) <= '1';
									outwait_next(i) <= '1';
								end if;
							end loop;
							stackoperation <= stackoperation_pop;
							element0mux(0) := element1;							
						else
							pc_next <= pc;       -- do not increase program counter
							addresssel := 1; -- pc-1;	-- request the followup command again so the pipeline stays filled
							fetchmode <= fetchmode_keep;	-- will try to execute this command once again
						end if;						
					
					-- load byte from absolute address. this operation is implemented by the same
					-- means as loading with index, so an index 0 is pushed on the stack
					when opcode_load =>
						stackoperation <= stackoperation_push;
						element0mux(0) := (others=>'0');
						state_next <= state_waitaddress;
						we_next <= '0';						
					
					-- write byte to absolute address. this operation is implemented by the same
					-- means as storing with index, so an index 0 is pushed on the stack
					when opcode_store =>
						stackoperation <= stackoperation_push;
						element0mux(0) := (others=>'0');
						state_next <= state_waitaddress;
						we_next <= '1';
				
					-- load byte from address + element0. until the second part of the address arrives,
					-- do nothing much
					when opcode_loadx =>
						state_next <= state_waitaddress;
						we_next <= '0';						
				
					-- write byte to address + element0. until the second part of the address arrives,
					-- do nothing much
					when opcode_storex =>
						state_next <= state_waitaddress;
						we_next <= '1';
															
					-- use <par> as higher 4 bit, and the next command byte as lower 8 bit
	            -- of address and jump 
					when opcode_jmp =>
						state_next <= state_waitjumptarget;						
						
					-- pop element0 and do a jump (address resolution like jmp) if zero 
					when opcode_jz => 			
						-- remove operand from stack
						stackoperation <= stackoperation_pop;
						element0mux(0) := element1;
						-- decide about jump condition
						if element0 = 0 then	             -- jump taken							
							state_next <= state_waitjumptarget;
						else                              -- jump not taken							
							-- skip next byte of instruction
							fetchmode <= fetchmode_nop;
						end if;
						
					-- pop element0 and do a jump (address resolution like jmp) if not zero 
					when opcode_jnz => 					
						-- remove operand from stack
						stackoperation <= stackoperation_pop;
						element0mux(0) := element1;
						-- decide about jump condition						
						if element0 /= 0 then	             -- jump taken
							state_next <= state_waitjumptarget;
						else                              -- jump not taken							
							-- skip next byte of instruction
							fetchmode <= fetchmode_nop;
						end if;
							
					-- use <par> has higher 4 bit, and the next command byte as lower 8 bit
	            -- of address and jump, storing the return address on the address stack
					when opcode_jsr =>
						addressstackenable <= '1';
						popaddress <= '0';            -- push return address onto return address stack
						state_next <= state_waitjumptarget;						
				end case;
			
			-- in this state, the second byte of the jump command was received.
			when state_waitjumptarget =>
				addressmux(0) := tmpaddr;
				pc_next <= tmpaddr + 1;
				fetchmode <= fetchmode_nop;   -- insert a NOP because the already requested command will be discarded
				state_next <= state_command;  -- must insert wait to retrieve the command			
			
			-- in this state, it was detected that a load/store instruction needs to be done,
			-- and complete base address is now available to be combined with an offset
			when state_waitaddress =>
				addresssel := 3; -- tmpadr + element0;    -- access to memory. the type of access was already 
															-- specified in previous state and is now available in we_current
															-- (which is directly linked to the ram pin)				
				stackoperation <= stackoperation_pop;	-- pop off the offset
				element0mux(0) := element1;				
				pc_next <= pc;							-- stop the program counter for one clock to allow time 
				                                 -- for the memory access
				state_next <= state_waitloadstore;
				
			-- in this state, the read or write was issued and the next instruction is available.
			-- nevertheless we must not execute it before the data arrives or is stored to avoid
			-- ordering conflicst. 
			-- when data is expected, we already prepare the stack to push the data 
			-- which will then be available
			-- the command that has alreay been retrieved must not be overwritten 
			when state_waitloadstore =>
				if we_prev='1' then		-- it was a write
					stackoperation <= stackoperation_pop;	-- pop off the written data byte
					element0mux(0) := element1;	
				else							-- it was a read
					stackoperation <= stackoperation_push;
					element0sel := 1; -- dataread;  -- directly transfer expected data into the stack
				end if;				
				
				fetchmode <= fetchmode_keep;	 -- command already recived must not be overwritten 
			
		end case;

		-- select values with MUXes
		element0_next <= element0mux(element0sel);
		address <= addressmux(addresssel);
				
		-- test output
		test_pc <= pc;
		test_command <= command;
		test_we <= we;
		test_element0 <= element0;
		test_element1 <= element1;
		case state is
			when state_command =>        test_state <= 0;
			when state_waitjumptarget => test_state <= 1;
			when state_waitaddress =>    test_state <= 2;
			when state_waitloadstore =>  test_state <= 3;
		end case;
	end process;
end rtl;




