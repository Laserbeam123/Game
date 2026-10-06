# Bloons Ops

Tower defense inside **Arma 3**, in the style of **Bloons TD 6**. Bloons float down a road on Altis. You walk the
track with a build tablet, place military towers beside the road, and pop 20 rounds of bloons before they
reach the end. Play solo, or co-op with up to 4 players sharing cash and lives.

**Requires:** Arma 3 (base game only, no DLC). It's a regular Arma 3 mod (`@bloonsops`) with no other dependencies.

**Optional: real Bloons TD 6 art.** If you also own **Bloons TD 6** on Steam, the BLOONS TD towers and the bloons
show as the real BTD6 monkeys and bloons (flat cut-outs that always face you), and pops use BTD6's pop sound.
The art is made **on your own PC from your own copy** by `@bloonsops/btd6/bloonsops_btd6.exe` (Melty runs it once
before the first launch). It writes a local `@bloonsops_btd6` mod next to Arma; nothing from BTD6 is uploaded or
shared, and this mod ships none of it. Without BTD6 everything keeps the Bloons Ops look. After a BTD6 update, run
the exe again.

## What you get
- **One Altis map.** The track follows the island's real roads, marked with cones. The ground around it is smoothed into gentle rolling terrain.
- **7 cartoon bloon types:** glossy red, blue, green, yellow and pink, each hiding the next one inside. **Lead** bloons only pop to explosives, and **camo** bloons are invisible to towers that can't see camo.
- **A build tablet with 15 towers in two sections**, each tower with one upgrade:
  - **ARMA 3:**
    - Dart Squad
    - M2 HMG Nest. *You can take the gun yourself.*
    - Sniper Team (sees camo)
    - Mk6 Mortar (pops lead)
    - **UH-80 Ghost Hawk** and **AH-99 Blackfoot.** These helicopters hover over the pad you place.
  - **BLOONS TD:**
    - Dart Monkey
    - Boomerang Monkey
    - Bomb Shooter (pops lead)
    - Tack Shooter
    - Ice Monkey (freezes bloons)
    - Glue Gunner (slows bloons)
    - Ninja Monkey (sees camo)
    - Super Monkey
    - Banana Farm (cash every round)
- **Players are invincible and run 2.5x faster on foot.** Your own gun still pops bloons, and grenades and launchers pop lead.
- **20 rounds,** with shared cash and lives, round bonuses, and selling towers back for 70%. Solo or co-op for up to 4.

## How to play
- **Solo:** Singleplayer → Scenarios → *Bloons Ops (Altis)*.
- **Co-op:** Multiplayer → Host → *Bloons Ops - Co-op 1-4 (Altis)*. Friends join the hosted game.

1. Open the scroll menu, choose **Build Tablet** and pick a tower from the ARMA 3 or BLOONS TD column. It's placed 4 m in front of you, at least 5 m off the road.
2. Choose **Start Next Round**.
3. Stand next to a tower to upgrade it, sell it or take the gun (scroll menu).

## Building from source
The design lives in `sheets/*.json`, one row per bloon, tower, upgrade, round, constant and game hook. The code is generated from those rows and checked against them.

```
python3 tools/make_sounds.py   # synthesise the sound effects (numpy + ffmpeg)
python3 tools/gen.py gen       # preflight the sheets, write generated SQF/config
hemtt release                  # build @bloonsops into releases/
SQFVM=path/to/sqfvm python3 tests/run_sqfvm.py   # headless logic tests (SQF-VM)
```

### The BTD6 art converter (`tools/btd6/`)
`sheets/btd6_art.json` says which BTD6 sprite (by name patterns) shows each tower and bloon, and which clip is the pop.
`bloonsops_btd6.py` finds BTD6 and Arma 3 through Steam's `libraryfolders.vdf`, indexes BTD6's asset bundles with
UnityPy, trims and pads each sprite to a power-of-two square, writes DXT5 PAAs and `pop.ogg`, and packs an unsigned
`@bloonsops_btd6/addons/bloonsops_btd6.pbo` (CfgPatches `bloonsops_btd6`). The game checks for that CfgPatches and
falls back to its own look without it.

```
python3 tools/btd6/bloonsops_btd6.py inspect          # list BTD6 sprite/clip names (writes btd6_inspect.txt)
python3 tools/btd6/bloonsops_btd6.py                  # build @bloonsops_btd6 in your Arma 3 folder
python3 tools/btd6/test_armafmt.py path/to/hemtt      # PAA/PBO writers checked by HEMTT's readers
python3 tools/btd6/sample_test.py python3 tools/btd6/bloonsops_btd6.py   # end-to-end on public Unity samples
```
The Windows exe is built by `.github/workflows/btd6-converter.yml` (PyInstaller). Bundled pieces and licences:
`tools/btd6/THIRD_PARTY.md`.

To test it in game, play Singleplayer → Scenarios → *Bloons Ops - Self Test*. It plays every round by itself and writes `[BloonsOps][TEST] PASS/FAIL` lines to the RPT log.

## Credits
- Made with Claude Code. All code, sheets and sound effects are original. Sounds are synthesised by `tools/make_sounds.py`.
- Built with [HEMTT](https://github.com/BrettMayson/HEMTT).
- BTD6 converter: [UnityPy](https://github.com/K0lb3/UnityPy) (MIT), [fsb5](https://github.com/HearthSim/python-fsb5) (MIT), libogg/libvorbis (BSD), numpy, Pillow. See `tools/btd6/THIRD_PARTY.md`.
- Arma 3 © Bohemia Interactive. Bloons TD 6 © Ninja Kiwi. This is a fan-made homage: it ships no files or assets from either game. The optional BTD6 art is converted on each player's own PC from their own copy and never leaves it.

## License
MIT (see LICENSE). Others may remix it on Melty.
