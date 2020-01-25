; game constants
.dw   song_addr =0x00      ; address to song start in data memory
.dw   cycles_per_tick = 100 ; number of cycles per row
.dw   ticks_per_row = 100   ; number of ticks per row
.dw   strum_start = 25      ; lower limit for strum (ticks after row begin)
.dw   strum_end = 75        ; upper limit for strum

; key addresses in keyboard memory
.dw   q_addr = 0x00
.dw   w_addr = 0x0F
.dw   e_addr = 0xF0
.dw   r_addr = 0x0C
.dw   t_addr = 0xC0
.dw   space_addr = 0x00

; sound address
.dw   sound_address = 0x00

; drawing constants
.dw   disp_width = 640
.dw   disp_height = 480
.dw   tile_size = 16
.dw   tiles_width = disp_width / tile_size
.dw   tiles_height = disp_height / tile_size
.dw   visible_rows = 7
.dw   tile_fret_addr = 0x00
.dw   tile_bg_addr = 0x00
.dw   rows_visible = 5
.dw   note_sprites_begin = 0x00

; game logic registers
.def  tmp = r0              ; temporary registers, used for various things
.def  x = r1                ; used for coordinates
.def  y = r2                ; used for coordinates
.def  cycles = r3           ; cycles since last tick
.def  ticks = r4            ; current tick count since start of game
.def  row = r5              ; current row number
.def  row_addr = r0         ; address to current row in song
.def  row_ticks = r0        ; ticks spent on current row
.def  qwert = r0            ; keys pressed (only q pressed will be 0b10000)
.def  space = r0            ; != 0 if space pressed
.def  row_handled = r0      ; = 0 if row hasn't been completed or failed
.def  row_keys = r0         ; keys of current row
.def  row_note = r0         ; note of current row
.def  input = r0            ; saves from song

; drawing registers
.def  rows_to_draw = r0     ; rows left to draw

; program
INIT:
  ; initialize game data
  ldi   cycles,0            ; start at 0 cycles
  ldi    ticks,0             ; start at 0 ticks
  ldi   row,0               ; start at row 0
  ldi   row_addr,song_addr  ; store address of first row
  ldi   row_ticks,0         ; start at tick 0 of current row
  ldi   row_handled,0       ; first row hasn't been handled
  ld    row_note,row_addr   ; store note for first row
  ld    row_keys,row_addr   ; store keys required for first row
  lsr   row_keys            ; move row_keys to least significant bits
  lsr   row_keys
  lsr   row_keys
LOOP:
  inc   cycles              ; increment cycles
  cmpi  cycles,cycles_per_tick
  brne  LOOP                ; don't tick
TICK:
  ; execute one game tick
  inc   ticks               ; increment ticks
INPUT:
  ; read input
  ldi   qwert,0             ; clear input

  ld    tmp,q_addr          ; load q state to temporary register
  or    qwert,input,tmp     ; load q state in qwert
  lsl   qwert               ; shift q to the left to make room for w
  ld    tmp,w_addr          ; repeat for w, e, r, t
  or    qwert,qwert,tmp
  lsl   qwert
  ld    tmp,e_addr
  or    qwert,qwert,tmp
  lsl   qwert
  ld    tmp,r_addr
  or    qwert,qwert,tmp
  lsl   qwert
  ld    tmp,t_addr
  or    qwert,qwert,tmp
  lsl   qwert

  ld    space,space_addr    ; load space state in space register
UPDATE:
  ; update logic
  inc   row_ticks           ; one more ticks spent on row
  cmpi  row_ticks,ticks_per_row
  brne   ROW_HANDLE          ; continue with current row if end not reached
ROW_END:
  ldi   row_ticks,0         ; otherwise, stop any current sound and go to next row
  inc   row
  inc   row_addr
  sti   sound_address,0
ROW_HANDLE:
  cmpi  row_handled,0       ; check if row has been handled
  brne   DRAW                ; just draw if row has already been handled

  subi  row_ticks,strum_start
  bmi   BEFORE_INTERVAL
  subi  strum_end,row_ticks
  bmi   AFTER_INTERVAL
  jmp   INSIDE_INTERVAL
BEFORE_INTERVAL:
  ; currently after of the interval where it is allowed to strum
  ; if the strum is pressed here, the note was missed
  cmpi  space,0
  beq   DRAW                ; do nothing is strum is not pressed
  jmp   ROW_FAIL
INSIDE_INTERVAL:
  ; currently inside of the interval where it is allowed to strum
  ; if the strum is pressed and all keys are correct, the note will play
  cmpi  space,0
  beq   DRAW                ; do nothing if strum is not pressed

  cmp   qwert,row_keys
  brne   ROW_FAIL            ; row is failed if keys pressed are not correct

  ldi   row_handled,1       ; otherwise, the row was played successfully
  st    sound_address,row_note
  jmp   DRAW
AFTER_INTERVAL:
  ; currently after of the interval where it is allowed to strum
  ; since we are here and the row hasn't been handled, the note was missed
ROW_FAIL:
  ldi   row_handled,1
  sti   sound_address,0b1111; play fail sound
DRAW:
  ; draw to screen
  ; move each note sprite down
  ; when a goes below the screen, move it up to the top

  ldi   rows_to_draw,0


  jmp   LOOP                ; loop again
