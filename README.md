# Bloons Ops

Tower defense inside **Arma 3**, in the style of **Bloons TD 6**. Bloons float down a road on Altis. You walk the
track with a build tablet, place military towers beside the road, and pop 20 rounds of bloons before they
reach the end. Play solo, or co-op with up to 4 players sharing cash and lives.

**Requires:** Arma 3 (base game only, no DLC). It's a regular Arma 3 mod (`@bloonsops`) with no other dependencies.

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
- **Players are invincible.** Your own gun still pops bloons, and grenades and launchers pop lead.
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

To test it in game, play Singleplayer → Scenarios → *Bloons Ops - Self Test*. It plays every round by itself and writes `[BloonsOps][TEST] PASS/FAIL` lines to the RPT log.

## Credits
- Made with Claude Code. All code, sheets and sound effects are original. Sounds are synthesised by `tools/make_sounds.py`.
- Built with [HEMTT](https://github.com/BrettMayson/HEMTT).
- Arma 3 © Bohemia Interactive. Bloons TD 6 © Ninja Kiwi. This is a fan-made homage: it ships no files or assets from either game.

## License
MIT (see LICENSE). Others may remix it on Melty.
