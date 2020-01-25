def set_op(op):
    ops = {"nop":"000000", "ld": "000001", "lds":"000010", "ldi":"000011", "st":"000100", "sts":"000101", "subi":"000110",
           "addi":"010011","inc":"010100","dec":"010101","lsr":"000111", "lsl":"001000", "or":"001001", "andi":"010111", "cp":"001010", "cpi":"001011",
           "jmp":"001100", "brne":"001101", "breq":"001110", "brmi":"001111", "brpl":"010000", "sub":"010001", "add":"010010", "and":"010110", "ori":"011000"}
    found = False
    for key in ops:
        if op == key:
            op = ops[key]
            found = True
    if found:
        return op
    else:
        print("Cant find command: " + op)
        return "11111"


def set_arg(arg, bits, pos = 1):
    if arg[:2] == "0x":
        return bindigits(int(arg[2:], 16), bits)
    elif arg[:2] == "0b":
        return bindigits(int(arg[2:], 2), bits)
    elif arg.lstrip("-").isdigit():
        return bindigits(pos * int(arg), bits)
    else:
        print("Arg: " + arg + " in instruction"+  " was not a number, check so it's correct.")
        return "FFFFFF"


def bindigits(n, bits):
    s = bin(n & int("1"*bits, 2))[2:]
    return ("{0:0>%s}" % (bits)).format(s)