#!/usr/bin/env python3
"""Synthesise every sounds-sheet effect from scratch (numpy + ffmpeg) into addons/main/sounds/<id>.ogg."""
import json, os, subprocess, wave
import numpy as np

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "addons", "main", "sounds")
TMP = os.path.join(ROOT, "build", "sounds")
SR = 44100
rng = np.random.default_rng(7)


def t(sec): return np.arange(int(SR * sec)) / SR


def env(x, a=0.002, r=0.1):
    n = len(x); e = np.ones(n); ai = max(1, int(a * SR)); e[:ai] = np.linspace(0, 1, ai)
    e *= np.exp(-np.arange(n) / (r * SR)); return x * e


def tone(f, sec, kind="sin"):
    ph = 2 * np.pi * np.cumsum(np.broadcast_to(f, t(sec).shape)) / SR
    return np.sin(ph) if kind == "sin" else np.sign(np.sin(ph))


def noise(sec): return rng.uniform(-1, 1, len(t(sec)))


def lowpass(x, k):
    k = max(1, int(k)); return np.convolve(x, np.ones(k) / k, mode="same")


R = {
    "pop": lambda: env(noise(0.08), 0.0005, 0.012) * 0.8 + env(tone(np.linspace(900, 300, len(t(0.08))), 0.08), 0.0005, 0.02) * 0.5,
    "throw": lambda: env(lowpass(noise(0.18), 6) * np.linspace(0.2, 1, len(t(0.18))), 0.01, 0.06),
    "boom": lambda: env(lowpass(noise(0.9), 40), 0.002, 0.25) * 1.6,
    "freeze": lambda: env(tone(np.linspace(2400, 1800, len(t(0.5))), 0.5) * 0.4 + lowpass(noise(0.5), 2) * 0.3, 0.005, 0.2),
    "place": lambda: env(tone(520, 0.12) + tone(780, 0.12) * 0.5, 0.002, 0.05) * 0.7,
    "sell": lambda: np.concatenate([env(tone(988, 0.08), 0.002, 0.04), env(tone(1319, 0.16), 0.002, 0.08)]) * 0.6,
    "lose": lambda: np.concatenate([env(tone(f, 0.3, "sq"), 0.005, 0.15) * 0.25 for f in (392, 330, 262)]),
    "win": lambda: np.concatenate([env(tone(f, 0.18, "sq"), 0.005, 0.1) * 0.25 for f in (523, 659, 784, 1047)]),
    "round": lambda: np.concatenate([env(tone(f, 0.12), 0.003, 0.06) * 0.6 for f in (660, 880)]),
}


def main():
    rows = json.load(open(os.path.join(ROOT, "sheets", "sounds.json")))["rows"]
    os.makedirs(OUT, exist_ok=True); os.makedirs(TMP, exist_ok=True)
    for r in rows:
        if r["recipe"] == "none": continue
        x = R[r["recipe"]]()
        x = np.clip(x / max(1e-6, np.abs(x).max()) * 0.9, -1, 1)
        wav = os.path.join(TMP, r["id"] + ".wav")
        with wave.open(wav, "wb") as w:
            w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes((x * 32767).astype("<i2").tobytes())
        ogg = os.path.join(OUT, r["id"] + ".ogg")
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", wav, "-c:a", "libvorbis", "-q:a", "5", ogg], check=True)
        print("  sound", os.path.relpath(ogg, ROOT))


if __name__ == "__main__":
    main()
