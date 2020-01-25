;
;
; GLOBAL REGISTER DEFINITIONS
;
;
.def  r_tmp0 = r15
.def  r_tmp1 = r14
.def  r_tmp2 = r13
.def  r_tmp3 = r12
.def  r_tmp4 = r11
.def  r_curr_chord_addr = r10
.def  r_curr_chord_data = r9
.def  r_curr_chord_y  = r8


;
;
; GLOBAL CONSTANT DEFINITIONS
;
;

; tile memory
.equ  a_tile_space_begin = 0
.equ  a_tile_space_end = 300

; sprite memory
.equ  a_sprite_n_space_begin = 300
.equ  a_sprite_n_space_end = 332
.equ  a_sprite_x_space_begin = 332
.equ  a_sprite_x_space_end = 364
.equ  a_sprite_y_space_begin = 364
.equ  a_sprite_y_space_end = 396

; audio memory
.equ  a_audio_space = 396

; keyboard memory
.equ  a_keyboard_q = 397
.equ  a_keyboard_w = 398
.equ  a_keyboard_e = 399
.equ  a_keyboard_r = 400
.equ  a_keyboard_t = 401
.equ  a_keyboard_space = 402

; collision memory
.equ  a_collision = 405

; data memory
.equ  a_data_space_begin = 406

; game constants
.equ  c_disp_width = 160
.equ  c_disp_height = 120
.equ  c_chord_notes = 5
.equ  c_chord_dy = 32
.equ  c_visible_chords = 4
; 52*2 + 8*5 + 4*4 = 160 
.equ  c_note_dx = 12
.equ  c_chord_x = 52
; range where it is allowed to strum
.equ  c_strum_y_begin = 100
.equ  c_strum_y_end   = 108


;
;
; INITIALIZE PROGRAM
;
;
INIT:
  ;
  ; Draw tiles (background and guitar)
  ;
  .equ  c_tile_num_bg = 1
  .equ  c_tile_num_guitar = 2
  .equ  c_tile_cols = 20
  .equ  c_tile_rows = 15
  .equ  c_guitar_x_begin = 9
  .equ  c_guitar_x_end = 14
  .def  r_tile = r0
  .def  r_tile_num = r1
  .def  r_tile_x = r2
  .def  r_tile_y = r3

  ldi   r_tile,a_tile_space_begin
  ldi   r_tile_y,0
  DRAW_TILE_ROW:
    ldi   r_tile_x,0
    DRAW_TILE_COL:
      ; determine which tile number to use
      ldi   r_tile_num,c_tile_num_bg
      cpi   r_tile_x,c_guitar_x_begin
      brmi  DRAW_TILE
      cpi   r_tile_x,c_guitar_x_end
      brpl  DRAW_TILE
      ; tile is within guitar bounds
      ldi   r_tile_num,c_tile_num_guitar
    DRAW_TILE:
      ; draw tile
      st    r_tile,r_tile_num
      ; go to next tile
      inc   r_tile
      ; go to next column
      inc   r_tile_x
      cpi   r_tile_x,c_tile_cols
      brne  DRAW_TILE_COL
    ; go to next row
    inc   r_tile_y
    cpi   r_tile_y,c_tile_rows
    brne  DRAW_TILE_ROW

  ;
  ; Draw sprites for strummable area, 5 blank notes
  ;
  .equ  c_sprite_num_blank_note = 6
  .def  r_blank_n = r0
  .def  r_blank_x = r1
  .def  r_blank_y = r2

  ldi   r_blank_n,c_sprite_num_blank_note
  ldi   r_blank_x,c_chord_x
  ldi   r_blank_y,c_strum_y

  ldi   r_tmp0,a_sprite_n_space_begin
  ldi   r_tmp1,a_sprite_x_space_begin
  ldi   r_tmp2,a_sprite_y_space_begin
  ldi   r_tmp3,0

  DRAW_BLANK_NOTE_COL:
    ; draw first blank note
    st    r_tmp0,r_blank_n
    st    r_tmp1,r_blank_x
    st    r_tmp2,r_blank_y
    ; go to next x position
    addi  r_blank_x,r_blank_x,c_note_dx
    ; go to next blank
    inc   r_tmp0
    inc   r_tmp1
    inc   r_tmp2
    ; continue if more blanks
    inc   r_tmp3
    cpi   r_tmp3,c_chord_notes
    brne  DRAW_BLANK_NOTE_COL

  ;
  ; Set initial game data
  ;

  ; beginning of song
  ldi   r_curr_chord_y,c_disp_height
  ldi   r_curr_chord_addr,a_data_space_begin


;
;
; Program loop
;
;
LOOP:


;
; Tick program
;
TICK:
  ; register to store current chord notes and sound
  .def  r_curr_chord_notes = r0
  .def  r_curr_chord_sound = r1
  ; go to next chord if current chord has reached end of screen
  cpi   r_curr_chord_y,c_disp_height
  breq  NEW_CHORD
  ; otherwise, update existing chord
  jmp   OLD_CHORD

;
; Update an old chord (move it down)
;
OLD_CHORD:
  ; move current chord down
  inc   r_curr_chord_y
  ; move sprites
  ldi   r_tmp0,a_sprite_y_space_begin
  addi  r_tmp0,r_tmp2,5
  ; loop counter
  ldi   r_tmp1,0
  OLD_NOTE_SPRITE:
    ; move note down
    st    r_tmp0,r_curr_chord_y
    ; go to next note
    inc   r_tmp0
    ; continue if more notes
    inc   r_tmp1
    cpi   r_tmp1,c_chord_notes
    brne  OLD_NOTE_SPRITE
  ; wait for next tick
  jmp   LOOP

;
; Initialize a new chord
;
NEW_CHORD:
  ; get chord data
  ld    r_curr_chord_data,r_curr_chord_addr
  ; exit if at end of song
  cpi   r_curr_chord_data,0
  breq  EXIT
  ; otherwise, load chord notes and sound
  ld    r_curr_chord_notes,r_curr_chord_addr
  lsr   r_curr_chord_notes,3
  ld    r_curr_chord_sound,r_curr_chord_addr
  ; chord starts at top of screen
  ldi   r_curr_chord_y,0

  ; the number of the first note sprite (has to be followed by the other 4)
  .equ  c_sprite_num_first_note = 1
  .def  r_new_note_n = r2
  .def  r_new_note_x = r3
  .def  r_new_note_y = r4
  ; initial data to write
  ldi   r_new_note_n,c_sprite_num_first_note
  ldi   r_new_note_x,c_chord_x
  ldi   r_new_note_y,0
  ; places to write to (first 5 sprites occupied by blank notes)
  ldi   r_tmp0,a_sprite_n_space_begin
  addi  r_tmp0,r_tmp0,5
  ldi   r_tmp1,a_sprite_x_space_begin
  addi  r_tmp1,r_tmp1,5
  ldi   r_tmp2,a_sprite_y_space_begin
  addi  r_tmp2,r_tmp2,5
  ; loop counter
  ldi   r_tmp3,0
  NEW_NOTE_SPRITE:
    ; check if note should be drawn
    andi  r_tmp4,r_curr_chord_notes,1
    cpi   r_tmp4,1
    brne  NEW_NOTE_SPRITE_NEXT
    ; draw note
    st    r_tmp0,r_new_note_n
    st    r_tmp1,r_new_note_x
    st    r_tmp2,r_new_note_y
  NEW_NOTE_SPRITE_NEXT:
    ; go to next x position
    addi  r_new_note_x,r_new_note_x,c_note_dx
    ; go to next sprite num
    inc   r_new_note_n
    ; go to next note
    inc   r_tmp0
    inc   r_tmp1
    inc   r_tmp2
    ; check next bit in note data
    lsr   r_curr_chord_notes
    ; continue if more notes
    inc   r_tmp3
    cpi   r_tmp3,c_chord_notes
    brne  NEW_NOTE_SPRITE
  ; update chord address
  inc   r_curr_chord_addr
  ; wait for next tick
  jmp   LOOP
  

;
; Exit program
;
EXIT:
  jmp   EXIT