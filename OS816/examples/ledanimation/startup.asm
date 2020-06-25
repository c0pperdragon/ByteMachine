
    ; external references
    XREF _ROM_BEG_DATA
    XREF _BEG_DATA
    XREF _END_DATA
    XREF _BEG_UDATA
    XREF _END_UDATA
    XREF ~~main

    CODE
START:
    ; enter emulation mode - now we can also access RAM
    CLC ;clear carry
    XCE ;clear emulation

    ; set up 16 bit mode for all registers and memory access
    REP #$30 ;16 bit registers
    LONGI ON
    LONGA ON

    ; set the stack to use the whole bank 0
    LDA #$FFFF 
    TCS 

;    SEP #$20 ;8 bit accum
;    LONGA OFF
;    LDA #^_BEG_DATA ;get bank of data
;    PHA
;    PLB ;set data bank register
;    REP #$20 ;back to 16 bit mode
;    LONGA ON 

;    ; copy initial content into DATA segment 
;    ; (this currently works only if not exceeding 64K)
;    LDA #_END_DATA-_BEG_DATA ;number of bytes to copy
;    BEQ SKIP ;if none, just skip
;    DEC A ;less one for MVN instruction
;    LDX #<_ROM_BEG_DATA ;get source into X
;    LDY #<_BEG_DATA ;get dest into Y
;    MVN #^_ROM_BEG_DATA,#^_BEG_DATA ;copy bytes
;SKIP: 
;
;    ; clear UDATA segment
;   ; (this currently works only if not exceeding 64K)
;    LDX #_END_UDATA-_BEG_UDATA ;get number of bytes to clear
;    BEQ DONE ;nothing to do
;    LDA #0 ;get a zero for storing
;    SEP #$20 ;do byte at a time
;    LDY #_BEG_UDATA ;get beginning of zeros
;LOOP:
;    STA |0,Y ;clear memory
;    INY ;bump pointer
;    DEX ;decrement count
;    BNE LOOP ;continue till done
;    REP #$20 ;16 bit memory reg
;DONE: 

    ; start the main function, and stop CPU upon return
    JSL >~~main
    STP
    ENDS

    ; The initial reset vector and a single long jump instruction to 
    ; get the code running from the true ROM address.
    ; If interrupt vectors need to be installed also, this must be done
    ; in RAM, because in native mode the whole of bank 0 is use for RAM
RESET SECTION   ; locate at 80FFF8 (FFF8 in ROM) by the linker
    JMP >START   ; long jump to the startup code (4 byte instruction)
    DW $FFF8     ; reset vector is relative to bank 0
    ENDS
    END 
