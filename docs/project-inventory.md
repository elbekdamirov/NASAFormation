# Existing project audit

Product root `outputs/Ares3D/NASAFormation-Windows`.

| File / folder | Responsibility |
| --- | --- |
| NASAFormation.exe / Launcher.cs | Native Windows launcher; bundled runtime and local userdata |
| runtime/Godot.exe | Godot 4.4.1 OpenGL Compatibility engine, bundled MIT license |
| game/project.godot, main.tscn | Fullscreen native entry point, scalable 1600×900 UI reference |
| game/main.gd | World, input, movement, simulation, menus, quests, persistence and integration tests |
| game/nur_data.gd | Resource IDs, recipe costs, equipment, buildable definitions, atomic transactions |
| game/nur_visuals.gd | Original procedural ore, machine, item and terrain-prop models |
| game/nur_icon_atlas.gd | Rendered model thumbnails |
| game/nur_rig.gd | Procedural first-person and astronaut animation |
| game/nur_hud.gd | HUD drawing and contextual data |
| game/nur_onboarding.gd | Narrated introduction and tutorial |
| game/nur_audio.gd, music, voice | Original generated effects, soundtrack and voice recordings |
| game/mars_map.gd, mars_regions.gd | Survey UI, landmarks and fictional playable regions |
| game/nasa_mission.gd | Sol clock and accelerated weather/communications model |
| game/visual_progression.gd | New nine-stage presentation layer |
| game/*.gdshader | Terrain strata, wetness, atmospheric sky, water, heat and hologram effects |
| game/nasa | NASA reference imagery kept separate from the fictional terrain |
| userdata | Existing save and settings, excluded from distributable ZIP |
| README.md, ASSETS.md | Player instructions and asset provenance |

No npm, React, R3F or browser runtime. No new external dependencies. Keep the historical internal user-directory name for save compatibility; the visible application is NASAFormation.

Baseline logic tests passed 55/55 before changes. Existing systems include finite/replenishing ore, inventory, recipes, equipment, construction/deconstruction, shared power, shelter oxygen, recoverable death crates, rain and vegetation, Storm Salvage, expedition route planner, heated cave gate, powered wreck compartment, and Earth-return mission. Known directive gaps are tracked in upgrade-checklist.md.
