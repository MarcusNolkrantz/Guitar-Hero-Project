DELAY:
	ldi r4, 1023
JMP3:
	ldi r3, 1023
JMP2:
	ldi r2, 16
JMP1:
	dec r2
  cpi r2, 0
  brne JMP1
	dec r3
  cpi r3, 0
  brne JMP2
  dec r4
  cpi r4, 0
  brne JMP3
END:
  jmp END
