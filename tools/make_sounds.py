#!/usr/bin/env python3
"""Synthesise the sound effects listed in sheets/sounds.json into .ogg files (needs numpy + ffmpeg)."""
import json
import subprocess
import tempfile
import wave
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent.parent
RATE = 44100


def synth(row):
    n = int(RATE * row["length_s"])
    t = np.arange(n) / RATE
    f = row["freq_hz"]
    if row["id"] == "pop":
        # short noise burst + falling chirp: a balloon pop
        env = np.exp(-t * 45)
        sig = 0.7 * np.random.default_rng(1).uniform(-1, 1, n) * env
        sig += 0.5 * np.sin(2 * np.pi * (f * t - 2500 * t * t)) * env
    elif row["id"] == "build":
        env = np.exp(-t * 9)
        sig = (np.sin(2 * np.pi * f * t) + 0.5 * np.sin(2 * np.pi * f * 1.5 * t)) * env * 0.6
    else:
        env = np.exp(-t * 5)
        sig = np.sin(2 * np.pi * (f * t - 60 * t * t)) * env * 0.7
    return np.clip(sig, -1, 1)


def main():
    rows = json.loads((ROOT / "sheets" / "sounds.json").read_text())["rows"]
    for row in rows:
        out = ROOT / "addons" / "main" / row["file"].replace("\\", "/")
        out.parent.mkdir(parents=True, exist_ok=True)
        pcm = (synth(row) * 32767).astype(np.int16)
        with tempfile.TemporaryDirectory() as td:
            wav = Path(td) / "s.wav"
            with wave.open(str(wav), "wb") as w:
                w.setnchannels(1)
                w.setsampwidth(2)
                w.setframerate(RATE)
                w.writeframes(pcm.tobytes())
            subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-i", str(wav), "-c:a", "libvorbis", "-q:a", "5", str(out)], check=True)
        print("wrote", out.relative_to(ROOT))


if __name__ == "__main__":
    main()
