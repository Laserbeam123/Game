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
