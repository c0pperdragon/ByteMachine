# IO expander

To allow more sophisticated communicaiton with the outside world than just blinking lights and buttons, 
a small IO board can be attached to the headers of the IO area. This board will allow correct handling 
of serial communication and also provides access to an SD card socket.

## UART receive buffer

One serious drawback of the no-interrupt design of the ByteMachine is its inability
to properly implement a simple two-wire UART. Without explicit flow control (basically
an outgoing RTS signal), the CPU will miss incomming data while its is doing
internal calculations of sending out data of its own.

A solution with RTS/CTS signals in additon to TX/RX will overcome this problem, but
then the communication partner must also implement this handshake. 
To make the whole scheme work also with other devices, an intermediary circuit is necessary
that will buffer data that comes in at arbitrary moments (because no handshake is implemented
by the sender) and send it on to the CPU only when the CPU is ready for it.
To keep things simple the sender is assumed to not exceed the internal buffer size by
burst sends. As this is intended mainly for keyboard input, this should work.

### Communcation protocol

The bridge acts as a buffer for the incomming transmission line and will forward data
to the main CPU board only if its CTS input (which is the RTS output on the CPU board) is low.
Otherwise it will just buffer the data for the next opportunity to send.

The outgoing line is under direct control of the CPU and will not use the UART receive buffer.

Communication speed is overall 9600 baud, 1 start bit, 1 stop bit, no parity.

### Hardware implementation

The hardware consists of a single ATTINY44A microcontroller in a DIP 14 package, 
running with its internal oscillator set to 8MHz. 
To prevent a high input signal pulling the supply voltage to high via the
input clamp diodes (and effectively turning the whole ByteMachine on), 
an additional input circuit is added.
 

## SD card interface

Communication with an SD card can be done using the SPI protocol which can be 
directly implemented in software by the ByteMachine's CPU.
But the voltage levels need to be shifted from 5V to 3.3V and the SD Card needs a 
3.3V power supply. 
The output from the SD card also needs a bit of preparation before feeding it into 
the HC245 input circuitry.
