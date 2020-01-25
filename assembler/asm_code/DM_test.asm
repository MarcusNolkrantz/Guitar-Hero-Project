.equ DM_2 = 0b0110010111
.equ sprite_mem = 0b0100101100

LOOP:
 ldi r1, 1
 sts DM_2, r1
 
 nop 
 nop 
 nop 
 lds r2, DM_2
  cpi r2, 1
 brne LOOP
 ldi r3, 1
 sts sprite_mem, r3
END:
 jmp END 
