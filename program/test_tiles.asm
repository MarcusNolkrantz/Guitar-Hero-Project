.equ c_tile_num_begin = 0
.equ c_tile_num_end = 4

.equ c_columns = 20
.equ c_rows = 15

.equ a_tiles  = 0x00

DRAW:
  ldi   r0, 20
  ldi   r1, a_tiles
  ldi   r2, c_rows
DRAW_ROW:
  ldi   r3, c_columns
DRAW_COL:
  inc   r0
  cpi   r0,c_tile_num_end
  brne  SKIP_RESET
  ldi r0,c_tile_num_begin
SKIP_RESET:
  st    r1,r0
  inc   r1
  dec   r3
  cpi   r3,0
  brne  DRAW_COL
  dec   r2
  cpi   r2,0
  brne  DRAW_ROW
WAIT:
  jmp   WAIT
