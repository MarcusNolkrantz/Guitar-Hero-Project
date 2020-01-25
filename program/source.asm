; see ./instructions.txt for instruction explanations

; constants
.equ  c_cycles_per_tick = 100 ; number of cycles per row
.equ  c_ticks_per_chord = 100 ; number of ticks per row
.equ  c_strum_start = 25      ; lower limit for strum (ticks after row begin)
.equ  c_strum_end = 75        ; upper limit for strum

; numbers
.equ  c_tile_bg     = 0x04    ; background tile number (creeper!!!)
.equ  c_sprite_invis= 0x00    ; invisible sprite number
.equ  c_sprite_note = 0x01    ; first note sprite number, should be orange followed by blue e.t.c.

; rendering
.equ  c_disp_width = 160      ; display width
.equ  c_disp_height = 120     ; display height
.equ  c_tile_size = 8         ; tile width and height
.equ  c_sprite_size = 8       ; sprite width and height
.equ  c_tiles_per_row = 20    ; number of tiles per screen row
.equ  c_tiles_per_col = 15    ; number of tiles per screen col
.equ  c_visible_chords = 4    ; number of visible rows on screen
.equ  c_chord_dist = 24       ; ~disp_height/(visible_chords+1)
.equ  c_note_dist = 27        ; disp_width/(5+1)


; addresses
.equ  a_song = 405            ; address to song start in data space
.equ  a_q = 397               ; q key
.equ  a_w = 398               ; w key
.equ  a_e = 399               ; e key
.equ  a_r = 400               ; r key
.equ  a_t = 401               ; t key
.equ  a_space = 402           ; space key
.equ  a_sound = 396           ; sound
.equ  a_tile_pic = 0          ; first address of tile picture memory
.equ  a_spr_pic_n = 300       ; first address of sprite picture memory (sprite num)
.equ  a_spr_pic_x = 332       ; first address of sprite picture memory (x pos)
.equ  a_spr_pic_y = 364       ; first address of sprite picture memory (y pos)

; registers
.def  r_tmp0 = r0             ; temporary register 0
.def  r_tmp1 = r1             ; temporary register 1
.def  r_tmp2 = r2             ; temporary register 2
.def  r_tmp3 = r3             ; temporary register 3
.def  r_tmp4 = r4             ; temporary register 4
.def  r_tmp5 = r5             ; temporary register 5
.def  r_tmp6 = r21            ; temporary register 0
.def  r_tmp7 = r22            ; temporary register 1
.def  r_tmp8 = r23            ; temporary register 2
.def  r_tmp9 = r24            ; temporary register 3
.def  r_tmp10 = r25           ; temporary register 4
.def  r_tmp11 = r26           ; temporary register 5

.def  r_x = r6                ; used for coordinates
.def  r_y = r7                ; used for coordinates
.def  r_cycles = r8           ; cycles since last tick
.def  r_ticks = r9            ; current tick count since start of game
.def  r_chord = r10           ; current chord number
.def  r_chord_addr = r11      ; address to current chord in song
.def  r_chord_ticks = r12     ; ticks spent on current chord
.def  r_qwert = r13           ; keys pressed (only q pressed will be 0b10000)
.def  r_space = r14           ; != 0 if space pressed
.def  r_chord_handled = r15   ; = 0 if row hasn't been completed or failed
.def  r_chord_keys = r16      ; keys of current row
.def  r_chord_note = r17      ; note of current row
.def  r_chords_to_draw = r18  ; chords left to draw
.def  r_notes_to_draw = r19   ; notes left to draw on each row
.def  r_last_chord_y = r20    ; y position of last row

; program
INIT:
  ; initialize game data
  ldi   r_cycles,0            ; start at 0 cycles
  ldi   r_ticks,0             ; start at 0 ticks
  ldi   r_chord,0             ; start at chord 0
  ldi   r_chord_addr,a_song   ; store address of first row
  ldi   r_chord_ticks,0       ; start at tick 0 of current row
  ldi   r_chord_handled,0     ; first chord hasn't been handled
  lds   r_chord_note,a_chord  ; store note for first row
  lds   r_chord_keys,a_chord  ; store keys required for first row
  lsr   r_chord_keys,3        ; move chord_keys to least significant bits
INIT_DRAW:
  ; draw background
  ldi   r_tmp0,c_tile_bg      ; store tile number of background
  ldi   r_tmp1,a_tile_pic     ; load beginning of tile_pic_mem
  ldi   r_y,c_tiles_per_row   ; row counter
INIT_DRAW_BG_ROW:
  ; draw a row
  ldi   r_x,c_tiles_per_col   ; col counter
INIT_DRAW_BG_COL:
  ; draw a column
  st    r_tmp1,r_tmp0         ; write background to tile_pic_mem ()
  inc   r_tmp1                ; go to next tile in tile picture memory
  ; draw remaining cols
  dec   r_x
  cpi   r_x,0
  brne  INIT_DRAW_BG_COL
  ; draw remaining rows
  dec   r_y
  cpi   r_y,0
  brne  INIT_DRAW_BG_ROW


LOOP:
  inc   r_cycles              ; increment cycles
  cpi   r_cycles,c_cycles_per_tick
  brne  LOOP                  ; only tick if enough cycles have passed
  ldi   r_cycles,0            ; reset cycle count for next loop
TICK:
  ; execute one game tick
  inc   r_ticks               ; increment ticks
INPUT:
  ; read input
  ldi   r_qwert,0             ; clear input

  lds   r_tmp0,a_q            ; load q state to temporary register
  or    r_qwert,r_input,r_tmp0; load q state in qwert
  lsl   r_qwert,1             ; shift q to the left to make room for w
  lds   r_tmp0,a_w            ; repeat for w, e, r, t
  or    r_qwert,r_qwert,r_tmp0
  lsl   r_qwert,1
  lds   r_tmp0,a_e
  or    r_qwert,r_qwert,r_tmp0
  lsl   r_qwert,1
  lds   r_tmp0,a_r
  or    r_qwert,r_qwert,r_tmp0
  lsl   r_qwert,1
  lds   r_tmp0,a_t
  or    r_qwert,r_qwert,r_tmp0
  lsl   r_qwert,1

  lds   r_space,a_space       ; load space state in space register
UPDATE:
  ; update logic
  inc   r_chord_ticks         ; one more tick spent on chord
  cpi   r_chord_ticks,c_ticks_per_chord
  brne  CHORD_HANDLE          ; continue with current chord if end not reached
CHORD_END:
  ldi   r_chord_ticks,0       ; otherwise, stop any current sound and go to next chord
  inc   r_chord
  inc   r_chord_addr
  ldi   r_tmp0,0              ; stop current chord sound
  sts   a_sound,r_tmp0
CHORD_HANDLE:
  cpi   r_chord_handled,0     ; check if chord has been handled
  brne  DRAW                  ; if the chord has already been handled, go to draw
  subi  r_tmp0,r_chord_ticks,c_strum_start
  brmi  BEFORE_INTERVAL       ; currently before interval if chord ticks < strum start ticks
  subi  r_tmp0,r_chord_ticks,c_strum_end
  brmi  INSIDE_INTERVAL       ; currently inside interval if chord ticks < strum end ticks
  jmp   AFTER_INTERVAL        ; currently after interval if not before or inside interval
BEFORE_INTERVAL:
  ; currently after of the interval where it is allowed to strum
  ; if the strum is pressed here, the chord was missed
  cpi   r_space,1
  breq  CHORD_FAIL            ; fail if space is down
  jmp   DRAW                  ; draw and wait otherwise
INSIDE_INTERVAL:
  ; currently inside of the interval where it is allowed to strum
  ; if the strum is pressed and all keys are correct, the chord note will play
  cpi   r_space,0
  breq  DRAW                  ; do nothing if strum is not pressed

  cp    r_qwert,r_chord_keys
  brne  ROW_FAIL            ; chord is failed if keys pressed are not correct

  ldi   r_chord_handled,1   ; otherwise, the chord was played successfully
  sts   a_sound,r_chord_note
  jmp   DRAW
AFTER_INTERVAL:
  ; currently after the interval where it is allowed to strum
  ; since we are here and the chord hasn't been handled the chord was missed
ROW_FAIL:
  ldi   r_chord_handled,1
  ldi   r_tmp0,0b1111
  sts   a_sound,r_tmp0        ; play fail sound

DRAW:
  ldi   r_tmp0,a_spr_pic_n    ; sprite num addr counter
  ldi   r_tmp1,a_spr_pic_x    ; sprite x addr counter
  ldi   r_tmp2,a_spr_pic_y    ; sprite y addr counter

  ld    r_tmp3,r_chord_addr   ; address of current chord
  ldi   r_y,disp_height       ; where to draw current chord, y
  ldi   r_tmp4,r_chord_ticks  ; begin from bottom
  lsr   r_tmp4,2              ; offset r_y depending on how many ticks that have been spent on chord
  sub   r_y,r_y,r_tmp4

  ldi   r_chords_to_draw,c_visible_chords
DRAW_CHORD:
  ld    r_tmp5,r_tmp3         ; song data of current chord
  lsr   r_tmp5,3              ; now contains which notes should be drawn on lsbs
  ldi   r_x,c_disp_width      ; where to draw current note, x
  subi  r_x,r_x,c_note_dist   ; begin from right
  ldi   r_notes_to_draw,5

  ldi   r_tmp6,c_sprite_note  ; load first sprite number
DRAW_NOTE:
  andi  r_tmp7,r_tmp5,0b1     ; tmp7 will now contain 1 if the note should be drawn, else 0
  ldi   r_tmp8,c_sprite_invis
  st    r_tmp0,r_tmp8         ; make note invisible temporarily
  cpi   r_tmp7,0
  breq  NO_NOTE               ; don't draw if there is no note

  st    r_tmp0,r_tmp6         ; set sprite number to note's number
  st    r_tmp1,r_x            ; set sprite x to note's x
  st    r_tmp2,r_y            ; set sprite x to note's y

NO_NOTE:
  inc   r_tmp0                ; go to next sprite index
  inc   r_tmp1
  inc   r_tmp2
  lsr   r_tmp5                ; go to next note on chord
  subi  r_x,r_x,note_dist     ; move to position of next note
  inc   r_tmp6                ; go to next sprite number

  dec   r_notes_to_draw       ; loop counter
  cp    r_notes_to_draw,0     ; condition check
  brne  DRAW_NOTE             ; keep looping/exit

  subi  r_y,r_y,chord_dist    ; move to position of next chord

  dec   r_chords_to_draw      ; loop counter
  cp    r_chords_to_draw,0    ; condition check
  brne  DRAW_CHORD            ; keep looping/exit

DRAW_NOTE_END:
  jmp   LOOP                  ; loop again
