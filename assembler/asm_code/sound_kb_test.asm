.def tile_counter = r20
.def reg_space = r21
.def reg_x = r22


.equ x_addr = 332
.equ x_val = 50
.equ tile_addr_start = 0
.equ tile_addr_end = 300
.equ space_addr = 402
.equ audio_start = 0b0110001100

INIT:
	ldi r0, 1
	sts 300, r0
	ldi reg_x, x_val
	sts x_addr, reg_x
	ldi r10, 0
	ldi r11, 1

INIT_BACKGROUND:
	ldi r0, 1
DRAW_BACKGROUND:
	st tile_counter, r0
	inc tile_counter
	cpi tile_counter, tile_addr_end
	brne DRAW_BACKGROUND

MAIN_LOOP:
	jmp GET_INPUT
MAIN_LOOP_2:
	addi reg_x, reg_x, 2
	sts x_addr, reg_x
	jmp MAIN_LOOP

GET_INPUT:
	lds reg_space, space_addr
	sts audio_start, r11
	cpi reg_space, 1
	brne GET_INPUT
GET_INPUT_2:
	lds reg_space, space_addr
	sts audio_start, r10
	cpi reg_space, 0
	brne GET_INPUT_2
  jmp MAIN_LOOP_2