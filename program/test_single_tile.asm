; expected output:
;

RUN:
  ldi r0,0
  ldi r1,1
  st  r0,r1   ; 1

  ldi r0,20
  ldi r1,1
  st  r0,r1   ; 2

  ldi r0,40
  ldi r1,1
  st  r0,r1   ; 3

  ldi r0,60
  ldi r1,1
  st  r0,r1   ; 4

  ldi r0,80
  ldi r1,1
  st  r0,r1   ; 5

  ldi r0,100
  ldi r1,1
  st  r0,r1   ; 6

  ldi r0,120
  ldi r1,1
  st  r0,r1   ; 7

  ldi r0,140
  ldi r1,1
  st  r0,r1   ; 8

  ldi r0,160
  ldi r1,1
  st  r0,r1   ; 9


  ldi r0,180
  ldi r1,1
  st  r0,r1   ; 10

  ldi r0,200
  ldi r1,1
  st  r0,r1   ; 11

  ldi r0,220
  ldi r1,1
  st  r0,r1   ; 12

  ldi r0,240
  ldi r1,1
  st  r0,r1   ; 13

  ldi r0,260
  ldi r1,1
  st  r0,r1   ; 14

  ldi r0,280
  ldi r1,1
  st  r0,r1   ; 15


END:
  jmp END
