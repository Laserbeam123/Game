#!/usr/bin/env python3
"""Run tests/oa_logic_test.sqf against the real OA edition functions in SQF-VM.

  SQFVM=/path/to/sqfvm python3 tests/run_sqfvm_oa.py

The OA files are plain Arma 2 SQF, so they load as-is: the oa/addons/main folder is mapped to its PBO path so
#include "\\z\\bloonsops_oa\\addons\\main\\script.hpp" resolves, and the clock is replaced (BO_T)."""
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MAIN = ROOT / "oa" / "addons" / "main"
TESTED = ["dist2D", "pathPos", "bloonDist", "spawnBloons", "slowBloon", "damageBloon", "towerCoverage"]


def main():
    vm = os.environ.get("SQFVM", "sqfvm")
    with tempfile.TemporaryDirectory() as td:
        # shimmed copy of the addon: SQF-VM lacks isServer, so the tests run "as the server"
        main = Path(td) / "main"
        shutil.copytree(MAIN, main)
        for f in main.rglob("*.sqf"):
            f.write_text(re.sub(r"\bisServer\b", "true", f.read_text()))
        suite = Path(td) / "suite.sqf"
        lines = [(main / "functions" / "fn_initData.sqf").read_text()]
        for n in TESTED:
            lines.append(f'BO_fnc_{n} = compile preprocessFileLineNumbers "\\z\\bloonsops_oa\\addons\\main\\functions\\fn_{n}.sqf";')
        lines.append("BO_fnc_now = { BO_T };")
        lines.append((ROOT / "tests" / "oa_logic_test.sqf").read_text())
        suite.write_text("\n".join(lines))
        cmd = [vm, "--suppress-welcome", "--no-spawn-player", "--no-work-print", "-a",
               "-v", f"{main}|/z/bloonsops_oa/addons/main", "--command-dummy-unary", "publicVariable",
               "--input-sqf", str(suite)]
        out = subprocess.run(cmd, capture_output=True, text=True, stdin=subprocess.DEVNULL, timeout=120).stdout
    res = [l.split("[DIAG_LOG] ", 1)[1] for l in out.splitlines() if "[DIAG_LOG]" in l]
    errs = [l for l in out.splitlines() if "[ERR]" in l or "[FAT]" in l]
    print("\n".join(res))
    for e in errs:
        print("VM ERROR:", e[:300])
    ok = "RESULT 0 failure(s)" in res and not errs
    print("OA SQF logic tests PASSED" if ok else "OA SQF logic tests FAILED")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
