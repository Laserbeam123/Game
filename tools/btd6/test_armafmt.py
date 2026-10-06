"""Round-trip check for the converter's PAA and PBO writers, decoded by HEMTT's own readers.

    python3 tools/btd6/test_armafmt.py path/to/hemtt
"""
import subprocess
import sys
import tempfile
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
import armafmt  # noqa: E402

hemtt = sys.argv[1] if len(sys.argv) > 1 else "hemtt"
fails = 0


def check(ok, what):
    global fails
    print(("PASS " if ok else "FAIL ") + what)
    fails += 0 if ok else 1


with tempfile.TemporaryDirectory() as d:
    d = Path(d)
    # a cartoon-ish test sprite: coloured disc with soft edge on transparent, off-centre in a non-square canvas
    h, w = 300, 420
    y, x = np.mgrid[0:h, 0:w]
    r = np.hypot(x - 260, y - 140)
    a = np.clip((110 - r) * 40, 0, 255).astype(np.uint8)
    img = np.stack([np.clip(x * 0.6, 0, 255), np.clip(y * 0.8, 0, 255), np.full_like(x, 60), a], -1).astype(np.uint8)
    src = armafmt.prepare(Image.fromarray(img, "RGBA"), 256)
    check(src.size == (256, 256), f"prepare -> {src.size}")
    (d / "t_ca.paa").write_bytes(armafmt.paa_bytes(src))
    subprocess.run([hemtt, "utils", "paa", "convert", str(d / "t_ca.paa"), str(d / "back.png")], check=True, capture_output=True)
    back = np.asarray(Image.open(d / "back.png").convert("RGBA")).astype(float)
    ref = np.asarray(src).astype(float)
    vis = ref[..., 3] > 128
    rgb_err = np.abs(back[..., :3] - ref[..., :3])[vis].mean()
    a_err = np.abs(back[..., 3] - ref[..., 3]).mean()
    check(rgb_err < 6, f"DXT5 colour error {rgb_err:.2f} (visible pixels)")
    check(a_err < 3, f"DXT5 alpha error {a_err:.2f}")
    info = subprocess.run([hemtt, "utils", "paa", "inspect", str(d / "t_ca.paa")], capture_output=True, text=True).stdout
    check("DXT5" in info and info.count("DXT5") >= 8, "PAA has a DXT5 mip chain down to 4x4")
    pbo = armafmt.pbo_bytes({"config.cpp": b"class CfgPatches { class x { units[] = {}; }; };\n", "t_ca.paa": (d / "t_ca.paa").read_bytes()}, r"z\test")
    (d / "x.pbo").write_bytes(pbo)
    out = subprocess.run([hemtt, "utils", "pbo", "inspect", str(d / "x.pbo")], capture_output=True, text=True).stdout
    stored = [l for l in out.splitlines() if "Stored" in l or "Actual" in l]
    check("prefix: z\\test" in out, "PBO prefix")
    check(len(stored) == 2 and stored[0].split()[-1] == stored[1].split()[-1], "PBO SHA1 checksum")
    check("Count: 2" in out, "PBO file count")
print("DONE:", fails, "failure(s)")
sys.exit(1 if fails else 0)
