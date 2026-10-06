#!/usr/bin/env python3
"""Flag scripting commands an SQF tree uses that Arma 2: Operation Arrowhead (1.64) does not have.

  python3 tools/oa/check_oa.py oa/addons        -> lists every unknown-in-OA command with file:line, exit 1 if any

Source of truth: tools/oa/commands_oa.txt (wiki 'since' data) + commands_oa_extra.txt (hand-verified).
Identifiers that are not scripting commands at all (variables, functions) are ignored.
"""
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent


def load(name):
    out = set()
    for line in (HERE / name).read_text().splitlines():
        line = line.split("#", 1)[0].strip()
        if line:
            out.add(line.split()[0].lower())
    return out


def main():
    root = Path(sys.argv[1] if len(sys.argv) > 1 else "oa/addons")
    allc = load("commands_all.txt")
    ok = load("commands_oa.txt") | load("commands_oa_extra.txt")
    bad = []
    for f in sorted(list(root.rglob("*.sqf")) + list(root.rglob("*.hpp")) + list(root.rglob("*.cpp")) + list(root.rglob("*.ext"))):
        for n, line in enumerate(f.read_text(errors="replace").splitlines(), 1):
            code = re.sub(r'"(?:[^"]|"")*"', '""', line.split("//", 1)[0])
            if f.suffix in (".hpp", ".cpp", ".ext"):
                # only the config strings that are code (button actions, display onLoad)
                code = " ".join(re.findall(r'(?:action|onLoad|onUnload)\s*=\s*"((?:[^"]|"")*)"', line))
            for w in re.findall(r"\b[A-Za-z_][A-Za-z0-9_]*\b", code):
                lw = w.lower()
                if lw in allc and lw not in ok:
                    bad.append(f"{f}:{n}: {w}")
    for b in bad:
        print("NOT IN OA:", b)
    print(f"OA command check: {len(bad)} problem(s)")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
