.equ  c_sprite_n_begin = 1
.equ  c_sprite_n_end = 5

.equ  c_columns = 20
.equ  c_rows = 15

.equ  a_sprite_n = 300
.equ  a_sprite_x = 332
.equ  a_sprite_y = 364
.equ  c_n_sprites = 32

.equ  c_delay_cycles = 2000

LOOP:
  ldi r0,0
WAIT0:
  ldi r1,0
WAIT1:
  inc r1
  cpi r1,c_delay_cycles
  brne WAIT1
  inc r0
  cpi r0,c_delay_cycles
  brne  WAIT0
TICK:
  ldi r1,a_sprite_n ; sprite n address counter
  ldi r2,a_sprite_x ; sprite x address counter
  ldi r3,a_sprite_y ; sprite y address counter
  ldi r4,0 ; sprite amount counter
  ldi r5,c_sprite_n_begin ; which sprite to use
TICK_SPRITE:
  ; choose sprite number
  st  r1,r5
  inc r5
  cpi r5,c_sprite_n_end
  brne  SKIP_RESET
  ldi r5,0
SKIP_RESET:
  ; move sprite
  ld  r6,r2 ; move sprite x depending on which sprite it is
  add r6,r6,r1
  st  r2,r6

  ld  r6,r3 ; move sprite y depending on which sprite it is
  add r6,r6,r1
  st  r3,r6

  inc r1
  inc r2
  inc r3
  inc r4
  cpi r4,c_n_sprites
  brne  TICK_SPRITE
EXIT:
  jmp LOOP
