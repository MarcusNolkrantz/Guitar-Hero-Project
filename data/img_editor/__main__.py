#!/usr/bin/env python3
"""Image editor entry point."""

import pickle
import argparse
import os
import tkinter as tk
import functools
from tkinter import filedialog
from palette import Palette
from image import Image
from canvas import Canvas
import colors


def main():
    """Image editor entry point."""
    print("starting image editor")

    # parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("file", help="file name")
    parser.add_argument("-c", "--columns", help="columns of new image", type=int, default=8)
    parser.add_argument("-r", "--rows", help="rows of new image", type=int, default=8)
    parser.add_argument("-s", "--scale", help="screen pixels per image pixel", type=int, default=32)
    parser.add_argument("-b", "--bits", help="bits per color (4/8)", type=int, default=8)
    args = parser.parse_args()

    file = args.file
    columns = args.columns
    rows = args.rows
    scale = args.scale
    color_list = colors.FPGA_8_BIT_COLORS if args.bits == 8 else colors.EGA_4_BIT_COLORS
    # create blank image
    image = Image(columns, rows)

    if os.path.isfile(file):
        # load image if file exists
        image.load(file)
        rows = image.rows
        columns = image.columns


    # create editor
    master = tk.Tk()
    master.resizable(False, False)
    master.title("image editor")

    # palette
    palette_window = tk.Toplevel(master)
    palette_window.resizable(False, False)
    palette_window.title("palette")
    palette = Palette(palette_window,
                      colors=color_list,
                      columns=16,
                      rows=len(color_list) // 16,
                      scale=scale)
    palette.pack()

    # canvas
    canvas = Canvas(master, image=image, palette=palette, scale=scale)
    canvas.pack(side=tk.LEFT)

    # buttons
    btn_toggle_fill = tk.Button(master, text="toggle fill",
                           command=canvas.toggle_fill)
    btn_toggle_fill.pack(side=tk.BOTTOM)
    btn_save = tk.Button(master, text="save",
                         command=functools.partial(image.save, file))
    btn_save.pack(side=tk.BOTTOM)
    btn_export = tk.Button(master, text="export",
                           command=functools.partial(image.export, file + ".vhd"))
    btn_export.pack(side=tk.BOTTOM)

    # start editor
    tk.mainloop()


if __name__ == "__main__":
    main()
