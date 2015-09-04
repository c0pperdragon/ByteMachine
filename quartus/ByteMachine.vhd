-- ByteMachine

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.Globals.all;

entity ByteMachine is	
	port (
		clk: in std_logic;		
		-- interface to RAM
		address : out unsigned(11 downto 0);	
		datawrite: out unsigned(7 downto 0);	
		dataread: in unsigned(7 downto 0);	
		we: out std_logic;
		
		-- test output
		test_pc    : out unsigned(11 downto 0);	
		test_state : out integer;
		test_command : out unsigned(7 downto 0);	 
		test_element0 : out unsigned(7 downto 0);
		test_element1 : out unsigned(7 downto 0)
	);
end entity;

architecture rtl of ByteMachine is
	-- components to use
	component ByteALU
	port (
		operation: in integer range 0 to 15;		
		a: in unsigned(7 downto 0);	
		b: in unsigned(7 downto 0);	
		x: out unsigned(7 downto 0)
	);
	end component;
	component ByteStack
	port (
		clk: in std_logic;		
		stackoperation: in integer range 0 to 3;	
		stackaddress: in integer range 0 to 15;		
		datasource : in integer range 0 to 3;
		data1: in unsigned(7 downto 0);	
		data2: in unsigned(7 downto 0);	
		data3: in unsigned(7 downto 0);			
		element0: out unsigned(7 downto 0);
		element1: out unsigned(7 downto 0)
	);
	end component;	
		
	-- signals to communicate with components
	signal aluoperation : integer range 0 to 15;
	signal alua : unsigned(7 downto 0);
	signal alub : unsigned(7 downto 0);
	signal alux : unsigned(7 downto 0);
	
	signal stackoperation : integer range 0 to 3;	
	signal stackaddress: integer range 0 to 15;		
	signal datasource : integer range 0 to 3;		
	signal data1 : unsigned(7 downto 0);	
	signal data2 : unsigned(7 downto 0);	
	signal data3 : unsigned(7 downto 0);	
	signal element0 : unsigned(7 downto 0);
	signal element1 : unsigned(7 downto 0);

	-- signals to get the state of the clocked process
	signal pc : unsigned (11 downto 0);
	signal state : integer range 0 to 5;
	signal command : unsigned (7 downto 0);
	
	-- signals to put data into the clocked process
	signal pc_next : unsigned (11 downto 0);
	signal state_next : integer range 0 to 5;
	signal retrieve_command : boolean;
		
begin		
	-- instantiate components
	ALU : ByteALU port map(
		operation => aluoperation,
		a => alua,	
		b => alub,
		x => alux 
	);
	Stack : ByteStack port map(
		clk => clk,
		stackoperation => stackoperation,
		stackaddress => stackaddress,
		datasource => datasource,
		data1 => data1,	
		data2 => data2,      
		data3 => data3,    
		element0 => element0,
		element1 => element1
	);
		
	-- clocked process that holds the current state of the machine
	process (clk)
		variable var_pc : unsigned (11 downto 0) := (others=>'0');
		variable var_state : integer range 0 to 5 := state_reset;
		variable var_command : unsigned (7 downto 0) := (others=>'0');
	begin
		if rising_edge(clk) then	
			var_pc := pc_next;
			var_state := state_next;
			if retrieve_command then
				var_command := dataread;
			end if;		
		end if;
		pc <= var_pc;
		state <= var_state;
		command <= var_command;
	end process;


	process (pc,state,command,alux,element0,element1,dataread)				
	-- combinational process to create internal and external signals to drive the whole machine
	-- all variables defined here are temporary and will be completely implemented by logic 
	-- instead of registers
		variable opcode: integer range 0 to 15;		
		variable parameter: integer range 0 to 15;		
	begin					
		opcode := to_integer(command(7 downto 4));
		parameter := to_integer(command(3 downto 0));
		
		-- wire stack with alu and data input directly
		aluoperation <= parameter;  -- independent of opcode, the ALU operation is always found here
		alua <= element1;
		alub <= element0;
		data1 <= alux;
		data2 <= dataread;
		stackaddress <= parameter;  -- whenever the stack uses the address, it can only be taken from here
		
		-- some default values (will be overwritten depending on the opcode and other circumstances)
		stackoperation <= stackoperation_nop;  
		datasource <= datasource_none;
		data3 <= "00000000";			
		address <= pc+2;		-- normally use RAM access to fetch the command 2 bytes further
		datawrite <= "00000000";
		we <= '0';
		pc_next <= pc+1;
		state_next <= state_run;
		retrieve_command <= true;
		
		case state is
			when state_reset =>
				address <= (others=>'0');
				state_next <= state_reset2;
				pc_next <= (others=>'0');
				retrieve_command <= false;

			when state_reset2 =>
				address <= (others=>'0');
				state_next <= state_waitinstruction;
				pc_next <= (others=>'0');
				retrieve_command <= false;
				
			when state_waitinstruction =>
				address <= pc+1;
				state_next <= state_run;
				pc_next <= pc;
				
			when state_run =>
				case opcode is
					-- ALU operation with 2 operands, but only pop 1 element
					when opcode_op1 => 	
						datasource <= datasource_data1;
					-- ALU operation with 2 operands, both are replaced by result				
					when opcode_op2 => 	
						datasource <= datasource_data1;
						stackoperation <= stackoperation_pop;   -- stack will be popped by 1 element
					-- Push a 4-bit literal on stack
					when opcode_literal =>
						stackoperation <= stackoperation_push;  -- make space for new data
						datasource <= datasource_data3;
						data3(3 downto 0) <= command(3 downto 0);
					-- Fill in 4 bits into the higher bit of stack element 0						
					when opcode_highbits =>
						stackoperation <= stackoperation_nop;   -- stack will not push/pop
						datasource <= datasource_data3;
						data3(7 downto 4) <= command(3 downto 0);
						data3(3 downto 0) <= element0(3 downto 0);
					-- Get stack element <par> and put on top of stack
					when opcode_get =>
						stackoperation <= stackoperation_push;
					-- Take element0 from stack in put in position <par> in stack		
					when opcode_put =>
						stackoperation <= stackoperation_popandset;
					-- use element0 as lower 8-bit and <par> as higher 4 bit, and 
	            -- overwrite element0 with data from RAM
					when opcode_load =>	
						stackoperation <= stackoperation_pop;
						address(11 downto 8) <= command (3 downto 0);
						address(7 downto 0) <= element0;
						state_next <= state_waitread;					
					-- use element1 as lower 8-bit and <par> has higher 4 bit, and store
	            -- element0 into RAM, popping both elements						
					when opcode_store =>
						stackoperation <= stackoperation_pop;
						address(11 downto 8) <= command (3 downto 0);
						address(7 downto 0) <= element1;
						datawrite <= element0;
						we <= '1';
						state_next <= state_waitwrite;

					-- pop element0 and branch forward if it is zero
					when opcode_bz_fwd =>
						stackoperation <= stackoperation_pop;
						if element0=0 then
							address <= pc + parameter;
							pc_next <= pc + parameter;
							state_next <= state_waitinstruction;
							retrieve_command <= false;							
						end if;
					-- pop element0 and branch backward if it is zero
					when opcode_bz_bwd =>
						stackoperation <= stackoperation_pop;
						if element0=0 then
							address <= pc - parameter;
							pc_next <= pc - parameter;
							state_next <= state_waitinstruction;
							retrieve_command <= false;							
						end if;					
					-- pop element0 and branch forward if it is not zero
					when opcode_nbz_fwd =>
						stackoperation <= stackoperation_pop;
						if element0/=0 then
							address <= pc + parameter;
							pc_next <= pc + parameter;
							state_next <= state_waitinstruction;
							retrieve_command <= false;							
						end if;					
					-- pop element0 and branch backward if it is not zero
					when opcode_nbz_bwd =>
						stackoperation <= stackoperation_pop;
						if element0/=0 then
							address <= pc - parameter;
							pc_next <= pc - parameter;
							state_next <= state_waitinstruction;
							retrieve_command <= false;							
						end if;										
						
					when others =>
					
				end case;
			
			-- in this state, the read was issued and the next instruction is available.
			-- nevertheless we must not execute it before the data arrives to avoid
			-- ordering conflicst. 
			-- because data will arrive before end of this state, we already prepare the
			-- stack to push the data which will be availabe on its data2 source
			when state_waitread =>
				stackoperation <= stackoperation_push;
				datasource <= datasource_data2;
				retrieve_command <= false;  -- it is not a command, that will arrive
				pc_next <= pc;
				
			-- in this state, the write was issued, and the next instruction is already
			-- available. but to keep the prefetch buffer filled, we must usue a new 
			-- instruction read before executing next instruction.
			-- this also gives us the time to pop the second operand of the write instructions
			-- off the stack
			when state_waitwrite =>
				stackoperation <= stackoperation_pop;
				address <= pc+1;			    -- prepare to get next command
				retrieve_command <= false;  -- at next clock, no command will arrive
				pc_next <= pc;
				
			when others =>
		end case;
		
		-- test output#
		test_pc <= pc;
		test_state <= state;
		test_command <= command;
		test_element0 <= element0;
		test_element1 <= element1;
	end process;
end rtl;




