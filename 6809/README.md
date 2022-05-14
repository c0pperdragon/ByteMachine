# MC6809P (or HD63x09P)

The 6809 is a great 8-Bit CPU from Motorola and it were used in many 8-bit computers of the 80th (Tandy, Dragon, Thomson ...).
Genuine old parts may probably be difficult to get, but luckily there is a object code compatible CPU from Hitachi still in production: HD6309P.

There are two kind of CPU, the P and the EP type. The P CPU is easier to use with ByteMachine, cause it can generate it's clock internally 
from a simple clock signal. This external clock has to be 4 times in frequenzy as the CPU clock (6809P divide clock by 4).
The 6309 is available for 3 different speedgrades: 6309 (1MHz), 63B09 (2MHz), 63C09 (3MHz)

It is relatively simple to wire up this chip to the ByteMachine. You basically need one additional 74HC00 chip (quad NAND). In my tests, this
setup is able to run at 12Mhz (3MHz CPU - 63C09) without any issue.

The schematic diagram (6809board.pdf) is designed to directly show the breadboard layout. The connections of some bus lines
are only shown by their designators to avoid too much clutter in the diagram.

![alt text](br6809pcb.jpg "Dedicated PCB build")

## Control signal generation

The 6809 provides a different set of control lines to access the memory than the main board expects. It basically just generates a single
R/W signal which tells the rest of the system if the current CPU cycle is meant to read from memory or write to it.
The main board on the other hand expects explicit RD and WR pulses for each access and does not care itself for the CPU clock
(it generates the clock, but does not use it itself in any way). To produce the correct WR and RD pulses, the CPU board
needs 3 NAND-gates to join together the clock E and the R/W line to create the necessary pulses.


## Memory map

The 64K address space which the 6809 can access using its 16 address lines are translated to the address spaces of the ByteMachine in the following way:

| CPU address| type | mem address  |
| ---------- | ---- | ------------ |
| 0000..7FFF | RAM  | 58000..5FFFF |
| 8000..FFFF | ROM  | 58000..5FFFF |

I intentionally use just this portion of the ROM so other areas can be used for different CPU boards without the
need to overwrite this area.

## More possibilities

With additional 74-series logic it is surely possible to implement some kind of bank switching scheme to access a larger area 
of the ByteMachine's total address space. This is open to experiment by anyone who wants to try.





