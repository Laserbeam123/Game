#!/bin/sh
# Full build: art, sounds, sheets -> code (with preflight), then HEMTT release into releases/.
set -e
cd "$(dirname "$0")/.."
python3 tools/make_art.py
python3 tools/make_sounds.py
python3 tools/gen.py gen
hemtt release
