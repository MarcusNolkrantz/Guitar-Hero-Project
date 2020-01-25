.equ  c_sprite_n = 2

.equ  a_sprite_n = 300
.equ  a_sprite_x = 332
.equ  a_sprite_y = 364

.equ  c_delay_cycles = 500

INIT:
  ldi r0,a_sprite_n ; sprite n address
  ldi r1,a_sprite_x ; sprite x address
  ldi r2,a_sprite_y ; sprite y address

  ldi r6,0          ; sprite x
  ldi r7,0          ; sprite y
LOOP:
  ldi r3,0
WAIT0:
  ldi r4,0
WAIT1:
  ldi r5,0
WAIT2:
  inc r5
  cpi r5,c_delay_cycles
  brne WAIT2
  inc r4
  cpi r4,c_delay_cycles
  brne WAIT1
  inc r3
  cpi r3,c_delay_cycles
  brne WAIT0
TICK:
  st  r0,c_sprite_n
  st  r1,r6
  st  r2,r7
  inc r6
  inc r7

  jmp LOOP
