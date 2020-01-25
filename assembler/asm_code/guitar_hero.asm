;
;
; GLOBAL REGISTER DEFINITIONS
;
;
.def  r_tmp0 = r31
.def  r_tmp1 = r30
.def  r_tmp2 = r29
.def  r_tmp3 = r28
.def  r_tmp4 = r27
.def  r_tmp5 = r26
.def  r_tmp6 = r20
.def  r_curr_chord_addr = r25
.def  r_curr_chord_notes = r24
.def  r_curr_chord_audio = r23
.def  r_curr_chord_y  = r22
.def  r_curr_chord_handled = r21
.def  r_input_qwert = r20
.def  r_input_space = r19
.def  r_input_space_prev = r18
.def  r_score_1 = r17
.def  r_score_10 = r16


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

; data memory
.equ  a_data_space_begin = 406

; game constants
.equ  c_disp_width = 160
.equ  c_disp_height = 120
.equ  c_disp_half_height = 60
.equ  c_chord_notes = 5
.equ  c_chord_dy = 32
.equ  c_visible_chords = 4
; 52*2 + 8*5 + 4*4 = 160 
.equ  c_note_dx = 12
.equ  c_chord_x = 100
; range where it is allowed to strum
.equ  c_strum_y_begin = 96
.equ  c_strum_y_end = 112
.equ  c_strum_y = 104

.equ  a_score_tile = 24
.equ  c_numbers_tile_n = 3

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
  .equ  c_guitar_x_begin = 6
  .equ  c_guitar_x_end = 13
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


  ; move button indicators for strummable area to correct positions
  .def  r_blank_x = r1
  .def  r_blank_y = r2
  ; initial positions
  ldi   r_blank_x,c_chord_x
  ldi   r_blank_y,c_strum_y
  ; locations in memory
  ldi   r_tmp0,a_sprite_x_space_begin
  addi  r_tmp0,r_tmp0,c_chord_notes
  ldi   r_tmp1,a_sprite_y_space_begin
  addi  r_tmp1,r_tmp1,c_chord_notes
  ; loop counter
  ldi   r_tmp2,0

  MOVE_BUTTON_INDICATOR:
    st    r_tmp0,r_blank_x
    st    r_tmp1,r_blank_y
    ; go to next x position
    subi  r_blank_x,r_blank_x,c_note_dx
    ; go to next sprite address
    inc   r_tmp0
    inc   r_tmp1
    ; continue if more button indicators to move
    inc   r_tmp2
    cpi   r_tmp2,c_chord_notes
    brne  MOVE_BUTTON_INDICATOR

  ; draw scoreboard
  ldi   r_tmp0,a_score_tile
  ldi   r_tmp1,c_numbers_tile_n
  st    r_tmp0,r_tmp1
  dec   r_tmp0  
  st    r_tmp0,r_tmp1

  ;
  ; Set initial game data
  ;

  ; beginning of song
  ldi   r_curr_chord_y,c_disp_height
  ldi   r_curr_chord_addr,a_data_space_begin
  ldi   r_curr_chord_handled,0
  ldi   r_score_1,0
  ldi   r_score_10,0


;
;
; Program loop
;
;
LOOP:
  .def  r_wait0 = r10
  .def  r_wait1 = r11
  .def  r_wait2 = r12
  ldi   r_wait0,15
WAIT0:
  ldi   r_wait1,511
WAIT1:
  ldi   r_wait2,1
WAIT2:
  ;
  ; Get input
  ;

  ; stores status of buttons qwert in r_input_qwert
  lds   r_input_qwert,a_keyboard_q
  
  
  lsl   r_input_qwert,1
  lds   r_tmp0,a_keyboard_w
  
  
  or    r_input_qwert,r_input_qwert,r_tmp0
  lsl   r_input_qwert,1
  lds   r_tmp0,a_keyboard_e
  
  
  or    r_input_qwert,r_input_qwert,r_tmp0
  lsl   r_input_qwert,1
  lds   r_tmp0,a_keyboard_r
  
  
  or    r_input_qwert,r_input_qwert,r_tmp0
  lsl   r_input_qwert,1
  lds   r_tmp0,a_keyboard_t
  
  
  or    r_input_qwert,r_input_qwert,r_tmp0

  lds   r_input_space,a_keyboard_space

  ; stop playing current sound when new note has traveled halfway to the strum
  cpi   r_curr_chord_y,c_disp_half_height
  brne  KEEP_AUDIO
  ldi   r_tmp0,0
  sts   a_audio_space,r_tmp0
KEEP_AUDIO:

  ;
  ; Check if user tried to play chord
  ;
  cpi   r_curr_chord_handled,0
  brne  CHORD_HANDLED
  ; check if space was pressed
  cpi   r_input_space,1
  brne  UPDATE_PREV_INPUT
  cpi   r_input_space_prev, 0
  brne  CHORD_HANDLED
  ldi   r_input_space_prev, 1
  ; strum active, check if chord is within strummable area
  cpi   r_curr_chord_y,c_strum_y_begin
  brmi  CHORD_FAILED
  cpi   r_curr_chord_y,c_strum_y_end
  brpl  CHORD_FAILED
  ; check if the correct keys are pressed
  cp    r_curr_chord_notes,r_input_qwert
  brne  CHORD_FAILED
  ; otherwise, chord was played successfully
CHORD_SUCCEEDED:
  ; chord is now handled
  ldi   r_curr_chord_handled,1
  ; play chord audio
  sts   a_audio_space,r_curr_chord_audio

  ;
  ; Update scoreboard
  ;
  inc   r_score_1
  cpi   r_score_1,10
  brne  UPDATE_SCORE
  ldi   r_score_1,0
  inc   r_score_10
UPDATE_SCORE:
  ldi   r_tmp0,a_score_tile
  ldi   r_tmp1,c_numbers_tile_n
  add   r_tmp1,r_tmp1,r_score_1
  st    r_tmp0,r_tmp1

  dec   r_tmp0
  ldi   r_tmp1,c_numbers_tile_n
  add   r_tmp1,r_tmp1,r_score_10
  st    r_tmp0,r_tmp1
  


  jmp   CHORD_HANDLED
CHORD_FAILED:
  ; chord is now handled
  ldi   r_curr_chord_handled,1
  ; stop playing audio
  ldi   r_tmp0,0
  sts   a_audio_space,r_tmp0
  jmp CHORD_HANDLED

UPDATE_PREV_INPUT:
  ldi   r_input_space_prev, 0
    
CHORD_HANDLED:

  ;
  ; Set sprite numbers for button indicators
  ;
  .equ  c_sprite_num_blank_note = 6
  .equ  c_sprite_num_pressed_note = 7
  .def  r_blank_n = r0
  ; sprite n location in memory
  ldi   r_tmp0,a_sprite_n_space_begin
  addi  r_tmp0,r_tmp0,c_chord_notes
  ; loop counter
  ldi   r_tmp1,0
  ; copy input
  ldi   r_tmp2,0
  or    r_tmp2,r_tmp2,r_input_qwert

  SET_BUTTON_INDICATOR:
    ; begin with blank indicator
    ldi   r_blank_n,c_sprite_num_blank_note
    ; check if indicator should be filled
    andi  r_tmp3,r_tmp2,1
    cpi   r_tmp3,1
    brne INDICATOR_DECIDED
    ldi   r_blank_n,c_sprite_num_pressed_note
  INDICATOR_DECIDED:
    st    r_tmp0,r_blank_n
    ; go to next indicator
    inc   r_tmp0
    ; check next key state
    lsr   r_tmp2,1
    ; continue if more indicators
    inc   r_tmp1
    cpi   r_tmp1,c_chord_notes
    brne  SET_BUTTON_INDICATOR
  
  ; wait
  dec   r_wait2
  cpi   r_wait2,0
  brne  WAIT2

  dec   r_wait1
  cpi   r_wait1,0
  brne  WAIT1

  dec   r_wait0
  cpi   r_wait0,0
  brne  WAIT0

;
; Tick program
;
TICK:
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
  ld    r_curr_chord_notes,r_curr_chord_addr
  
  
  ; exit if at end of song
  cpi   r_curr_chord_notes,1023
  breq  EXIT
  ; otherwise, load chord notes and audio
  lsr   r_curr_chord_notes,3
  ld    r_curr_chord_audio,r_curr_chord_addr
  
  
  ; chord starts at top of screen
  ldi   r_curr_chord_y,0
  ; chord starts as not handled
  ldi   r_curr_chord_handled,0

  ; the number of the first note sprite (has to be preceeded by the other 4)
  .equ  c_sprite_num_last_note = 5
  .def  r_new_note_n = r0
  .def  r_new_note_x = r1
  .def  r_new_note_y = r2
  ; initial data to write
  ldi   r_new_note_n,c_sprite_num_last_note
  ldi   r_new_note_x,c_chord_x
  ldi   r_new_note_y,0
  ; places to write to (first 5 sprites occupied by blank notes)
  ldi   r_tmp0,a_sprite_n_space_begin
  ldi   r_tmp1,a_sprite_x_space_begin
  ldi   r_tmp2,a_sprite_y_space_begin
  ; loop counter
  ldi   r_tmp3,0
  ; copy current chord notes
  ldi   r_tmp5,0
  or    r_tmp5,r_curr_chord_notes,r_tmp5

  NEW_NOTE_SPRITE:
    ; draw transparent note initially
    ldi   r_tmp6,0
    st    r_tmp0,r_tmp6

    andi  r_tmp4,r_tmp5,1
    cpi   r_tmp4,1
    brne  NOTE_SPRITE_DECIDED
    ; draw note
    st    r_tmp0,r_new_note_n
  NOTE_SPRITE_DECIDED:
    ; set position
    st    r_tmp1,r_new_note_x
    st    r_tmp2,r_new_note_y
    ; go to next x position
    subi  r_new_note_x,r_new_note_x,c_note_dx
    ; go to prev sprite num
    dec   r_new_note_n
    ; go to next note
    inc   r_tmp0
    inc   r_tmp1
    inc   r_tmp2
    ; check next bit in note data copy
    lsr   r_tmp5,1
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
