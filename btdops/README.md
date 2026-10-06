# Bloons TD Ops

Bloons TD 6 inside **Arma 3**. You hover-glide in first person anywhere on Altis, place **Arma 3 towers** (M2 HMG nest, Mk6 mortar, sniper team) and **Bloons TD 6 monkeys** (Dart Monkey, Bomb Shooter, Ice Monkey) beside the bloon track, and pop 10 rounds of bloons with them and your own gun. Rounds 5 and 10 end with a M.O.A.B. Solo, or co-op for up to 4 players sharing cash and lives.

**Requires:** Arma 3 (base game, no DLC). **Bloons TD 6** on the same PC for the real monkey and bloon pictures: on first launch the mashup reads them from *your own* BTD6 install (read-only, nothing is uploaded or shared). Without BTD6 it plays with stand-in pictures.

## What you get
- **Hover-glide:** you float about a metre off the ground and slide fast in any direction with WASD (Shift = faster), gun in hand. Toggle it from the scroll menu.
- **One Altis map:** a winding bloon track by the main airfield, marked with cones and a line.
- **7 bloons:** red, blue, green, yellow, pink (each hiding the one before), lead (only explosives pop it) and the M.O.A.B. (80 hp, drops 4 pinks).
- **Build Tablet with 6 towers in two columns**, each with one upgrade:
  - **ARMA 3:** M2 HMG Nest (AP Rounds), Mk6 Mortar (Heavy Shells, pops lead), Sniper Team (.50 Cal, whole-map range).
  - **BLOONS TD 6:** Dart Monkey (Sharp Shots), Bomb Shooter (Bigger Bombs, pops lead), Ice Monkey (Permafrost, freezes bloons).
  - Arma towers are real Arma soldiers and weapons; BTD6 monkeys are your BTD6 pictures standing on the ground.
- **Your own gun pops bloons** (a layer per bullet); grenades and launchers pop lead.
- **10 rounds** with round bonuses, upgrades, selling for 70%, and fast forward.
- **Solo or co-op 1-4:** shared cash and lives; friends join the host's game.

## How to play
- **Solo:** the red **PLAY BLOONS TD OPS** button on Arma 3's main menu (also Singleplayer > Scenarios > *Bloons TD Ops (Altis)*).
- **Co-op:** the host picks Multiplayer > Host > *Bloons TD Ops - Co-op 1-4 (Altis)*; friends join that game from the server browser.
1. Scroll menu > **Build Tablet**, pick a tower: it goes where you are looking (not on the track, not on another tower).
2. Scroll menu > **Start next round**.
3. Stand next to a tower to **Upgrade** or **Sell** it (scroll menu); its range ring shows.

## How it is built
- `sheets/*.json` hold the whole design: one row per bloon, tower, upgrade, round, constant, picture, sound, map and game hook. `tools/gen.py` preflights every cell and cross-reference, then generates the data structs, function list, sounds, tablet buttons, network allow-list and scenarios from them.
- `addons/main` is the Arma 3 mod (SQF), `addons/missions` the scenarios. The server owns the game; clients draw bloons and BTD6 monkeys as camera-facing billboards.
- `tools/btd6art/` is the BTD6 art converter (Python + UnityPy). Melty runs it once before the first launch with its own bundled Windows Python. It writes `<Arma 3>/@btdops/addons/btdops_art.pbo`, a private add-on that stays on the player's PC.

```
tools/build.sh                                     # art, sounds, sheets -> code (preflight), HEMTT release
SQFVM=path/to/sqfvm python3 tests/run_sqfvm.py     # headless rule tests on the real functions
python3 tools/package_btd6art.py <ver> <python.nupkg> <wheels>   # the converter package
```
In game: Singleplayer > Scenarios > *Bloons TD Ops - Self Test* builds every tower, checks the glide and plays all rounds by itself, writing `[BTDOPS][TEST] PASS/FAIL` lines to the RPT log.

## Credits
- Made with Claude Code. Code, sheets, stand-in pictures and sound effects are original (pictures drawn by `tools/make_art.py`, sounds synthesised by `tools/make_sounds.py`).
- Built with [HEMTT](https://github.com/BrettMayson/HEMTT). Converter libraries: see `tools/btd6art/CREDITS.txt`.
- Arma 3 (c) Bohemia Interactive. Bloons TD 6 (c) Ninja Kiwi. Arma 2: Operation Arrowhead (c) Bohemia Interactive. A fan-made mashup: it ships no files from any of these games.

## License
MIT (see LICENSE).
