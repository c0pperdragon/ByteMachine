
    CODE
    xdef ~~portout
~~portout:
    ; initial stack layout:  
    ;   SP+1, SP+2, SP+3    return address
    ;   SP+4, SP+5          16-bit parameter 

    SEP #$30 ;8 bit registers

    DB $a3,4  ; LDA SP+4
    STA >$800000            ; temporarily switch to IO mode
    DB $83,4  ; STA SP+4    ; switch back to normal mode

    REP #$30 ;16 bit registers

	; take down stack and return
    DB $a3,2  ; LDA SP+2
    DB $83,4  ; STA SP+4
    PLA 
    DB $83,1  ; STA SP+1
    RTL

    ENDS
    END 
