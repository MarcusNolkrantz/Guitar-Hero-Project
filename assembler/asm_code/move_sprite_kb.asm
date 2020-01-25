.def tile_counter = r20
.def reg_space = r21
.def reg_x = r22

.equ x_addr = 332
.equ x_val = 50
.equ tile_addr_start = 0
.equ tile_addr_end = 300
.equ space_addr = 402

INIT:
	ldi r0, 1
	sts 300, r0
	ldi reg_x, x_val
	sts x_addr, reg_x
MAIN_LOOP:
	jmp GET_INPUT	
MAIN_LOOP_2:
	addi reg_x,reg_x 2
	sts x_addr, reg_x
	jmp MAIN_LOOP

GET_INPUT:
	lds reg_space, space_addr
	cpi reg_space, 1
	brne GET_INPUT
GET_INPUT_2:
	lds reg_space, space_addr
	cpi reg_space, 0
	brne GET_INPUT_2
  jmp MAIN_LOOP_2
