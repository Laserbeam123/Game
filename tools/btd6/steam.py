"""Find Steam games through Steam's libraryfolders.vdf (Windows registry first, then the usual folders)."""
import os
import re
import sys
from pathlib import Path

BTD6_APPID = "960090"
ARMA3_APPID = "107410"


def steam_roots():
    roots = []
    if sys.platform == "win32":
        import winreg
        for hive, key, val in ((winreg.HKEY_CURRENT_USER, r"Software\Valve\Steam", "SteamPath"),
                               (winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\WOW6432Node\Valve\Steam", "InstallPath"),
                               (winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Valve\Steam", "InstallPath")):
            try:
                with winreg.OpenKey(hive, key) as k:
                    roots.append(Path(winreg.QueryValueEx(k, val)[0]))
            except OSError:
                pass
        roots += [Path(os.environ.get("ProgramFiles(x86)", r"C:\Program Files (x86)")) / "Steam",
                  Path(os.environ.get("ProgramFiles", r"C:\Program Files")) / "Steam"]
    else:
        home = Path.home()
        roots += [home / ".steam/steam", home / ".local/share/Steam", home / ".var/app/com.valvesoftware.Steam/data/Steam"]
    seen, out = set(), []
    for r in roots:
        try:
            key = str(r.resolve()).lower()
        except OSError:
            continue
        if key not in seen and (r / "steamapps").is_dir():
            seen.add(key)
            out.append(r)
    return out


def libraries():
    libs = []
    for root in steam_roots():
        libs.append(root)
        vdf = root / "steamapps" / "libraryfolders.vdf"
        if vdf.is_file():
            for p in re.findall(r'"path"\s+"([^"]+)"', vdf.read_text(errors="replace")):
                libs.append(Path(p.replace("\\\\", "\\")))
    seen, out = set(), []
    for l in libs:
        k = str(l).lower().rstrip("\\/")
        if k not in seen:
            seen.add(k)
            out.append(l)
    return out


def find_app(appid):
    """(install folder, Steam build id) for an installed app, or (None, None)."""
    for lib in libraries():
        acf = lib / "steamapps" / f"appmanifest_{appid}.acf"
        if acf.is_file():
            txt = acf.read_text(errors="replace")
            m = re.search(r'"installdir"\s+"([^"]+)"', txt)
            b = re.search(r'"buildid"\s+"([^"]+)"', txt)
            if m:
                d = lib / "steamapps" / "common" / m.group(1)
                if d.is_dir():
                    return d, (b.group(1) if b else "unknown")
    return None, None
