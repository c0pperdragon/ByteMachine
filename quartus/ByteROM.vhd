
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE ieee.math_real.log2;
USE ieee.math_real.ceil;
use work.ByteMachine_pkg.all;

ENTITY ByteROM IS
	generic ( 
		 code : bytemachinecode
	);
	PORT
	(
		clock		: IN STD_LOGIC  := '1';
		address		: IN unsigned (15 DOWNTO 0);
		q		    : OUT unsigned (7 DOWNTO 0)
	);
END ByteROM;

ARCHITECTURE SYN OF ByteROM IS		

	constant addressbits: integer := INTEGER(CEIL(LOG2(REAL(code'length))));
	type memory_t is array (0 to (2**addressbits)-1) of std_logic_vector (7 downto 0);
     
	function init_rom return memory_t is 
		variable tmp : memory_t := (others => (others => '0'));
	begin 
		for k in 0 to code'length-1 loop 
			tmp(k) := std_logic_vector(to_unsigned(code(k),8));
		end loop;
		return tmp;
	end init_rom;
     
	signal memory: memory_t := init_rom;
   
BEGIN
	process (clock)
	variable a:integer range 0 to 2**addressbits-1;
	begin
		if rising_edge(clock) then
			a := to_integer(address) mod (2**addressbits);
			q <= unsigned(memory(a));
		end if;
	end process;
END SYN;
