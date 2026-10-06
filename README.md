# Bloons Ops

Tower defense inside **Arma 3**, in the style of **Bloons TD 6**. Bloons float down a road on Altis. You walk the
track with a build tablet, place military towers beside the road, and pop 20 rounds of bloons before they
reach the end. Play solo, or co-op with up to 4 players sharing cash and lives.

**Requires:** Arma 3 (base game only, no DLC). It's a regular Arma 3 mod (`@bloonsops`) with no other dependencies.

## What you get
- **One Altis map.** The track is built from the island's real road network, marked with cones and map markers.
- **7 bloon types:**
  - red, blue, green, yellow and pink, each hiding the next one inside;
  - **lead**, which only explosives pop;
  - **camo**, which only the Sniper can see.
- **4 towers, each with one upgrade:**
  - **Dart Squad** (3 riflemen) → *Veteran Squad*
  - **M2 HMG Nest** → *AP Rounds* (pops lead). **You can take the gun yourself.**
  - **Sniper** (sees camo) → *Semi-Auto Rifle*
  - **Mk6 Mortar** (explosive splash, pops lead) → *Heavy Shells*
- **Your own gun pops bloons too.** Bullets pop one layer, and grenades and launchers pop everything in the blast, lead included.
- **Shared rules:** cash and lives are shared, and you earn an end-of-round bonus. Towers sell back for 70%.
- **20 rounds,** with a win and a lose screen.

## How to play
- **Solo:** Singleplayer → Scenarios → *Bloons Ops (Altis)*.
- **Co-op:** Multiplayer → Host → *Bloons Ops - Co-op 1-4 (Altis)*. Friends join the hosted game.

1. Open the scroll menu, choose **Build Tablet** and pick a tower. It's placed 4 m in front of you, at least 5 m off the road.
2. Choose **Start Next Round**.
3. Walk up to a tower to upgrade it, sell it or take the gun.

## Building from source
The design lives in `sheets/*.json`, one row per bloon, tower, upgrade, round, constant and game hook. The code is generated from those rows and checked against them.

```
python3 tools/make_sounds.py   # synthesise the sound effects (numpy + ffmpeg)
python3 tools/gen.py gen       # preflight the sheets, write generated SQF/config
hemtt release                  # build @bloonsops into releases/
SQFVM=path/to/sqfvm python3 tests/run_sqfvm.py   # headless logic tests (SQF-VM)
```

To test it in game, play Singleplayer → Scenarios → *Bloons Ops - Self Test*. It plays every round by itself and writes `[BloonsOps][TEST] PASS/FAIL` lines to the RPT log.

## Credits
- Made with Claude Code. All code, sheets and sound effects are original. Sounds are synthesised by `tools/make_sounds.py`.
- Built with [HEMTT](https://github.com/BrettMayson/HEMTT).
- Arma 3 © Bohemia Interactive. Bloons TD 6 © Ninja Kiwi. This is a fan-made homage: it ships no files or assets from either game.
