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

## Arma 2: Operation Arrowhead edition (`oa/`)
- **Who decided:** the user chose "inside Arma 2: OA itself".
- **Can't go on Melty:** OA isn't in Melty's catalog, so it can't be installed or launched from Melty, and the edition can't be published there. The Arma 3 "Bloons Ops" draft is untouched.
- **Same sheets, separate generator.** `tools/gen_oa.py` (called by `tools/gen.py gen`) turns every row into a plain array (a struct):
  - `data.hpp` names the fields, rows and economy constants (`T_COST`, `TROW_GHOST_HAWK`, `CFG_START_CASH`, `PROP_HELIPAD`).
  - Refs become row indexes.
  - Also generated: the tablet dialog (one button per tower), CfgSounds, and the function loader (OA has no CfgFunctions without the Functions module).
- **OA-specific sheet data:** columns `oa_name`, `oa_object_class`, `oa_crew_class` and `oa_turrets` in towers; a Takistan row in maps; `sheets/oa_props.json` (cone, sandbag, helipad, spheres, mortar shell); `sheets/oa_hooks.json` (41 functions, net allowlist).
- **OA command check:** `tools/oa/check_oa.py` checks every command against OA's real command list, built from the community wiki's "since" data (github.com/acemod/arma3-wiki), plus a hand-verified allowlist for old commands the wiki dates to Arma 3 (addAction, removeAction). Result: 0 problems. The same tool finds 504 Arma 3-only uses in the Arma 3 edition.
- **What OA lacks, and the replacements:**
  - **Messaging between players:** publicVariable channels with an allowlist (netAll / netServer / netClient), instead of remoteExec.
  - **Bloon state:** arrays indexed by id instead of hashmaps.
  - **Sorting:** selection sort.
  - **3D sounds:** say3D from an invisible emitter (no playSound3D).
  - **Speed boost:** a per-frame push along the player's own movement (no setAnimSpeedCoef).
  - **Tower actions:** re-added when the nearest tower changes (no setUserActionText).
  - **Dropped:** shot streaks and name tags (no Draw3D) and terrain smoothing (no setTerrainHeight).
- **Build:** HEMTT builds `@bloonsops_oa` (`oa/.hemtt`). Arma 3-style lint suggestions are switched off for OA. One harmless warning remains.
- **Tests:** `tests/run_sqfvm_oa.py` runs the real OA functions in SQF-VM, 22/22 PASS.
- **Not yet verified in OA (needs the user's PC):**
  - the class names in `oa_props` and the towers' OA columns;
  - Takistan roads near [6000, 11200];
  - Sign_sphere hiddenSelections (do bloon textures show?);
  - the Fired EH projectile parameter;
  - `fire` on turret units;
  - helicopters hovering;
  - the dialog layout;
  - say3D sounds;
  - the speed boost;
  - co-op over publicVariable.
