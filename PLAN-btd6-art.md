# Plan: real Bloons TD 6 art in Bloons Ops (option 1)

## Goal
Towers and bloons in Arma show **the real BTD6 art**, taken from the player's own BTD6 install on their PC.
- **Monkeys and bloons:** flat cut-outs (billboards) that always face the camera.
- **Pop sound:** BTD6's own, if it can be extracted.
- **Arma side:** soldiers, the HMG, the mortar and the helicopters stay as they are.

Nothing from Ninja Kiwi is uploaded or redistributed. Players need **both** games.

## Why this needs the player's PC
The work must run against a real BTD6 install: inspect its asset bundles, pick the right sprites, and test the result in Arma.
This was decided in the cloud session; that session had no BTD6, no Arma and no .NET download access.

## Steps (for the session running on the user's PC)
1. **Find BTD6.** Read Steam's `libraryfolders.vdf` and locate the `BloonsTD6` folder. Record the BTD6 version (Steam build).
2. **Inspect the bundles.** BTD6 is Unity (IL2CPP); its art lives in Addressables bundles under `BloonsTD6_Data/StreamingAssets/aa/StandaloneWindows64/`.
   - Use UnityPy (Python, MIT) or AssetsTools.NET (MIT) to list the Sprite and Texture2D names.
   - Find the tower portraits/icons for the 9 BTD towers and the bloon sprites, then fill `sheets/btd6_art.json` (`btd6_asset`, `btd6_bundle`).
   - Preflight fails on every `TBD` until this is done.
3. **Write the converter.** It runs on the player's PC as Melty `recipe.setup` before the first launch.
   - It finds BTD6 the same way as step 1. BTD6 isn't in Melty's catalog, so Melty can't pass `{game}` for it.
   - It extracts the rows in `btd6_art.json`, trims and pads them to power-of-two sizes with alpha, writes PAA files (DXT5) and an OGG for the pop sound.
   - It packs them into an **unsigned** `@bloonsops_btd6/addons/bloonsops_btd6.pbo` (prefix `z\bloonsops_btd6`) with a CfgPatches `bloonsops_btd6`.
   - It writes a `done` marker file for Melty's setup check.
   - **Language:** pick whatever builds a single Windows exe on the PC (Python + PyInstaller, or .NET `dotnet publish -r win-x64 --self-contained`).
   - **Bundle only redistributable pieces** (UnityPy MIT, a DXT encoder, etc.) and credit them.
4. **Arma side (this repository).**
   - **Detect the pack:** `isClass (configFile >> "CfgPatches" >> "bloonsops_btd6")`. Without it, fall back to today's look.
   - **Billboards:** use `UserTexture1m_F` (or a local simple object of it, so `setObjectScale` works) with the converted texture. Every frame, turn each one to face the camera with `setVectorDirAndUp` from `positionCameraToWorld`. Scale towers to ~2 m and bloons to ~1 m.
   - **Replace the visuals:** swap the sphere monkeys and sphere bloons for billboards, and use the BTD6 pop sound when present.
5. **Recipe.**
   - Add `setup` (run the converter, wait for its done file).
   - Change launch to `-mod=@bloonsops;@bloonsops_btd6`.
   - Add BTD6 as a second game players must own (`custom-` slug, or `ownCopy` if Melty asks for it).
   - Re-run `validate_recipe` and `one_click_check`. If Melty can't express "requires BTD6 installed", say so in the description and fall back gracefully.
6. **Test in Arma.** Melty Test, then play a round.
   - Screenshot: real BTD6 monkeys on Altis next to an Arma helicopter. That's the new cover.
   - Then the user publishes.

## Current state (0.3.0)
- **Steps 2–5 are built** (see MODLOG 0.3.0): sheet patterns + preflight, converter in `tools/btd6/` with a Windows exe
  workflow, billboards on the Arma side with fallback, recipe changes. HEMTT check/release clean.
- **Open, needs the user's PC:** confirm sprite names with `inspect`, run the converter, play-test (billboard facing,
  sizes), screenshot, Melty upload + validate_recipe + Test + publish.
- **Listing:** "Bloons Ops" on Melty (modId `ec2625fa-f337-4aa5-9180-843c3c9f5b89`), draft. 0.2.1 submitted; 0.3.0 not yet uploaded.
