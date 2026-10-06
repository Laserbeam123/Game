#!/usr/bin/env python3
"""Stand-in pictures for every btd6_art row, drawn from scratch (no game files).
Used when a player has no converted BTD6 art. Writes addons/main/data/art_<id>_ca.paa via HEMTT."""
import json, os, subprocess, sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "addons", "main", "data")
TMP = os.path.join(ROOT, "build", "art")


def font(sz):
    for f in ["/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", "/usr/share/fonts/dejavu/DejaVuSans-Bold.ttf"]:
        if os.path.exists(f): return ImageFont.truetype(f, sz)
    return ImageFont.load_default()


def rgb(c, k=1.0):
    return tuple(max(0, min(255, int(x * 255 * k))) for x in c)


def bloon(c, n):
    im = Image.new("RGBA", (n, n), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    w, h = n * 0.62, n * 0.74; x0, y0 = (n - w) / 2, n * 0.06
    d.ellipse([x0, y0, x0 + w, y0 + h], fill=rgb(c) + (255,), outline=rgb(c, 0.55) + (255,), width=max(2, n // 40))
    d.polygon([(n / 2 - n * .06, y0 + h - 2), (n / 2 + n * .06, y0 + h - 2), (n / 2, y0 + h + n * .09)], fill=rgb(c, 0.75) + (255,))
    d.ellipse([x0 + w * .18, y0 + h * .12, x0 + w * .42, y0 + h * .36], fill=(255, 255, 255, 170))
    return im


def blimp(c, n, label):
    im = Image.new("RGBA", (n, n), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    d.ellipse([n * .04, n * .28, n * .96, n * .72], fill=rgb(c) + (255,), outline=rgb(c, .5) + (255,), width=n // 40)
    d.polygon([(n * .04, n * .5), (n * -.02, n * .3), (n * .14, n * .42)], fill=rgb(c, .7) + (255,))
    d.polygon([(n * .04, n * .5), (n * -.02, n * .7), (n * .14, n * .58)], fill=rgb(c, .7) + (255,))
    d.ellipse([n * .2, n * .32, n * .55, n * .42], fill=(255, 255, 255, 120))
    f = font(n // 7); tw = d.textlength(label, font=f)
    d.text(((n - tw) / 2, n * .43), label, font=f, fill=(255, 255, 255, 255), stroke_width=3, stroke_fill=(0, 0, 0, 255))
    return im


def badge(c, n, label):
    im = Image.new("RGBA", (n, n), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    d.ellipse([n * .08, n * .08, n * .92, n * .92], fill=rgb(c) + (255,), outline=(20, 20, 20, 255), width=n // 28)
    d.ellipse([n * .25, n * .2, n * .75, n * .68], fill=(240, 205, 160, 255))
    for ex in (.39, .61):
        d.ellipse([n * (ex - .05), n * .36, n * (ex + .05), n * .46], fill=(255, 255, 255, 255))
        d.ellipse([n * (ex - .025), n * .39, n * (ex + .025), n * .44], fill=(0, 0, 0, 255))
    f = font(n // 7); tw = d.textlength(label, font=f)
    d.text(((n - tw) / 2, n * .72), label, font=f, fill=(255, 255, 255, 255), stroke_width=3, stroke_fill=(0, 0, 0, 255))
    return im


def main():
    rows = json.load(open(os.path.join(ROOT, "sheets", "btd6_art.json")))["rows"]
    os.makedirs(OUT, exist_ok=True); os.makedirs(TMP, exist_ok=True)
    for r in rows:
        if r["id"] == "none": continue
        n = r["size_px"]
        if r["kind"] == "bloon":
            im = blimp(r["fallback_rgb"], n, r["fallback_label"]) if r["fallback_label"] else bloon(r["fallback_rgb"], n)
        else:
            im = badge(r["fallback_rgb"], n, r["fallback_label"])
        png = os.path.join(TMP, f"art_{r['id']}_ca.png")
        im.save(png)
        paa = os.path.join(OUT, f"art_{r['id']}_ca.paa")
        subprocess.run(["hemtt", "utils", "paa", "convert", png, paa], check=True, capture_output=True)
        print("  art", os.path.relpath(paa, ROOT))


if __name__ == "__main__":
    main()
