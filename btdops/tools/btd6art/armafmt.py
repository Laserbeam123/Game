"""Arma file formats the converter writes: PAA textures (DXT5, uncompressed mipmaps) and PBO archives.
Layouts follow HEMTT's readers/writers (github.com/BrettMayson/HEMTT, libs/paa and libs/pbo)."""
import hashlib, struct, time
import numpy as np


def _565(c):
    c = c.astype(np.int32)
    return ((c[..., 0] >> 3) << 11) | ((c[..., 1] >> 2) << 5) | (c[..., 2] >> 3)


def _unpack565(v):
    r = ((v >> 11) & 31) * 255 // 31
    g = ((v >> 5) & 63) * 255 // 63
    b = (v & 31) * 255 // 31
    return np.stack([r, g, b], -1).astype(np.int32)


def dxt5(rgba):
    """rgba: HxWx4 uint8, H and W multiples of 4. Returns DXT5 (BC3) block bytes."""
    h, w, _ = rgba.shape
    blocks = rgba.reshape(h // 4, 4, w // 4, 4, 4).transpose(0, 2, 1, 3, 4).reshape(-1, 16, 4).astype(np.int32)
    n = len(blocks)
    # alpha: 8-level palette between max and min
    a = blocks[:, :, 3]
    a0 = a.max(1); a1 = a.min(1)
    lv = np.stack([a0, a1] + [((7 - i) * a0 + i * a1) // 7 for i in range(1, 7)], 1)  # n x 8 (code order 0..7)
    ai = np.abs(a[:, :, None] - lv[:, None, :]).argmin(2)  # n x 16
    abits = np.zeros(n, dtype=np.uint64)
    for i in range(16): abits |= (ai[:, i].astype(np.uint64) << np.uint64(3 * i))
    # colour: endpoints from the per-channel bounding box of opaque-ish pixels
    rgb = blocks[:, :, :3]
    mx = rgb.max(1); mn = rgb.min(1)
    c0 = _565(mx); c1 = _565(mn)
    swap = c0 < c1
    c0, c1 = np.where(swap, c1, c0), np.where(swap, c0, c1)
    same = c0 == c1
    p0 = _unpack565(c0); p1 = _unpack565(c1)
    pal = np.stack([p0, p1, (2 * p0 + p1) // 3, (p0 + 2 * p1) // 3], 1)  # n x 4 x 3
    ci = ((rgb[:, :, None, :] - pal[:, None, :, :]) ** 2).sum(3).argmin(2)
    ci = np.where(same[:, None], 0, ci)
    cbits = np.zeros(n, dtype=np.uint32)
    for i in range(16): cbits |= (ci[:, i].astype(np.uint32) << np.uint32(2 * i))
    out = bytearray()
    for k in range(n):
        out += struct.pack("<BB", int(a0[k]), int(a1[k])) + int(abits[k]).to_bytes(6, "little")
        out += struct.pack("<HHI", int(c0[k]), int(c1[k]), int(cbits[k]))
    return bytes(out)


def paa_dxt5(img):
    """PIL RGBA image (square, power of two) -> PAA bytes with a full DXT5 mip chain."""
    from PIL import Image
    w, h = img.size
    a = np.asarray(img, dtype=np.uint8)
    avg = a.reshape(-1, 4).mean(0).astype(np.uint8)
    taggs = [(b"CGVA", bytes([avg[2], avg[1], avg[0], avg[3]])), (b"CXAM", bytes([255, 255, 255, 255]))]
    if avg[3] < 255: taggs.append((b"GALF", bytes([1, 0, 0, 0])))
    mips = []
    cur = img
    while True:
        mips.append((cur.size[0], cur.size[1], dxt5(np.asarray(cur, dtype=np.uint8))))
        if cur.size[0] <= 4 or cur.size[1] <= 4: break
        cur = cur.resize((cur.size[0] // 2, cur.size[1] // 2), Image.LANCZOS)
    out = bytearray(bytes([5, 255]))
    offset = 2
    for name, data in taggs:
        out += b"GGAT" + name + struct.pack("<I", len(data)) + data
        offset += 12 + len(data)
    offset += 2 + 12 + 64
    out += b"GGAT" + b"SFFO" + struct.pack("<I", 64)
    offs = []
    for mw, mh, data in mips:
        offs.append(offset); offset += len(data) + 7
    out += struct.pack("<16I", *(offs + [0] * (16 - len(offs))))
    out += struct.pack("<H", 0)
    for mw, mh, data in mips:
        out += struct.pack("<HH", mw, mh) + len(data).to_bytes(3, "little") + data
    out += struct.pack("<IH", 0, 0)
    return bytes(out)


def pbo(files, prefix):
    """files: {name with backslashes: bytes}. Returns an uncompressed PBO with a prefix property."""
    head = bytearray()
    head += b"\0" + struct.pack("<5I", 0x56657273, 0, 0, 0, 0)
    head += b"prefix\0" + prefix.encode() + b"\0" + b"\0"
    names = sorted(files, key=lambda n: n.lower())
    ts = int(time.time())
    for n in names:
        head += n.encode() + b"\0" + struct.pack("<5I", 0, 0, 0, ts, len(files[n]))
    head += b"\0" + struct.pack("<5I", 0, 0, 0, 0, 0)
    body = bytes(head) + b"".join(files[n] for n in names)
    return body + b"\0" + hashlib.sha1(body).digest()
