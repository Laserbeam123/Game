#!/usr/bin/env python3
"""Build releases/btdops-btd6art-<version>.zip: the BTD6 art converter with its own Windows Python,
so players install nothing. Melty unpacks it to {managed}/btd6art and runs it once before the first launch.

  python3 tools/package_btd6art.py <version> <python.nupkg> <wheels dir>

python.nupkg is the official CPython for Windows from NuGet (package "python", by the Python Software
Foundation). The wheels are win_amd64 / pure-Python wheels of UnityPy and the libraries it needs
(see tools/btd6art/CREDITS.txt). FMOD's audio libraries are deliberately left out.
"""
import glob, json, os, shutil, sys, zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SKIP = ("tools/Lib/site-packages/pip", "tools/Lib/ensurepip", "tools/Lib/idlelib", "tools/Lib/tkinter", "tools/Lib/turtledemo",
        "tools/Lib/test/", "tools/tcl/", "tools/Lib/lib2to3", "tools/Scripts/", "tools/include/", "tools/libs/")


def main(version, nupkg, wheels):
    out_zip = os.path.join(ROOT, "releases", f"btdops-btd6art-{version}.zip")
    os.makedirs(os.path.dirname(out_zip), exist_ok=True)
    with zipfile.ZipFile(out_zip, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as z:
        with zipfile.ZipFile(nupkg) as n:
            for info in n.infolist():
                name = info.filename
                if not name.startswith("tools/") or name.endswith("/") or any(name.startswith(s) for s in SKIP): continue
                if "/__pycache__/" in name: continue
                z.writestr("btd6art/python/" + name[len("tools/"):], n.read(name))
        for whl in sorted(glob.glob(os.path.join(wheels, "*.whl"))):
            if "fmod" in os.path.basename(whl).lower(): continue
            with zipfile.ZipFile(whl) as w:
                for info in w.infolist():
                    if info.filename.endswith("/"): continue
                    z.writestr("btd6art/python/Lib/site-packages/" + info.filename, w.read(info.filename))
        src = os.path.join(ROOT, "tools", "btd6art")
        for f in ["btd6art.py", "armafmt.py", "CREDITS.txt", "nofmod/fmod_toolkit/__init__.py"]:
            z.write(os.path.join(src, f), "btd6art/" + f)
        z.write(os.path.join(ROOT, "sheets", "btd6_art.json"), "btd6art/btd6_art.json")
    print(out_zip, os.path.getsize(out_zip) // 1024, "KB")


if __name__ == "__main__":
    main(*sys.argv[1:4])
