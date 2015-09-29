-- ByteMachine
--
-- RAM layout: 
--   The ByteMachine has several independen memory areas for different purposes that are all located inside the
--   1024 bytes of the ByteRAM. 
--     address    0 - 511    ("0")  the operand stack (can hold 512 operands)
--     address  512 - 767    ("10") the return address stack (can hold 128 addresses)
--     address  768 - 1023   ("11") ram area    (can be accessed with LOAD/STORE operations)

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
		test_command : out unsigned(7 downto 0);
		test_pc : out unsigned(11 downto 0);
		test_sp : out unsigned(8 downto 0);
		test_accu : out unsigned(7 downto 0);
		test_readaddress : out unsigned(9 downto 0);
		test_readdata : out unsigned(7 downto 0);
		test_writeaddress : out unsigned(9 downto 0);
		test_writedata : out unsigned(7 downto 0)
	);
		
end entity;

architecture rtl of ByteMachine is

	component ByteRAM
	port (
		clk: in std_logic;		
		readaddress : in unsigned(9 downto 0);	
		readdata: out unsigned(7 downto 0);	
		writeaddress : in unsigned(9 downto 0);	
		writedata: in unsigned(7 downto 0);	
		we: in std_logic  );
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
		x:  out unsigned(7 downto 0)
	);	
	end component;	
	
	-- signals to communicate with the components 
	signal readaddress : unsigned(9 downto 0);	
	signal readdata: unsigned(7 downto 0);	
	signal writeaddress : unsigned(9 downto 0);	
	signal writedata: unsigned(7 downto 0);	
	signal aluoperation : unsigned(3 downto 0);	
	signal alubselector : unsigned(1 downto 0);		
	signal alua : unsigned(7 downto 0);	
	signal alub0 : unsigned(7 downto 0);	
	signal alub1 : unsigned(7 downto 0);	
	signal alub2 : unsigned(7 downto 0);	
	signal alub3 : unsigned(7 downto 0);	
	signal alux  : unsigned(7 downto 0);	
	
--	type state_t is (state_reset, state_run, state_loadx, state_skip, state_return, state_load );   -- machine states
	subtype state_t is integer range 0 to 5;
	constant state_reset : state_t := 0;
	constant state_run : state_t := 1;
	constant state_loadx : state_t := 2;
	constant state_skip  : state_t := 3;
	constant state_return : state_t := 4;
	constant state_load : state_t := 5;
	-- current and followup states of the registers
	signal state_current : state_t;
	signal pc_current : unsigned(11 downto 0);
	signal sp_current : unsigned(8 downto 0);
	signal rsp_current : unsigned(6 downto 0);
	signal highbitscache_current : unsigned(3 downto 0);
	signal accu_current : unsigned(7 downto 0);	
	signal state_next : state_t;
	signal pc_next : unsigned(11 downto 0);
	signal sp_next : unsigned(8 downto 0);
	signal rsp_next : unsigned(6 downto 0);
	signal highbitscache_next : unsigned(3 downto 0);
	signal accu_next : unsigned(7 downto 0);
	signal fetchcommand : std_logic;
	signal command : unsigned(7 downto 0);
	signal ack : std_logic;
begin		
	ram: ByteRAM 	port map (clk, readaddress,readdata,writeaddress,writedata,'1');
	alu: ByteALU   port map (aluoperation,alubselector,alua,alub0,alub1,alub2,alub3,alux);
	
	---------------- PROCESS FOR TAKING NEW VALUES INTO REGISTERS -----------
	process (clk)
		-- various registers of the machine 
		variable v_state : state_t := state_reset;
		variable v_pc : unsigned(11 downto 0) := (others=>'0');
		variable v_sp : unsigned(8 downto 0) := (others=>'0');      -- address of operand(1), operand(0) is on sp+1
		variable v_rsp : unsigned(6 downto 0) := (others=>'0');
		variable v_highbitscache : unsigned(3 downto 0) := (others=>'0');
		variable v_accu : unsigned(7 downto 0) := (others=>'0');
		variable v_command : unsigned(7 downto 0) := (others=>'0');
		variable v_ack : std_logic := '0';
	begin
		if rising_edge (clk) then
		  -- reset simply forces a jump to address 0 (aborting any instruction)
			if reset='1' then
				v_state := state_reset;
			else
				v_state := state_next;
				v_pc := pc_next;
				v_sp := sp_next;			
				v_rsp := rsp_next;
				v_accu := accu_next;
				if (fetchcommand='1') then
					v_command := romdata;   -- read command from rom
				end if;
			end if;
			v_highbitscache := highbitscache_next;
			v_ack := ack_i;         -- sample ack signal from wishbone interface
		end if;
		
		state_current <= v_state;
		pc_current <= v_pc;
		sp_current <= v_sp;
		rsp_current <= v_rsp;
		highbitscache_current <= v_highbitscache;
		accu_current <= v_accu;	
		command <= v_command;
		ack <= v_ack;
	end process;
	
	----------- COMBINATIONAL LOGIC TO DRIVE INTERNAL AND EXTERNAL SIGNALS ----------
	process (state_current,pc_current,sp_current,rsp_current,accu_current,highbitscache_current,command,romdata,readdata,alux,ack)	
		
		-- temporary copies of the processor state - modifications will take effect at next clock
		variable state : state_t;
		variable pc : unsigned(11 downto 0);
		variable sp : unsigned(8 downto 0);      -- address of operand(0) which is also cached in accu
		variable rsp : unsigned(6 downto 0);     -- address of top of return stack
		variable highbitscache : unsigned(3 downto 0);

		-- purely temporary variables
		variable tmp12 : unsigned(11 downto 0);
		variable blocking : std_logic;
	begin			
		-- prepare temporary state variables for modifications
		state := state_current;
		pc := pc_current;	
		sp := sp_current;
		rsp := rsp_current;
		highbitscache := highbitscache_current;
		fetchcommand <= '1';     -- by default take in byte from instruction rom
		blocking := '0';
		
		-- default values for outgoing signals
		adr_o <= (others=>'0');
		dat_o <= (others=>'0');
		we_o <= '0';
		cyc_o <= '0';
		stb_o <= '0';		

		-- configuration for the inputs and outputs of the alu 
		alua <= readdata;
		alub0 <= accu_current;                                
		alub1 <= "0000" & command(3 downto 0);                       -- prepare for the PUSH action
		alub2 <= (accu_current(7 downto 4) OR command(3 downto 0))
	          	& (accu_current(3 downto 0));                       -- prepare for the HIGHBIT action
		alub3 <= romdata;                                            -- prepare for the LOADX
		aluoperation <= "0000";  -- use b0 (accu re-gets its value)
		alubselector <= "00";		
		accu_next <= alux;	-- accu takes its next value always from alu
		
		-- default values for rom and ram access (read address is done later in the code)
		writeaddress <= "0" & sp;      -- write alu output to current stack location
		writedata <= alux;	          -- memory write normally uses data from alu (can be redirected)
		romaddress <= pc;		          -- normally fetching instructions from rom

		-- decision tree depending on state and current instruction
		case state is
		when state_reset =>
			state := state_skip;
			pc := "000000000001";
			sp := (others=>'0');
			rsp := (others=>'0');
			highbitscache := (others=>'0');
			romaddress <= (others=>'0');
			
		when state_run =>
		
			pc := pc + 1;
			
			-- decode command 
			case command(7 downto 4) is
			when "0000" =>       -- 0p  Add high bits
				aluoperation <= "0000"; -- use input b2
				alubselector <= "10";     
			when "0001" =>       -- 1p  >PUSH p 		
				aluoperation <= "0000";  -- use input b1
				alubselector <= "01";     
				sp := sp+1;
				writeaddress <= "0" & sp;				
			when "0010" =>       -- 2o Operations with popping the stack
				aluoperation <= command(3 downto 0);
				sp := sp-1;				
				writeaddress <= "0" & sp;
			when "0011" =>       -- 3o Operations with pushing the stack 
				aluoperation <= command(3 downto 0);
				sp := sp+1;				
				writeaddress <= "0" & sp;
			when "0100" =>			 --  4p  >GET p
				aluoperation <= "0001"; -- use input a
				sp := sp+1;
				writeaddress <= "0" & sp;
			when "0101" =>			 --  5p  <SET p
				aluoperation <= "0001"; 	  -- cause accu to take ram data and ram take previous accu data
				sp := sp-1;
				writedata <= accu_current;
				writeaddress <= "0" & (sp - 1 - command(3 downto 0));      -- where to write accu to
			when "0110" =>				-- 6o >LOAD
				pc := pc_current;   -- stall program to allow time for requesting the data
				fetchcommand <= '0';
				romaddress <= pc-1;
				state := state_load;
			when "0111" =>          -- 7x  <STORE o
				aluoperation <= "0001";	-- pop by one element - accu takes value of operand(1)
				writedata <= accu_current;  -- write previous value of accu to ram
				writeaddress <= "11" & readdata;	-- address is operand(1)			
				sp := sp-1;
			when "1000" =>          -- 8x >READ
				-- not implemented. just doing DUP
				sp := sp + 1;
				writeaddress <= "0" & sp;
			when "1001" =>          --	9x WRITE
				adr_o <= command(3 downto 0);	
				dat_o <= accu_current; 
				we_o <= '1';
				cyc_o <= '1';
				stb_o <= '1';						
				pc := pc_current;   -- stall program
				fetchcommand <= '0';
				romaddress <= pc-1;
				blocking := '1';
				if ack='1' then	 -- until client acknowledges, block operation	
					state := state_skip;
					aluoperation <= "0001";  -- pop by one element
					sp := sp-1;
					writeaddress <= "0" & sp;
				end if;
			when "1010" =>        --  Ammm JUMP			
				pc := command(3 downto 0) & romdata;
				romaddress <= pc;
				pc := pc+1;
				state:=state_skip;	    		  
			when "1011" =>        --  Bmmm JZ
				aluoperation <= "0001"; 	  -- popping - accu get value of operand(1)
				sp := sp-1;				
				writeaddress <= "0" & sp;
				if accu_current="00000000" then				
					pc := command(3 downto 0) & romdata;
					romaddress <= pc;
					pc := pc+1;
				end if;
				state:=state_skip;	    		  
			when "1100" =>        --  Cmmm JNZ
				aluoperation <= "0001"; 	  -- popping - accu get value of operand(1)
				sp := sp-1;				
				writeaddress <= "0" & sp;
				if accu_current/="00000000" then				
					pc := command(3 downto 0) & romdata;
					romaddress <= pc;
					pc := pc+1;
				end if;
				state:=state_skip;	    		  
			when "1101" =>         -- Dm mm JSR
				-- start to write return value to return stack
				rsp := rsp+1;
				writeaddress <= "10" & "0" & rsp;
				writedata <= pc_current (7 downto 0);    -- at first write lower bits
				highbitscache := pc_current(11 downto 8); -- memorize higher 4 bits for later storage				
				pc := command(3 downto 0) & romdata;
				romaddress <= pc;
				pc := pc+1;
				state:=state_skip;  -- this state will store higher address bits
			when "1110" =>         -- Dp RET p
				pc := highbitscache & readdata;  -- combine cached high bits with data previously requested
				romaddress <= pc;        -- continue at return address
				pc := pc+1;              				
				state:=state_return;	    		  
			when "1111" =>         -- Cm mm >LOADX
				tmp12 := command(3 downto 0) & romdata;  -- extract read base address
				romaddress <= tmp12 + accu_current;      -- compute complete rom adress
				pc := pc_current;                        -- stall program counter to allow rom acces
				state:=state_loadx;					
			end case;					
      						
		when state_loadx =>
			pc := pc + 1;			
			aluoperation <= "0000"; -- use input b3 (which receives the rom data)
			alubselector <= "11";     			
			state := state_skip;    -- need extra wait state to fill up instruction pipeline			
			sp := sp+1;                  -- push the stack 
			writeaddress <= "0" & sp;				

		when state_skip =>
			pc := pc + 1;			
			state := state_run;
			-- this state is also used for storing the higher bits of the return address during JSR
			-- in other situations, storing the same data to the same location should not cause trouble
			writeaddress <= "10" & "1" & rsp;-- second part of address
			writedata <= "0000" & highbitscache;
			
		when state_return =>
			pc := pc + 1;			
			state := state_run;
			-- in this state, the previously requested higher bits of the next return address is available.
			-- just memorize for future use
			highbitscache := readdata(3 downto 0);
			rsp := rsp-1;				 -- remove address from address stack                        			
			
		when state_load =>
			pc := pc + 1;			
			state := state_run;		
			aluoperation <= "0001"; 	  -- cause accu to take ram data 
			sp := sp+1;                  -- push the stack 
		end case;
					

		-- snoop at the followup-command to decide at which address the next ram read should be done.			
		-- normally prepare the value operand(1) to be ready in next instruction
		if romdata(7 downto 4) = "0100" then               -- 4p  >GET p    
			if command(7 downto 4) = "0101"       			   --  5p  <SET p
			and romdata(3 downto 0) = command(3 downto 0) 	-- when a >GET follows a <SET of same element, 
			then                                            -- can not fetch directly from there, because of read during write
				readaddress <= "0" & (sp+1);      -- original data is still on this location over stack top
			else
				readaddress <= "0" & (sp-1-romdata(3 downto 0));  -- read from real stack location
			end if;
		elsif romdata(7 downto 4) = "1110" then                   -- Ex RET 
			readaddress <= "10" & "0" & rsp;                       -- (request lower part of return address)
		else 
			readaddress <= "0" & (sp-1);                           -- operand(1)
		end if;
		-- when the state is state_return this will cause a read of the lower bits also
		if state=state_return then    -- Dp RET p
			readaddress <= "10" & "1" & (rsp-1);           -- request higher bits of next return address (prepare for next RET)
		-- when the state is state_load, the ram address is available in accu and can be set as input to ram
		elsif state=state_load then
			readaddress <= "11" & accu_current;            -- when doing LOAD, fetch address from accu
		end if;
		-- when operation blocks, must re-load operand(1) - no matter what is the subsequent command
		if blocking='1' then
			readaddress <= "0" & (sp-1);
		end if;
		
		-- after modifications, set the signals to use the modified values at next clock
		state_next <= state;
		pc_next <= pc;	
		sp_next <= sp;
		rsp_next <= rsp;
		highbitscache_next <= highbitscache;
		
	end process;
	
	
	--------------------- test output --------------------
	process (command,state_current,pc_current,sp_current,accu_current,readaddress,readdata,writeaddress,writedata)
	begin
		case state_current is
			when state_reset =>          test_state <= 0;
			when state_run =>            test_state <= 1;
			when state_skip =>           test_state <= 2;
			when state_loadx =>          test_state <= 3;
			when state_return =>         test_state <= 4;
			when state_load =>           test_state <= 5;
		end case;
		test_command <= command;
		test_pc <= pc_current;
		test_sp <= sp_current;
		test_accu <= accu_current;
		test_readaddress <= readaddress;
		test_readdata <= readdata;
		test_writeaddress <= writeaddress;
		test_writedata <= writedata;	
	end process;
end rtl;




