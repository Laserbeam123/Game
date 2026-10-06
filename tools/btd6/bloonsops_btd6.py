"""Bloons Ops BTD6 art converter.

Runs on the player's own PC. It reads the player's own Bloons TD 6 install, takes the monkey and bloon images
(and the pop sound when it can be decoded) listed in sheets/btd6_art.json, and writes a local Arma 3 mod:

    <Arma 3>/@bloonsops_btd6/addons/bloonsops_btd6.pbo   (unsigned, prefix z\\bloonsops_btd6)
    <Arma 3>/@bloonsops_btd6/manifest.json               (which BTD6 asset each row resolved to)
    <Arma 3>/@bloonsops_btd6/done                        (marker for Melty's setup step)

Nothing from BTD6 leaves the PC: the converter has no network code, and the pack is never uploaded.
If BTD6 isn't installed, the folder is still created (without the PBO) and Bloons Ops keeps its own look.

    bloonsops_btd6.exe                 convert (finds BTD6 and Arma 3 through Steam)
    bloonsops_btd6.exe inspect         list BTD6 sprite/clip names that look like towers, bloons or pops
    options: --btd6 DIR  --arma DIR  --out DIR  --sheet FILE
"""
import argparse
import json
import re
import sys
import traceback
from pathlib import Path

HERE = Path(getattr(sys, "_MEIPASS", Path(__file__).resolve().parent))
sys.path.insert(0, str(HERE))
import armafmt  # noqa: E402
import steam  # noqa: E402

try:  # UnityPy imports fmod_toolkit for its audio export; the exe leaves FMOD out (not redistributable)
    import fmod_toolkit  # noqa: F401
except ImportError:
    import types
    sys.modules["fmod_toolkit"] = types.ModuleType("fmod_toolkit")

PREFIX = r"z\bloonsops_btd6"
SIZES = {"tower": 512, "bloon": 256}
WANT = {"tower": ("Sprite", "Texture2D"), "bloon": ("Sprite", "Texture2D"), "sound": ("AudioClip",)}
INSPECT_WORDS = ["dart", "boomerang", "bomb", "tack", "ice", "glue", "ninja", "super", "banana", "farm",
                 "red", "blue", "green", "yellow", "pink", "lead", "camo", "bloon", "pop", "portrait", "icon"]


def log(*a):
    print(*a, flush=True)


def find_sheet(arg):
    for p in ([Path(arg)] if arg else []) + [HERE / "btd6_art.json", HERE.parent.parent / "sheets" / "btd6_art.json"]:
        if p.is_file():
            return json.loads(p.read_text())
    sys.exit("btd6_art.json not found")


def bundles(btd6, globs):
    """Files under the BTD6 folder matching any of the |-separated globs in a btd6_bundle cell."""
    out = set()
    for g in globs.split("|"):
        out |= {p for p in (btd6 / Path(g).parent).glob(Path(g).name) if p.is_file()}
    return sorted(out)


def index(files, cache_file):
    """[(bundle, path_id, type, name)] for every Sprite/Texture2D/AudioClip, cached by bundle size+mtime."""
    import UnityPy
    try:
        cache = json.loads(cache_file.read_text())
    except (OSError, ValueError):
        cache = {}
    out, fresh = [], {}
    for i, f in enumerate(files):
        key = f"{f.name}|{f.stat().st_size}|{int(f.stat().st_mtime)}"
        rows = cache.get(key)
        if rows is None:
            rows = []
            try:
                env = UnityPy.load(str(f))
                for obj in env.objects:
                    t = obj.type.name
                    if t in ("Sprite", "Texture2D", "AudioClip"):
                        try:
                            name = obj.peek_name()
                        except Exception:
                            name = getattr(obj.read(), "m_Name", "")
                        if name:
                            rows.append([obj.path_id, t, name])
            except Exception as e:  # unreadable bundle: skip it, keep going
                log(f"  skipped {f.name}: {e}")
            if i % 50 == 0:
                log(f"  indexed {i + 1}/{len(files)} bundles")
        fresh[key] = rows
        out += [(f, pid, t, n) for pid, t, n in rows]
    try:
        cache_file.parent.mkdir(parents=True, exist_ok=True)
        cache_file.write_text(json.dumps(fresh))
    except OSError:
        pass
    return out


def resolve(row, idx):
    """First pattern (in sheet order) that full-matches a name of the wanted type. Several hits: prefer Sprite."""
    types = WANT[row["uses"]]
    for pat in row["btd6_asset"].split("|"):
        rx = re.compile(pat, re.I)
        hits = [e for e in idx if e[2] in types and rx.fullmatch(e[3])]
        if hits:
            hits.sort(key=lambda e: (types.index(e[2]), len(e[3]), e[0].name))
            return pat, hits
    return None, []


def load_obj(bundle, path_id, all_files):
    import UnityPy
    env = UnityPy.load(str(bundle))
    for obj in env.objects:
        if obj.path_id == path_id:
            return obj.read(), env
    raise KeyError(path_id)


def image_of(entry, all_files):
    bundle, pid, t, name = entry
    data, env = load_obj(bundle, pid, all_files)
    try:
        return data.image
    except Exception as e:
        # usually a sprite whose atlas texture lives in another bundle: load them all and retry
        import UnityPy
        log(f"  {name}: {e!r}; retrying with every bundle loaded (slow)")
        env = UnityPy.load(*[str(f) for f in all_files])
        for obj in env.objects:
            if obj.path_id == pid and obj.type.name == t:
                return obj.read().image
        raise


def raw_audio(clip):
    """The AudioClip's stored bytes (inline or from its .resS/.resource stream)."""
    if clip.m_AudioData:
        return bytes(clip.m_AudioData)
    from UnityPy.helpers.ResourceReader import get_resource_data
    r = clip.m_Resource
    return bytes(get_resource_data(r.m_Source, clip.object_reader.assets_file, r.m_Offset, r.m_Size))


def sound_of(entry, all_files):
    """(extension, bytes) Arma can play: OGG or WAV. FSB5 banks are rebuilt with fsb5 (MIT) + libogg/libvorbis
    (BSD), never FMOD, so everything the exe bundles is redistributable. None if it can't be decoded."""
    clip, env = load_obj(entry[0], entry[1], all_files)
    raw = raw_audio(clip)
    if raw[:4] == b"OggS":
        return "ogg", raw
    if raw[:4] == b"RIFF":
        return "wav", raw
    if raw[:4] == b"FSB5":
        import fsb5
        bank = fsb5.FSB5(raw)
        return bank.get_sample_extension(), bank.rebuild_sample(bank.samples[0])
    return None


def config_cpp(build, pop, rows):
    lines = ["class CfgPatches {", "    class bloonsops_btd6 {",
             '        name = "Bloons Ops - BTD6 art (made locally from your own Bloons TD 6)";',
             '        author = "Bloons Ops converter";', "        units[] = {};", "        weapons[] = {};",
             "        requiredVersion = 2.14;", "        requiredAddons[] = {};",
             f'        btd6Build = "{build}";', f'        pop = "{pop}";',
             "        art[] = {" + ", ".join(f'"{r}"' for r in rows) + "};", "    };", "};", ""]
    return "\n".join(lines).encode()


def convert(args):
    sheet = find_sheet(args.sheet)
    rows = sheet["rows"]
    btd6, build = (Path(args.btd6), "manual") if args.btd6 else steam.find_app(steam.BTD6_APPID)
    if args.out:
        out = Path(args.out)
    else:
        arma = Path(args.arma) if args.arma else steam.find_app(steam.ARMA3_APPID)[0]
        if not arma:
            sys.exit("Arma 3 not found in any Steam library; pass --arma <Arma 3 folder>")
        out = arma / "@bloonsops_btd6"
    (out / "addons").mkdir(parents=True, exist_ok=True)
    (out / "mod.cpp").write_text('name = "Bloons Ops - BTD6 art (local)";\nauthor = "made on this PC from your own Bloons TD 6";\n')
    for stale in ("done", "addons/bloonsops_btd6.pbo"):
        (out / stale).unlink(missing_ok=True)
    manifest = {"btd6": str(btd6) if btd6 else None, "btd6_build": build, "rows": {}}
    files = {}
    if not btd6:
        log("Bloons TD 6 not found in any Steam library: Bloons Ops will use its own look. (--btd6 <folder> to point at it)")
    else:
        log(f"Bloons TD 6: {btd6} (build {build})")
        globs = sorted({r["btd6_bundle"] for r in rows})
        all_files = sorted({f for g in globs for f in bundles(btd6, g)})
        log(f"  {len(all_files)} asset bundles")
        idx = index(all_files, out / "index_cache.json")
        for r in rows:
            pat, hits = resolve(r, idx)
            rec = {"pattern": pat, "asset": None, "bundle": None, "candidates": [h[3] for h in hits[:8]]}
            for h in hits[:4]:
                try:
                    if r["uses"] == "sound":
                        snd = sound_of(h, all_files)
                        if snd:
                            files[str(Path(r["out_file"]).with_suffix("." + snd[0]))] = snd[1]
                    else:
                        files[r["out_file"]] = armafmt.paa_bytes(armafmt.prepare(image_of(h, all_files), SIZES[r["uses"]]))
                except Exception as e:
                    log(f"  {r['id']}: {h[3]} failed ({e})")
                    continue
                if any(Path(f).stem == Path(r["out_file"]).stem for f in files):
                    rec.update(asset=h[3], bundle=h[0].name)
                    break
            manifest["rows"][r["id"]] = rec
            log(f"  {r['id']:13s} -> {rec['asset'] or 'NOT FOUND (keeps the Bloons Ops look)'}" + (f"  [{rec['bundle']}]" if rec["bundle"] else ""))
    art = [r["id"] for r in rows if r["out_file"] in files and r["uses"] != "sound"]
    if art:
        pop = next((f for f in files if Path(f).stem == "pop"), "")
        has_pop = bool(pop)
        files["config.cpp"] = config_cpp(build, pop, art)
        (out / "addons" / "bloonsops_btd6.pbo").write_bytes(armafmt.pbo_bytes(files, PREFIX))
        log(f"wrote {out / 'addons' / 'bloonsops_btd6.pbo'}: {len(art)} images, pop sound {'yes' if has_pop else 'no (Bloons Ops pop is used)'}")
    (out / "manifest.json").write_text(json.dumps(manifest, indent=1))
    (out / "done").write_text("ok\n")
    log(f"done: {out}")


def inspect(args):
    sheet = find_sheet(args.sheet)
    btd6 = Path(args.btd6) if args.btd6 else steam.find_app(steam.BTD6_APPID)[0]
    if not btd6:
        sys.exit("Bloons TD 6 not found; pass --btd6 <folder>")
    globs = sorted({r["btd6_bundle"] for r in sheet["rows"]})
    files = sorted({f for g in globs for f in bundles(btd6, g)})
    outdir = Path(args.out or ".")
    outdir.mkdir(parents=True, exist_ok=True)
    idx = index(files, outdir / "index_cache.json")
    every = sorted({f"{t}\t{n}\t{f.name}" for f, pid, t, n in idx})
    likely = [l for l in every if any(w in l.split("\t")[1].lower() for w in INSPECT_WORDS)]
    report = outdir / "btd6_inspect.txt"
    report.write_text("# likely towers / bloons / pops\n" + "\n".join(likely) + "\n\n# every Sprite, Texture2D and AudioClip\n" + "\n".join(every) + "\n")
    for r in sheet["rows"]:
        pat, hits = resolve(r, idx)
        log(f"{r['id']:13s} {pat or '-':28s} {', '.join(h[3] + ' [' + h[0].name + ']' for h in hits[:3]) or 'NO MATCH'}")
    log(f"{len(every)} names ({len(likely)} likely) written to {report}")


def main():
    ap = argparse.ArgumentParser(description="Make @bloonsops_btd6 from your own Bloons TD 6 install.")
    ap.add_argument("cmd", nargs="?", default="convert", choices=["convert", "inspect"])
    ap.add_argument("--btd6")
    ap.add_argument("--arma")
    ap.add_argument("--out")
    ap.add_argument("--sheet")
    args = ap.parse_args()
    try:
        (inspect if args.cmd == "inspect" else convert)(args)
    except SystemExit:
        raise
    except Exception:
        traceback.print_exc()
        sys.exit(2)


if __name__ == "__main__":
    main()
