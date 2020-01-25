import assembler
from os import path
import sys

args = sys.argv

def main(in_name, out_name = ""):
    if out_name == "":
        out_name = in_name
    base_path = path.dirname(__file__)
    assembler.main(in_name, out_name, base_path)

if __name__ == "__main__":
    if len(args) > 1:
        if args[1] == "h":
            print("This is the help page")
        elif len(args) == 2:
            if type(args[1]) is str:
                main(args[1])
        elif len(args) == 3:
            if type(args[1]) is str and type(args[2]) is str:
                main(args[1], args[2])
        else:
            print("The argument is not recognized")
    else:
        print("No argument for the filename was passed")
