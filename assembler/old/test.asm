.def temp = r2
.equ val = 12
.equ val1 = 0b1111
.equ val2 = 0xCC
;brUh
nop
ld      temp, r1
lds     r0, val
ldi     r3, val1
st      r1,r2
sts     r3,r4
sub     r0,r1,r2
subi    r1, r2, 24
addi    r3, r1, 0b00101010
inc     r2
dec     r5
lsr     0b011101001,23
lsl     r1,4
or      r0,r2,r3
andi    r1,r3,0b111111
cp      temp, temp, r12
cpi     r2, val2
jmp     0xFC
brne    0b00100011
breq    123
brmi    0xDD
brpl    0b0111011011
sub     r1,r2,r3
add     r4,r5,r15
and     r1,r2,r3
ori     r2,r3,0xCD