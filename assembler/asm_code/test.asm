.def y1 = r10
.def y2 = r11

INIT:

	ldi r0,300
	ldi r1,1
	st  r0,r1
	ldi r0, 332
	ldi r1, 20
	st r0, r1
	ldi r0,301
	ldi r1,2
	st  r0,r1
	ldi r0, 333
	ldi r1, 50
	st r0, r1
	ldi y1, 0
	ldi y1, 0
RUN1:
	ldi r0, 398
	ld r1, r0
	cpi r1, 1
	brne RUN1
RUN2:
	ld r1, r0
	cpi r1, 0
	brne RUN2
	inc y1
	sts 364,y1
	jmp RUN1
