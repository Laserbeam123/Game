"""End-to-end converter test on public Unity sample bundles (UnityPy's own test files, not BTD6).

    python3 tools/btd6/sample_test.py <converter command...>
e.g. python3 tools/btd6/sample_test.py python3 tools/btd6/bloonsops_btd6.py
     python  tools/btd6/sample_test.py dist/bloonsops_btd6.exe

Builds a fake BTD6 folder from an atlas bundle, a plain sprite bundle and an FSB5 Vorbis audio bundle, points
three rows at them, and checks the converter resolves all three and packs PAAs plus pop.ogg into the PBO.
"""
import json
import subprocess
import sys
import tempfile
import urllib.request
from pathlib import Path

BASE = "https://media.githubusercontent.com/media/K0lb3/UnityPy/master/tests/samples/"
SAMPLES = {"atlas_test": "a.bundle", "banner_1": "b.bundle", "char_118_yuki.ab": "c.bundle"}
ROOT = Path(__file__).resolve().parent.parent.parent

with tempfile.TemporaryDirectory() as d:
    d = Path(d)
    aa = d / "btd6" / "BloonsTD6_Data" / "StreamingAssets" / "aa" / "StandaloneWindows64"
    aa.mkdir(parents=True)
    for src, dst in SAMPLES.items():
        urllib.request.urlretrieve(BASE + src, aa / dst)
    sheet = json.loads((ROOT / "sheets" / "btd6_art.json").read_text())
    pats = {"dart_monkey": "DartMonkey000|WaterTower", "red": "banner_1", "pop": "Pop|CN_001"}
    for r in sheet["rows"]:
        r["btd6_asset"] = pats.get(r["id"], "no_such_asset")
    (d / "sheet.json").write_text(json.dumps(sheet))
    subprocess.run(sys.argv[1:] + ["--btd6", str(d / "btd6"), "--out", str(d / "out"), "--sheet", str(d / "sheet.json")], check=True)
    man = json.loads((d / "out" / "manifest.json").read_text())["rows"]
    got = {k: v["asset"] for k, v in man.items() if v["asset"]}
    pbo = (d / "out" / "addons" / "bloonsops_btd6.pbo").read_bytes()
    ok = got == {"dart_monkey": "WaterTower", "red": "banner_1", "pop": "CN_001"} and b"pop.ogg\x00" in pbo \
        and b"tower_dart_monkey_ca.paa\x00" in pbo and (d / "out" / "done").is_file()
    print("resolved:", got)
    print("PASS" if ok else "FAIL")
    sys.exit(0 if ok else 1)
