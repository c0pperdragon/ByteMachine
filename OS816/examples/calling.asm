;:ts=8
R0	equ	1
R1	equ	5
R2	equ	9
R3	equ	13
	code
	xdef	~~inc
	func
~~inc:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L2
	tcs
	phd
	tcd
x_0	set	4
	lda	<L2+x_0
	ina
L4:
	tay
	lda	<L2+2
	sta	<L2+2+2
	lda	<L2+1
	sta	<L2+1+2
	pld
	tsc
	clc
	adc	#L2+2
	tcs
	tya
	rtl
L2	equ	0
L3	equ	1
	ends
	efunc
	code
	xdef	~~get
	func
~~get:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L5
	tcs
	phd
	tcd
	pea	#<$1
	jsl	~~inc
L7:
	tay
	pld
	tsc
	clc
	adc	#L5
	tcs
	tya
	rtl
L5	equ	0
L6	equ	1
	ends
	efunc
	code
	xdef	~~put
	func
~~put:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L8
	tcs
	phd
	tcd
x_0	set	4
	pei	<L8+x_0
	jsl	~~inc
L10:
	lda	<L8+2
	sta	<L8+2+2
	lda	<L8+1
	sta	<L8+1+2
	pld
	tsc
	clc
	adc	#L8+2
	tcs
	rtl
L8	equ	0
L9	equ	1
	ends
	efunc
	code
	xdef	~~put2
	func
~~put2:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L11
	tcs
	phd
	tcd
x_0	set	4
y_0	set	6
	pei	<L11+x_0
	jsl	~~inc
	pei	<L11+y_0
	jsl	~~inc
L13:
	lda	<L11+2
	sta	<L11+2+4
	lda	<L11+1
	sta	<L11+1+4
	pld
	tsc
	clc
	adc	#L11+4
	tcs
	rtl
L11	equ	0
L12	equ	1
	ends
	efunc
	code
	xdef	~~rcv
	func
~~rcv:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L14
	tcs
	phd
	tcd
p_0	set	4
	jsl	~~get
	sta	[<L14+p_0]
L16:
	lda	<L14+2
	sta	<L14+2+4
	lda	<L14+1
	sta	<L14+1+4
	pld
	tsc
	clc
	adc	#L14+4
	tcs
	rtl
L14	equ	0
L15	equ	1
	ends
	efunc
	code
	xdef	~~ptr
	func
~~ptr:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L17
	tcs
	phd
	tcd
p_0	set	4
	ldx	<L17+p_0+2
	lda	<L17+p_0
L19:
	tay
	lda	<L17+2
	sta	<L17+2+4
	lda	<L17+1
	sta	<L17+1+4
	pld
	tsc
	clc
	adc	#L17+4
	tcs
	tya
	rtl
L17	equ	0
L18	equ	1
	ends
	efunc
	code
	xdef	~~fill
	func
~~fill:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L20
	tcs
	phd
	tcd
c_0	set	4
i_1	set	0
	stz	<L21+i_1
	brl	L10002
L10001:
	inc	<L21+i_1
L10002:
	lda	<L21+i_1
	cmp	#<$a
	bcc	L22
	brl	L10003
L22:
	sep	#$20
	longa	off
	lda	#$7
	ldy	<L21+i_1
	sta	[<L20+c_0],Y
	rep	#$20
	longa	on
	brl	L10001
L10003:
L23:
	lda	<L20+2
	sta	<L20+2+4
	lda	<L20+1
	sta	<L20+1+4
	pld
	tsc
	clc
	adc	#L20+4
	tcs
	rtl
L20	equ	2
L21	equ	1
	ends
	efunc
	code
	xdef	~~l
	func
~~l:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L24
	tcs
	phd
	tcd
	lda	#$1f40
	tax
	lda	#$d7ab
L26:
	tay
	pld
	tsc
	clc
	adc	#L24
	tcs
	tya
	rtl
L24	equ	0
L25	equ	1
	ends
	efunc
	code
	xdef	~~main
	func
~~main:
	longa	on
	longi	on
	tsc
	sec
	sbc	#L27
	tcs
	phd
	tcd
x_1	set	0
b_1	set	2
	jsl	~~get
	sta	<L28+x_1
	pei	<L28+x_1
	jsl	~~put
	pea	#0
	clc
	tdc
	adc	#<L28+x_1
	pha
	jsl	~~ptr
	sta	<R0
	stx	<R0+2
	phx
	pha
	jsl	~~rcv
	pea	#0
	clc
	tdc
	adc	#<L28+b_1
	pha
	jsl	~~fill
	jsl	~~l
L29:
	pld
	tsc
	clc
	adc	#L27
	tcs
	rtl
L27	equ	16
L28	equ	5
	ends
	efunc
	end
