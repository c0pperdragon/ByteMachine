# The Byte Machine - Specification

The CPU fetches instructions from a dedicated read-only instruction memory with an address
width of 16 bit and data width of 8 bit (65536 instructions maximum) and operate 
on a read-write memory 65536 bytes (M).
The instruction set is optimized to allow for every instruction to fit into one
byte and to be executed in one clock. To achieve this, the instructions are quite low-level
and sometimes multiple instructions need to work together to achieve anything meaningful.
To make programming a bit easier, the assembler offers some higher-level instructions
that compile down to multiple machine instructions and are easier to read.

## Registers

The CPU contains the following registers:
    A (8 bit):  
        Data register to receive the result of computations and provide first parameter.
        Can be transfered from/to memory with dedicated operations.
    B (8 bit):  
        Data register to provide second parameter for computations. Can be transfered
        to/from memory with dedicated operations. Can also be easily loaded with direct values.
    PAGE (8 bit):               
        Auxilary register to provide the higher 8 bit for a 16 bit address (together with the
        8 bits from the B register)
    SP (8 bit):
        Pointer to the start of a 16-byte long sliding memory window (a.k.a stack frame)
		that can be directly accessed.
		This register can not be read, but only modified by incrementing/decrementing.
    PC (16 bit):
        Address of the next instruction to be fetched.
    IR (8 bit):
        Instruction register. The content for this register will always be fetched
        from M[PC] in each clock cycle to be used in the next clock cycle.
		
Upon power-up or reset, all registers are initialized to 0, so execution will always start
at program address 0, with the stack frame located at ram address 0. Note, that the very first
instruction that is then executed is in fact the 00 instruction to which the IS was initialized to.
This is a no-operation, so no harm is done ;-)
		
## Instruction set

The general type of the instructions is defined by the higher 4 bits of the instruction byte, and
the lower 4 bits specify a parameter:

    0x  OP x
        ALU-Operation: Use the content of the A and B register and
        compute a result according to the operation x (see section ALU below).
        The result is stored in A.
        A = alu(x, A, B)

    1x  CONST x
        Use x as an unsigned 4-bit value and store this into the B register.            
        B = x
		
	2x  EXT x
        Uses x as high 4 bits which are then stored into the 4 high bits of the B register.
        This instruction will often be used in conjunction with CONST to bring a full 
        byte to the B register.
        B = (B&0x0f) | (x<<4)   
                              
    3x  GET x
        Fetch a value from a location in the current stack frame and put it into A.
        A = M[SP+x]
            
    4x  SET x
        Write the value of A into a location in the current stack frame.
        M[SP+x] = A

	5x  GETB x
        Fetch a value from a location in the current stack frame and put it into B.
        B = M[SP+x]
            
    6x  SETB x
        Write the value of B into a location in the current stack frame.
        M[SP+x] = B
		
    7x  PUSH
        Increment SP by the value of x+1. This will slide the current stack frame forward
		by up to 16 bytes.
		SP = SP + x + 1

	8x  POP
        Decrement SP by the value of x+1. This will slide the current stack frame backward
		by up to 16 bytes.
		SP = SP - x - 1
		
	9x  ADDRESS
		Copy content of B into PAGE register and fetch a stack frame location
		into B.
		PAGE = B
		B = M[SP+x]
	
	Ax  LOAD
		Use the value of B together with PAGE to form a 16-bit memory address.
		Then add x to that address and read the memory value from there an store in A.
		A = M[PAGE*256 + B + x]
		
	Bx 	STORE
		Use the value of B together with PAGE to form a 16-bit memory address.
		Then add x to that address and store the value of A to this address.
		M[PAGE*256 + B + x] = A
	
	Cx  IN 
		Read the pins of input port x and store in A
		A = INPORT{x]
		
	Dx OUT
		Set the output pins of port x to the value of A
		
	Ex JUMP
		Do the alu operation x on A and B, and if the result is not 0, do an 
		absolute jump. The target address is the combination of B and PAGE. 
		if (alu(x, A, B) != 0) { PC = PAGE*256 + B }
		
	Fx RJMP
		Do the alu operation x on A and B, and if the result is not 0, do a 
		relative jump. The target address is computed by adding a sign-extended
		value of B to PC. 
		if (alu(x, A, B) != 0) { PC += (B<<8)>>>8) }

		
## ALU operations
        
A set of operations (o) are supported that take two 8-bit operands (A,B) and produce an
8-bit result. These are mainly arithmetic or logic operations or just a 
direct selection of one of the input operands.

    0    A           result = A                          
	1    B           result = B
		 
    2    ADD         result = A + B                      addition modulo 256 
    3    SUB         result = A - B                      subtraction modulo 256
    4    XSUB        result = B - A                      subtraction modulo 256
	
    5    AND         result = A & B                      bitwise and
    6    OR          result = A | B                      bitwise or 
    7    XOR         result = A ^ B                      bitwise x-or
    8    SHL         result = (A << 1) | (B >> 7)        shift left, take new bit from second operand
    9    SHR         result = (A >> 1) | (B << 7)        shift right, take new bit from second operand

    10   LT          result = 1 when A<B , 0 otherwise
    11   GT          result = 1 when A>B , 0 otherwise
	12   EQ          result = 1 when A=B , 0 otherwise
	13   ZERO        result = 1 when A=0 , 0 otherwise
	
	