"""Builds static/imgs/matt-stretton-scrubs.webp from .doncheckin/Matt Stretton -4.jpg.

Crop the headroom, resize, even out the studio backdrop's light falloff so it is
one flat colour, then blend the left, right and top edges into that colour.
Run from the repository root: python3 scripts/make-about-photo.py (needs Pillow;
.doncheckin/ is not in git, so it runs only where the original photo is).
"""
from PIL import Image, ImageChops, ImageFilter

FLAT = (0x27, 0x2D, 0x31)  # $studio
src = Image.open('.doncheckin/Matt Stretton -4.jpg').convert('RGB').crop((0, 775, 2189, 3283))
im = src.resize((1440, 1650), Image.LANCZOS)
W, H = im.size

# 1. Estimate the backdrop on a coarse grid, away from Matt.
GW, GH = 72, 83  # about 20px cells
small = im.resize((GW, GH), Image.BOX)
sp = small.load()
far = lambda p: sum(abs(a - b) for a, b in zip(p, FLAT)) > 24
matt = [[far(sp[x, y]) for x in range(GW)] for y in range(GH)]
# grow Matt's area by two cells so his edges do not leak into the estimate
grown = [[any(matt[yy][xx] for yy in range(max(0, y - 2), min(GH, y + 3))
              for xx in range(max(0, x - 2), min(GW, x + 3))) for x in range(GW)] for y in range(GH)]
est = [[None if grown[y][x] else list(sp[x, y]) for x in range(GW)] for y in range(GH)]
# fill Matt's area from the backdrop around it, ring by ring
while any(v is None for row in est for v in row):
    nxt = [row[:] for row in est]
    for y in range(GH):
        for x in range(GW):
            if est[y][x] is None:
                n = [est[yy][xx] for yy, xx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1))
                     if 0 <= yy < GH and 0 <= xx < GW and est[yy][xx] is not None]
                if n:
                    nxt[y][x] = [sum(c) / len(n) for c in zip(*n)]
    est = nxt
grid = Image.new('RGB', (GW, GH))
grid.putdata([tuple(round(c) for c in est[y][x]) for y in range(GH) for x in range(GW)])
backdrop = grid.filter(ImageFilter.GaussianBlur(3)).resize((W, H), Image.BILINEAR).filter(ImageFilter.GaussianBlur(30))

# 2. Shift every pixel by (flat - backdrop), so the backdrop becomes the flat colour.
flat = Image.new('RGB', (W, H), FLAT)
up = ImageChops.subtract(flat, backdrop)    # where the backdrop is darker than flat
down = ImageChops.subtract(backdrop, flat)  # where it is lighter
even = ImageChops.subtract(ImageChops.add(im, up), down)

# 3. Blend the edges into the flat colour (Matt spans 16.3%-81.7% of the width; his head is ~9% down).
def ramp(t):
    t = max(0.0, min(1.0, t))
    return t * t * (3 - 2 * t)
left, right, top = int(W * .12), int(W * .17), int(H * .06)
col = [ramp(min(x / left, (W - 1 - x) / right)) for x in range(W)]
row = [ramp(y / top) for y in range(H)]
mask = Image.new('L', (W, H))
mask.putdata([int(255 * col[x] * row[y]) for y in range(H) for x in range(W)])
out = Image.composite(even, flat, mask)
out.save('static/imgs/matt-stretton-scrubs.webp', quality=80, method=6)

op = out.load()
for y in (300, 900, 1500):
    print(y, [op[x, y] for x in (60, 200, 1250, 1350, 1430)])
