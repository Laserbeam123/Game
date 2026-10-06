#!/usr/bin/env python3
"""Headless logic tests: loads the real game functions into SQF-VM and runs tests/logic_test.sqf.

  SQFVM=path/to/sqfvm python3 tests/run_sqfvm.py

SQF-VM lacks a few Arma commands, so this runner rewrites ITS COPY of the code to equivalents:
getOrDefault, forEach over a hashmap, getDir between positions, sort (SQF-VM doesn't sort nested arrays by number), and the multiplayer/locality
nulars (isServer true, isMultiplayer false...). Commands with no effect on the rules
(publicVariable, remoteExecCall, createVehicle...) become no-ops: str for one argument, isEqualTo for two.
"""
import glob, os, re, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FN = os.path.join(ROOT, "addons", "main", "functions")
TESTED = ["initData", "now", "buildTrack", "trackPos", "trackNear", "bloonDist", "towerStats", "spawnBloon",
          "damageBloon", "slowBloon", "towerFire", "serverTick", "flushBatch", "gameOver", "requestBuild",
          "requestUpgrade", "requestSell", "requestRound", "playerHit", "playerBlast"]
MAPS = ["BTD_Live", "BTD_CLive", "BTD_Bloons", "BTD_Sounds", "BTD_Towers", "BTD_Upgrades"]
NULARS = {"isMultiplayer": "false", "isServer": "true", "hasInterface": "true", "isRemoteExecuted": "false",
          "remoteExecutedOwner": "0", "serverTime": "0"}
DUMMY_UNARY = ["publicVariable", "createVehicle", "AGLToASL", "deleteVehicle", "crew", "weapons", "primaryWeapon"]
DUMMY_BINARY = ["remoteExecCall", "remoteExec", "setVelocity", "doWatch", "deleteVehicleCrew"]


def match_bracket(s, i, o, c, step):
    depth = 0
    while 0 <= i < len(s):
        if s[i] == o: depth += 1
        elif s[i] == c:
            depth -= 1
            if depth == 0: return i
        i += step
    raise ValueError("unbalanced")


def rewrite(code):
    code = re.sub(r"/\*.*?\*/", "", code, flags=re.S)
    # A getOrDefault [k, d]  ->  ([A, [k, d]] call TEST_god)
    while True:
        m = re.search(r"([\w#()]+) getOrDefault \[", code)
        if not m: break
        start = m.end() - 1
        end = match_bracket(code, start, "[", "]", 1)
        code = code[:m.start()] + f"([{m.group(1)}, {code[start:end+1]}] call TEST_god)" + code[end + 1:]
    # {body} forEach MAP  ->  [{body}, MAP] call TEST_fem
    for name in MAPS:
        while True:
            m = re.search(r"\}\s*forEach\s+" + name + r"\b", code)
            if not m: break
            close = m.start()
            open_ = match_bracket(code, close, "}", "{", -1)
            code = code[:open_] + f"([{code[open_:close+1]}, {name}] call TEST_fem)" + code[m.end():]
    code = re.sub(r"(_\w+) sort (true|false)", r"[\1, \2] call TEST_sort", code)
    code = re.sub(r"(_\w+(?:#\d+)?) getDir (_\w+)", r"([\1, \2] call TEST_getDir)", code)
    for k, v in NULARS.items(): code = re.sub(r"\b" + k + r"\b", v, code)
    # binary commands with no effect on the rules -> isEqualTo (evaluates both sides, changes nothing)
    for u in DUMMY_UNARY: code = re.sub(r"\b" + u + r"\b", "str", code)
    for b in DUMMY_BINARY: code = re.sub(r"\b" + b + r"\b", "isEqualTo", code)
    return code


PRELUDE = r"""
TEST_god = { params ["_m", "_a"]; if ((_a#0) in _m) then {_m get (_a#0)} else {_a#1} };
TEST_fem = { params ["_tfC", "_tfM"]; { private _y = _tfM get _x; call _tfC } forEach (keys _tfM) };
TEST_getDir = { params ["_a", "_b"]; private _d = ((_b#0) - (_a#0)) atan2 ((_b#1) - (_a#1)); if (_d < 0) then {_d = _d + 360}; _d };
TEST_sort = {
    params ["_arr", "_asc"];
    private _key = { if (_this isEqualType []) then {_this#0} else {_this} };
    for "_i" from 1 to (count _arr - 1) do {
        private _v = _arr#_i; private _k = _v call _key; private _j = _i - 1;
        while {_j >= 0 && {[(((_arr#_j) call _key) < _k), (((_arr#_j) call _key) > _k)] select _asc}} do {
            _arr set [_j + 1, _arr#_j]; _j = _j - 1;
        };
        _arr set [_j + 1, _v];
    };
};
BIS_fnc_padNumber = { params ["_n", "_d"]; private _s = str _n; while {count _s < _d} do {_s = "0" + _s}; _s };
BIS_fnc_fire = {};
BIS_fnc_endMissionServer = {};
"""


def main():
    vm = os.environ.get("SQFVM") or "sqfvm"
    out = [PRELUDE]
    for f in TESTED:
        out.append(f"BTD_fnc_{f} = {{\n{rewrite(open(os.path.join(FN, f'fn_{f}.sqf')).read())}\n}};\n")
    out.append(rewrite(open(os.path.join(ROOT, "tests", "logic_test.sqf")).read()))
    os.makedirs(os.path.join(ROOT, "build"), exist_ok=True)
    path = os.path.join(ROOT, "build", "logic_all.sqf")
    open(path, "w").write("".join(out))
    args = [vm, "-a", "--suppress-welcome", "--no-spawn-player", "--no-execute-print", "--input-sqf", path]
    r = subprocess.run(args, capture_output=True, text=True, timeout=600)
    text = r.stdout + r.stderr
    lines = [l for l in text.splitlines() if "[TEST]" in l or "[ERR]" in l or "[FAT]" in l]
    for l in lines: print(l.split("[DIAG_LOG] ")[-1] if "[DIAG_LOG]" in l else l)
    passed = sum("[TEST] PASS" in l for l in lines)
    failed = sum("[TEST] FAIL" in l for l in lines) + sum("[ERR]" in l or "[FAT]" in l for l in lines)
    done = any("[TEST] DONE" in l for l in lines)
    print(f"\n{passed} passed, {failed} failed{'' if done else ', and the run did not reach the end'}")
    sys.exit(0 if failed == 0 and done else 1)


if __name__ == "__main__":
    main()
