from PIL import Image

image = Image.open("colors.png")
pixels = image.load()

width, height = image.size
sections = 8
columns, rows = 4, 8

colors = []

for s in range(sections):
    for r in range(rows):
        for c in range(columns):
            x = s * width/sections + c * (width/sections/columns)
            y = r * (height/rows)
            rgb = pixels[x, y]
            r_hex = "{:02x}".format(rgb[0])
            g_hex = "{:02x}".format(rgb[1])
            b_hex = "{:02x}".format(rgb[2])
            hex = r_hex + g_hex + b_hex;
            colors.append('#' + hex)

print(colors)
