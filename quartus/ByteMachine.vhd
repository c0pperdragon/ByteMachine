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
		test_state : out integer range 0 to 15;
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
		a: in unsigned (7 downto 0);	
		b: in unsigned (7 downto 0);	
		c: in unsigned (7 downto 0);	
		x0: out unsigned(7 downto 0);
		x1: out unsigned(7 downto 0)
	);	
	end component;	
	
	-- signals to communicate with the components 
	signal readaddress : unsigned(9 downto 0);	
	signal readdata: unsigned(7 downto 0);	
	signal writeaddress : unsigned(9 downto 0);	
	signal writedata: unsigned(7 downto 0);	
	signal aluoperation : unsigned(3 downto 0);	
	signal alua : unsigned(7 downto 0);	
	signal alub : unsigned(7 downto 0);	
	signal aluc : unsigned(7 downto 0);	
	signal alux0  : unsigned(7 downto 0);	
	signal alux1  : unsigned(7 downto 0);	
	
begin		
	ram: ByteRAM 	port map (clk, readaddress,readdata,writeaddress,writedata,'1');
	alu: ByteALU   port map (aluoperation,alua,alub,aluc,alux0,alux1);
	
	
	process (clk,romdata,readaddress,readdata,writeaddress,writedata,alux0,alux1)			
		-- processor state 		
		subtype t_state is integer range 0 to 7;
		constant state_run : integer := 0;
		constant state_skip : integer := 1;
		constant state_load : integer := 2;
		constant state_loadx : integer := 3;
		constant state_jump : integer := 4;
		constant state_jsr  : integer := 5;
		constant state_ret  : integer := 6;
		constant state_write  : integer := 7;
		-- substate - jumpcondition
		subtype t_jumpcondition is integer range 0 to 2;
		constant jumpcondition_always : integer := 0;
		constant jumpcondition_z : integer := 1;
		constant jumpcondition_nz : integer := 2;		
		-- type for alu-input-b selector
		subtype t_selector is integer range 0 to 4;
		constant selector_accu : integer := 0;
		constant selector_highbits : integer := 1;
		constant selector_constant : integer := 2;
		constant selector_pc : integer := 3;
		constant selector_retaddr : integer := 4;
		-- type for alu-operation override
		subtype t_aluoverride is integer range 0 to 4;
		constant aluoverride_a : integer := 0;
		constant aluoverride_b : integer := 1;
		constant aluoverride_crossover : integer := 2;
		constant aluoverride_operation : integer := 3;
		constant aluoverride_romdata : integer := 4;
		-- type for pc modification
		subtype t_pcmod is integer range 0 to 3;
		constant pcmod_stall : integer := 0;
		constant pcmod_increment : integer := 1;
		constant pcmod_jump : integer := 2;
		constant pcmod_return : integer := 3;
		-- type for sp modification
		subtype t_spmod is integer range 0 to 2;
		constant spmod_zero : integer := 0;
		constant spmod_push : integer := 1;
		constant spmod_pop : integer := 2;
		-- type for how write address should be computed
		subtype t_writemode is integer range 0 to 3;
		constant writemode_stacktop : integer := 0;
		constant writemode_ram : integer := 1;
		constant writemode_instack : integer := 2;
		constant writemode_returnstack : integer := 3;
		-- type for how read address should be computed
		subtype t_readmode is integer range 0 to 3;
		constant readmode_stacktop : integer := 0;
		constant readmode_ram : integer := 1;
		constant readmode_instack : integer := 2;
		constant readmode_returnstack : integer := 3;
		-- type for how data from rom should be read
		subtype t_rommode is integer range 0 to 3;
		constant rommode_instruction : integer := 0;
		constant rommode_jumptarget : integer := 1;
		constant rommode_data: integer := 2;
		constant rommode_return : integer := 3;
		
		-- registers maintained by stage 1 
		variable clockedreset : std_logic;                            -- this reset signal stays stable for the whole cycle
		variable state : t_state := state_skip;
		variable jumpcondition : t_jumpcondition := jumpcondition_always;
		variable accu : unsigned(7 downto 0) := (others => '0');
		variable pc : unsigned(11 downto 0) := (others => '0');
		variable sp : unsigned(8 downto 0)  := (others => '0');       -- address of operand(0) which is also cached in accu
		variable rsp : unsigned(7 downto 0) := (others => '0');       -- address of top of return stack
		variable retaddr: unsigned (3 downto 0) := (others => '0');   -- highest bits of latest return address
		variable reloadretaddr : std_logic := '0';                    -- flag that means, the retaddr must now be taken from ram 
		
		-- switches to control the datapath during stage 2 (are set by stage 1)
		variable x_selector : t_selector := selector_accu;
		variable x_parameter : unsigned(3 downto 0);
		variable x_writemode : t_writemode := writemode_stacktop;
		variable x_aluoverride : t_aluoverride := aluoverride_b;
		variable x_accufetches : std_logic := '0';
		
		-- variables for wishbone communication
		variable ack : std_logic := '0';
		
		-- purely temporary variables
		variable parameter : unsigned(3 downto 0);
		variable newstate : t_state;
		variable newjumpcondition : t_jumpcondition;
		variable pcmod : t_pcmod;
		variable spmod : t_spmod;
		variable newsp : unsigned(8 downto 0);
		variable rspmod : t_spmod;	-- same modification type as stack pointer
		variable selector : t_selector;
		variable writemode : t_writemode;
		variable aluoverride : t_aluoverride;
		variable accufetches : std_logic;
		variable readmode : t_readmode;
		variable rommode : t_rommode;
		variable retaddr_takefrompc : std_logic;
		variable retaddr_takefromram : std_logic;
		variable sendingtowishbone : std_logic;
		variable tmp12 : unsigned(11 downto 0);
	begin			

		-- clocking in signals from outside
		if rising_edge(clk) then
			ack := ack_i;
			clockedreset := reset;
		end if;
	
		---------------------------------------------------------------------------
		-- instruction pipeline stage 2: computation and storing result
		-- (this is done mainly by preparing the internal and external components)
		writedata <= alux0;
		case x_writemode is
		when writemode_stacktop    => writeaddress <= "0" & (sp-1);
		when writemode_ram         => writeaddress <= "11" & (readdata + x_parameter);
		when writemode_instack     => writeaddress <= "0" & (sp + x_parameter);
		when writemode_returnstack => writeaddress <= "10" & rsp;
		end case;
		alua <= readdata;		
		alub <= accu;
		aluc <= romdata;
		case x_aluoverride is
			when aluoverride_b =>         aluoperation <= "0000";
			when aluoverride_a =>         aluoperation <= "0001";
			when aluoverride_crossover => aluoperation <= "1111";
			when aluoverride_romdata =>   aluoperation <= "1110";
			when aluoverride_operation => aluoperation <= x_parameter; 
		end case;
		case x_selector is
			when selector_accu         =>       
			when selector_constant     => alub <= "0000" & x_parameter;
			when selector_highbits     => alub <= (x_parameter or accu(7 downto 4)) & accu(3 downto 0); 
			when selector_pc           => alub <= pc(7 downto 0);
			when selector_retaddr      => alub <= "0000" & retaddr(3 downto 0);
		end case;
				
		if rising_edge(clk) and x_accufetches='1' then
			accu := alux1;		-- take new accu from alu output 1
		end if;
			
		
		---------------------------------------------------------------------------------------
		-- instruction pipeline stage 1: decode instructions and adjust PC,SP,RPS to new values		
		-- default values for internal triggers
		parameter := romdata(3 downto 0);
		newstate := state;
		pcmod := pcmod_increment;
		spmod := spmod_zero;
		rspmod := spmod_zero;
		selector := selector_accu;
		writemode := writemode_stacktop;
		aluoverride := aluoverride_b;
		accufetches := '1';
		readmode := readmode_stacktop;
		rommode := rommode_instruction;
		retaddr_takefrompc := '0';
		retaddr_takefromram := '0';
		sendingtowishbone := '0';
		newjumpcondition := jumpcondition_always;		
		
		-------------------- decode new instruction -------------------
		case state is
		when state_skip =>
			newstate := state_run;
			
		when state_load =>
			readmode := readmode_ram;
			aluoverride := aluoverride_a;
			spmod := spmod_push;
			newstate := state_run;

		when state_loadx =>
			aluoverride := aluoverride_romdata;
			writemode := writemode_stacktop;
			spmod := spmod_push;
			pcmod := pcmod_stall;
			rommode := rommode_data;
			newstate := state_skip;				
			
		when state_jump =>
			if jumpcondition=jumpcondition_always 
			 or (jumpcondition=jumpcondition_z and accu="00000000")
			 or (jumpcondition=jumpcondition_nz and accu/="00000000")  
			then			 
				pcmod := pcmod_jump;
				rommode := rommode_jumptarget;
			end if;
			newstate := state_run;			
			if jumpcondition/=jumpcondition_always then
				aluoverride := aluoverride_a;
				spmod := spmod_pop;
			end if;
			
		when state_jsr =>
			-- write lower bits of return address through the ALU to the RAM
			retaddr_takefrompc := '1';         -- memorize the highest bits of the current position of the PC			
			selector := selector_retaddr;      -- pipe high bits of return address through the ALU to the RAM
			accufetches := '0';                -- do not take this value into the accu
			writemode := writemode_returnstack;
			pcmod := pcmod_jump;
			rommode := rommode_jumptarget;
			rspmod := spmod_push;
			newstate := state_run;

		when state_ret =>	
			retaddr_takefromram := '1';
			readmode := readmode_returnstack;
			rspmod := spmod_pop;
			pcmod := pcmod_return;
			rommode := rommode_return;
			newstate := state_run;
									
		when state_write =>
			if ack='1' then
				spmod := spmod_pop;				-- popping the stack
				aluoverride := aluoverride_a;
				newstate := state_run;
			else
				pcmod := pcmod_stall;
				sendingtowishbone := '1';
			end if;				
						
		when state_run =>
			case romdata(7 downto 4) is
			when "0000" =>             -- 0p  Add high bits
				selector := selector_highbits;
			when "0001" =>             -- 1p  >PUSH p 		
				selector := selector_constant;
				spmod := spmod_push;
			when "0010" =>       -- 2o Operations with popping the stack
				aluoverride := aluoverride_operation;
				spmod := spmod_pop;
			when "0011" =>       -- 3o Operations with pushing the stack 
				aluoverride := aluoverride_operation;
				spmod := spmod_push;
			when "0100" =>			 --  4p  >GET p				
				readmode := readmode_instack;
				aluoverride := aluoverride_a;
				spmod := spmod_push;
			when "0101" =>			 --  5p  <SET p
				aluoverride := aluoverride_crossover; 	  -- cause accu to take ram data and ram take previous accu data
				spmod := spmod_pop;
				writemode := writemode_instack;
			when "0110" =>				-- 6o >LOAD
				newstate := state_load; -- insert waitstate for data fetch (address is not available yet)
				pcmod := pcmod_stall;
			when "0111" =>          -- 7x  <STORE o
				aluoverride := aluoverride_crossover;	   -- cause accu to take ram data and ram take previous accu data
				writemode := writemode_ram;	-- address is current operand(1)			
				spmod := spmod_pop;
			when "1000" =>          -- 8x >READ
				-- not implemented. just doing DUP
				spmod := spmod_push;
			when "1001" =>          --	9x WRITE
				newstate := state_write;
				pcmod := pcmod_stall;
			when "1010" =>          -- Am mm JMP
				newjumpcondition := jumpcondition_always;
				newstate := state_jump;			
			when "1011" =>          -- Bm mm <JZ
				newjumpcondition := jumpcondition_z;
				newstate := state_jump;			
			when "1100" =>          -- Cm mm <JNZ
				newjumpcondition := jumpcondition_nz;
				newstate := state_jump;			
			when "1101" =>          -- Dm mm JSR				
				selector := selector_pc;          -- pipe low bits of return address through the ALU to the RAM
				accufetches := '0';               -- do not take this value into the accu
				writemode := writemode_returnstack;		
				rspmod := spmod_push;
				newstate := state_jsr;
			when "1110" =>				-- Ex RET 
				readmode := readmode_returnstack;
				rspmod := spmod_pop;
				newstate := state_ret;			
			when "1111" =>           -- Fm mm >LOADX
				newstate := state_loadx;										
			end case;									
		end case;

		-- calculate the read address according to the given triggers 
		case readmode is 
		when readmode_ram =>			  readaddress <= "11" & (accu + x_parameter);
		when readmode_stacktop => 	  readaddress <= "0" & sp;
		when readmode_instack =>	  
			-- detect that a "read during write" collision would happen in the stack.
			-- fetch still available data from top of stack instead.
			if x_writemode = writemode_instack and parameter = x_parameter then
				readaddress <= "0" & (sp-2);
			else
				readaddress <= "0" & (sp+parameter);
			end if;
		when readmode_returnstack => readaddress <= "10" & (rsp+1);
		end case;

		-- calculate the rom address according to the given triggers
		case rommode is
		when rommode_instruction =>	romaddress <= pc;
		when rommode_jumptarget  =>   romaddress <= x_parameter & romdata;
		when rommode_data        =>   romaddress <= (x_parameter & romdata) + accu;
		when rommode_return      =>   romaddress <= retaddr & readdata;
		end case;

		-- controll the wishbone interface
		adr_o <= parameter;	
		dat_o <= accu; 
		we_o <= sendingtowishbone;
		cyc_o <= sendingtowishbone;
		stb_o <= sendingtowishbone;
		
		-- at the end of the stage, adjust internal registers and set up the instructions for the next stage
		if rising_edge(clk) then
			if retaddr_takefrompc = '1' then
				retaddr := pc (11 downto 8);
			elsif reloadretaddr='1' then 
				retaddr := readdata(3 downto 0);
			end if;			
			reloadretaddr := retaddr_takefromram;
			
			if pcmod/=pcmod_stall or clockedreset='1'	then			
				case pcmod is
				when pcmod_stall      =>     tmp12 := pc;  -- can only happen in case of reset
				when pcmod_increment =>		  tmp12 := pc;  
				when pcmod_jump =>           tmp12 := x_parameter & romdata; 
				when pcmod_return =>         tmp12 := retaddr & readdata;  
				end case;	
				if clockedreset='1' then
					tmp12 := to_unsigned(-1,12);
				end if;
				pc := tmp12+1;
			end if;
			case spmod is
			when spmod_push =>	sp := sp -1;
			when spmod_pop =>   sp := sp +1;
			when spmod_zero =>
			end case;
			case rspmod is
			when spmod_push =>	rsp := rsp -1;
			when spmod_pop =>   rsp := rsp +1;
			when spmod_zero =>
			end case;
			state := newstate;			
			jumpcondition := newjumpcondition;
			
			x_selector := selector;
			x_aluoverride := aluoverride;
			x_accufetches := accufetches;
			x_parameter := parameter;
			x_writemode := writemode;
			
			if clockedreset='1' then
				state := state_skip;
			end if;
		end if;
				
		
		--------------------- test output --------------------
		test_state <= state;
		test_command <= romdata;
		test_pc <= pc;
		test_sp <= sp;
		test_accu <= accu;
		test_readaddress <= readaddress;
		test_readdata <= readdata;
		test_writeaddress <= writeaddress;
		test_writedata <= writedata;	
	end process;
end rtl;




