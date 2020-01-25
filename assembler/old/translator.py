import binary
debug = False

#Gets the name of a variable/register assuming the .def/.dw has been stripped from the line
def get_name(s : str):
    for e in range(len(s) - 1):
        if s[e] == " ":
            s = s[:e]
            break
    return s

#gets the arguments from each string
def get_arg(s : str):
    eq_i = s.find("=")
    arg = s[eq_i + 1 :]
    arg = arg.strip()
    return arg

#Gets variables from each string
def get_variables(data):
    variables = {}
    for line in data:
        if line.find(".equ ") is not -1:
            name = get_name(line[5:])
            arg = get_arg(line)
            variables[name] = arg
    return variables

def get_registers(data):
    registers = {}
    for line in data:
        if line.find(".def ") is not -1:
            name = get_name(line[5:])
            arg = get_arg(line)
            registers[name] = arg
    return registers

def replacer(data, vars, regs, labels):
    replace_vars(data, vars)
    replace_regs(data, regs)
    replace_labels(data,labels)

def replace_vars(data, vars):
    for i in range(len(data)):
        for key in vars:
            fix_key = " " + key + " "
            found = data[i].find(fix_key)
            if found is not -1:
                data[i] = data[i].replace(key, vars[key])

def replace_regs(data, regs):
    reg_addrs = {"r0":"0b00000000", "r1":"0b00000001", "r2":"0b00000010","r3":"0b00000011","r4":"0b00000100","r5":"0b00000101",
                "r6":"0b00000110", "r7":"0b00000111", "r8":"0b00001000","r9":"0b00001001","r10":"0b00001010","r11":"0b00001011",
                "r12":"0b00001100", "r13":"0b00001101", "r14":"0b00001110","r15":"0b00001111","r16":"0b00010000","r17":"0b00010001",
                "r18":"0b00010010", "r19":"0b00010011", "r20":"0b00010100","r21":"0b00010101","r22":"0b00010110","r23":"0b00010111",
                "r24" : "0b00011000", "r25":"0b00011001", "r26":"0b00011010"}
    for i in range(len(data)):
        for key in regs:

            found = data[i].find(" " + key + " ")
            if found is not -1:
                data[i] = data[i].replace(" " + key + " ", " " + regs[key] +" ")
                found = data[i].find(" " + key + " ")
                if found:
                    data[i] = data[i].replace(" " + key + " ", " " + regs[key] + " ")
    for i in range(len(data)):
        for key in reg_addrs:
            found = data[i].find(" " + key + " ")
            if found is not -1:
                data[i] = data[i].replace(" " + key + " ", " " + reg_addrs[key] + " ")
                found = data[i].find(" " + key + " ")
                if found:
                    data[i] = data[i].replace(" " + key + " ", " " + reg_addrs[key] + " ")

def get_labels(data):
    labels = {}
    correction = 0
    for i in range(len(data)):
        found = data[i].find(":")
        if found is not -1:
            labels[data[i][:found]] = i - correction
            correction += 1
    return labels

def replace_labels(data, labels):
    for i in range(len(data)):
        for key in labels:
            fix_key = " " + key + " "
            found = data[i].find(fix_key)
            if found is not -1:
                data[i] = data[i].replace(key, str(labels[key]))


def get_binary(data):
    for i in range(len(data)):
        data[i] = data[i].split(" ")
        temp = []
        for j in range(len(data[i])):
            op = data[i][0]
            if data[i][j] == "":
                break
            if j is 0:
                temp.append(binary.set_op(data[i][j]))
            if j is 1:
                #checks if there are variants of subi that need to be positive/negative
                if op in ["inc", "dec"]:
                    temp.append(binary.set_arg(data[i][1], 8))
                    temp.append(binary.set_arg(data[i][1], 8))

                #if there is a jump the address will be 10 bits long,
                elif op in ["breq", "jmp", "brmi", "brne"]:
                    temp.append(binary.set_arg(data[i][j],10))
                #if the instruction has the same destination and A register, they are duplicated here
                elif op in ["lsl", "lsr"]:
                    temp.append(binary.set_arg(data[i][1], 8))
                    temp.append(binary.set_arg(data[i][1], 8))
                elif op in ["sts"]:
                    temp.append(binary.set_arg(data[i][2], 16))
                    temp.append(binary.set_arg(data[i][j], 10))
                else:
                    temp.append(binary.set_arg(data[i][j], 8 ))
            if j is 2:
                if op not in ["sts", "ldi", "cpi", "lds"]:
                    temp.append(binary.set_arg(data[i][j], 8))
                elif op in ["ldi", "cpi", "lsl", "lds"]:
                    temp.append(binary.set_arg(data[i][j], 10))
            if j is 3:
                if op in ["subi", "addi", "andi", "ori"]:
                    temp.append(binary.set_arg(data[i][j], 10))

                else:
                    temp.append(binary.set_arg(data[i][j], 8))
        if debug:
            print("Instruction " +str(i) +": " + op + " had " + str(j) + " arguments.")
        data[i] = temp

    return data


