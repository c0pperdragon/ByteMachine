# 65c816

This not so well known CPU is an extended variant of the 6500. It extends the address space to 24 bit
as well as some internal registers to a width of 16 bit.
It was used in the Super Nintendo Entertainment System (SNES) but did not get much use in its time otherwise.

The main problem when using this CPU is the way in which the high address lines are multiplexed on the data lines.
With the use of a latch and two more 74-series logic parts (one hex inverter and one quad or), this can be solved.
Generation of RD and WR signals is done similar to the 65C02 board. To avoid bus collisions during the
first half of each cycle as much as possible, the CPU is driven with a slightly delayed clock so the times spans where the 
CPU writes the higher address lines to the data bus do least overlap with the time spans when the memory writes 
back the memory content. With this simple circuit collisions can not be entirely avoided, but it seems to be OK
to have collisions for only a few nanoseconds on each clock cycle.

The schematic diagram (65c816.pdf) is designed to directly show the breadboard layout. The connections of some bus lines 
are only shown by their designators to avoid too much clutter in the diagram.

## Memory map

The 16M address space which the 65c816 can access is larger than the total available RAM and ROM space of the 
main board, so many addresses map to the same target locations. 
Because the bank 0 (000000 - 00FFFF) has special meaning and needs to contain some RAM (zero page, stack)
and also some ROM (reset vector, bootup code), this bank is split along the 32K boundary.
To access other parts of ROM and RAM in a more linear fashion, whole banks are mapped to either ROM or RAM.


| CPU address    | type | mem address  |
| -------------- | ---- | -------------|
| 000000..007FFF | RAM  | 00000..07FFF |
| 008000..00FFFF | ROM  | 08000..0FFFF |
| 800000..87FFFF | ROM  | 00000..7FFFF |
| C00000..C7FFFF | RAM  | 00000..7FFFF |

All ranges not specified in this table also map to some part of RAM or ROM, but it is explicitely not specified and 
reserved for future use.
