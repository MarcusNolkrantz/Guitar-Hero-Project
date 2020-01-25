"""Palette module."""

import tkinter as tk


class Palette(tk.Canvas):
    """Palette class."""

    def __init__(self, master, colors, columns, rows, scale):
        """Create palette."""
        # call canvas constructor
        super().__init__(master, width=columns*scale, height=rows*scale)
        # set color variables
        self.colors = colors if colors else []
        self.color = 0
        # set shape variables
        self.columns = columns
        self.rows = rows
        self.scale = scale
        # click handler
        self.bind("<Button-1>", self.on_click)

        # draw palette
        for row in range(self.rows):
            for col in range(self.columns):
                i = row*self.columns+col
                # stop drawing if there are no more colors
                if i >= len(self.colors):
                    break
                # draw color
                self.create_rectangle(col*self.scale, row*self.scale,
                                      (col+1)*self.scale, (row+1)*self.scale,
                                      fill=self.colors[i])


    def on_click(self, event):
        """Set color number and value depending on click position."""
        col = event.x // self.scale
        row = event.y // self.scale
        i = row * self.columns + col

        if i < len(self.colors):
            self.color = i

        print(self.get_color_number(), self.get_color_value())


    def get_color_number(self):
        """Return color number."""
        return self.color


    def get_color_value(self, color=None):
        """Return color value (hex string)."""
        return self.colors[self.color if not color else color]
