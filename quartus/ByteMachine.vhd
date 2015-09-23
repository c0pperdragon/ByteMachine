-- ByteMachine

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity ByteMachine is	
	port (
		clk: in std_logic;		
		reset: in std_logic;

		-- rom access
		romaddress : out unsigned(11 downto 0);
		romdata: in unsigned(7 downto 0);
		-- simple wishbone master interface
		adr_o: out unsigned(3 downto 0);
		ack_i: in std_logic;
		dat_o: out unsigned(7 downto 0);
		dat_i: in unsigned(7 downto 0);
		we_o: out std_logic;
		cyc_o: out std_logic;
		stb_o: out std_logic;
		
		-- test output
		test_state : out integer range 0 to 7;
		test_pc : out unsigned(11 downto 0);
		test_sp : out unsigned(7 downto 0);
		test_accu : out unsigned(7 downto 0);
		test_readdata : out unsigned(7 downto 0);
		test_command : out unsigned(7 downto 0)
	);
		
end entity;

architecture rtl of ByteMachine is

	component ByteRAM
	generic ( addressbits: integer := 9 );    -- by default hold 512 bytes
	port (
		clk: in std_logic;		
		readaddress : in unsigned(addressbits-1 downto 0);	
		readdata: out unsigned(7 downto 0);	
		writeaddress : in unsigned(addressbits-1 downto 0);	
		writedata: in unsigned(7 downto 0);	
		we: in std_logic 
	);
	end component;		
	component ByteALU is	
	port (
		operation: in unsigned (3 downto 0);
		bselector: in unsigned (1 downto 0);
		a: in unsigned (7 downto 0);	
		b0: in unsigned (7 downto 0);	
		b1: in unsigned (7 downto 0);	
		b2: in unsigned (7 downto 0);	
		b3: in unsigned (7 downto 0);	
		x0: out unsigned(7 downto 0);
		x1: out unsigned(7 downto 0)
	);	
	end component;	
	
	-- signals to communicate with the components 
	signal readaddress : unsigned(8 downto 0);	
	signal readdata: unsigned(7 downto 0);	
	signal writeaddress : unsigned(8 downto 0);	
	signal writedata: unsigned(7 downto 0);	
	signal we: std_logic; 
	signal aluoperation : unsigned(3 downto 0);	
	signal alubselector : unsigned(1 downto 0);		
	signal alua : unsigned(7 downto 0);	
	signal alub0 : unsigned(7 downto 0);	
	signal alub1 : unsigned(7 downto 0);	
	signal alub2 : unsigned(7 downto 0);	
	signal alub3 : unsigned(7 downto 0);	
	signal alux0 : unsigned(7 downto 0);	
	signal alux1 : unsigned(7 downto 0);	
	
	type state_t is (state_run, state_skip, state_loadx, state_loadx2);   -- machine states
	-- current and followup states of the registers
	signal state_current : state_t;
	signal pc_current : unsigned(11 downto 0);
	signal sp_current : unsigned(7 downto 0);
	signal accu_current : unsigned(7 downto 0);	
	signal state_next : state_t;
	signal pc_next : unsigned(11 downto 0);
	signal sp_next : unsigned(7 downto 0);
	signal accu_next : unsigned(7 downto 0);
	signal command : unsigned(7 downto 0);

begin		
	ram: ByteRAM 	port map (clk, readaddress,readdata,writeaddress,writedata,we);
	alu: ByteALU   port map (aluoperation,alubselector,alua,alub0,alub1,alub2,alub3,alux0,alux1);
	
	---------------- PROCESS FOR TAKING NEW VALUES INTO REGISTERS -----------
	process (clk)
		-- various registers of the machine 
		variable v_state : state_t := state_run;
		variable v_pc : unsigned(11 downto 0) := (others=>'0');
		variable v_sp : unsigned(7 downto 0) := (others=>'0');      -- address of operand(1), operand(0) is on sp+1
		variable v_accu : unsigned(7 downto 0) := (others=>'0');
		variable v_command : unsigned(7 downto 0) := (others=>'0');
	begin
		if rising_edge (clk) then
			v_state := state_next;
			v_pc := pc_next;
			v_sp := sp_next;
			v_accu := accu_next;
			v_command := romdata;   -- read command from rom
		end if;
		state_current <= v_state;
		pc_current <= v_pc;
		sp_current <= v_sp;
		accu_current <= v_accu;	
		command <= v_command;
	end process;
	
	----------- COMBINATIONAL LOGIC TO DRIVE INTERNAL AND EXTERNAL SIGNALS ----------
	process (state_current,pc_current,sp_current,accu_current,command,romdata,readdata,alux0,alux1)	
		
		-- temporary copies of the processor state - modifications will take effect at next clock
		variable state : state_t;
		variable pc : unsigned(11 downto 0) := (others=>'0');
		variable sp : unsigned(7 downto 0) := (others=>'0');      -- address of operand(1), operand(0) is on sp+1
	begin			
		-- prepare temporary state variables for modifications
		state := state_current;
		pc := pc_current;	
		sp := sp_current;
		
		-- default values for outgoing signals
		adr_o <= (others=>'0');
		dat_o <= (others=>'0');
		we_o <= '0';
		cyc_o <= '0';
		stb_o <= '0';		

		-- hardwire the inputs and outputs of the alu  (but not the operation selector)
		alua <= readdata;
		alub0 <= accu_current;                                
		alub1 <= "0000" & command(3 downto 0);                       -- prepare for the PUSH action
		alub2 <= (command(3 downto 0)) & (accu_current(3 downto 0)); -- prepare for the HIGHBIT action
		alub3 <= "00000000"; -- unused
		accu_next <= alux0;
		writedata <= alux1;
		
		-- decision tree depending on state and current instruction
		case state is
		when state_run =>
			-- defaults in this state
			romaddress <= pc;		
			pc := pc + 1;
			
			-- decode command 
			case command(7 downto 4) is
			when "0000" =>       -- 0o  Operations without stack movement
				aluoperation <= command(3 downto 0);
				alubselector <= "00";
				writeaddress <= '0' & (sp+1);
				we <= '1';
			when "0001" =>       -- 1o Operations with popping the stack
				aluoperation <= command(3 downto 0);
				alubselector <= "00";
				sp := sp-1;				
				writeaddress <= '0' & (sp+1);
				we <= '1';
			when "0010" =>       -- 2o Operations with pushing the stack 
				aluoperation <= command(3 downto 0);
				alubselector <= "00";
				sp := sp+1;				
				writeaddress <= '0' & (sp+1);
				we <= '1';
			when "0011" =>       -- 3p  >PUSH p 		
				aluoperation <= "0000";  -- use input b1
				alubselector <= "01";     
				sp := sp+1;				
				writeaddress <= '0' & (sp+1);
				we <= '1';
			when "0100" =>        -- 4p  Add high bits
				aluoperation <= "0000"; -- use input b2
				alubselector <= "10";     
				writeaddress <= '0' & (sp+1);
				we <= '1';
			when "0101" =>			 --  5p  >GET p
				aluoperation <= "0001"; -- use input a
				alubselector <= "00";     
				sp := sp+1;
				writeaddress <= '0' & (sp+1);
				we <= '1';
			when "0110" =>			 --  6p  <SET p
				aluoperation <= "1111"; 	  -- cause accu to take ram data and ram take previous accu data
				alubselector <= "00";     
				sp := sp-1;
				writeaddress <= '0' & (sp - command(3 downto 0));      -- where to write accu to
				we <= '1';								
			when "0111" =>			 --  67  SET p
				aluoperation <= "0000"; 	  -- no popping - accu can keep its value, ram will also take this value
				alubselector <= "00";     
				writeaddress <= '0' & (sp - command(3 downto 0));      -- where to write accu to
				we <= '1';								
			when "1000" =>        --  8nmm JUMP
				aluoperation <= "0000"; 	  -- no popping - accu can keep its value
				alubselector <= "00";     
				writeaddress <= (others<='-');
				we <= '0';								
				pc := command(3 downto 0) & romdata;
				romaddress <= pc;
				pc := pc+1;
				state:=state_skip;				
			when "1001" =>        --  9nmm JZ
				aluoperation <= "0001"; 	  -- popping - accu get value of operand(1)
				alubselector <= "00";     
				sp := sp-1;				
				writeaddress <= (others<='-')
				we <= '0';
				if accu_current="00000000" then				
					pc := command(3 downto 0) & romdata;
					romaddress <= pc;
					pc := pc+1;
				end if;
				state:=state_skip;				
			when "1101" =>        --  Anmm JNZ
				aluoperation <= "0001"; 	  -- popping - accu get value of operand(1)
				alubselector <= "00";     
				sp := sp-1;				
				writeaddress <= (others<='-');
				we <= '0';
				if accu_current/="00000000" then				
					pc := command(3 downto 0) & romdata;
					romaddress <= pc;
					pc := pc+1;
				end if;
				state:=state_skip;								
				
				
			when others =>
				aluoperation <= "0000"; 	 
				alubselector <= "00";     
				writeaddress <= (others=>'-');
				we <= '0';
			end case;					
						
		when state_skip =>
			romaddress <= pc;            -- fetch next instruction, but do not execute
			pc := pc + 1;
			
			aluoperation <= "0000"; 	  -- no popping - accu can keep its value, ram will also take this value
			alubselector <= "00";     
			writeaddress <= (others<='-');
			we <= '0';				
			state := state_run;
			
		when others=>
			romaddress <= pc;		

			aluoperation <= "0000"; 	 
			alubselector <= "00";     
			writeaddress <= (others=>'-');
			we <= '-';
		end case;

		
		-- snoop at the followup-command to decide at which address the next ram read should be done.			
		case romdata(7 downto 4) is
			when "0101" =>			 --  5p  >GET p    
				readaddress <= "0" & (sp - 1 - command(3 downto 0));
			when others =>
				-- normally prepare the value operand(1) to be ready in next instruction
				readaddress <= "0" & sp;  
		end case;
		
		-- after modifications, set the signals to use the modified values at next clock
		state_next <= state;
		pc_next <= pc;	
		sp_next <= sp;
	
		--------------------- test output --------------------
		case state_current is
			when state_run =>            test_state <= 0;
			when state_skip =>           test_state <= 1;
			when state_loadx =>          test_state <= 2;
			when state_loadx2 =>         test_state <= 3;
		end case;
		test_pc <= pc_current;
		test_sp <= sp_current;
		test_accu <= accu_current;
		test_readdata <= readdata;
		test_command <= command;
				
	
	end process;
end rtl;




