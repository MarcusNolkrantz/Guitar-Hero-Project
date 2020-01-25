# Instructions and more

The assembly code is written with these instructions, macros and literal
definitions in mind.

## General info
### Data memory
|memory               |length |from   |to     |comment            |
|---                  |---    |---    |---    |---                |
|tile picture memory  |300    |0      |299    |20*15 tiles        |
|sprite number memory |32     |300    |331    |32 sprites         |
|sprite x memory      |32     |332    |363    |32 sprites         |
|sprite y memory      |32     |364    |395    |32 sprites         |
|audio memory         |1      |396    |396    |1 sound at a time  |
|keyboard memory      |8      |397    |404    |qwert,space        |
|collision memory     |1      |405    |405    |1 if collision     |
|data memory          |619    |406    |1023   |song + remaining   |




## Macros
### comment
Write a comment.
```
; comment text
```

### constant
Define a constant. Any instances of the identifier will be replaced with the value.
```
.equ  identifier = value
```

### register alias
Define a register alias. Any instances of the identifier will be replaced with the register.
```
.def  identifier = register
```

### label
Define a label. Any instances of the label will be replaced with the address of the line after it in program memory.
```
NAME:
  ; ...
```

## Literals

### decimal literal
```
47
```

### binary literal
```
0b10100
```

### hex literal
```
0xFFA0
```


## Instructions


### nop - no operation
Does nothing. Ignored in every pipeline step.

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)     |addr(9-0)      |
|---      |---        |---        |---        |---        |---            |
|0        |[nothing]  |[nothing]  |[nothing]  |[nothing]  |[nothing]      |

```
nop
```

### ld - load indirect from data space to register using register
Uses address stored in register1 to get value from data space to store in
register0.

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)     |addr(9-0)      |
|---      |---        |---        |---        |---        |---            |
|1        |[register0]|[register1]|[nothing]  |[nothing]  |[nothing]      |

```
ld [register0],[register1]
ld r0,r1
```


### lds - load direct from data space
Load content of address in data space to register.

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)     |addr(9-0)      |
|---      |---        |---        |---        |---        |---            |
|2        |[register] |[nothing]  |[nothing]  |[nothing]  |[address]      |

```
lds [register],[address]
lds r0,0xF0
```


### ldi - load immediate
Load immediate to register.


|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)     |addr(9-0)      |
|---      |---        |---        |---        |---        |---            |
|3        |[register] |[nothing]  |[nothing]  |[immediate]|[nothing]      |

```
ldi [register],[immediate]
ldi r0,10
```


### st - store indirect from register to data space using register
Store contents of register1 to address in data space given by register0.

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)     |addr(9-0)      |
|---      |---        |---        |---        |---        |---            |
|4        |[register0]|[register1]|[nothing]  |[nothing]  |[nothing]      |

```
st [register0],[register1]
st r0,r1
```


### sts - store direct to data space
Store contents of register to immediate address in data space.

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)     |addr(9-0)      |
|---      |---        |---        |---        |---        |---            |
|5        |[nothing]  |[register] |[nothing]  |[nothing]  |[address]      |

```
sts [address],[register]
sts 0xF0,r0
```


### subi - subtract with immediate
Subtract immediate value from register1 and store result in register0.

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)     |addr(9-0)      |
|---      |---        |---        |---        |---        |---            |
|6        |[register0]|[register1]|[nothing]  |[immediate]|[nothing]      |

```
subi [register0],[register1],[immediate]
subi r0,r1,10
```



### lsr - logical shift right
Shifts contents of register en immediate of steps to the right.

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)     |addr(9-0)      |
|---      |---        |---        |---        |---        |---            |
|7        |[register] |[register] |[nothing]  |[immediate]|[nothing]      |

```
lsr [register], [immediate]
lsr r0, 3
```


### lsl - logical shift left
Shifts contents of register an immediate of steps to the left.

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)     |addr(9-0)      |
|---      |---        |---        |---        |---        |---            |
|8        |[register] |[register] |[nothing]  |[immediate]|[nothing]      |

```
lsl [register], [immediate]
lsl r0, 3
```


### or - logical or
Perform a logical or of register1 and register2  and store result in register0.

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)     |addr(9-0)      |
|---      |---        |---        |---        |---        |---            |
|9        |[register0]|[register1]|[register2]|[nothing]  |[nothing]      |

```
or [register0],[register1],[register2]
or r0,r1,r2
```


### cp - compare
Compare two register0 and register1 contents. Set zero flag if they are equal.

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)     |addr(9-0)      |
|---      |---        |---        |---        |---        |---            |
|10       |[nothing]  |[register0]|[register1]|[nothing]  |[nothing]      |

```
cp [register0],[register1]
cp r0,r1
```


### cpi - compare with immediate
Compare register contents with immediate. Set zero flag if they are equal.

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)     |addr(9-0)    |
|---      |---        |---        |---        |---        |---          |
|11       |[nothing]  |[register] |[nothing] |[immediate]|[nothing]    |

```
cpi [register],[immediate]
cpi r0,0
```


### jmp - jump
Jump to address in program memory.

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)     |addr(9-0)    |
|---      |---        |---        |---        |---        |---          |
|12       |[nothing]  |[nothing]  |[nothing]  |[nothing]  |[address]    |

```
jmp [address]
jmp LABEL
```


### brne - branch if not equal
Branch if the zero flag is not set.

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)     |addr(9-0)    |
|---      |---        |---        |---        |---        |---          |
|13       |[nothing]  |[nothing]  |[nothing]  |[nothing]  |[address]    |

```
brne [address]
brne LABEL
```


### breq - branch if equal
Branch if the zero flag is set.

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)     |addr(9-0)    |
|---      |---        |---        |---        |---        |---          |
|14       |[nothing]  |[nothing]  |[nothing]  |[nothing]  |[address]    |

```
breq [address]
breq LABEL
```


### brmi - branch if minus
Branch if the negative flag is set.

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)     |addr(9-0)    |
|---      |---        |---        |---        |---        |---          |
|15       |[nothing]  |[nothing]  |[nothing]  |[nothing]  |[address]    |

```
brmi [address]
brmi LABEL
```


### brpl - branch if plus
Branch if zero and negative flag are not set.

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)     |addr(9-0)    |
|---      |---        |---        |---        |---        |---          |
|16       |[nothing]  |[nothing]  |[nothing]  |[nothing]  |[address]    |

```
brpl [address]
brpl LABEL
```



### sub - subtract
Subtract register1 from register2 and store result to register0

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)     |addr(9-0)      |
|---      |---        |---        |---        |---        |---            |
|17       |[register0]|[register1]|[register2]|[nothing]  |[nothing]      |

```
sub [register0],[register1],[register2]
sub r0,r1,r2
```



### add - add
Add register1 and register2 and store result to register0

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)       |addr(9-0)      |
|---      |---        |---        |---        |---          |---            |
|18       |[register0]|[register1]|[register2]|[nothing]    |[nothing]      |

```
addi [register0],[register1],[register2]
addi r0,r1,10
```



### addi - add with immediate
Add immediate to register1 and store in register0.

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)       |addr(9-0)      |
|---      |---        |---        |---        |---          |---            |
|19       |[register0]|[register1]|[nothing]  |-[immediate] |[nothing]      |

```
addi [register0],[register1],[immediate]
addi r0,r1,10
```


### inc - increment
Increment register contents by one.

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)     |addr(9-0)      |
|---      |---        |---        |---        |---        |---            |
|20       |[register] |[register] |[nothing]  |-1         |[nothing]      |

```
inc [register]
inc r0
```



### dec - decrement
Decrement register contents by one.

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)     |addr(9-0)      |
|---      |---        |---        |---        |---        |---            |
|21       |[register] |[register] |[nothing]  |1          |[nothing]      |

```
dec [register]
dec r0
```


### and - and
Takes register1 AND register2 and store result to register0

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)       |addr(9-0)      |
|---      |---        |---        |---        |---          |---            |
|22       |[register0]|[register1]|[register2]|[nothing]    |[nothing]      |

```
and [register0],[register1],[register2]
addi r0,r1,10
```



### andi - and with immediate
Takes register1 AND an immediate and store the result in register0.

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)       |addr(9-0)      |
|---      |---        |---        |---        |---          |---            |
|23       |[register0]|[register1]|[nothing]  |-[immediate] |[nothing]      |

```
and1 [register0],[register1],[immediate]
andi r0,r1,10
```



### ori - or with immediate
Takes register1 OR an immediate and store the result in register0.

|op(31-26)|d(25-18)   |a(17-10)   |b(9-2)     |i(9-0)       |addr(9-0)      |
|---      |---        |---        |---        |---          |---            |
|24       |[register0]|[register1]|[nothing]  |-[immediate] |[nothing]      |

```
ori [register0],[register1],[immediate]
ori r0,r1,10
```
