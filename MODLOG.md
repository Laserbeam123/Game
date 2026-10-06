# Bloons Ops: build log

## Route
- Arma 3, Real Virtuality 4 engine, scripted in SQF.
- It uses the official mod route: an `@bloonsops` folder of PBOs loaded with `-mod=@bloonsops`. No loader is needed, and no game files are touched.
- Bloons TD 6 is the inspiration only, not a required game.

## Tooling (cloud session, Linux)
- **HEMTT v1.22.0**, built from source (git tag v1.22.0) with `cargo build --release`. It isn't on crates.io, and GitHub release downloads are blocked here. The main branch needs nightly Rust.
- **universal-modder**, cloned for reference. It has no Arma 3 note yet.
- **Sounds** are synthesised with numpy and ffmpeg (`tools/make_sounds.py`).

## Design
- **Server-authoritative state.** `BO_Live` maps each id to `[type, d0, t0]`. A bloon's position is computed as `d0 + speed * (now - t0)` along the track polyline, using `BO_fnc_now` (serverTime in MP).
- **Bloon visuals are client-local.** Spheres are `Sign_Sphere100cm_F` created with createVehicleLocal and moved every frame, so there's no per-tick network traffic. The server only broadcasts spawn and pop batches.
- **Tower targeting** compares track distances with precomputed coverage intervals (`towerCoverage`), so there are no 3D checks per tick.
- **Tower fire is visual only.** The real projectile is deleted in a Fired handler on every machine, and damage is scripted. The mortar drops a real `Sh_82mm_AMOS` on the impact point.
- **Player shots** are tracked per frame from FiredMan, as a segment-vs-sphere test. Explosives use the projectile `Explode` event.

## Verified (no game in this session)
- `tools/gen.py preflight`: all 84 rows, 604 cells and every cross-sheet reference resolve.
- `hemtt check` / `hemtt release`: 34 SQF files compile, 4 configs rapify, 2 PBOs are built and signed, and there are 0 lint warnings.

## Headless logic tests (SQF-VM)
- **What runs:** `tests/run_sqfvm.py` loads the real `fn_initData`, `fn_pathPos`, `fn_spawnBloons`, `fn_damageBloon` and `fn_towerCoverage` into SQF-VM. SQF-VM was built from github.com/SQFvm/runtime with `-fpermissive -Wno-changes-meaning`.
- **Shims:** SQF-VM lacks `getOrDefault`, `isServer`, `getDir` and hashmap `forEach`, `keys` and `values`. The runner swaps only `getOrDefault` and `isServer` for equivalent helpers.
- **What they check:**
  - track maths, including around a corner and clamping at the end;
  - tower reach;
  - bloon layers popping into their children, damage carrying through layers, and children staying in place;
  - lead immunity, and explosives splitting lead into 2 pinks;
  - cash: fully popping each bloon pays exactly its lives_cost;
  - stale ids, and no pops after game over;
  - that the start cash can afford a tower.
- **Result:** 28/28 pass. Red-bloon equivalents per round: 20,35,35,71,59,57,75,92,90,120,78,80,169,146,120,92,48,240,115,114.

## Not yet verified in game (needs Arma 3 on the player's PC)
- That walking the Altis road network from [14100,16300] gives a ≥400 m track. A straight fallback exists if it doesn't.
- `BIS_fnc_fire` on static weapons and infantry, with projectile deletion.
- `setObjectTexture` colours on `Sign_Sphere100cm_F`.
- playSound3D with addon `.ogg` paths and the local flag.
- Taking the HMG gun (moveInGunner) and the AI re-manning it.
- Co-op hosting and joining. Joining by address (`-connect`) is untested.
- One-click launch straight into the mission, for example with `-init=playMission[...]`.

## In-game test harness
- **Run it:** Singleplayer → Scenarios → *Bloons Ops - Self Test*.
- **What it does:** builds and upgrades every tower, plays all 20 rounds at 4× speed, and checks the track length, the sound files, the static guns' gunners and weapons, the infantry crews, tower coverage, and whether the bloon textures show and the bloons move.
- **Where results go:** `[BloonsOps][TEST] PASS/FAIL ...` lines in `%LOCALAPPDATA%\Arma 3\Arma3_x64_*.rpt`, ending with a `DONE: N failure(s)` line.

## Melty
- **Draft:** "Bloons Ops", modId ec2625fa-f337-4aa5-9180-843c3c9f5b89 (slug bloons-ops), linked to Laserbeam123/Game.
- **Install recipe:** `melty.json`. Melty unzips `@bloonsops/` into `{game}/@bloonsops` and launches Arma 3 with `-mod=@bloonsops -skipIntro -noSplash`. It's set as multiplayer with maxPlayers 4 and no connect section: Arma has no relay, so players join from the in-game browser.
- **Check results:** `validate_recipe` says valid, and `one_click_check` says yes.
- **Main-menu tile:** a "Play Bloons Ops" spotlight (sheets/ui.json; art from tools/make_art.py, converted with `hemtt utils paa convert`) starts the solo mission.
- **0.1.1:** on the user's PC (Arma 2.22.154.45), Melty installed and launched the mod, but the spotlight tile didn't appear. Arma's own spotlights probably take the slots. Added `menuButton` (postInit, runs in the main-menu background scene): a red PLAY BLOONS OPS button at the top of RscDisplayMain.

## 0.2.0: playtest feedback
- **Rounds auto-starting:** the user had most likely opened the Self Test scenario, which auto-builds towers and auto-plays rounds. It's removed from CfgMissions (commented out).
- **Players invincible:** `allowDamage false` in setupUnit, controlled by the `players_invincible` row in the economy sheet.
- **15 towers in two sections:**
  - ARMA 3: the original 4, plus a Ghost Hawk and a Blackfoot that hover over a helipad (AI crew, CARELESS/BLUE, re-issued doMove and setFuel every 5 s).
  - BLOONS TD: 9 sphere-built cartoon monkeys and a banana farm.
- **New tower mechanics:** aoe (tack, ice), slow/freeze (`slowBloon` re-bases a bloon as [type, d0, t0, mult, until]; children keep a running slow), and income (farm).
- **Shot streaks:** drawn as `drawLine3D` lines from server batches (fxLocal).
- **Tower name tags:** drawn with `drawIcon3D`.
- **Tablet:** now the BO_TabletDialog dialog, with two button columns built from the towers sheet.
- **Tower actions** moved onto the player and act on the nearest tower: spheres and helipads have no geometry for actions of their own.
- **Cartoon bloons:** painted PAA textures from `tools/make_art.py`, plus a knot sphere and a drawn string.
- **Flatter ground:** `flattenTrack` uses setTerrainHeight on grid points within 80 m of the track. Each point goes to the local track level ±25% of its original bump, capped at 2.5 m, with the edges faded.
- **Tests:** SQF-VM logic tests cover slow, freeze and inherited-freeze rules, and all pass. HEMTT check is clean.
- **0.2.1:** from the first real playtest screenshot (co-op with friends worked): monkeys looked washed-out yellow because flat colours wash out on the helper spheres, so they now use painted PAA textures (tools/palette.py) like the bloons. The HUD heart glyph rendered as "d", so it says "Lives" now. Added `player_speed_mult` (setAnimSpeedCoef 2.5).

## 0.3.0: real BTD6 art from the player's own copy (option 1)
Done in a cloud session again (no Steam, BTD6, Arma or Melty there), so everything that needs the user's PC is
built to run there and listed under "Still needs the user's PC" below.

- **btd6_art sheet filled.** BTD6's Addressables bundle file names contain content hashes that change with every
  BTD6 update, so exact bundle names would break on the next patch. The two TBD columns are now typed:
  `btd6_asset` = `patterns` (|-separated regexes, best first, full-match, case-insensitive) and
  `btd6_bundle` = `globs` (relative to the BTD6 folder: the aa/StandaloneWindows64 bundles plus `*.assets`).
  The converter resolves them on the PC and writes the exact asset and bundle to `@bloonsops_btd6/manifest.json`.
  The patterns follow BTD6's sprite naming as used by BTD6 modders (`DartMonkey000` portraits, `Red`, `Lead`,
  `GreenCamo`...), with fallbacks. They are **not yet confirmed against a real install**, so the rows stay
  `designed`; `inspect` dumps every sprite/clip name to pin them. Preflight checks the regexes, the globs,
  the ids (only monkey/farm towers, bloons, the pop sound), `_ca.paa` names and duplicates.
- **Converter** (`tools/btd6/`): Python, built into `bloonsops_btd6.exe` by a GitHub Actions workflow (windows-latest,
  PyInstaller), because a Windows exe can't be built from this Linux container. Steps: Steam registry +
  `libraryfolders.vdf` + `appmanifest_960090.acf` (build id) → UnityPy index of Sprite/Texture2D/AudioClip names
  (cached by size+mtime) → regex resolve → trim to visible pixels, pad to a centred square, Lanczos to 512 (towers)
  or 256 (bloons), bleed colour into transparent pixels → own numpy DXT5 encoder + PAA writer (full mip chain,
  LZO1X literal-run framing for ≥64 px, the AVGC/MAXC/FLAG/OFFS taggs HEMTT writes) → pop clip as OGG (FSB5
  Vorbis rebuilt by the MIT `fsb5` package with BSD libogg/libvorbis) → unsigned PBO with SHA1 and prefix
  `z\bloonsops_btd6`, plain-text config.cpp with CfgPatches `bloonsops_btd6` (`art[]`, `pop`, `btd6Build`) → `done`.
  Without BTD6 it still makes the folder and `done`, without the PBO, so `-mod=@bloonsops;@bloonsops_btd6` always
  resolves. FMOD is excluded from the exe (not redistributable); UnityPy's import of it is stubbed.
- **Verified here:** `test_armafmt.py`: HEMTT decodes the PAAs (8 mips, colour error 1.6, alpha 0.3) and accepts the
  PBO (prefix, SHA1, files). `sample_test.py`: end to end on UnityPy's public sample bundles: an atlas-packed
  sprite, a plain sprite and an FSB5 Vorbis clip resolve, convert and pack, also with FMOD blocked.
- **Arma side:** `initData` (generated) sets `BO_Btd6Has` / `BO_Btd6Pop` from the pack's CfgPatches on every machine.
  `billboard` makes a local `UserTexture1m_F` simple object with the converter's PAA; `faceBoard` stands it upright,
  turned to the camera, then re-applies `setObjectScale` (setVectorDirAndUp resets scale). Bloons with art become
  1.1 m billboards (no knot/string); BLOONS TD towers hide their spheres locally (`hideObject` on the anchor and its
  attachedObjects) and get a 2.2 m billboard that goes away when the tower is sold. Pops use the BTD6 pop when the
  pack has one. Each machine decides for itself, so co-op mixes players with and without BTD6. Sizes and the facing
  sign are economy rows (`btd6_tower_size_m`, `btd6_bloon_size_m`, `btd6_board_side`).
- **Recipe:** `melty.json` gets the converter component, a `setup` step (run the exe with `--arma {game}`, wait for
  `@bloonsops_btd6/done`), BTD6 as an optional second game and `-mod=@bloonsops;@bloonsops_btd6`. The field names
  for setup and the optional game were written without Melty's schema at hand: **re-run validate_recipe and
  one_click_check** and adjust to what Melty accepts.
- HEMTT 0.3.0: check clean (47 SQF compiled, 6 configs), release zip built.

### Still needs the user's PC
1. Run `bloonsops_btd6.exe inspect` (or the .py) once: confirms the sprite names; pin them in btd6_art.json.
2. Run the converter, launch with `-mod=@bloonsops;@bloonsops_btd6`, check the RPT line `[BloonsOps] BTD6 art pack: N images`.
3. In game: if billboards are invisible from the front, set `btd6_board_side` to -1. Screenshot: BTD6 monkeys on Altis next to a helicopter.
4. Melty: upload 0.3.0 + converter zip, validate the recipe, Test, set the screenshot as cover, publish.
