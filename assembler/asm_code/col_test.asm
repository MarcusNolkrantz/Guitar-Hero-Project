.equ sprite_num_1 = 300
.equ sprite_x_1 = 332
.equ sprite_y_1 = 364
.equ sprite_num_2 = 301
.equ sprite_x_2 = 333
.equ sprite_y_2 = 365
.equ kb_q = 397
.equ col_mem = 405

.def color = r2
.def cur_y = r1


draw_static:
	ldi r0, 1
	sts sprite_num_1, r0
	ldi r0, 50
	sts sprite_x_1, r0
	ldi r0, 100
	sts sprite_y_1, r0

  inc color
	sts sprite_num_2, color
	ldi r0, 50
	sts sprite_x_2, r0
	ldi cur_y, 0
	

WAIT_1:
	lds r0, kb_q
	cpi r0, 1
	brne WAIT_1
WAIT_2:
	lds r0, kb_q
	cpi r0, 0
	brne WAIT_2

UPDATE_SPRITE:
  inc cur_y
	sts sprite_y_2, cur_y
	lds r0, col_mem
	cpi r0, 1
	brne WAIT_1

CHANGE:	
	inc color
	sts sprite_num_2, color
	ldi r0, 0
	sts sprite_y_2, r0
	ldi cur_y, 0
	jmp WAIT_1
