# The Byte CPU - Specification

This CPU is designed to work with the ByteMachine main board. 
It uses a unified memory space of 64KByte for code and data. In this respect it works
very similar to a 6502 or Z80 processor. 

The instruction set of the CPU is quite simple to keep the implemetation small,
as it is mainly done with 7400 logic chips (with one FLASH memory IC to build the ALU).
All instruction execute in one or two clocks. 

Arithmetic operations are 8-bit only without carry flag and all operands are always
treated as unsigned. Multiplication works modulo 256 as expected.
Results of divisions are always rounded down. Division by 0 is just defined to give 0 always.


## Registers

The CPU contains the following registers:
    R0, R1, R2, R3 (8 bits each):  
        General purpose registers. In the instruction format, the registers are encoded with
        two bits each
    DP (8 bit): 
        Data page register. All read and write accesses to the RAM are done with
        one of the data registers holding the lower 8 bits of the memory address. The higher
        8 bits are always taken from DP.
    PC (16 bit):
        Address of the next instruction to be fetched.
    IR (8 bit):
        Instruction register. The content for this register will always be fetched
        from the memory location at PC in the instruction fetch stage. It is not explicitely
        accessible by the program.

Upon power-up or reset, the PC is initialized to 0, so execution starts at this address.
Note that the content of the data registes and the DP is unspecified. The program needs to
initialize these registers before use.
There is intentionally no register copy instruction. You can easily emulate one by combining
an AND and an OR. 

## Instruction set

The general type of the instructions is defined by the higher 4 bits of the instruction byte, and
the lower 4 bits may specify parameters. So there are 16 possible instructions. Some instructions
have an additonal byte as immediate operand.
Digits denoted with R are reserved and should be set to 0 for upward compatibility.

    0000yyxx             ST xx yy
        Transfer content of register xx to the memory location pointed to by register yy. The high 8 bits
        of the address are taken from DP.

    0001yyxx             LD xx yy
        Load the data from the memory location pointed to by register yy and copy it into xx.

    0010RRxx immediate   SET xx immediate
        Two-byte instruction. Take the byte after the opcode and store in register xx.

    0011yyRR             DP yy
        Transfer content of register yy into the data page register.

    0100yyxx             JMP xx yy 
        Jump to the location specified by the register xx (low bits) and the register yy
        (high bits)

    0111yyxx immediate   BGE xx yy target 
        Branch if register xx is greater or equal to register yy.
        This instruction has an immediate operand that specifies the 
        low 8 bits of the address to be jumped to if the specified condition is met. The high
        8 bits of the program counter will not change when branching. So basically it is not possible
        to cross page boundaries with branches. In case of "branch not taken", the program counter
        progresses normally even across page boundaries. 
        By choosing the right registers, this instruction can also be used as BLE, as well to branch
        always, when using the same register twice.

     1000yyxx            ADD xx yy
        Add register yy to register xx, store in xx.
     
     1001yyxx            SUB xx yy
        Subtract register yy from register xx, store in xx.
        
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
   
     1111yyxx            LT xx yy
        Compare xx and yy and if xx contains a lower value, store 1 in xx. Otherwise store 0.
   
   