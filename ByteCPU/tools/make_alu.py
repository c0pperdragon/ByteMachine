# Generate the content of the 512kB flash to work as the ALU
# The address bits are quite shuffeled up to match the physical pin layout

def op(o,a,b):
    if o==0 and a>b:
        return 1
    elif o==1:
        return (a+b) & 0xff
    elif o==2:
        return (a+256-b) & 0xff
    elif o==3:
        return (a*b) & 0xff
    elif o==4 and b!=0:
        return int(a/b) 
    elif o==5:
        return a & b 
    elif o==6:
        return a | b 
    elif o==7:
        return a ^ b
    else:
        return 0

table = bytearray(256*256*8)
for o in range(8):
    for a in range(256):
        for b in range(256):
            address = (
                  a 
                | ((b&0x01)<<12) 
                | ((b&0x02)<<14)
                | ((b&0x04)<<14)
                | ((b&0x08)<<15)
                | ((b&0x10)<<4)
                | ((b&0x20)<<8)
                | ((b&0x40)<<8)
                | ((b&0x80)<<10)
                | ((o&0x01)<<10)
                | ((o&0x02)<<10)
                | ((o&0x04)<<7)
                )
            table[address] = op(o,a,b)
            
dest = open("alu.bin", "wb")
dest.write(table)
dest.close()
