#!/usr/bin/env python3
"""Draw the main-menu spotlight tile (original art): bloons drifting over an Altis-coloured road."""
import math
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
W, H = 1024, 512


def main():
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
