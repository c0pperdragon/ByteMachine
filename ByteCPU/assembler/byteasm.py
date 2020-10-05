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
    if s in identifiers:
        return identifiers[s]
    elif len(s)>0 and s[0]=='.': 
        return evaluate(identifiers, s[1:]) & 0xff
    elif len(s)>0 and s[0]=='^': 
        return (evaluate(identifiers, s[1:]) >> 8) & 0xff
    elif len(s)>0 and s[0]=='$':
        return int(s[1:], 16) & 0xffff 
    else:
        return int(s,10) & 0xffff

def op(identifiers, tokens, generate, tidx, bitpos, bitlen):
    if tidx >= len(tokens):
        raise AssemblerException("Missing parameter")
    elif not generate:
        return 0
    else:
        value = evaluate(identifiers, tokens[tidx])
        if value<0 or value >= (1<<bitlen):
            raise AssemblerException("Parameter exceeds range "+str(1<<bitlen))
        else:
            return value << bitpos

def printlisting(startaddress, bytes, line):
    perpart = 4
    numparts = (max(len(bytes),1) +perpart-1) // perpart
    for i in range(numparts):
        x = [ "{:04x} ".format(startaddress+i*perpart) ]
        for j in range(perpart):
            if i*perpart+j < len(bytes):
                x.append("{:02x}".format(bytes[i*perpart+j]) )
            else:
                x.append("  ");
        if i==0:
            x.append("  ")
            x.append(line)
        print ("".join(x))

def processline(identifiers, tokens, generate, codeaddress):
    I = identifiers
    T = tokens
    G = generate
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
            value = evaluate(identifiers,tokens[2]);
            if id in identifiers:
                raise AssemblerException("May not redefine '"+id+"'")#
            else:
                identifiers[id] = value
    elif len(tokens)==2 and tokens[0]=="ORG":
        codeaddress[0] = evaluate(identifiers,tokens[1])
    elif tokens[0]=="BYTE":
        for idx in range(1,len(tokens)):
            bytes.append(op(I,T,G, idx, 0,8))
    elif tokens[0]=="MOVE":
        bytes = [ 0x00 | op(I,T,G, 1, 0,2) | op(I,T,G, 2, 2,2) ]
    elif tokens[0]=="ST":
        bytes = [ 0x10 | op(I,T,G, 1, 0,2) | op(I,T,G, 2, 2,2) ]
    elif tokens[0]=="LD":
        bytes = [ 0x20 | op(I,T,G, 1, 0,2) | op(I,T,G, 2, 2,2) ]
    elif tokens[0]=="SET":
        bytes = [ 0x30 | op(I,T,G, 1, 0,2) , op(I,T,G, 2, 0,8) ]
    elif tokens[0]=="DP":
        bytes = [ 0x40 | op(I,T,G, 1, 2,2) ]
    elif tokens[0]=="JMP":
        bytes = [ 0x50 | op(I,T,G, 1, 0,2) , op(I,T,G, 2, 0,8) ]
    elif tokens[0]=="RET":
        bytes = [ 0x60 | op(I,T,G, 1, 0,2) | op(I,T,G, 2, 2,2) ]
    elif tokens[0]=="BNZ":
        bytes = [ 0x70 | op(I,T,G, 1, 0,2) | op(I,T,G, 2, 0,8) ]
    elif tokens[0]=="BR":
        bytes = [ 0x71 | op(I,T,G, 1, 0,8) ]
    elif tokens[0]=="BZ":
        bytes = [ 0x72 | op(I,T,G, 1, 0,2) | op(I,T,G, 2, 0,8) ]
    elif tokens[0]=="ADD":
        bytes = [ 0x80 | op(I,T,G, 1, 0,2) | op(I,T,G, 2, 2,2) ]
    elif tokens[0]=="SUB":
        bytes = [ 0x90 | op(I,T,G, 1, 0,2) | op(I,T,G, 2, 2,2) ]
    elif tokens[0]=="MUL":
        bytes = [ 0xA0 | op(I,T,G, 1, 0,2) | op(I,T,G, 2, 2,2) ]
    elif tokens[0]=="DIV":
        bytes = [ 0xB0 | op(I,T,G, 1, 0,2) | op(I,T,G, 2, 2,2) ]
    elif tokens[0]=="AND":
        bytes = [ 0xC0 | op(I,T,G, 1, 0,2) | op(I,T,G, 2, 2,2) ]
    elif tokens[0]=="OR":
        bytes = [ 0xD0 | op(I,T,G, 1, 0,2) | op(I,T,G, 2, 2,2) ]
    elif tokens[0]=="XOR":
        bytes = [ 0xE0 | op(I,T,G, 1, 0,2) | op(I,T,G, 2, 2,2) ]
    elif tokens[0]=="CMP":
        bytes = [ 0xF0 | op(I,T,G, 1, 0,2) | op(I,T,G, 2, 2,2) ]
    else:        
        raise AssemblerException("Unknown instruction "+tokens[0])     

    codeaddress[0] += len(bytes)
    return bytes        
                
def process(identifiers, sourcefile, generate):
    src = open(sourcefile, "r")
    codeaddress = [0]
    linenumber = 1
    for rawline in src:
        line = rawline.rstrip()
        try:
            tokens = tokenize(line)
            startaddress = codeaddress[0]
            bytes = processline(identifiers, tokens, generate, codeaddress)
            if generate:
                printlisting(startaddress, bytes, line)
        except AssemblerException as e:
            print(sourcefile+":"+str(linenumber)+" "+str(e),file=sys.stderr)
        linenumber = linenumber+1
    src.close()

def asm(sourcefile,hexfile):
    identifiers = { "A": 0, "B": 1, "C": 2, "D": 3 }
    process(identifiers, sourcefile, False)
#    print(identifiers)
    process(identifiers, sourcefile, True)

f = "../samples/ledanimation"
asm(f+".asm",f+".hex")
