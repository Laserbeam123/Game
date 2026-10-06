#!/usr/bin/env python3
"""Draw the main-menu spotlight tile (original art): bloons drifting over an Altis-coloured road."""
import math
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
W, H = 1024, 512


def bloon_textures():
    """Cartoon bloon skins: saturated colour, soft shading, a big white shine (glossy), camo blotches or a
    brushed-metal look. Written next to the sphere UVs' likely 'top-left' so the shine shows from most angles."""
    import json
    rows = json.loads((ROOT / "sheets" / "bloons.json").read_text())["rows"]
    out_dir = ROOT / "addons" / "main" / "data"
    out_dir.mkdir(exist_ok=True)
    S = 256
    for r in rows:
        base = [int(c * 255) for c in r["rgba"][:3]]
        img = Image.new("RGB", (S, S))
        d = ImageDraw.Draw(img)
        for y in range(S):  # light at the top, deeper at the bottom
            t = y / S
            k = 1.25 - 0.55 * t
            d.line([(0, y), (S, y)], fill=tuple(max(0, min(255, int(c * k + 30 * (1 - t)))) for c in base))
        rnd = random.Random(r["id"])
        if r["pattern"] == "camo":
            for _ in range(28):
                x, y, rad = rnd.randint(0, S), rnd.randint(0, S), rnd.randint(10, 34)
                c = rnd.choice([(60, 75, 35), (110, 95, 55), (35, 45, 25)])
                d.ellipse([(x - rad, y - rad * 0.7), (x + rad, y + rad * 0.7)], fill=c)
        if r["pattern"] == "metal":
            for y in range(0, S, 3):
                g = rnd.randint(-18, 18)
                d.line([(0, y), (S, y)], fill=tuple(max(0, min(255, c + g)) for c in base))
            for x, y in ((40, 60), (200, 70), (60, 190), (190, 200), (128, 128)):
                d.ellipse([(x - 6, y - 6), (x + 6, y + 6)], fill=(70, 72, 76))  # rivets
        for cx, cy in ((S * 0.3, S * 0.25), (S * 0.8, S * 0.25)):  # shine (two, for the sphere's wrap)
            d.ellipse([(cx - 26, cy - 16), (cx + 26, cy + 16)], fill=(255, 255, 255))
            d.ellipse([(cx + 18, cy + 14), (cx + 30, cy + 22)], fill=(255, 255, 255))
        d.rectangle([(0, S - 10), (S, S)], fill=tuple(int(c * 0.45) for c in base))  # dark rim near the knot
        png = out_dir / f"bloon_{r['id']}_co.png"
        img.save(png)
        print("wrote", png.relative_to(ROOT))


def monkey_textures():
    """Painted fur/hat colours for the sphere monkeys: the colour with a soft top-lit gradient and light grain."""
    import json
    import sys
    sys.path.insert(0, str(Path(__file__).resolve().parent))
    from palette import tex_name, tower_colours
    towers = json.loads((ROOT / "sheets" / "towers.json").read_text())["rows"]
    out_dir = ROOT / "addons" / "main" / "data"
    out_dir.mkdir(exist_ok=True)
    S = 64
    for c in tower_colours(towers):
        base = [int(v * 255) for v in c[:3]]
        rnd = random.Random(tex_name(c))
        img = Image.new("RGB", (S, S))
        px = img.load()
        for y in range(S):
            k = 1.15 - 0.35 * (y / S)
            for x in range(S):
                g = rnd.randint(-8, 8)
                px[x, y] = tuple(max(0, min(255, int(v * k) + g)) for v in base)
        png = out_dir / f"{tex_name(c)}_co.png"
        img.save(png)
        print("wrote", png.relative_to(ROOT))


def main():
    bloon_textures()
    monkey_textures()
    img = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(img)
    for y in range(H):  # sky to dry hills
        t = y / H
        c = (int(120 + 90 * t), int(170 + 40 * t), int(220 - 110 * t)) if t < 0.55 else (int(170 - 30 * t), int(150 - 30 * t), int(100 - 30 * t))
        d.line([(0, y), (W, y)], fill=c)
    d.polygon([(380, H), (640, H), (545, 290), (500, 290)], fill=(70, 70, 72))  # road
    for i in range(8):
        y = 300 + i * 28
        d.rectangle([(518 - i, y), (526 + i, y + 10 + i)], fill=(230, 230, 200))
    rnd = random.Random(7)
    colours = [(215, 15, 15), (25, 115, 240), (50, 205, 25), (255, 230, 15), (255, 115, 180), (115, 120, 128)]
    for i in range(14):
        t = i / 13
        x = 520 + math.sin(i * 1.7) * (40 + 220 * t) + rnd.randint(-20, 20)
        y = 300 + 190 * t - 30
        r = 10 + 34 * t
        c = colours[i % len(colours)]
        d.line([(x, y + r), (x + 4, y + r + 2.2 * r)], fill=(40, 40, 40), width=2)
        d.ellipse([(x - r, y - r * 1.15), (x + r, y + r)], fill=c, outline=(30, 30, 30), width=3)
        d.ellipse([(x - r * 0.55, y - r * 0.8), (x - r * 0.15, y - r * 0.35)], fill=(255, 255, 255))
    try:
        font = ImageFont.truetype("DejaVuSans-Bold.ttf", 92)
    except OSError:
        font = ImageFont.load_default()
    for dx, dy in ((4, 4), (0, 0)):
        d.text((W // 2 + dx, 70 + dy), "BLOONS OPS", font=font, anchor="mm", fill=(20, 20, 20) if dx else (255, 215, 0))
    out = ROOT / "addons" / "main" / "ui" / "spotlight_co.png"
    img.save(out)
    print("wrote", out.relative_to(ROOT))


if __name__ == "__main__":
    main()
