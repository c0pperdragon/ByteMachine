; LED animation demo to run with the ByteMachine main board.

; address space layout
ROM = $0000
RAM = $8000
COUNTER = $8001
DUMMY = $8002


    ORG $0000     
MAIN:
    ; init memory location COUNTER with 0
    SET R0 ^RAM
    DP R0                
    SET R0 .COUNTER
    SET R1 0
    ST R1 R0
    ; test initial jump instruction
    SET R0 .LOOP
    SET R1 ^LOOP
    JMP R0 R1
    
LOOP:
    ; increment COUNTER up to 15 and then wrap back to 0
    SET R0 .COUNTER
    LD R2 R0
    SET R1 1
    ADD R2 R1
    SET R1 15
    AND R2 R1
    ST R2 R0    
    
    ; fetch pattern from ROM
    SET R3 ^PATTERN
    DP R3
    SET R1 .PATTERN
    ADD R2 R1
    LD R2 R2
    
    ; write pattern to ROM range to hit the output port 
    ST R2 R1
    
    ; switch back to RAM address and RAM mode also
    SET R0 ^RAM
    DP R0
    SET R1 .DUMMY
    ST R0 R1
    
    ; delay loop
    SET R3 1
    SET R0 30
L1:
    SET R1 100
L2:
    SET R2 100
L3 :
    SUB R2 R3
    BGE R2 R3 .L3
    SUB R1 R3
    BGE R1 R3 .L2
    SUB R0 R3
    BGE R0 R3 .L1
    
    ; start over
    SET R0 .LOOP
    SET R1 ^LOOP
    JMP R0 R1
    
PATTERN:
    BYTE $80 $C0 $60 $30 $18 $0C $06 $03 
    BYTE $01 $03 $06 $0C $18 $30 $60 $C0
