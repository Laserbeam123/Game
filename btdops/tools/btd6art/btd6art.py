#!/usr/bin/env python3
"""Bloons TD Ops - BTD6 art converter. Runs once on the player's PC (Melty starts it before the
first launch). It reads the player's OWN Bloons TD 6 install, read-only, and writes a private
Arma add-on with those pictures into the mod's own folder:  <Arma 3>/@btdops/addons/btdops_art.pbo
Nothing is uploaded or shared, and BTD6 is never started, changed or patched.

  btd6art.py --game "<Arma 3 folder>" [--btd6 "<BTD6 folder>"] [--force]

Which pictures to take comes from btd6_art.json (the design sheet, shipped next to this file).
Without BTD6 it still writes the add-on (empty), so the game starts with its stand-in pictures.
"""
import argparse, gc, glob, json, os, re, sys, time, traceback

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.append(os.path.join(HERE, "nofmod"))  # only used when the real fmod_toolkit is absent
import armafmt  # noqa: E402

PREFIX = r"z\btdops\addons\art"
LOG = []


def log(msg):
    line = time.strftime("%H:%M:%S ") + msg
    LOG.append(line)
    print(line, flush=True)


# ------------------------------------------------------------ finding BTD6
def _steam_roots(arma_dir):
    roots = []
    if arma_dir:  # <library>/steamapps/common/Arma 3
        p = os.path.abspath(arma_dir)
        for _ in range(3): p = os.path.dirname(p)
        roots.append(p)
    try:
        import winreg
        for hive, key, val in [(winreg.HKEY_CURRENT_USER, r"Software\Valve\Steam", "SteamPath"),
                               (winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\WOW6432Node\Valve\Steam", "InstallPath")]:
            try:
                with winreg.OpenKey(hive, key) as k: roots.append(winreg.QueryValueEx(k, val)[0])
            except OSError: pass
    except ImportError: pass
    roots += [r"C:\Program Files (x86)\Steam", os.path.expanduser("~/.steam/steam"), os.path.expanduser("~/.local/share/Steam")]
    libs = []
    for r in roots:
        libs.append(r)
        vdf = os.path.join(r, "steamapps", "libraryfolders.vdf")
        if os.path.exists(vdf):
            libs += [m.replace("\\\\", "\\") for m in re.findall(r'"path"\s+"([^"]+)"', open(vdf, encoding="utf-8", errors="ignore").read())]
    out = []
    for l in libs:
        if l and l not in out: out.append(l)
    return out


def find_btd6(arma_dir, given):
    cands = []
    if given: cands.append(given)
    if os.environ.get("BTDOPS_BTD6_DIR"): cands.append(os.environ["BTDOPS_BTD6_DIR"])
    for lib in _steam_roots(arma_dir):
        cands.append(os.path.join(lib, "steamapps", "common", "BloonsTD6"))
    for item in glob.glob(r"C:\ProgramData\Epic\EpicGamesLauncher\Data\Manifests\*.item"):
        try:
            j = json.load(open(item, encoding="utf-8"))
            if "bloons" in (j.get("DisplayName", "") + j.get("AppName", "")).lower(): cands.append(j.get("InstallLocation", ""))
        except Exception: pass
    for c in cands:
        if c and os.path.isdir(os.path.join(c, "BloonsTD6_Data")):
            return c
    log("Looked for BTD6 in: " + "; ".join(c for c in cands if c))
    return None


# ------------------------------------------------------------ reading its sprites
def scan(btd6, rows, max_mb):
    import UnityPy
    base = os.path.join(btd6, "BloonsTD6_Data", "StreamingAssets", "aa", "StandaloneWindows64")
    bundles = sorted(glob.glob(os.path.join(base, "*.bundle")), key=lambda p: (not os.path.basename(p).startswith("sprite_atlases"), os.path.getsize(p)))
    log(f"{len(bundles)} bundles in {base}")
    pats = {r["id"]: [re.compile(c, re.I) for c in r["candidates"]] for r in rows}
    best = {}  # id -> (rank, typeOrder, len(name), bundle, path_id, name)
    names_seen = []
    for b in bundles:
        mb = os.path.getsize(b) / 1e6
        if mb > max_mb:
            log(f"skip {os.path.basename(b)} ({mb:.0f} MB)"); continue
        try:
            env = UnityPy.Environment(path="")
            env.load_file(b)
        except Exception as e:
            log(f"cannot open {os.path.basename(b)}: {e}"); continue
        n = 0
        for obj in env.objects:
            t = obj.type.name
            if t not in ("Sprite", "Texture2D"): continue
            try:
                name = obj.peek_name() if hasattr(obj, "peek_name") else obj.read().m_Name
            except Exception:
                continue
            n += 1
            names_seen.append(f"{t}\t{name}\t{os.path.basename(b)}")
            for rid, ps in pats.items():
                for rank, p in enumerate(ps):
                    if p.search(name):
                        key = (rank, 0 if t == "Sprite" else 1, len(name))
                        if rid not in best or key < best[rid][:3]:
                            best[rid] = key + (b, obj.path_id, name)
                        break
        log(f"{os.path.basename(b)}: {n} pictures")
        del env; gc.collect()
        if len(best) == len(pats) and all(v[0] == 0 and v[1] == 0 for v in best.values()):
            break
    return best, names_seen


def extract(best):
    import UnityPy
    by_bundle = {}
    for rid, v in best.items(): by_bundle.setdefault(v[3], []).append((rid, v[4], v[5]))
    images = {}
    for b, items in by_bundle.items():
        env = UnityPy.Environment(path="")
        env.load_file(b)
        objs = {o.path_id: o for o in env.objects}
        for rid, pid, name in items:
            try:
                images[rid] = objs[pid].read().image.convert("RGBA")
                log(f"{rid}: {name} {images[rid].size}")
            except Exception as e:
                log(f"{rid}: could not read {name}: {e}")
        del env, objs; gc.collect()
    return images


def fit(img, size):
    """Trim transparent edges, centre on a transparent square of `size` (a power of two)."""
    from PIL import Image
    bbox = img.getchannel("A").getbbox()
    if bbox: img = img.crop(bbox)
    w, h = img.size
    s = (size - 4) / max(w, h)
    img = img.resize((max(1, round(w * s)), max(1, round(h * s))), Image.LANCZOS)
    sq = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sq.paste(img, ((size - img.size[0]) // 2, (size - img.size[1]) // 2), img)
    return sq


# ------------------------------------------------------------ writing the add-on
def write_addon(out_dir, rows, images, sources):
    files = {}
    cls = []
    for r in rows:
        if r["id"] not in images: continue
        tex = f"{r['id']}_ca.paa"
        files[tex] = armafmt.paa_dxt5(fit(images[r["id"]], r["size_px"]))
        src = sources.get(r["id"], "").replace('"', "'")
        cls.append(f'    class {r["id"]} {{ texture = "\\{PREFIX}\\{tex}"; source = "{src}"; }};\n')
    config = ("class CfgPatches {\n    class btdops_art {\n        name = \"Bloons TD Ops - your BTD6 art (made on this PC)\";\n"
              "        units[] = {};\n        weapons[] = {};\n        requiredVersion = 2.14;\n        requiredAddons[] = {};\n    };\n};\n"
              "class BTD_ArtPack {\n" + "".join(cls) + "};\n")
    files["config.cpp"] = config.encode()
    os.makedirs(os.path.join(out_dir, "addons"), exist_ok=True)
    data = armafmt.pbo(files, PREFIX)
    with open(os.path.join(out_dir, "addons", "btdops_art.pbo"), "wb") as f: f.write(data)
    return len(cls)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--game", required=True, help="Arma 3 folder")
    ap.add_argument("--btd6", default="", help="Bloons TD 6 folder (found automatically if left out)")
    ap.add_argument("--out", default="", help="the mod folder, default: <Arma 3>/@btdops")
    ap.add_argument("--sheet", default=os.path.join(HERE, "btd6_art.json"))
    ap.add_argument("--max-mb", type=float, default=900, help="skip bundles bigger than this")
    ap.add_argument("--force", action="store_true")
    a = ap.parse_args()
    out = a.out or os.path.join(a.game, "@btdops")
    ready = os.path.join(out, "btdops_art_ready.txt")
    os.makedirs(out, exist_ok=True)
    if os.path.exists(ready) and not a.force:
        print("Already done:", ready); return 0
    rows = [r for r in json.load(open(a.sheet))["rows"] if r["id"] != "none"]
    status = "no-btd6"
    count = 0
    names = []
    try:
        log("Bloons TD Ops: making your BTD6 art pack (reads your Bloons TD 6, changes nothing)")
        btd6 = find_btd6(a.game, a.btd6)
        images, sources = {}, {}
        if btd6:
            log(f"Found Bloons TD 6: {btd6}")
            best, names = scan(btd6, rows, a.max_mb)
            for rid, v in best.items(): sources[rid] = v[5]
            for r in rows:
                if r["id"] not in best: log(f"{r['id']}: no matching picture (stand-in will be used)")
            images = extract(best)
            status = "ok"
        else:
            log("Bloons TD 6 not found: the game will use its stand-in pictures. Install BTD6, then run this again with --force.")
        count = write_addon(out, rows, images, sources)
    except Exception:
        status = "error"
        log(traceback.format_exc())
        try: count = write_addon(out, rows, {}, {})
        except Exception: log(traceback.format_exc())
    if names:
        with open(os.path.join(out, "btdops_art_pictures.txt"), "w", encoding="utf-8") as f: f.write("\n".join(names))
    log(f"Done: {count} of {len(rows)} pictures from your BTD6 ({status}).")
    with open(os.path.join(out, "btdops_art.log"), "w", encoding="utf-8") as f: f.write("\n".join(LOG) + "\n")
    with open(ready, "w") as f: f.write(f"status={status}\npictures={count}/{len(rows)}\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
