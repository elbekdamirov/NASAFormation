# NASAFormation — FINAL 

> **Type:** In-place upgrade of an existing browser-based 3D terraforming survival game  
> **Priority:** Playable, visually compelling, well-integrated, reliable  
> **Project name:** NASAFormation  
> **Reference video supplied by creator:** https://www.youtube.com/watch?v=wxZFCOb5z0A  
> **Reference wiki:** https://planet-crafter.fandom.com/wiki/Planet_Crafter_Wiki  
> **Other reference pages:** https://planet-crafter.fandom.com/wiki/Machines ; https://planet-crafter.fandom.com/wiki/Terraformation_Stages ; https://planet-crafter.fandom.com/wiki/Terraformation_Index ; https://planet-crafter.fandom.com/wiki/Construction

## 0. Mission and critical constraints

Act as a senior technical game director, Three.js/R3F engineer, UI/UX designer, shader artist, animator, QA automation engineer, and performance specialist. **Upgrade the repository that is already open**, not a new blank template. Build an excellent, original mini space survival/terraforming experience called **NASAFormation**, with the same broad genre appeal, pacing, ergonomics, environmental storytelling and clarity as *The Planet Crafter*. Target polished premium-indie quality within browser constraints.

**Inspect the code before acting.** Detect the existing stack and retain working frameworks, game state, assets, scripts, saves and controls wherever feasible. If the project is React/TypeScript/Three.js/React Three Fiber/Zustand, continue using them. Avoid rewriting working subsystems solely for aesthetic preference. Build on existing V1/V2 features.

**Do not represent unverified details of the reference YouTube video as facts.** Attempt to inspect it if the environment supports video browsing/transcripts; if not, use its URL only as a reference for the creator to compare, and use the listed wiki material for factual mechanical reference. Do not silently download proprietary videos, images, fonts, audio or meshes. Respect copyright: do not scrape and embed Planet Crafter's original icons, models, screenshots, textures or UI files. Make original assets, layouts and branding that evoke the high-level experience, rather than pixel-perfect replicas. The NASAFormation identity should feature a Mars/astronaut concept and a **single accurate Uzbekistan flag patch**; do not duplicate crescent/stars in multiple places. Do not imply official NASA endorsement.

**A working product takes precedence over an oversized feature list.** The finished game should let a player land, walk, look, mine, craft, build, recharge survival needs, inspect machines, power the base, terraform visibly, save, load, and complete an introductory mission without critical errors. Every visible action must have a working effect. No decorative dummy buttons. No fake percentage completion reports.

## 1. First: audit, protect, plan

1. List current project files, scripts, dependencies, data stores, existing implemented features and known placeholders.
2. Run the current app and test/build commands; write down baseline errors. Fix broken core functionality before adding spectacle.
3. Create a `docs/upgrade-checklist.md` that maps each goal below to file(s), acceptance test(s), and status.
4. Preserve save compatibility by introducing a versioned migration strategy. Back up current save representation; never wipe user saves on update. Add a manual reset only behind confirmation.
5. Prefer incremental commits or checkpoints, one logical subsystem at a time. Keep compilation passing at each stage.
6. If browser automation is available (Playwright), capture screenshots at the main menu, gameplay, inventory, construction, and each terraforming stage; verify there are no clipped panels, missing icons, or blocking runtime errors.
7. Review the supplied YouTube link and wiki links only if accessible; record what you could and could not verify in `docs/references.md`.

## 2. Art direction: an immersive original red-world transformation

- **Opening look:** wide dusty orange-red landscape, dramatic warm directional lighting, distant ridgelines, rocky silhouettes, lander pod, believable material scale, scattered mineral clusters, atmospheric perspective, windblown dust, distant hints of abandoned science structures.
- **Visual goal:** real textured ground and machines rather than plastic boxes, primitive cubes, repeated spheres, bare wireframes or flat colored planes. Use well-crafted original procedural meshes, gradients, baked details, instancing, noise textures, roughness/metalness maps, emissive accents, decals and readable silhouettes. Lightweight, not photorealistic at the expense of smooth gameplay.
- Make at least three visually distinct zones: landing basin, broken canyon/highlands, and dry lakebed. Add navigable caves/arches and interesting landmarks. Make the spawn area easily learnable and safe.
- Use one consistent unit scale: astronaut ~1.8 m, doorway ~2.2 m, machines physically plausible, pickups large enough to read without being comically huge.
- Time-of-day: cycle sunlight and starry sky; gradual exposure and shadow adjustments. Avoid pitch-black early game; headlamp is useful but not mandatory.
- Planet atmosphere is a **continuous** visual system, not abrupt scene replacements. Earthlike color/vegetation/water changes track the terraforming index; transitions animate smoothly and persist across save/load.
- Include optional gentle environmental weather: dust gusts, thin clouds, rain, subtle meteor streaks with particles; environmental audio adapts. Keep events non-lethal on Story difficulty.
- Add clean postprocessing only where performance permits: ACES-like tone mapping, color grading, optional bloom for emissive lights, soft fog, grounded contact shadows, anti-aliasing. Don't overdo lens flares, saturation or camera shake.

### Distinct resource art requirements

Each resource MUST have a distinct visual identity in 3D and in its icon, not just a recolored sphere. Create an original mesh/texture/icon variant for:

| Resource | In-world model and material | UI/icon direction |
|---|---|---|
| Iron | chunky layered ironstone, brown steel flakes, matte metal edges | angular graphite ore with silver flecks |
| Titanium | pale gray metallic shards with elongated cleavage planes | cool silver blade-like fragments |
| Silicon | semi-gloss charcoal mineral, fractured crystalline planes | smoky faceted shard |
| Magnesium | pale cream-white mineral with crumbly porous rock | off-white crystalline cluster |
| Cobalt | vivid cobalt-blue crystal needles in darker host rock | blue luminous crystal cluster |
| Ice | translucent icy blue-white chunk with frosted crack lines | frosted prism/ice chip |
| Aluminum | silver-white polygonal metallic formations, fine grain | bright silver nuggets |
| Iridium | dark volcanic rock with glowing reddish-orange iridium seams | red glowing irregular stone |
| Sulfur | yellow crystalline and powdery mineral on dark rock | golden-yellow crystal |
| Seed | botanical capsule/pouch, faint green life accent | green seed capsule |

Use sensible PBR roughness, metalness, transparency and restrained emissive highlights. Surface placement should be grounded (no floating ores), with collision and centered raycast hitboxes. Model assets should be shared instanced geometry where possible. Add 2–3 deterministic mesh variants per type to avoid clones.

### Tools, equipment and machine art

Create original, professionally legible illustrated thumbnails for every inventory item, craftable, tool and buildable. The icon should resemble the actual in-world 3D object in form and color. Prefer render-to-texture thumbnails from the mesh library (or generated SVGs) rather than bland Unicode or generic emojis. Cache them and use graceful placeholders only during loading. Build machines with purposeful geometry: feet, panels, vents, cables, motors, status LEDs, bolts, transparent chambers, fans, heated coils, pipes and readable progress displays. Add idle/active/powered-off animation states.

## 3. First-person astronaut presence and animation

**Fix the problem of motionless hands and legs.** Implement a coherent first-person viewmodel (helmet not covering FOV) with animated gloves/forearms and multi-tool, plus a third-person astronaut body/shadow if technically appropriate. Do not show full legs blocking camera unless the player looks down. Add subtle hand/tool sway, breathing, walk bob, sprint motion, jump impulse, landing recovery, mining reach/beam/vibration, pick-up gesture, machine interaction/press, construction placement gesture and flashlight handling. Use animation state transitions and delta-time smoothing (not frame-count-based motion). Ensure ADS-like cursor raycasts still point where reticle indicates; no camera clipping into hands or helmet. Releasing pointer lock, pausing or opening inventory must stop mining and release held input state.

If using skeletal models, respect licensing and store assets locally with attribution. If no suitable models exist, build an original lightweight articulated astronaut with procedural arm/leg rigs and state-based animation. **Avoid zero-animation placeholder limbs.** Make footstep sounds vary by ground material. Add clear feedback for jumping, running, item collection, mining progress, oxygen warnings, and damage. Provide a third-person inspection/photomode optionally, but preserve polished first-person gameplay as the primary mode.

### Controls and consistency

WASD walk, mouse look, Shift sprint, Space jump, E interact/pickup, hold LMB mine, B build, Tab inventory, C craft at station, F lamp, M map, J objectives, 1–6 hotbar, R rotate preview, RMB cancel, Esc pause. Prevent event conflicts across UI/build/mining: input must be **mode-aware**. In HUD mode mouse look is locked, while modal panels unlock mouse and capture keyboard focus. Keybindings visible under Settings. Provide sensitivity, FOV, motion reduction, and optional invert Y.

## 4. HUD — polished sci-fi readability, not a website dashboard

Create a balanced on-screen game HUD inspired by the **functional hierarchy** of modern sci-fi survival games. Use original shapes/type/icons and NASAFormation colors (deep navy, titanium gray, cyan/teal, warm Mars orange, oxygen blue; green only for life). Avoid copying Planet Crafter UI pixel by pixel. Aim for minimal but information-rich immersion:

- **Top right:** Terraforming Index (Ti), next stage, animated stage progress, compact heat/pressure/oxygen/biomass gains and rate indicators. Expand by hotkey or clicking when cursor is released.
- **Bottom left:** compact horizontal/arc oxygen, hydration and health/food gauges, exact values on hover, context warnings without huge flashing overlays.
- **Bottom center:** six-slot quick bar with active slot, item/tool image, quantity/durability if applicable, clean selection state.
- **Center:** subtle crosshair; when aiming at ore, show resource name and mining prompt; while mining show elegant progress ring. When aiming at a machine, show the machine name, status, operating numbers and contextual E action.
- **Top left:** current mission objective with one-sentence next step and optional waypoint distance. Hide on cinematic/photo mode.
- **Messages:** compact contextual pickup/toast notifications in a queue, max 3 visible, disappear smoothly.
- **Power:** small indicator for positive/negative base power with expanded breakdown in machine panel.
- **Reticle should stay aligned with interaction raycast** across screen sizes and FOV; safe margins and high contrast.

Provide a proper UI design system: 8px spacing rhythm, accessible keyboard focus, consistent type scale, shared panel/glass border styling, line icons, selected/hover/disabled/error states, 120–180 ms transitions. Avoid excessive blur because it harms FPS and legibility. Layout should adapt to 1366x768, 1920x1080, 2560x1440 and a smaller laptop viewport. Prevent clipping at 125% browser zoom.

## 5. Inventory — clear visual grid, equipment and real transactions

Create a large, clean, game-like inventory overlay with a dark translucent background and original spacecraft panel styling:

- Left: astronaut equipment silhouette with slots for backpack, oxygen tank, mining chip, flashlight and suit (if implemented).
- Center: organized backpack grid, item artwork, quantity, stack information, selected state, tooltips.
- Right: selected item info with large thumbnail, description, rarity, usage, recipe/relevant systems, equip/use/drop/transfer action.
- Inventory capacity and weight/slot count visible.
- Move/split/merge stacks, use consumables, equip upgrades, transfer to storage. Implement drag and drop **and** click-based fallback; test pointer capture and inventory state invariants.
- Sort/filter by resources, equipment, consumables; search optional. No fake buttons or actions.
- Items do not disappear if crafting outputs cannot fit or transfer fails. Clicking an item never accidentally mines/places a structure in the world behind UI.
- Tooltips are intelligently positioned within the viewport (flip on edges), do not cover their trigger or jump unpredictably.

## 6. Crafting and building UI — visual and informative

Build a **real recipe explorer** rather than text buttons. Categories: Equipment, Consumables, Base, Power, Terraforming, Automation, Decorations. Every recipe tile shows a distinct original thumbnail, label, tier/unlock status and affordance. On hover/focus/select show:

1. item/tool/building name and one-sentence practical description;
2. large preview image or rotatable 3D model;
3. required materials with icons, **have / need** counts and green/red sufficiency;
4. exact effect: power +/- kW, oxygen/heat/pressure/biomass per second, capacity, radius, time, or storage slots;
5. prerequisites (tech level, terraforming stage, workstation, location);
6. craft/build action, with disabled reason if unavailable.

An example popover for Drill T1: `Drill T1 — generates planetary pressure. Requires: Iron 1/1 ✓; Titanium 0/1 ✕. Power draw: 0.5 kW. Output: +0.2 pressure units/s. Missing: Titanium x1.` Use existing game balancing values from code if available; the above is only an example.

**Construction mode:** present a semi-transparent original model preview that follows valid ground, green when placeable, red when invalid, readable reason tooltip, snap for connected habitats, rotate (R), fixed reach limit, stable surface normal alignment and slope check. Confirm only once per click; never duplicate structures or deduct items twice. Ensure players cannot build inside each other, on steep rocks, inside themselves, or outside map. Allow deconstruction and material refund per chosen rules. Add a spatial placement sound and brief particles. Preview must not obstruct the center raycast and cancel cleanly on Esc/RMB.

**World hover / gaze behaviors:**
- Ore: show name, pickup/mine action, mining time, rarity, inventory capacity info.
- Machine: show name, short purpose, power use/output, operating state and E interaction.
- Existing habitat/door: E enter/use where applicable; allow door opening animation and collisions.
- Blueprint in build menu: materials + image + description automatically.
- Ghost structure during placement: missing material summary + requirement list when invalid.
- No tooltip should appear through solid occluding terrain or when the object is outside interaction range.

## 7. Core world and gameplay systems — deepen, do not break

### Resources and economy

Keep the game's current resource IDs and recipes working, upgrading visuals and interactions. Resource catalog: iron, titanium, silicon, magnesium, cobalt, ice, aluminum, iridium, sulfur, seeds. Consider a small set of later-game additions only if the underlying loop is stable. Place early ores densely near lander and rarer ones in distinct biomes. Maintain fair replenishment to prevent softlocks. Use finite deposits or respawn rules consistently and explain them. Implement collectible storage crates in wreckage with a deterministic loot table. At least one secret environmental story collectible per biome.

### Survival and shelter

Oxygen, water, food/health should change over in-game time using `deltaSeconds`, not render-frame count. Outdoor oxygen decreases; indoors in valid sealed habitat it refills. Habitat detection must be physically correct (no oxygen restoration through walls). Consumable actions work from inventory and hotbar. Add early warning, critical warning, recovery sounds and sensible difficulty presets (Relaxed / Standard / Challenge). After death, respawn at lander or last safe shelter and preserve a recoverable item crate; avoid state corruption and infinite death loops.

### Energy

Wind turbines and solar panels generate shared planet-wide or connected-grid power depending on the current game's architecture (prefer the existing mechanic and document it). Machines consume power and must visibly power down when insufficient. Explain power surplus/shortfall in a detailed energy panel. Ensure generation, consumption, machine activation and terraforming output agree in one authoritative simulation. No machine generates Ti while unpowered. Test removing a power source, changing weather/time-of-day if solar output varies, and save/load.

### Terraforming and environment progression

The appeal of NASAFormation is seeing a dead world become alive. Ensure progress is **observable**:

1. Barren Mars — dusty orange sky, reddish haze, rocky basin.
2. Clearing Skies — reduced haze, more azure at zenith, improved visibility.
3. Clouds — subtle volumetric-looking cloud layers and more atmospheric scatter.
4. Rain — weather transition, droplets, darker wet rock, atmospheric audio.
5. Surface Water — puddles and a basin slowly filling; physically consistent waterline.
6. Lakes — reflective blue-green water and shoreline transition.
7. Moss & Grass — gradual ground vegetation near water and life generators.
8. Flora — trees and small greenery patches begin to appear.
9. Breathable World — greener horizon, abundant plant life, unlocked outdoor oxygen comfort.

These 9 **mini-game** stages are original compressed progression, not a claim that the original game has exactly 9. Use a data-driven thresholds table with deliberate pacing; do not require hours of idle waiting. Different stage elements should interpolate over time, with player-friendly milestone announcements and meaningful unlocks. If the existing game has more stages, map them into this art progression without deleting prior progress. Make oxygen, heat, pressure, biomass and Ti calculation consistent and testable. Do not double count rates on reload. Stage transitions should not spawn thousands of expensive meshes at once.

### Machines and buildables

Upgrade existing models/animations for: landing pod, habitats, doors, foundations, crates, craft stations, wind turbine, solar panels T1/T2, drills T1/T2, heaters T1/T2, vegetubes T1/T2, grass spreader, water collector, ore extractor, terraforming terminal. Functional interactions for opening containers, inserting seeds, collecting output, checking energy and viewing data. Add advanced models only if there are enough resources and implemented unlocks to make them usable. Let machines visibly change with status: fans turn, heater coils glow, pressure drill pistons pump, vegetube plants grow, solar panels tilt or glow, storage shows fill status, terminal screens display actual data.

### Feedback and environmental sound

Add an original audio design layer (Web Audio generated tones or locally licensed assets): footsteps, wind, breathing in helmet, tool hum, mining pulse, metal placement, UI confirms, power-on/off, water splashes, rain and stage success. Provide master/music/SFX controls and mute; initialize audio only after user gesture. No loud autoplay or copyrighted soundtrack. Add small particles and decals in key interactions; avoid noisy clutter.

## 8. NASAFormation branding and presentation

Update all visible legacy project names to **NASAFormation** in the window title, menus, loading panel, pause UI, save screen and metadata; do not blindly rename code identifiers if that would break imports. Create a title screen with a large astronaut in the foreground, Mars landscape behind, understated Uzbek blue-white-green cues and a **single recognizable Uzbekistan flag patch** on the suit (one crescent and 12 stars, not repeated around the logo). Add original cinematic branding, not the Planet Crafter title treatment. Provide buttons: Continue (only if save exists), New Game, Settings, Credits. Add background visual motion with an inexpensive camera flyover/animated planet; all menu actions must function. App icon: legible astronaut silhouette + Mars disc at 32px and 64px, without a tiny unreadable full wordmark; larger splash logo can contain NASAFormation text. Do not copy official NASA insignia.

Add an introductory sequence that is skippable: landing pod ambience, short mission card 'Make Mars habitable', camera revealing red terrain, first objective to gather ore and create initial power. Show a concise six-step objective chain that teaches mining, crafting, shelter, power, machine placement and watching the sky change. All tutorial objectives are state-driven, trigger on actual events and resume correctly after load.

## 9. Minimap, waypoints, details, polish

- Map (M) shows a discoverable area map with player position, home pod, biome landmarks, placed major buildings and waypoints. Display distance and direction to objective.
- Compass or minimal waypoint arrow, only when needed.
- Device details panel includes original 3D thumbnail, current power, rate, operating status, storage/seed requirements, upgrade conditions and description.
- Interactive lighting: base interior illumination, door lights, colored machine status LEDs, flashlight cone and shadows.
- Explore at least one wreckage or ancient abandoned laboratory with collectible lore and a rare resource, but do not turn game into shooter/combat.
- Optional Photo Mode: hide HUD, release camera and allow capture through browser mechanisms if possible.
- Include readable UI at 16:9 and 16:10; keyboard navigation for panels; color not sole indicator of affordances; optional reduced motion and subtitles for tutorial prompts.

## 10. Engineering architecture and stability

If repository is React/TypeScript/R3F/Zustand, prefer this organization **without unnecessary large-scale rewriting**:

- `src/game/data/`: typed resources, recipes, buildables, unlocks, balancing, stages
- `src/game/systems/`: resource collection, survival, crafting, building, power, terraforming, quests, audio, save manager
- `src/game/world/`: terrain generation, biomes, instances, atmosphere, water, vegetation, landmarks
- `src/game/player/`: movement, first-person rig, animations, targeting, collisions, camera
- `src/game/machines/`: machine visual library, machine behaviors, interaction components
- `src/ui/`: HUD, hotbar, inventory, crafting, build catalogue, object tooltip, settings, menu
- `src/game/utils/`: deterministic seeded PRNG, units, validation, type guards
- `tests/`: state transitions and end-to-end smoke tests

Use one authoritative simulation clock and delta-time update loop (clamp unusually large delta, handle pause and background tab) separate from React render cycle. Avoid writing to Zustand on every render frame just to animate viewmodel; use refs or a fixed-rate simulation tick and selective subscriptions. Make sure React StrictMode does not double-spawn deposits or double-run effects. Stabilize IDs and instance matrices; dispose GPU resources on cleanup. Clean pointer lock listeners and timers on unmount.

Strong TypeScript, no `any` in gameplay state, no broad `@ts-ignore`, no console errors in normal play, no setState loops, no stale closures on events, no useEffect-driven repeated spawn. Validate stored saves, migrate old schemas, handle corrupt data gracefully with a user-visible recovery option. Use deterministic IDs where suitable; avoid putting unstable runtime references in persisted JSON. Keep the main thread responsive; avoid loading all geometry synchronously.

### Performance standards

- Target a stable 60 FPS on an ordinary desktop GPU at 1080p in Standard quality; provide Low/Medium/High settings for weaker machines. FPS target is aspirational; actually measure and report.
- Use instanced meshes for rocks and vegetation; LOD and frustum/distance culling. Avoid excessive real-time shadow casters and full-resolution postprocessing.
- Generate terrain once per seed/chunk and cache it. Ensure no memory leak when moving across map or switching menus.
- Cap pixel ratio, GPU particles, active lights, water reflection cost, and draw distance based on selected profile.
- Show loading progress while assets initialize. If WebGL unavailable, show a helpful fallback instead of blank screen.
- Use a model/asset registry and actual fallback behavior for missing textures, models and sounds.

## 11. QA and test matrix — no unverified 'bug free' promises

Write and run Vitest/unit tests for:

1. Resource pickup while inventory has room, and while full.
2. Mining progress interruption, object out-of-range and prevention of duplicate rewards.
3. Crafting success, insufficient inputs, full output capacity, batch crafting; transactions atomic.
4. Split/merge/drop/equip/unequip/transfer and quantity invariants.
5. Placeable vs blocked building terrain; no duplicate placement on double click; cancellation returns to normal mode; deconstruction refunds correct amounts.
6. Power production/consumption, machines disabled on deficit and reactivated on restored power.
7. Terraforming output changes only when machines are powered and seeded where required; stage transitions and rate math.
8. Survival depletion at different FPS and pause/background states; indoor oxygen refill; respawn and recovery crate.
9. Save, reload, corrupted save fallback, migration from prior data, preserving world placements and player equipment.
10. Quest progress triggers exactly once and loads correctly.

Use Playwright or comparable browser test tools if available for:

- New Game -> walking/mouse look -> mine ore -> inventory -> craft capsule -> build generator -> build drill -> Ti goes up -> save -> refresh -> state restored.
- All menus open/close properly with Esc and pointer lock; no mining while dragging UI.
- HUD at 1366x768 and 1920x1080, responsive panels, tooltips near corners, no overflow.
- No uncaught errors in browser console, no failed local assets or React hydration errors.
- Settings persists; difficulty modifiers apply; pause actually pauses.

Also **manually inspect in-browser screenshots** of menu, world, inventory, crafting tooltip, build preview and terraforming stage. Fix visible layout flaws: text contrast, overlap, tiny icons, low-resolution artwork, missing textures, clipping, debug shapes, stretched logos, unresponsive controls and unreachable close buttons. Avoid merely checking if the build succeeds; demonstrate that core user journeys work.

## 12. Implementation sequence and acceptance gates

Work in these phases, with running software after each:

**Phase A — Stabilize:** inspect, baseline build, fix errors, save migration, state/input architecture.  
**Phase B — Core loop:** movement/collision, mining and collection, inventory, craft transactions, placement and power correctness.  
**Phase C — Game-quality graphics:** world, ore models/icons, machine modeling, lighting, particles, day/night and atmospheric effects.  
**Phase D — Player immersion:** animated first-person rig, tool, footsteps, audio and responsive targeting.  
**Phase E — Premium UI:** HUD, inventory, recipe cards, hover descriptions, construction hologram, devices and settings.  
**Phase F — Living world:** nine-stage visual terraforming, plants, water, clouds, environmental events and milestone quests.  
**Phase G — Finish:** branding, opening/tutorial, map, performance optimization, full QA and bug fixes.

Don't leave incomplete placeholders after moving between phases. Favor a smaller number of **complete, integrated** features rather than a giant half-working interface. If context, time or tool availability is limited, maintain a factual checklist with implemented/not implemented/tested status and prioritize the complete core game and visual quality. Never say the game is flawless without testing.

## 13. Final delivery format

At completion provide:

- Brief summary of what you changed in the **existing** repository.
- Accurate changed-file list and the architecture you used.
- Commands to install, run and build locally.
- Tests actually run, results and known limitations.
- Screenshot paths or snapshots when browser tools are available.
- Current feature checklist (Implemented / Tested / Not yet implemented).
- A 2-minute manual playable smoke-test procedure: start, move, mine, craft, build, terraform, save, reload.

**Definition of done:** I can open NASAFormation, see a cinematic Mars world with a recognizable astronaut identity, move naturally with animated hands/tool, mine distinctly shaped ores, open a polished inventory, hover a buildable to see beautiful image and exact ingredients, build functioning power and terraforming machines, watch environmental change, and resume a saved game. All core actions must work, with build/tests passing and no known blocking defects.

**Begin immediately by inspecting the repository and implementing Phase A, then continue through the phases as resources allow. Do not ask me to re-explain requirements already in this document.**
