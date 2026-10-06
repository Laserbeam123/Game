# Bloon Strike: Altis: build log

## Route
- **Host game:** Arma 3 (Real Virtuality 4, SQF). Official mod route: an `@btdops` folder of PBOs loaded with `-mod=@btdops`. No loader, no game files touched. Melty installs no loader for Arma 3 and needs none.
- **Bloons TD 6:** its pictures only, read from the player's own install by `tools/btd6art` (UnityPy, read-only, offline). BTD6 is never started or patched, so its online account checks are not involved. Nothing from BTD6 is shipped.
- **Arma 2: OA:** named as a related game only (Melty can't install into it).

## Tooling (cloud session, Linux)
- HEMTT v1.22.0 built from source (`cargo build --release`); SQF-VM built from github.com/SQFvm/runtime.
- Windows Python for the converter: CPython 3.12.10 from NuGet (python.org is blocked in this session), win_amd64 wheels from PyPI; NumPy pinned to 1.26.4 (2.5 needs `crealf`, which Wine 9 lacks, so the package could not be tested otherwise).
- Wine 9 (Ubuntu archive) to run the Windows converter package here.

## Verified here
- `tools/gen.py preflight`: 9 sheets, all cells and cross-sheet references, code <-> hooks rows, network allow-list, constants and sounds used by code. CLEAN.
- `hemtt check` / `hemtt release`: 45 SQF files compile, 8 configs rapify, 2 PBOs built and signed, no lint warnings.
- `tests/run_sqfvm.py`: 52/52 headless tests on the real functions (bloon rules, lead/MOAB, freeze, every tower against bloons it should/shouldn't pop, build/upgrade/sell, rounds through the real server loop, a whole 10-round game won by a modest defence and lost with none).
- Converter on real Unity sprite atlases (UnityPy's test bundles standing in for BTD6), on Linux and as the Windows package under Wine: finds sprites by name, crops from atlas, writes DXT5 PAAs (decoded back by HEMTT) and a PBO HEMTT validates (checksum, sorted, prefix). Without BTD6: empty add-on, game uses stand-ins.
- Melty: validate_recipe valid (1860 files placed, 0 left out); one_click_check yes, publishable, nothing to finish.

## Not yet verified (needs Arma 3 on the user's PC) - also listed by `tools/gen.py verify`
- Glide feel and animation, billboard size (icon_scale), the track's spot on Altis (slope is logged), main-menu button, all towers' Arma classes firing, sounds, BTD6 sprite names on a real install, co-op with two PCs.
- In-game self test: Singleplayer > Scenarios > Bloon Strike: Altis - Self Test, then `[BTDOPS][TEST]` lines in `%LOCALAPPDATA%\Arma 3\Arma3_x64_*.rpt`.

## Balance (from the headless full game)
- MOAB 80 hp at 0.6x speed; start cash 850; round bonus 150 + 10/round (+100 on MOAB rounds); dart $170 / 0.8 s; M2 $400 / 0.2 s.

## Melty
- Listing: "Bloon Strike: Altis" (modId ec2625fa-f337-4aa5-9180-843c3c9f5b89, slug bloon-strike-altis), the draft formerly "Bloons Ops", reused as agreed. MIT, remixes allowed. Games: arma-3 (primary), custom-bloons-td-6, custom-arma-2-operation-arrowhead (secondary).
- Release 0.1.0 submitted as a draft: btdops-0.1.0.zip (main) + btdops-btd6art-0.1.0.zip (converter, setup step). One click: yes. Not published.
- Recipe: mode installed; `@btdops/` -> `{game}/@btdops`; `btd6art/` -> `{managed}/btd6art`; setup runs the converter and waits for `{game}/@btdops/btdops_art_ready.txt`; launch `-mod=@btdops -skipIntro -noSplash`; multiplayer maxPlayers 4, no connect (Arma has no relay; players join from the server browser).
