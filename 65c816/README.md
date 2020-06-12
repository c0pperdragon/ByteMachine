# 65c02

The 6502 is one of the best known 8-bit processors as various variants if it were used in many 8-bit computers of the 80th.
Apple, Commodore, Atari, Acorn and many other manufacturers used this CPUs to drive their products.
Genuine old parts may probably be difficult to get, but luckily there is a not-so-modern variant that is still in production: WD65c02.

It is relatively simple to wire up this chip to the ByteMachine. You basically need one additional 74HC00 chip (quad NAND). In my tests, this 
setup is able to run at 16Mhz without any issue. Even 20Mhz were possible with a bit of extra parts to tweak the timings of the WR and RD signals,
but this is not really reliable. 

The schematic diagram (65c05board.pdf) is designed to directly show the breadboard layout. The connections of some bus lines 
are only shown by their designators to avoid too much clutter in the diagram.

## Memory map

The 64K address space which the 6502 can access using its 16 address lines are translated to the address space of the ByteMachine
in the following way:

| CPU        | main board   |     |
| ---------- | ------------ | --- |
| 0000..7FFF | 88000..8FFFF | RAM | 
| 8000..FFFF | 08000..0FFFF | ROM |

## More possibilities

With additional 74-series logic it is surely possible to implement some kind of bank switching scheme to access a larger area 
of the ByteMachine's total address space. This is open to experiment by anyone who wants to try.

## Gallery

![alt text](gallery/breadboard.jpg "Breadboard before connecting to the main board")
![alt text](gallery/complete.jpg "Complete system")

