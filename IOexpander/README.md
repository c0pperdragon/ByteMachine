# IO expander

To allow more sophisticated communication with the outside world than just blinking lights and buttons, 
a small IO board can be attached to the headers of the IO area. This boards provides ports to directly
attach SPI devices, as well as do propper serial communication and also provides an SD card socket.

## SPI ports

Using the 8 output pins and 6 of the input pins, 6 independent SPI interfaces can be controlled by the 
machine. One shared output pin for SCLK and MOSI, and dedicated SS and MISO pins for each port.
Having dedicated MISO pins for each slave avoids bus-collisions between misbehaving slaves. 

## SD card interface

One of the SPI ports is dedicated to control an SD card. For this purpose voltage level shifters are
provided to translate the 5V of the ByteMachine to the necessary 3.3V.
The output from the SD card also needs a bit of preparation before feeding it into 
the HC245 input circuitry.

## UART

One serious drawback of the no-interrupt design of the ByteMachine is its inability
to properly implement a simple two-wire UART. Without explicit flow control (basically
an outgoing RTS signal), the CPU will miss incomming data while its is doing
internal calculations of sending out data of its own. 
Additionally without interrupts, the CPU must take care of the exact timing for
sending and receiving by waiting loops, so nothing else can be done while
data is transmitted.
To solve this issue, the board provides a SPI to UART bridge with a simple 
transmission protocol. To keep things simple, the UART speed is default of
9600 baud (1 start bit, 1 stop bit, no parity). This will allow the use of a basic 
serial terminal with reasonable speed.

### Communcation protocol requirements

SPI is strictly driven by the bus master (the ByteMachine), so it needs to regularly
poll the bridge to check if new data has been received.
Outgoing data can be sent to the bridge in bursts and will be transmitted from there
at the specified output speed.
And important thing is controlling the amount of data being sent and received. The bridge only
as a very limited amount of buffer space, so the ByteMachine must not send more data as can be
buffered in the output buffer and it must also receive the data fast enough to keep the
input buffer from overflowing (there is no flow control on the UART side itself).


### Hardware implementation

The hardware consists of a single ATTINY44A microcontroller in a DIP 14 package, 
running with its internal oscillator set to 8MHz. 
To prevent a high input signal pulling the supply voltage to high via the
input clamp diodes (and effectively turning the whole ByteMachine on), 
an additional input circuit is added.
 

### Protocol details

All SPI requests are started with the SS going low then an arbitrary amount
of bytes is transfered between master and slave as well as from slave to master
at the same time. 
The first byte of the data from the master contains a command byte.
The first byte from the slave always contains the number of bytes present
in the slaves input buffer. 
The meaning of the rest of the bytes in a request are depending on the command.
* Command $73: Send
   All following request bytes are intended to be sent to the UART. The bridge may not be able
   to buffer as many bytes, so it will write in its response which bytes it was actually able
   to accept: (1-accept, 0-refuse). If the master receives back 0-bytes it needs to resend
   the bytes in the next request.
* Command $72: Receive
   The following bytes from the master are ignored, but the client will start to send 
   send as many bytes it has, until the SS goes idle again. The maximum number of bytes the client
   will send in this request is the value that it already sent as the very first byte. 
   A very simple way for the server to just poll if there are any bytes at all would be to 
   just send the Receive command with 0 additional bytes.

