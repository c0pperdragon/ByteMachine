# ByteCPU

Implementation of my own 8-bit CPU in 7400 series logic to work together with the ByteMachine main board.

* [Specification](specification.md)
* [Schematics](cpuboard/cpuboard.pdf)

## Architecture overview

To keep things simple, I decided to make a RISC architecture with 4 general purpose registers.
Instruction opcodes could then be 8 bits long, with 16 different operations and two register addresses
(2 bits each). The target register of the ALU operations would be the same as the first source register.

Instructions work two phases: Opcode fetch, execution. Instructions which do access the memory
in their execution stage will take the full 2 clock cycles. Instructions that work on internal
registers alone and also do not mess with the instruction pointer
can interleave their execution stage with the fetch stage of the next instruction
to make the effective execution time one cycle only.


## Register file

This building block is the largest part of the design and contains 4 8-bit registers and their 
addressing logic. It has one 8-bit data input port (port C) and two 8-bit output ports (A and B).
Each port has an asosiated register address input (2 bits each).
At every cycle, the value on port C may be stored into the register specified by the C address.
And the outputs A and B will always show the value of the registers specified by the A and B
addresses (asynchronously). 
Specifically this random access addressing of the outputs makes the register file a relatively large build
in 7400 logic. Nevertheless it is a very powerfull building block that simplifies everything else 
greatly.

## ALU

The main component of the ALU is a fully tabulated operation matrix implemented in flash memory.
For all combinations of 2 8-bit inputs (A and B) and a 3-bit operator selector, the 8-bit C outputs are 
directly visible (after some propagation delay of course). 
Gating data from and to the general data bus is also implemented in this module: 
1. Selected by  a control signal (SELALU#) the ALU does provide the content of the data bus to its C output
instead of the computation result. 
2. When selected by OEA#, the A-input is forwarded to the data bus (otherwise this gate is tri-stated).

## Addressing

This module drives the address output lines.
The output can be switched between the program counter (PC) and the combination of the data page 
register (DP) with the B data line. This switch is asynchronous.
The program counter itself works synchronously with the clock input and can perform 5 distinct operations
on each clock, selected by control inputs:
1. idle
2. count
3. set to a 16-bit value (provided on B data line and the data bus)
4. set lower 8 bits only (provided on the data bus)
5. reset to 0
Independently to the PC operation, the DP register can be set to the value of the B-data line.

## Control logic

This module contains the 8-bit instruction register (IR) and an internal state register to handle 
the transition between fetch and execution stage. All control signals to coordinate the other
modules are generated here, as well as the WR and RD signals to control the access to the 
external memory. Because the signal generation is not too complex (and to avoid flash memory access delays),
it is implemented directly in 7400 logic.


