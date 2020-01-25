from os import path
import copy
import cleaner
import translator

def main(in_path, out_path, base_path, ):
    Debug = False

    file_path = path.abspath(path.join(base_path, "..","asm_code", in_path +".asm"))
    try:
        source_file =  open(file_path, "r")
    except:
        print("Unable to find path" + str(file_path))
        exit(1)
    source_data = source_file.readlines()
    data = cleaner.clean_empty_lines(source_data)
    variables = translator.get_variables(data)
    registers = translator.get_registers(data)
    cleaner.clean_declerations(data)


    labels = translator.get_labels(data)
    data = cleaner.clean_labels(data)
    translator.replacer(data, variables, registers, labels)
    test_data = copy.deepcopy(data)
    binary_code = translator.get_binary(data)
    #binary structure 32-bit
    #6 op - destination 8 bit - arg a 8 bit - arg b 8 bit - arg c 1 bit
    #
    # 6 op - dest 8 - arg a 8 bit - IR1_i 10
    # 6 op - dest 8 - ir1-addr 18
    binary_lines = cleaner.fix_length(binary_code)


    out_path = path.abspath(path.join(base_path, "..", "binary_code",out_path + ".txt"))
    f = open(out_path, "a+")
    f.truncate(0)
    f.write("--Labels: " + str(labels) + "\n")
    f.write("--Variables: " + str(variables) + "\n")
    f.write("--Registers: " + str(registers) + "\n")
    for i in range(len(binary_lines)):
        #immediete calls: ldi, subi, sti, cmpi
        imi = ["000001","001110","001100","000110"]

        full_line = ""

        for j in range(len(data[i])):
            full_line = full_line + data[i][j] + "_"
        full_line = "B\""+ full_line[:len(full_line) -1] + "\"," + " -- " + test_data[i]

        f.writelines(full_line+ "\n")


    f.close()
    print("Done")

