# NASAFormation directive update

Updated the existing Godot 4.4.1 Windows installation in place. No engine rewrite, proprietary Planet Crafter assets or save reset.

## Changes

- Stack splitting, drag/drop and click merging, persistent stack counts, automatic compaction to avoid hiding pickups, corrected occupied-slot display.
- Atomic batches of five supplies or components. Ingredient counts and disabled reasons reflect batch size. Equipment stays single-craft.
- FOV 60–100 degrees, invert Y, bounded settings values, controls reference and redesigned settings layout.
- Modal entry releases movement and mining. Mouse look requires captured cursor.
- Nine original biosphere presentation milestones, continuous clouds/rain onset, young plant growth, later woodland and outdoor oxygen comfort at the final milestone. Existing machine unlocks and campaign saves remain compatible.
- Save decoding validates optional stack fields and doesn't mutate the source save during migration.
- Fixed inventory and crafting description layout and removed unusable consumable actions from electronic components.

## Architecture and files

`game/main.gd` retains the authoritative simulation, menus, transactions and native integration checks. New `game/visual_progression.gd` holds the nine presentation thresholds. `game/nasa_mission.gd` adjusts fictional rain onset. `README.md` documents controls and limitations. `docs/upgrade-checklist.md`, `docs/references.md` and this file record scope and evidence.

## Run and build

No dependency installation is needed. From `outputs/Ares3D/NASAFormation-Windows`, run `./NASAFormation.exe`. Keep game and runtime folders beside it.

```powershell
./runtime/Godot.exe --path ./game
./runtime/Godot.exe --headless --path ./game -- --self-test
./runtime/Godot.exe --path ./game -- --render-test
```

Tests should use an isolated APPDATA directory to protect real settings. The existing launcher reads the updated local GDScript; it does not need recompilation. Package with `tar.exe -a -cf ../NASAFormation-Windows.zip NASAFormation.exe nasaformation.ico "NASAFormation Intro.mp4" ASSETS.md README.md Launcher.cs Generate-Voice.ps1 Generate-Music.mjs game runtime docs`. Exclude userdata from distribution.

## Two-minute smoke test

1. Launch and Continue, or start a new expedition and skip the intro. Walk, sprint, jump and use the lamp.
2. Hold LMB over nearby cobalt. Open Tab, inspect and split a stack. Drag matching stacks together or select one and click the other.
3. Open C. Craft an oxygen capsule with two cobalt. Switch batch quantity and check ingredient counts; unavailable batches must not spend anything.
4. Mine two iron and a titanium. Build a turbine and T1 drill on nearby clear ground. Confirm positive pressure production and rising Ti.
5. Open M to check the return oxygen budget and nearby shelters. Open Settings and change FOV.
6. Save with F5, exit and reopen. Confirm inventory, buildings, Ti and camera settings persist.

Allow additional time for resource gathering. This short smoke route does not complete the entire campaign or all nine visual milestones.

## Known limits

See the checklist for unimplemented directive items. This is a tested incremental update, not completion of every art and UI aspiration. The engine emits physics-interpolation warnings during scripted scene repositioning. Full hardware performance profiling and long-session stability remain unverified. NASA source imagery remains separate from the fictional local map; the nine biosphere stages describe speculative game progression, not present-day Mars.

## Final verification

A fresh extraction of the Windows ZIP passed **70 logic checks and 108 rendered checks**, zero failures. Source SHA256 was compared against the extracted tested copy. The renderer reported AMD Radeon 780M with OpenGL Compatibility. This identifies the test device, not a benchmark.

Rendered checks exercised mining, construction, power, collision, walk-in pod and caves, Storm Salvage, planner routing, wreck power/loot, cave thaw, return-vehicle clearance and Earth arrival. Scripted time advancement was used for campaign events. Screenshots include the nine visual milestones, settings at 1366×768 and 1920×1080, stack inventory and batch crafting. Settings, inventory and crafting screenshots were visually inspected; the overflowing item description was fixed and rechecked.

Logs and screenshots are in `outputs/upgrade-evidence` in the shared workspace. The screenshots are test fixtures, not a claim that every campaign path was manually played through.


## Full feature-pass completion

The subsequent pass adds game/expedition_polish.gd for equipment, archives, photo camera, notifications, progress, portrait and profiling. game/nur_rig.gd now uses a single original flag patch. game/nur_visuals.gd caches three geometry variants per ore. game/nur_audio.gd adds deck/water footsteps and rain. game/nur_data.gd appends three Decorations. Terrain/rock/menu shaders and original app-mark.svg/uzbekistan-patch.svg complete the presentation pass. NASAFormation.exe was rebuilt with the multi-resolution original icon.

Earlier 'remaining gaps' and incremental-release statements above describe the earlier checkpoint. The current acceptance mapping is upgrade-checklist.md. Equipment is managed through Backpack, lore through Journal, photos through F8/F9, and quality through Settings. See README for user instructions.

Profiling is a local rendered sample, with 30 cycles of six menus and node-count stability. It does not prove the absence of long-session leaks. Screenshots are visually inspected and tests advance campaign clocks for long-duration events. The Mars map is fictional; no claim of NASA-mapped mineable ore locations.

## Full-pass verification results

Freshly extracted Windows package passed 79 logic checks and 123 rendered checks with zero failures. Short profile on AMD Radeon 780M at 1080p output measured Low 44.8 FPS, Medium 36.9 FPS and High 33.7 FPS after warm-up. The initial 180-frame sample included a 1.2-second terrain-loading hitch and averaged 25.3 FPS. Thirty cycles through six menus held node count at 5,982. These are short local observations; 60 FPS and multi-hour stability are not established.

Visual inspection covered the equipment silhouette, archive reading, astronaut title, ore/world presentation, cave interior, settings and crafting layouts. Final adjustments move notices away from the target card, preserve fractional stage-meter values, soften relief shading and provide native small icon frames. The nine stage images and campaign mission checks remain part of the rendered suite. Evidence and logs are retained in outputs/full-upgrade-evidence.

A repeat validation exposed intro timing sensitivity during a long loading frame. The authoritative frame delta is now clamped before narration/cinematic advancement as well as survival. Runtime window branding uses the generated astronaut Image; the rebuilt launcher retains the matching native icon. Historical ARES internal scene/save identifiers stay in place for compatibility, while the visible victory text uses the current outpost identity.

Final clean validation after the cinematic frame-time fix passed all 123 rendered checks. No script errors or small-icon warnings were emitted. Physics interpolation warnings during scripted teleports remain. The final local quality samples were Low 46.8, Medium 34.2 and High 31.5 FPS; see outputs/full-upgrade-evidence/final-performance.txt. The final 180-frame scene sample averaged 26.4 FPS including a terrain-load hitch. This remains below the aspirational 60 FPS target on this integrated GPU.

## Creator-requested logo restoration and sky revision

Restored the original creator-provided logo in the title/pause menu and rebuilt the Windows launcher icon from the same image. Removed the new procedural astronaut portrait from the menu and its rendering cost. The runtime window icon uses the original logo. The retained controls, inventory and campaign upgrades are unchanged.

Updated the HUD to navy/cyan glass styling, refined panel outlines, and added a subdued technical menu grid. Sky shading now has layered drifting high ice veils, denser clouds with terraforming, copper/mauve daylight, twilight accents and stronger star-map detail. Corrected sky fog blending so clear-weather ground fog no longer hides the sky; storms retain stronger obscuration. Daylight, sunset and night preview screenshots are included in the rendered tests.

Logo/sky revision validation passed 126 rendered checks with zero failures. Title and daylight/sunset/night screenshots were visually inspected. The clear-night view now shows the previously fog-obscured star map. Evidence is in outputs/logo-sky-update.
