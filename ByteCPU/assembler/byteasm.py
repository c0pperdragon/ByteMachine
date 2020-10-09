import sys

class AssemblerException(Exception):
    pass

def findany(str, patterns):
    first = -1
    for p in patterns:
        pos = str.find(p)
        if pos>=0 and (first<0 or pos<first):
            first = pos
    return first

def tokenize(line):
    # strip comments and uppercase everything
    comment = line.find(";")
    if comment>=0:
        line = line[0:comment]
    # uppercase everything - rely on pythons definiton of "upper"
    line = line.upper()
    # break appart on white space and additionally seperate out ':' or '=' 
    tokens = []
    for token in line.split():
        first = findany(token, [":","="])
        if first>=0:
            if first>0:
                tokens.append(token[:first])
            tokens.append(token[first:first+1])
            if first<len(token)-1:
                tokens.append(token[first+1:])
        else:
            tokens.append(token)
    return tokens

def evaluate(identifiers, s):
    try:
        if s in identifiers:
            return identifiers[s]
        elif len(s)>0 and s[0]=='.': 
            return evaluate(identifiers, s[1:]) & 0xff
        elif len(s)>0 and s[0]=='^': 
            return (evaluate(identifiers, s[1:]) >> 8) & 0xff
        elif len(s)>0 and s[0]=='$':
            return int(s[1:],16)
        else:
            return int(s,10)
    except ValueError as e:
        raise AssemblerException("Can not parse number "+s)

def reg(tokens, tidx, bitpos):
    if tidx >= len(tokens):
        raise AssemblerException("Missing register specifier")
    if tokens[tidx]=="R0":
        return 0 << bitpos;
    elif tokens[tidx]=="R1":
        return 1 << bitpos;
    elif tokens[tidx]=="R2":
        return 2 << bitpos;
    elif tokens[tidx]=="R3":
        return 3 << bitpos
    else:
        raise AssemblerException("Invalid register name");

def op(identifiers, generate, tokens, tidx, bitlen):
    if tidx >= len(tokens):
        raise AssemblerException("Missing operand")
    elif not generate:
        return 0
    else:
        value = evaluate(identifiers, tokens[tidx])
        if value<0 or value>=(1<<bitlen):
            raise AssemblerException("Operand exceeds range")
        else:
            return value

def printlisting(startaddress, bytes, line):
    perpart = 4
    numparts = (max(len(bytes),1) +perpart-1) // perpart
    for i in range(numparts):
        x = [ "{:04x} ".format(startaddress+i*perpart) ]
        for j in range(perpart):
            if i*perpart+j < len(bytes):
                x.append("{:02x} ".format(bytes[i*perpart+j]) )
            else:
                x.append("   ");
        if i==0:
            x.append(" ")
            x.append(line)
        print ("".join(x))

def processline(identifiers, generate, tokens, codeaddress):
    I = identifiers
    G = generate
    T = tokens
    bytes = []
    if len(tokens)==0:
        pass
    elif len(tokens)==2 and tokens[1]==":":
        if not generate:
            id = tokens[0]
            if id in identifiers:
                raise AssemblerException("May not redefine '"+id+"'")#
            else:
                identifiers[id] = codeaddress[0]
    elif len(tokens)==3 and tokens[1]=='=':
        if not generate:
            id = tokens[0]
            value = op(I,G,T, 2, 16);
            if id in identifiers:
                raise AssemblerException("May not redefine '"+id+"'")#
            else:
                identifiers[id] = value
    elif len(tokens)==2 and tokens[0]=="ORG":
        codeaddress[0] = op(I,G,T, 1, 16)
    elif tokens[0]=="BYTE":
        for idx in range(1,len(tokens)):
            bytes.append(op(I,G,T, idx, 8))
    elif tokens[0]=="ST":
        bytes = [ 0x00 | reg(T, 1, 0) | reg(T, 2, 2) ]
    elif tokens[0]=="LD":
        bytes = [ 0x10 | reg(T, 1, 0) | reg(T, 2, 2) ]
    elif tokens[0]=="SET":
        bytes = [ 0x20 | reg(T, 1, 0) , op(I,G,T, 2, 8) ]
    elif tokens[0]=="DP":
        bytes = [ 0x30 | reg(T, 1, 2) ]
    elif tokens[0]=="JMP":
        bytes = [ 0x40 | reg(T, 1, 0) , op(T, 2, 2) ]
    elif tokens[0]=="BGE":
        bytes = [ 0x70 | reg(T, 1, 0) | reg(T, 2, 2) , op(I,G,T, 3, 8) ]
    elif tokens[0]=="BLE":
        bytes = [ 0x70 | reg(T, 1, 2) | reg(T, 2, 0) , op(I,G,T, 3, 8) ]
    elif tokens[0]=="BRA":
        bytes = [ 0x70 , op(I,G,T, 1, 8) ]
    elif tokens[0]=="ADD":
        bytes = [ 0x80 | reg(T, 1, 0) | reg(T, 2, 2) ]
    elif tokens[0]=="SUB":
        bytes = [ 0x90 | reg(T, 1, 0) | reg(T, 2, 2) ]
    elif tokens[0]=="MUL":
        bytes = [ 0xA0 | reg(T, 1, 0) | reg(T, 2, 2) ]
    elif tokens[0]=="DIV":
        bytes = [ 0xB0 | reg(T, 1, 0) | reg(T, 2, 2)]
    elif tokens[0]=="AND":
        bytes = [ 0xC0 | reg(T, 1, 0) | reg(T, 2, 2) ]
    elif tokens[0]=="OR":
        bytes = [ 0xD0 | reg(T, 1, 0) | reg(T, 2, 2) ]
    elif tokens[0]=="XOR":
        bytes = [ 0xE0 | reg(T, 1, 0) | reg(T, 2, 2) ]
    elif tokens[0]=="LT":
        bytes = [ 0xF0 | reg(T, 1, 0) | reg(T, 2, 2) ]
    else:
        raise AssemblerException("Unknown instruction "+tokens[0])     

    codeaddress[0] += len(bytes)
    return bytes

def process(identifiers, sourcefile, outbuffer):
    generate = bool(outbuffer)
    src = open(sourcefile, "r")
    codeaddress = [0]
    linenumber = 1
    numerrors = 0
    for rawline in src:
        line = rawline.rstrip()
        try:
            tokens = tokenize(line)
            startaddress = codeaddress[0]
            bytes = processline(identifiers, generate, tokens, codeaddress)
            if generate:
                printlisting(startaddress, bytes, line)
                outbuffer[startaddress:startaddress+len(bytes)] = bytes
        except AssemblerException as e:
            print(sourcefile+":"+str(linenumber)+" "+str(e),file=sys.stderr)
            numerrors += 1
        linenumber += 1
    src.close()
    if numerrors>0:
        raise AssemblerException("Encountered "+str(numerrors)+" errors")

def formatwithchecksum(record):
    line = ":"
    sum = 0x00
    for i in range(len(record)):#
        b = record[i]
        line = line + "{:02x}".format(b)
        sum += b
    return line + "{:02x}".format((-sum) & 0xff)
        
def printhexfile(hexfile, buffer):
    dest = open(hexfile, "w")
    start=0
    while start<len(buffer):
        if buffer[start] == None:
            start += 1
        else:
            record = [ 0x00, (start>>8) & 0xff, start&0xff, 0x00 ]
            l = 0
            while l<16 and start+l<len(buffer) and buffer[start+l] != None:
                record.append(buffer[start+l])
                l += 1
            record[0] = l
            print(formatwithchecksum(record), file=dest)
            start += l
    print(formatwithchecksum([0x00,0x00,0x00,0x01]), file=dest)                
    dest.close()
        
def asm(sourcefile,hexfile):
    try:
        identifiers = { }
        process(identifiers, sourcefile, None)
        rom = [None]*65536
        process(identifiers, sourcefile, rom)
        printhexfile(hexfile, rom)
    except AssemblerException as e:
        print (e,file=sys.stderr) 

if len(sys.argv)>=2: 
    asm(sys.argv[1]+".asm",sys.argv[1]+".hex")
else:
    print("No filename given to assemble",file=sys.stderr)
