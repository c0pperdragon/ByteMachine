# The Byte CPU - Specification

This CPU is designed to work with the ByteMachine main board. 
It uses a unified memory space of 64KByte for code and data. In this respect it works
very similar to a 6502 or Z80 processor. 

The instruction set of the CPU is quite simple to keep the implemetation small,
as it is mainly done with 7400 logic chips (with one FLASH memory IC to build the ALU).
All instruction execute in two clocks (instruction fetch & execution stage). 

Arithmetic operations are 8-bit only without carry flag and all operands are always
threated as unsigned. Multiplication works modulo 256 as expected.
Results of divisions are always rounded down. Division by 0 is just defined to give 0 always.


## Registers

The CPU contains the following registers:
    A,B,C,D (8 bit each):  
        Multi-purpose data registers. In the instruction format, the registers are encoded with
        two bits each (A=00,B=01,C=10,D=11)
    DP (8 bit): 
        Data page register. All read and write accesses to the RAM are done with
        one of the data registers holding the lower 8 bits of the memory address. The higher
        8 bits are always taken from DP.
    PC (16 bit):
        Address of the next instruction to be fetched.
    IR (8 bit):
        Instruction register. The content for this register will always be fetched
        from the memory location at PC in the instruction fetch stage.

Upon power-up or reset, the PC is initialized to 0, so execution starts at this address.
Note that the content of the data registes and the DP is unspecified. The program needs to
initialize these registers before use.


## Instruction set

The general type of the instructions is defined by the higher 4 bits of the instruction byte, and
the lower 4 bits may specify parameters. So there are 16 possible instructions. Some instructions
have an additonal byte as immediate operand.
Digits denoted with R are reserved and should be set to 0 for upward compatibility.

    0000yyxx             MOVE xx yy
        Copy content of register yy to register xx.
        e.g. COPY A D   ; copy content of D into A 

    0001yyxx             ST xx yy
        Transfer content of register yy to the memory location pointed to by register xx. The high 8 bits
        of the address are taken from DP.

    0010yyxx             LD xx yy
        Load the data from the memory location pointed to by register xx and copy it into yy.
        Due to a limitation of the CPU datapath design it is currently only poossible to use the same
        register for xx and yy. Future designs may remove this restriction.

    0011RRxx immediate   SET xx immediate
        Two-byte instruction. Take the byte after the opcode and store in register xx.

    0100yyRR             DP yy
        Transfer content of register yy into the data page register.

    0101RRxx immediate   JMP xx immediate 
        Jump to the location specified by the immediate operand (low bits) and the register xx
        (high 8 bits)

    0110yyxx             RET xx yy
        Jump to the location given by registers yy (low bits) and xx (high bits). This instruction
        will mainly be used to return from a subroutine.

    0111ccxx immediate   BNZ/BR/BZ (xx) target 
        Various flavours of branch instructions. These have an immedate operand that specifies the 
        low 8 bits of the address to be jumped to if the specified condition is met. The high
        8 bits of the program counter will not change when branching. So basically it is not possible
        to cross page boundaries with branches. In case of "branch not taken", the program counter progresses
        normally even across page boundaries. 
        Condition cc:
        00   BNZ  branch if register xx is not zero
        01   BR   branch always         
        10   BZ   branch if register xx is zero
        11        reserved - do not use   

     1000yyxx            ADD xx yy
        Add register yy to register xx.
     
     1001yyxx            SUB xx yy
        Subtract register yy from register xx.
        
     1010yyxx            MUL xx yy
        Multiply registers xx and yy and store in xx.
        
     1011yyxx            DIV xx yy
        Divide xx by yy and store in xx.
   
     1100yyxx            AND xx yy
        Bitwise AND of xx and yy. store in xx.
   
     1101yyxx            OR xx yy
        Bitwise OR of xx and yy. store in xx.
   
     1110yyxx            XOR xx yy
        Bitwise XOR of xx and yy. store in xx.
   
     1111yyxx            CMP xx yy
        Compare xx and yy and if xx contains a higher value, store 1 in xx. Otherwise store 0.
   
   