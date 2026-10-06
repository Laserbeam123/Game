#!/usr/bin/env python3
"""Bloons Ops sheet tooling.

  python3 tools/gen.py preflight   overlay every sheet, list unfilled cells and broken references
  python3 tools/gen.py gen         preflight, then write the generated SQF/config from the sheets

The sheets in sheets/*.json are the source of truth. Generated files:
  addons/main/functions/fn_initData.sqf   one hashmap per row
  addons/main/CfgFunctions.hpp            one class per hooks row
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from palette import TAN, WHITE, tex_name, tex_path, tower_colours  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
SHEETS = ROOT / "sheets"
MAIN = ROOT / "addons" / "main"
FUNCS = MAIN / "functions"
MISSIONS = ROOT / "addons" / "missions"
STATUSES = ("designed", "built", "tested")
FNC_PATH = r"\z\bloonsops\addons\main\functions"


def load():
    return {p.stem: json.loads(p.read_text()) for p in sorted(SHEETS.glob("*.json"))}


def ids(sheets, name):
    return {r["id"] for r in sheets[name]["rows"]}


def preflight(sheets):
    errors, notes = [], []
    status_count = {s: 0 for s in STATUSES}
    for name, sheet in sheets.items():
        cols = sheet["columns"]
        colnames = [c["name"] for c in cols]
        seen = set()
        for i, row in enumerate(sheet["rows"]):
            rid = row.get("id", f"#{i}")
            where = f"{name}[{rid}]"
            if rid in seen:
                errors.append(f"{where}: duplicate id")
            seen.add(rid)
            for extra in set(row) - set(colnames):
                errors.append(f"{where}: cell '{extra}' has no column")
            for c in cols:
                cn, ct = c["name"], c["type"]
                if cn not in row:
                    errors.append(f"{where}.{cn}: unfilled")
                    continue
                v = row[cn]
                optional = ct.endswith("?")
                if v == "TBD":
                    errors.append(f"{where}.{cn}: TBD (not yet established)")
                    continue
                if v is None or (v == "" and not optional) or (v == [] and ct not in ("refs", "groups")):
                    errors.append(f"{where}.{cn}: unfilled")
                    continue
                if ct in ("int",) and not isinstance(v, int):
                    errors.append(f"{where}.{cn}: expected int, got {v!r}")
                if ct == "number" and not isinstance(v, (int, float)):
                    errors.append(f"{where}.{cn}: expected number, got {v!r}")
                if ct == "bool" and not isinstance(v, bool):
                    errors.append(f"{where}.{cn}: expected bool, got {v!r}")
                if ct == "enum" and v not in c["values"]:
                    errors.append(f"{where}.{cn}: {v!r} not in {c['values']}")
                if ct == "rgba" and not (isinstance(v, list) and len(v) == 4 and all(0 <= x <= 1 for x in v)):
                    errors.append(f"{where}.{cn}: bad rgba {v!r}")
                if ct == "pos2" and not (isinstance(v, list) and len(v) == 2):
                    errors.append(f"{where}.{cn}: bad position {v!r}")
                if ct == "status":
                    if v not in STATUSES:
                        errors.append(f"{where}.{cn}: status must be one of {STATUSES}")
                    else:
                        status_count[v] += 1
                if ct in ("ref", "ref?") and v != "" and v not in ids(sheets, c["ref"]):
                    errors.append(f"{where}.{cn}: '{v}' does not resolve in {c['ref']}")
                if ct == "refs":
                    for x in v:
                        if x not in ids(sheets, c["ref"]):
                            errors.append(f"{where}.{cn}: '{x}' does not resolve in {c['ref']}")
                if ct == "groups":
                    if not v:
                        errors.append(f"{where}.{cn}: round has no groups")
                    for g in v:
                        if not (isinstance(g, list) and len(g) == 4):
                            errors.append(f"{where}.{cn}: group {g!r} must be [bloon,count,spacing,delay]")
                        elif g[0] not in ids(sheets, c["ref"]):
                            errors.append(f"{where}.{cn}: bloon '{g[0]}' does not resolve")
                        elif not (isinstance(g[1], int) and g[1] > 0 and g[2] > 0 and g[3] >= 0):
                            errors.append(f"{where}.{cn}: group {g!r} has bad numbers")

    # cross-sheet rules
    bl = {r["id"]: r for r in sheets["bloons"]["rows"]}
    for b in bl.values():
        if (b["child"] == "") != (b["child_count"] == 0):
            errors.append(f"bloons[{b['id']}]: child and child_count disagree")
        if b["child"] in bl:
            want = 1 + b["child_count"] * bl[b["child"]]["lives_cost"]
            if b["lives_cost"] != want:
                errors.append(f"bloons[{b['id']}].lives_cost: {b['lives_cost']} != {want} (1 + children)")
    tw = {r["id"]: r for r in sheets["towers"]["rows"]}
    for u in sheets["upgrades"]["rows"]:
        if u["tower"] in tw and tw[u["tower"]]["upgrade"] != u["id"]:
            errors.append(f"upgrades[{u['id']}]: tower {u['tower']} points at {tw[u['tower']]['upgrade']}")
    for t in tw.values():
        if t["splash_m"] > 0 and t["impact_delay_s"] <= 0:
            notes.append(f"towers[{t['id']}]: splash with no impact delay")
        if t["kind"] != "static" and t["mannable"]:
            errors.append(f"towers[{t['id']}]: only static weapons can be mannable")
        if t["kind"] in ("infantry", "static", "heli") and not t["object_class"]:
            errors.append(f"towers[{t['id']}].object_class: {t['kind']} needs an Arma class")
        if t["kind"] in ("infantry", "static") and not t["crew_class"]:
            errors.append(f"towers[{t['id']}].crew_class: {t['kind']} needs a crew class")
        if (t["kind"] == "heli") != (t["hover_m"] > 0):
            errors.append(f"towers[{t['id']}].hover_m: helicopters (and only helicopters) hover")
        if (t["kind"] == "farm") != (t["income"] > 0):
            errors.append(f"towers[{t['id']}].income: farms (and only farms) pay income")
        if t["kind"] != "farm" and (t["range_m"] <= 0 or (t["damage"] <= 0 and t["slow_mult"] >= 1)):
            errors.append(f"towers[{t['id']}]: a shooting tower needs range and either damage or a slow")
        if (t["slow_mult"] < 1) != (t["slow_s"] > 0):
            errors.append(f"towers[{t['id']}]: slow_mult and slow_s disagree")
    eco = {r["id"]: r["value"] for r in sheets["economy"]["rows"]}
    rounds = sorted(r["id"] for r in sheets["rounds"]["rows"])
    if rounds != list(range(1, eco.get("final_round", 0) + 1)):
        errors.append(f"rounds: ids {rounds[:3]}..{rounds[-3:]} must run 1..final_round ({eco.get('final_round')})")
    lead_round = min((r["id"] for r in sheets["rounds"]["rows"] for g in r["groups"] if bl[g[0]]["needs_lead_popper"]), default=None)
    if lead_round and not any(t["pops_lead"] for t in tw.values()) and not any(u["grants_lead"] for u in sheets["upgrades"]["rows"]):
        errors.append("rounds: lead bloons appear but nothing pops lead")
    camo_round = min((r["id"] for r in sheets["rounds"]["rows"] for g in r["groups"] if bl[g[0]]["camo"]), default=None)
    if camo_round and not any(t["sees_camo"] for t in tw.values()):
        errors.append("rounds: camo bloons appear but no tower sees camo")

    # hooks <-> files
    hook_ids = ids(sheets, "hooks")
    for h in sheets["hooks"]["rows"]:
        f = FUNCS / f"fn_{h['id']}.sqf"
        if not h["generated"] and not f.exists():
            errors.append(f"hooks[{h['id']}]: {f.relative_to(ROOT)} missing (unimplemented)")
    for f in FUNCS.glob("fn_*.sqf"):
        if f.stem[3:] not in hook_ids:
            errors.append(f"{f.relative_to(ROOT)}: no hooks row")
    # every BO_fnc_x used in code must be a hooks row
    import re
    used = set()
    for f in list(FUNCS.glob("*.sqf")) + list(MISSIONS.rglob("*.sqf")):
        used |= set(re.findall(r"BO_fnc_(\w+)", f.read_text()))
    for u in sorted(used - hook_ids):
        errors.append(f"code calls BO_fnc_{u} but hooks has no such row")
    mission_classes = set(re.findall(r"class (\w+) \{", (MISSIONS / "config.cpp").read_text()))
    for u in sheets["ui"]["rows"]:
        if not (MAIN / u["picture"].replace("\\", "/")).exists():
            errors.append(f"ui[{u['id']}]: {u['picture']} missing (run tools/make_art.py + hemtt utils paa convert)")
        if u["mission"] not in mission_classes:
            errors.append(f"ui[{u['id']}].mission: {u['mission']} is not a CfgMissions class")
    for c in tower_colours(sheets["towers"]["rows"]):
        if not (MAIN / "data" / f"{tex_name(c)}_co.paa").exists():
            errors.append(f"towers: painted texture data/{tex_name(c)}_co.paa missing (tools/make_art.py + paa convert)")
    for b in sheets["bloons"]["rows"]:
        if not (MAIN / "data" / f"bloon_{b['id']}_co.paa").exists():
            errors.append(f"bloons[{b['id']}]: data/bloon_{b['id']}_co.paa missing (tools/make_art.py + hemtt utils paa convert)")
    for s in sheets["sounds"]["rows"]:
        if not (MAIN / s["file"].replace("\\", "/")).exists():
            errors.append(f"sounds[{s['id']}]: {s['file']} missing (run tools/make_sounds.py)")
    for d in [MISSIONS / m["mission_dir"] for m in sheets["maps"]["rows"]] + [MISSIONS / "BloonsOps_Test.Altis"]:
        for need in ("mission.sqm", "description.ext", "initServer.sqf", "initPlayerLocal.sqf", "onPlayerRespawn.sqf"):
            if not (d / need).exists():
                errors.append(f"{d.relative_to(ROOT)}/{need} missing")
    return errors, notes, status_count


def sqf(v):
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return repr(v)
    if isinstance(v, str):
        return '"' + v.replace('"', '""') + '"'
    if isinstance(v, list):
        return "[" + ",".join(sqf(x) for x in v) + "]"
    raise TypeError(v)


def row_struct(row, skip=("status",)):
    pairs = ",".join(f"[{sqf(k)},{sqf(v)}]" for k, v in row.items() if k not in skip)
    return f"createHashMapFromArray [{pairs}]"


def generate(sheets):
    out = ["// GENERATED by tools/gen.py from sheets/*.json - edit the sheets, not this file.", ""]
    for name in ("bloons", "towers", "upgrades", "maps", "sounds"):
        out.append(f"BO_{name.capitalize()} = createHashMap;")
        for r in sheets[name]["rows"]:
            out.append(f"BO_{name.capitalize()} set [{sqf(r['id'])}, {row_struct(r)}];")
        out.append("")
    # painted textures for the sphere monkeys (derived from body_rgba / accent_rgba)
    for t in sheets["towers"]["rows"]:
        out.append(f"(BO_Towers get {sqf(t['id'])}) set [\"body_tex\", {sqf(tex_path(t['body_rgba']))}];")
        out.append(f"(BO_Towers get {sqf(t['id'])}) set [\"accent_tex\", {sqf(tex_path(t['accent_rgba']))}];")
    out.append(f"BO_TexTan = {sqf(tex_path(TAN))};")
    out.append(f"BO_TexWhite = {sqf(tex_path(WHITE))};")
    out.append("")
    out.append("BO_Rounds = [];")
    for r in sorted(sheets["rounds"]["rows"], key=lambda r: r["id"]):
        out.append(f"BO_Rounds pushBack {row_struct(r)};")
    out.append("")
    out.append("BO_Cfg = createHashMap;")
    for r in sheets["economy"]["rows"]:
        out.append(f"BO_Cfg set [{sqf(r['id'])}, {sqf(r['value'])}];")
    out.append("BO_TowerOrder = " + sqf([r["id"] for r in sheets["towers"]["rows"]]) + ";")
    (FUNCS / "fn_initData.sqf").write_text("\n".join(out) + "\n")

    hpp = ["// GENERATED by tools/gen.py from sheets/hooks.json", "class CfgFunctions {", "    class BO {",
           "        tag = \"BO\";", "        class core {", f"            file = \"{FNC_PATH}\";"]
    for h in sheets["hooks"]["rows"]:
        extra = " preInit = 1;" if h["hook"].startswith("preInit") else (" postInit = 1;" if h["hook"].startswith("postInit") else "")
        hpp.append(f"            class {h['id']} {{{extra}}};")
    hpp += ["        };", "    };", "};"]
    (MAIN / "CfgFunctions.hpp").write_text("\n".join(hpp) + "\n")

    spot = ["// GENERATED by tools/gen.py from sheets/ui.json", "class CfgMainMenuSpotlight {"]
    for u in sheets["ui"]["rows"]:
        action = f"playMission ['', configFile >> 'CfgMissions' >> 'Missions' >> '{u['mission']}']"
        spot += [f"    class {u['id']} {{",
                 f"        text = {sqf(u['text'])};",
                 "        textIsQuote = 0;",
                 f"        picture = {sqf(chr(92) + 'z' + chr(92) + 'bloonsops' + chr(92) + 'addons' + chr(92) + 'main' + chr(92) + u['picture'])};",
                 f"        action = {sqf(action)};",
                 f"        actionText = {sqf(u['action_text'])};",
                 "        condition = \"true\";",
                 "    };"]
    spot.append("};")
    (MAIN / "CfgMainMenuSpotlight.hpp").write_text("\n".join(spot) + "\n")


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "preflight"
    sheets = load()
    if cmd == "gen":
        generate(sheets)  # generated files count as implemented for the preflight below
    errors, notes, counts = preflight(sheets)
    cells = sum(len(s["rows"]) * len(s["columns"]) for s in sheets.values())
    print(f"preflight: {len(sheets)} sheets, {sum(len(s['rows']) for s in sheets.values())} rows, {cells} cells")
    print("row status: " + ", ".join(f"{k}={v}" for k, v in counts.items()))
    for n in notes:
        print("note: " + n)
    for e in errors:
        print("FAIL: " + e)
    print("preflight CLEAN" if not errors else f"preflight: {len(errors)} problem(s)")
    sys.exit(1 if errors else 0)


if __name__ == "__main__":
    main()
