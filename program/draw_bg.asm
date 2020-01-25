; expected output:
; screen filled with different tiles

DRAW:
  ldi   r0,1	; tile num to write
  ldi   r1,0	; address to write tile num to
  ldi   r2,15	; rows
DRAW_ROW:
  ldi   r3,20	; columns
DRAW_COL:
  st    r1,r0	; write tile
  inc   r1	; go to next tile
  dec   r3
  cpi   r3,5
  brne  DRAW_COL
  dec   r2
  cpi   r2,5
  brne  DRAW_ROW
WAIT:
  jmp   WAIT
