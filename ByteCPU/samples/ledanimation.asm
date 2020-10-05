; LED animation demo to run with the ByteMachine main board.

; address space layout
ROM = $0000
RAM = $8000
COUNTER = $8000
DUMMY = $8001


    ORG $0000     
MAIN:
    ; init memory location COUNTER with 0
    SET A ^RAM
    DP A                
    SET A .COUNTER
    SET B 0
    ST A B
    
LOOP:
    ; increment COUNTER up to 15 and then wrap back to 0
    SET A .COUNTER
    MOVE C A
    LD C C
    SET B 1
    ADD C B
    SET B 15
    AND C B
    ST A C    
    
    ; fetch pattern from ROM
    SET D ^PATTERN
    DP D
    SET B .PATTERN
    ADD C B 
    LD C C
    
    ; write pattern to ROM range to hit the output port 
    ST C C
    
    ; switch back to RAM address and RAM mode also
    SET A ^RAM
    DP A
    SET B .DUMMY
    ST B A
    
    ; delay loop
    SET D 1
    SET A 10
L1:
    SET B 255
L2:
    SET C 255
L3 :
    SUB C D
    BNZ C .L3
    SUB B D
    BNZ B .L2
    SUB A D
    BNZ A .L1
    
    ; start over
    SET A ^LOOP
    JMP A .LOOP
    
    ORG $0100
PATTERN:
    BYTE $80 $C0 $60 $30 $18 $0C $06 $03 
    BYTE $01 $03 $06 $0C $18 $30 $60 $C0
