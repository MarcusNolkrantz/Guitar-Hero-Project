"""Image module."""

import pickle


class Image:
    """Image class. An image is a two dimensional array of integers."""

    def __init__(self, columns=0, rows=0):
        """Create an image."""
        self.columns = columns
        self.rows = rows
        self.data = [[0 for col in range(columns)] for row in range(rows)]


    def get_pixel(self, col, row):
        """Get pixel."""
        return self.data[row][col]


    def set_pixel(self, col, row, color):
        """Set picolel."""
        self.data[row][col] = color


    def save(self, file):
        """Save to disk."""
        f = open(file, "wb")
        pickle.dump(self, f)
        f.close()


    def load(self, file):
        """Load from disk."""
        f = open(file, "rb")
        image = pickle.load(f)
        f.close()
        self.columns = image.columns
        self.rows = image.rows
        self.data = image.data


    def export(self, file):
        """Export to VHDL formatted string."""
        f = open(file, "w")
        for row in range(self.rows):
            for col in range(self.columns):
                color = self.data[row][col]
                hex = "{:02x}".format(color)
                f.write("x\"" + hex + "\",")
            f.write("\n")
        f.close()


    def neighbors(self, col, row):
        """Get neighbors."""
        neighbors = []
        delta = [(1,0),(-1,0),(0,1),(0,-1)]
        for dc, dr in delta:
            c, r = col + dc, row + dr
            if c >= 0 and c < self.columns and r >= 0 and r < self.rows:
                neighbors.append((c, r))
        return neighbors

    def __str__(self):
        """String representation."""
        return str(self.data)
