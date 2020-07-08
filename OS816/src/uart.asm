    XREF ~~portset
    XREF ~~portclear
    XREF ~~portin

    CODE
    xdef ~~uartsend
~~uartsend:
    longa on
    longi on
    ; initial stack layout:  
    ;   SP+1, SP+2, SP+3    return address
    ;   SP+4, SP+5          data to send (in lower bits only)

    ; must wait until the receiver is ready to accept new data 
waitforready:
    JSL >~~portin
    AND #$0001
    BEQ waitforready

    ; send one byte bit by bit (1 start bit, 1 stop bit, no parity)
    CLC         
    JSR sendbit ; start bit
    LDA <4,S
    LSR A       
    STA <4,S
    JSR sendbit ; bit 0
    LDA <4,S
    LSR A       
    STA <4,S
    JSR sendbit ; bit 1
    LDA <4,S
    LSR A       
    STA <4,S
    JSR sendbit ; bit 2
    LDA <4,S
    LSR A       
    STA <4,S
    JSR sendbit ; bit 3
    LDA <4,S
    LSR A       
    STA <4,S
    JSR sendbit ; bit 4
    LDA <4,S
    LSR A       
    STA <4,S
    JSR sendbit ; bit 5
    LDA <4,S
    LSR A       
    STA <4,S
    JSR sendbit ; bit 6
    LDA <4,S
    LSR A       
    STA <4,S
    JSR sendbit ; bit 7
    LDA <4,S
    STA <4,S
    SEC        
    JSR sendbit  ; stop bit
    
    ; take down stack and return
    LDA <2,S
    STA <4,S
    PLA 
    STA <1,S
    RTL

sendbit:
    ; send the bit that is given in the carry flag.
    ; may change a,x,y like for normal function calls 
    BCS send1
send0:
    LDA #$0001
    PHA
    JSL	>~~portclear   
    BRA delay
send1: 
    LDA #$0001
    PHA
    JSL	>~~portset
    BRA delay
delay:
    LDX #106   ; to get a total bitrate of 19200 baud
delay2:
    DEX        ; 2 cycles
    BNE delay2 ; 3 cycles
    RTS
    ENDS

    END 
