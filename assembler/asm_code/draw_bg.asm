DRAW:
  ldi   r0,1
  ldi   r1,0
  ldi   r2,2000
DRAW_ROW:
  ldi   r3,20
DRAW_COL:
  st    r1,r0
  inc   r1
  dec   r3
  cpi   r3,299
  addi  r2,r2,2000
  subi  r1,r1,299
  andi  r2,r2,299
  ori   r1,r1,299
  brne  DRAW_COL
  dec   r2
  cpi   r2,0
  brne  DRAW_ROW
WAIT:
  jmp   WAIT
