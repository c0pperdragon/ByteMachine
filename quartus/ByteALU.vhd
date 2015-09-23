-- Byt7eALU
-- Building block for the stack machine that performs the logic 
-- and arithmetic operations.
-- This entity is not clocked, but changes its output at every
-- change of the input values.

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity ByteALU is	
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
end entity;

architecture immediate of ByteALU is
begin		
	process (operation,bselector,a,b0,b1,b2,b3)				
	variable r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,rA,rB,rC,rD,rE : unsigned(7 downto 0);
	begin						
		-- compute all possible intermediate results, before selecting the correct one
		case bselector is          -- use selected B
		when "00" => r0 := b0;
		when "01" => r0 := b1;
		when "10" => r0 := b2;
		when "11" => r0 := b3;
		end case;							
		r1 := a;                   -- use A
      r2 := a + b0;                                                        -- ADD
      r3 := a - b0;													                  -- SUB
      r4 := shift_left(a,to_integer(b0(2 downto 0)));                      -- LSL
      r5 := shift_right(a,to_integer(b0(2 downto 0)));                     -- LSR
      r6 := unsigned(shift_right(signed(a), to_integer(b0(2 downto 0))));  -- ASR
		r7 := a AND b0;                                                      -- AND
      r8 := a OR b0;                                                       -- OR
      r9 := a XOR b0;                                                      -- XOR
      if a<b0 then                                                         -- LT
			rA := "00000001";
		else	
			rA := "00000000";
		end if;
      if a>b0 then                                                         -- GT
			rB := "00000001";
		else	
			rB := "00000000";
		end if;
      rC := b0 + 1;                                                        -- INC
      rD := b0 - 1;							                                    -- DEC
		rE := "00000000";	                                                   -- unused
		
		-- select outputs according to operation 
		case operation is
		when "0000" =>	x0<=r0; x1<=r0;       			  					  
		when "0001" => x0<=r1; x1<=r1;
      when "0010" => x0<=r2; x1<=r2;
      when "0011" => x0<=r3; x1<=r3;
      when "0100" => x0<=r4; x1<=r4;
      when "0101" => x0<=r5; x1<=r5;
      when "0110" => x0<=r6; x1<=r6;
      when "0111" => x0<=r7; x1<=r7;
      when "1000" => x0<=r8; x1<=r8;
      when "1001" => x0<=r9; x1<=r9;
      when "1010" => x0<=rA; x1<=rA;
      when "1011" => x0<=rB; x1<=rB;
      when "1100" => x0<=rC; x1<=rC;
      when "1101" => x0<=rD; x1<=rD;
      when "1110" => x0<=rE; x1<=rE;
		when "1111" => x0<=a; x1<=b0;   -- special operation that delivers a to x0 and b0 to x1.
		end case;
		
		
		
	end process;
end immediate;




