DELAY:
	ldi r4, 2
	ldi r3, 2
	ldi r2, 2

	dec r2
  cpi r2, 0
  brne 11
	dec r3
  cpi r3, 0
  brne 10
  dec r4
  cpi r4, 0
  brne 9 
  jmp RUN2
