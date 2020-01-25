import tokenize
import re

#Removes all comments from each line
def clean_data(data):
    for i in range(len(data) ):
        for j in range(len(data[i]) - 1):
            if data[i][j] is ";":
                data[i] = data[i][0:j]
                break

#clean up all spaces and EOFs
def clean_chars(data):
    for i in range(len(data)):
        data[i] = re.sub('\t', ' ', data[i])
        data[i] = re.sub(' +', ' ', data[i])
        data[i] = data[i].lstrip()
        data[i] = re.sub(',', " ", data[i])
        data[i] = re.sub('\n', "", data[i])

def clean_labels(data):
    to_remove = []
    for i in range(len(data) - 1):
        found = data[i].find(":")
        if found is not -1:
            to_remove.append(i)
    to_remove = to_remove[::-1]
    for i in to_remove:
        data.pop(i)
    return data


#removes empty lines and labels from the list
def clean_empty_elem(data):
    to_remove = []
    for i in range(len(data)):
        found = data[i].find(":")
        if data[i] is "":
            to_remove.append(i)
    to_remove = to_remove[::-1]
    for i in to_remove:
        data.pop(i)

def add_correct_spacing(data):
    for i in range(len(data)):
        if data[i][len(data[i]) - 1] is not " ":
       	    data[i] = data[i] + " "

def clean_empty_lines(d):
    clean_data(d)
    clean_chars(d)
    clean_empty_elem(d)
    add_correct_spacing(d)
    clean_chars(d)
    return d


def clean_declerations(data):
    to_remove = []
    for i in range(len(data) - 1):
        if data[i].find(".equ") is not -1 or data[i].find(".def") is not -1:
            to_remove.append(i)
    to_remove = to_remove[::-1]
    for i in to_remove:
        data.pop(i)

#fixes the binary length of all finished binary code
def fix_length(data):
    #list of imediete instructions
    # reg = where the instruction is performed and returned to the same register
    # regreg= destination and 1 register is used
    # regi = destination and immidete/address
    # regregi = destination one argument and immidete/address
    # jmp = an instruction with only an address to jump to
    #fixa cp (001010) och cpi (001011)
    reg_types = {"000000":"nop","000001":"regreg", "000010":"regi", "000011":"regi", "000100":"regreg", "000101":"sts", "000110":"regregi",
           "000111":"shift", "001000":"shift", "001001":"regregreg", "001010":"comp", "001011":"comp", "001100":"jmp",
           "001101":"jmp" , "001110":"jmp", "001111":"jmp", "010000":"jmp", "010001":"regregreg", "010010":"regregreg", "010011":"regregi", "010100":"regreg",
           "010101":"regreg", "010110":"regregreg", "010111":"regregi", "011000":"regregi"}
    for i in range(len(data)):
        reg_type = False
        for op in reg_types:
            if op == data[i][0]:
                reg_type = reg_types[op]
        for j in range(len(data[i])):
            if j is 1:
                #destination
                if reg_type == "comp":
                    data[i][j] = set_len(data[i][j], 16)
                else:
                    data[i][j] = set_len(data[i][j], 8)
            if reg_type == "nop":
                data[i][j] = set_len(data[i][j], 32)
            #handles the cases with an immediate instruction
            if reg_type == "regi":
                if j is 2:
                    data[i][j] = set_len(data[i][j], 18)
            if reg_type == "sts":
                pass

            if reg_type == "shift":
                if j is 3:
                    data[i][j] = set_len(data[i][j], 10)
            if reg_type == "comp":
                if j is 1:
                    data[i][j] = set_len(data[i][j], 16)
                if j is 2:
                    data[i][j] = set_len(data[i][j], 8)
                    data[i][j] = set_len(data[i][j], 10, False)
            if reg_type == "reg":
                if j is 1:
                    data[i][j] = set_len(data[i][j], 8)
                if j is 2:
                    data[i][j] = set_len(data[i][j], 18, False)
            if reg_type == "regreg":
                if j is 1:
                    data[i][j] = set_len(data[i][j], 8)
                if j is 2:
                    data[i][j] = set_len(data[i][j], 18, False)
            if reg_type == "regregi":
                if j is 1:
                    data[i][j] = set_len(data[i][j], 8)
                if j is 2:
                    data[i][j] = set_len(data[i][j], 8)
                if j is 3:
                    data[i][j] = set_len(data[i][j], 8)
                    data[i][j] = set_len(data[i][j], 10, False)
            if reg_type == "regregreg":
                if j is 2 :
                    if (len(data[i][j]) > 8):
                        print("Arg: " + str(j) + " on line: " + str(i) + " was too long")
                        data[i][j] = data[i][j][len(data[i][j]) - 8:]
                    else:
                        data[i][j] = set_len(data[i][j], 8)
                if j is 3:
                    if (len(data[i][j]) > 8):
                        print("Arg: " + str(j) + " on line: " + str(i) + " was too long")
                        data[i][j] = data[i][j][len(data[i][j]) - 8:]
                    else:
                        data[i][j] = set_len(data[i][j], 8)
                        data[i][j] = set_len(data[i][j], 10, False)

            #handles instructions with only 1 argument, lsl, lsr etc.
            if reg_type == "jmp":
                if j is 1:
                    data[i][j] = set_len(data[i][j], 26)



    return data

def set_len(word, length, from_left = True):
    if from_left:
        while(len(word) < length):
            word = "0" + word
    else:
        while(len(word) < length):
            word = word + "0"
    return word
