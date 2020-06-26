
    CODE
    xdef ~~sleep
~~sleep:
    longa on
    longi on
    ; initial stack layout:  
    ;   SP+1, SP+2, SP+3    return address
    ;   SP+4, SP+5          16-bit parameter: kiloclocks

    DB $a3,4  ; LDA SP+4

    ; this loop is fine-tuned to take exactly 1000 clocks per iteration
    ; (one-time method call overhead can not be avoided) 
    beq done
continue:
    ldx #198         ; 3 cycles
    ldx #198         ; 3 cycles
continue2:
    dex              ;   2 cycles
    bne continue2    ;   2 or 3 (if taken) cycles
    dec a            ; 2 cycles
    bne continue     ; 2 or 3 (if taken) cycles
done:
                     ; SUM = 3 + 3 + (2+3)*198 - 1 + 2 + 3 = 1000
					 
    ; take down stack and return
    DB $a3,2  ; LDA SP+2
    DB $83,4  ; STA SP+4
    PLA 
    DB $83,1  ; STA SP+1
    RTL

    ENDS
    END 
