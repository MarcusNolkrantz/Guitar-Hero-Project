"""Canvas module."""

import tkinter as tk
import tool


class Canvas(tk.Canvas):
    """Canvas class."""

    def __init__(self, master, image, palette, scale):
        """Create canvas."""
        # call canvas constructor
        super().__init__(master, width=image.columns*scale, height=image.rows*scale)
        # set shape variables
        self.scale = scale
        self.image = image
        self.columns = image.columns
        self.rows = image.rows
        self.fill_active = False
        # click handler
        self.bind("<Button-1>", self.on_click)
        self.bind("<B1-Motion>", self.on_click)
        # store palette
        self.palette = palette
        # draw based on image
        for row in range(self.rows):
            for col in range(self.columns):
                color = self.image.get_pixel(col, row)
                self.create_rectangle(col*self.scale, row*self.scale,
                                      (col+1)*self.scale, (row+1)*self.scale,
                                      fill=self.palette.get_color_value(color))


    def on_click(self, event):
        """Draw at mouse position depending on palette color."""
        col = event.x // self.scale
        row = event.y // self.scale
        if not self.fill_active:
            self.paint(col, row)
        else:
            self.fill(col, row)


    def toggle_fill(self):
        """Toggle fill."""
        self.fill_active = not self.fill_active


    def paint(self, col, row):
        """Paint tool."""
        # draw to screen
        self.create_rectangle(col*self.scale, row*self.scale,
                              (col+1)*self.scale, (row+1)*self.scale,
                              fill=self.palette.get_color_value())

        # draw to image
        self.image.set_pixel(col, row, self.palette.get_color_number())


    def fill(self, col, row):
        """Fill tool."""
        # bfs
        color = self.image.get_pixel(col, row)
        visited = [[False for c in range(self.image.columns)] for r in range(self.image.rows)]
        queue = []
        queue.append((col, row))
        visited[row][col] = True
        while queue:
            c, r = queue.pop(0)
            self.paint(c, r)
            for n in self.image.neighbors(c, r):
                nc, nr = n
                neighbor_color = self.image.get_pixel(nc, nr)
                neighbor_visited = visited[nr][nc]
                if not neighbor_visited and color == neighbor_color:
                    queue.append(n)
                    visited[nr][nc] = True
