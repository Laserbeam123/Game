#!/usr/bin/env python3
"""Run tests/logic_test.sqf against the real mod functions in SQF-VM (https://github.com/SQFvm/runtime).

  SQFVM=/path/to/sqfvm python3 tests/run_sqfvm.py

SQF-VM lacks a few Arma commands; this runner swaps only those for equivalent helpers before loading:
  a getOrDefault [k, d]  ->  ([a, k, d] call BO_t_god)
  isServer               ->  BO_t_isServer (true)
The clock (BO_fnc_now) is replaced with the test variable BO_T.
"""
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FUNCS = ROOT / "addons" / "main" / "functions"
TESTED = ["initData", "pathPos", "bloonDist", "spawnBloons", "slowBloon", "damageBloon", "towerCoverage"]

PRELUDE = """
BO_t_god = { params ["_h", "_k", "_d"]; if (_k in _h) then { _h get _k } else { _d } };
BO_fnc_now = { BO_T };
BO_t_isServer = true;
"""


def shim(src):
    src = re.sub(r"(\w+) getOrDefault \[([^,\]]+), ([^\]]+\]?)\]", r"([\1, \2, \3] call BO_t_god)", src)
    src = re.sub(r"\bisServer\b", "BO_t_isServer", src)
    return src


def main():
    vm = os.environ.get("SQFVM", "sqfvm")
    parts = [PRELUDE]
    for name in TESTED:
        body = shim((FUNCS / f"fn_{name}.sqf").read_text())
        if name == "initData":
            parts.append(body)
        else:
            parts.append(f"BO_fnc_{name} = {{\n{body}\n}};")
    parts.append((ROOT / "tests" / "logic_test.sqf").read_text())
    with tempfile.TemporaryDirectory() as td:
        f = Path(td) / "suite.sqf"
        f.write_text("\n".join(parts))
        cmd = [vm, "--suppress-welcome", "--no-spawn-player", "--no-work-print", "-a",
               "--command-dummy-unary", "publicVariable", "--command-dummy-unary", "diag_log_dummy",
               "--input-sqf", str(f)]
        out = subprocess.run(cmd, capture_output=True, text=True, stdin=subprocess.DEVNULL, timeout=120).stdout
    lines = [l.split("[DIAG_LOG] ", 1)[1] for l in out.splitlines() if "[DIAG_LOG]" in l]
    errs = [l for l in out.splitlines() if "[ERR]" in l or "[FAT]" in l]
    for l in lines:
        print(l)
    for e in errs:
        print("VM ERROR:", e[:300])
    ok = any(l == "RESULT 0 failure(s)" for l in lines) and not errs
    print("SQF logic tests PASSED" if ok else "SQF logic tests FAILED")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
