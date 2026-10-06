"""Arma 3 file writers used by the BTD6 converter: DXT5 PAA textures and unsigned PBOs.

Pure Python + numpy + Pillow, so it builds into a single Windows exe. Formats follow HEMTT's readers
(libs/paa, libs/pbo), which tools/btd6/selftest.py uses to check the output.
"""
import hashlib
import struct
import time

import numpy as np
from PIL import Image


# ---------------------------------------------------------------- image prep

def prepare(img, size):
    """Trim to the visible pixels, pad to a centred square, scale to size x size (power of two) RGBA."""
    img = img.convert("RGBA")
    bbox = img.getchannel("A").point(lambda a: 255 if a > 8 else 0).getbbox()
    if bbox:
        img = img.crop(bbox)
    side = max(img.size)
    pad = max(1, side // 32)  # small margin so mipmaps don't bleed into the edge
    sq = Image.new("RGBA", (side + 2 * pad, side + 2 * pad), (0, 0, 0, 0))
    sq.paste(img, ((sq.width - img.width) // 2, (sq.height - img.height) // 2))
    sq = sq.resize((size, size), Image.LANCZOS)
    return bleed(sq)


def bleed(img):
    """Give fully transparent pixels the average visible colour, so filtering doesn't draw dark halos."""
    a = np.asarray(img).copy()
    vis = a[..., 3] > 8
    if vis.any():
        a[~vis, :3] = a[vis, :3].mean(axis=0).astype(np.uint8)
    return Image.fromarray(a, "RGBA")


# ---------------------------------------------------------------- DXT5

def _rgb565(c):
    c = c.astype(np.uint32)
    return ((c[..., 0] >> 3) << 11) | ((c[..., 1] >> 2) << 5) | (c[..., 2] >> 3)


def _unpack565(v):
    r = ((v >> 11) & 31) * 255 // 31
    g = ((v >> 5) & 63) * 255 // 63
    b = (v & 31) * 255 // 31
    return np.stack([r, g, b], axis=-1).astype(np.int32)


def dxt5(rgba):
    """Encode an (H, W, 4) uint8 array (H, W multiples of 4) as DXT5 blocks."""
    h, w, _ = rgba.shape
    blk = rgba.reshape(h // 4, 4, w // 4, 4, 4).transpose(0, 2, 1, 3, 4).reshape(-1, 16, 4).astype(np.int32)
    n = blk.shape[0]
    # alpha: 8-level mode (a0 > a1)
    amax = blk[..., 3].max(axis=1)
    amin = blk[..., 3].min(axis=1)
    a0 = amax.copy()
    a1 = amin.copy()
    flat = a0 == a1
    a0[flat & (a0 < 255)] += 1
    a1[flat & (a1 == 255)] -= 1
    flat = a0 == a1
    pal_a = np.stack([a0, a1] + [((7 - i) * a0 + i * a1) // 7 for i in range(1, 7)], axis=1)
    ai = np.abs(blk[..., 3][:, :, None] - pal_a[:, None, :]).argmin(axis=2).astype(np.uint64)
    abits = np.zeros(n, dtype=np.uint64)
    for i in range(16):
        abits |= ai[:, i] << np.uint64(3 * i)
    # colour: endpoints from the RGB bounding box of the visible pixels, inset a little
    rgb = blk[..., :3]
    vis = blk[..., 3] > 8
    lo = np.where(vis[..., None], rgb, 255).min(axis=1)
    hi = np.where(vis[..., None], rgb, 0).max(axis=1)
    none = ~vis.any(axis=1)
    lo[none] = rgb[none].min(axis=1)
    hi[none] = rgb[none].max(axis=1)
    inset = (hi - lo) // 16
    hi, lo = hi - inset, lo + inset
    c0 = _rgb565(hi)
    c1 = _rgb565(lo)
    swap = c0 < c1
    c0, c1 = np.where(swap, c1, c0), np.where(swap, c0, c1)
    eq = c0 == c1  # 4-colour mode needs c0 > c1
    c0 = np.where(eq & (c0 < 0xFFFF), c0 + 1, c0)
    c1 = np.where(eq & (c0 == 0xFFFF) & (c1 > 0), c1 - 1, c1)
    p0, p1 = _unpack565(c0), _unpack565(c1)
    pal = np.stack([p0, p1, (2 * p0 + p1) // 3, (p0 + 2 * p1) // 3], axis=1)
    ci = ((rgb[:, :, None, :] - pal[:, None, :, :]) ** 2).sum(axis=3).argmin(axis=2).astype(np.uint32)
    cbits = np.zeros(n, dtype=np.uint32)
    for i in range(16):
        cbits |= ci[:, i] << np.uint32(2 * i)
    out = bytearray()
    for k in range(n):
        out += bytes((int(a0[k]), int(a1[k])))
        out += int(abits[k]).to_bytes(6, "little")
        out += struct.pack("<HHI", int(c0[k]), int(c1[k]), int(cbits[k]))
    return bytes(out)


def lzo_literal(data):
    """A valid LZO1X stream holding data as one literal run (Arma's DXT mipmaps >= 64 px are LZO)."""
    n = len(data)
    if n <= 238:
        head = bytes((n + 17,))
    else:
        rem = n - 18
        zeros = (rem - 1) // 255
        head = b"\x00" + b"\x00" * zeros + bytes((rem - 255 * zeros,))
    return head + data + b"\x11\x00\x00"


def paa_bytes(img):
    """DXT5 PAA with a full mip chain (img: square power-of-two RGBA PIL image)."""
    maps = []
    cur = img
    while True:
        w, h = cur.size
        data = dxt5(np.asarray(cur))
        big = w >= 64 or h >= 64
        maps.append((w | (0x8000 if big else 0), h, lzo_literal(data) if big else data))
        if w <= 4 or h <= 4:
            break
        cur = bleed(cur.resize((w // 2, h // 2), Image.LANCZOS))
    a = np.asarray(img).reshape(-1, 4).astype(np.uint64)
    avg = (a.sum(axis=0) // len(a)).astype(np.uint8)
    taggs = [(b"CGVA", bytes((int(avg[2]), int(avg[1]), int(avg[0]), int(avg[3])))),  # BGRA
             (b"CXAM", b"\xff\xff\xff\xff")]
    if avg[3] < 255:
        taggs.append((b"GALF", b"\x01\x00\x00\x00"))
    out = bytearray(b"\x05\xff")  # DXT5
    for name, data in taggs:
        out += b"GGAT" + name + struct.pack("<I", len(data)) + data
    offset = len(out) + 12 + 64 + 2
    offs = []
    for w, h, d in maps:
        offs.append(offset)
        offset += 7 + len(d)
    offs += [0] * (16 - len(offs))
    out += b"GGATSFFO" + struct.pack("<I", 64) + struct.pack("<16I", *offs)
    out += b"\x00\x00"  # no palette
    for w, h, d in maps:
        out += struct.pack("<HH", w, h) + len(d).to_bytes(3, "little") + d
    out += b"\x00" * 6
    return bytes(out)


# ---------------------------------------------------------------- PBO

def pbo_bytes(files, prefix):
    """Unsigned, uncompressed PBO. files: {name with backslashes: bytes}."""
    stamp = int(time.time())
    head = bytearray(b"\x00" + struct.pack("<5I", 0x56657273, 0, 0, 0, 0))
    head += b"prefix\x00" + prefix.encode() + b"\x00\x00"
    names = sorted(files)
    for n in names:
        head += n.encode() + b"\x00" + struct.pack("<5I", 0, len(files[n]), 0, stamp, len(files[n]))
    head += b"\x00" + struct.pack("<5I", 0, 0, 0, 0, 0)
    body = bytes(head) + b"".join(files[n] for n in names)
    return body + b"\x00" + hashlib.sha1(body).digest()
