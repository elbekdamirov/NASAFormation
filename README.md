# NASAFormation — Windows edition

Extract the Windows ZIP and run **NASAFormation.exe**. Keep the `game` and `runtime` folders next to the launcher. NASAFormation runs fullscreen with the bundled Godot 4.4.1 runtime. It works offline.

New expeditions open with the UZ-01 landing, the astronaut’s first surface survey, and a preview of the Silent Basin as water, rain, and plant life appear. Mission Control narrates the sequence. Press **Esc** or **Space** to skip. **Replay mission intro** is available from the main and pause menus. The included **NASAFormation Intro.mp4** is the standalone version.

Mission Control calls out the current objective and low supplies. Captions follow the radio guidance, and **Settings → Mission voice** turns off radio audio and in-game guidance. The intro keeps its captions. The visor tracks the next five objectives at the top left, terraformation at the top right, and nutrition, water, and oxygen at the bottom left.

To use an existing NUR expedition in a fresh extraction, copy your old installation’s `userdata` folder beside the new launcher before opening the game. This build reads the previous NUR save format. If an old save placed the astronaut inside a rock, the game finds clear ground at load.

The campaign opens at the Uzbekistan UZ-01 landing capsule and ends at Living Planet, after which you can continue building. The walk-in ramp leads to a manual fabricator and oxygen refill. The **P** menu gives control over power to shielding, greenhouse lights, and Earth radio. Each system draws electricity before other machines.

## Controls

| Input | Action |
| --- | --- |
| WASD / mouse | Move and look |
| Shift / Space | Sprint and jump |
| Hold Space in the air | Boost with an installed jetpack, using suit oxygen |
| Hold left click | Mine the highlighted deposit |
| E | Open a survey cache or use a machine |
| Tab or I / C | Backpack / Fabricator |
| B / R | Open blueprints / Rotate placement |
| Left click / right click | Confirm / Cancel placement |
| Delete | Dismantle the targeted structure and recover materials if there is room |
| 1–6 / Q | Select a hotbar slot / Use its consumable |
| F / V | Flashlight / Camera view |
| H | Toggle detailed terraforming telemetry |
| M / J | Surface map / Mission journal |
| P | Outpost power, food, shielding, and Earth radio |
| Esc / F5 | Pause / Save |

## Progression

1. Mine common resources around the pod. Return inside to restore oxygen. Craft an oxygen capsule from two cobalt and a water bottle from one ice. A food pack takes one seed and one ice.
2. Build a wind turbine and a T1 drill. Pressure raises the Terraform Index right away. Open the marked survey cache for seeds. Insert one in a powered vegetube to produce oxygen.
3. Build a habitat and attach a door to its wall. The pod and sealed habitats refill oxygen even during a grid outage.
4. At 100 Ti, add heating. At 400 Ti, T2 drills and solar arrays unlock. At 900 Ti, the lake begins to fill and water collectors unlock. At 1800 Ti, add grass spreaders, T2 heaters, and an ore extractor. The 3500 Ti Living Planet milestone completes the expedition.

The equipment tab contains the T1 oxygen tank, T2 backpack, and mining upgrade. Consumables go into your backpack, where you can use or assign them to a hotbar slot. Storage crates accept up to 24 stacks. Ore extractors and water collectors keep a separate output inventory.

Aim at a deposit or machine to see its model and interaction details. Drag inventory stacks to move them, or Shift-click in storage to transfer all matching items when space permits. The construction menu can pin a recipe and show the missing materials as you explore.

After outpost systems, the grid allocates power to machines in placement order. Select a machine with E to see its state, switch it off, or view its input or output. During dust storms the solar arrays generate less power. Wind turbines provide backup in the game model. The Terraform Index is twice the sum of pressure, heat, and oxygen, plus three times biomass.

## Mars science

A real Mars solar day lasts about 24 hours 39 minutes 35 seconds. In the game a sol lasts six active minutes. The clock is an accelerated local solar clock. Dust storms and solar storms use a generated schedule. Rain belongs to the fictional terraforming stages. The map surveys an 800 × 800 m fictional sector. Click an area to set a compass waypoint.

- The 2018 Opportunity dust storm illustrates why solar panels need backup power. [NASA dust storm archive](https://science.nasa.gov/solar-system/planets/mars/10-things-massive-dust-storm-on-mars/)
- Curiosity’s Radiation Assessment Detector recorded 8,100 micrograys during the May 2024 event. Shielding affects the game’s recoverable radiation risk meter. [NASA/JPL solar storm report](https://www.jpl.nasa.gov/news/nasa-watches-mars-light-up-during-epic-solar-storm/)
- NASA gives a one-way communication range of about 3–22 minutes. The game uses a fixed 14-minute one-way model compressed with the sol clock. [NASA Perseverance communications](https://science.nasa.gov/blog/speaking-percys-language-how-to-talk-so-perseverance-will-listen/)
- Atmospheric pressure and the length of a sol come from published Mars references. Sunset colors draw on rover and lander observations. [NASA Mars fact sheet](https://nssdc.gsfc.nasa.gov/planetary/factsheet/marsfact.html), [NASA Mars24](https://www.giss.nasa.gov/tools/mars24/help/notes.html), [NASA Mars sunsets](https://science.nasa.gov/solar-system/planets/mars/what-does-a-sunrise-sunset-look-like-on-mars/)

NASA does not endorse any non-U.S. Government entity. The game is an independent educational prototype.

## Saves and settings

Autosaves run every 25 active seconds and shortly after significant actions. The launcher stores new campaign data under `userdata/Godot/app_userdata`. A corrupt save falls back to the previous valid copy. Restart asks for confirmation and keeps a pre-restart backup. Settings include Relaxed Survival, graphics quality, reduced motion, HUD scale, and master volume.

## Development and verification

Open `game/project.godot` in Godot 4.4.1. Machine costs, equipment recipes, resource properties, and stage thresholds live in `game/nur_data.gd`.

```powershell
godot --headless --path game --check-only --script main.gd
godot --headless --path game -- --self-test
godot --path game -- --render-test
```

The render test uses a clean test world and saves its PNG snapshots in the user data directory. The environment and resources are procedural. The map is a top-down relief survey. The 20–40 minute campaign duration and 60 FPS goal are design targets.

The English script and caption cues live under `game/voice`. Run `Generate-Voice.ps1` on Windows to regenerate the bundled recordings and caption cues. Godot Movie Maker can record the sequence with `--write-movie intro.avi --fixed-fps 30 -- --capture-intro`.

The expanded fabricator adds a Components tab and new suit upgrades, including agility boots, a larger oxygen tank, a jetpack, and an air filter. The blueprint browser adds a food grower, algae cultivator, tree spreader, highland wind turbine, and water purifier. The original ambient soundtrack brings in a rhythmic layer when the astronaut runs, mines, or faces hazardous conditions. Toggle it under Settings.

The survey has 36 regions, including six walk-in caves and three marked salvage wrecks. Basalt Lava Tube contains osmium and Ejecta Cavern contains uranium. The two new wrecks carry salvage and limited supplies. Longer expeditions still draw on suit oxygen and water, so check the waypoint distance before leaving shelter.

## Storm salvage

Press **J** and accept **Storm salvage**. Follow the HUD heading to South Freight Wreck, recover a circuit board, and bring it back to UZ-01. If the wreck cache was opened earlier, visit the wreck and fabricate a replacement board if needed. Install the board through **P** while inside UZ-01. At storm peak, select one system to keep running for a 75-second reserve trial. The peak arrives seven active minutes after accepting. You can still install the board or run the trial after the front passes. The journal records which system you kept powered.

The sequence adapts the wreck salvage and resource progression from [Miju Games’ released Planet Crafter](https://store.steampowered.com/app/1284190/The_Planet_Crafter/) and its [developer FAQ](https://steamcommunity.com/app/1284190/discussions/0/5805689546864510028/). The forecast, isolated training reserve, and power consequences are NASAFormation mechanics. The NASA orbital atlas is available from **M**.

## Expedition planner and extraction

- Open **M** and select a waypoint. The round-trip oxygen estimate returns to your current position. It uses the suit's outdoor drain and walking speed, with an allowance for stops and rough terrain. The planner lists the two closest shelters to the destination and both dust and solar storm windows in active game time.
- At **East Survey Wreck**, enter the detached cargo bay from the south. Craft a **Portable power cell** under **Components** and use **E** at the sealed hatch to unlock the salvage. The cell is consumed once.
- The basin's low crossing floods at **900 Ti**. Wading is slower, and the map recommends the higher rim when a route crosses the lake. The back branch of **Zeolite Cave** opens at **35 Heat** and exposes osmium.
- At **3,500 Ti**, build an **Earth return vehicle** from **B → Industry**. Load three oxygen capsules, three water bottles, and three food packs. Use **P** to power the Earth radio, then use **E** at the vehicle to send a clearance request. Leave the manifest open only while reviewing it. Time passes in the game world. Return and board after clearance when visibility is safe. The expedition stays playable after the arrival sequence.

The wreck interior and extraction progression use [Miju Games’ official game references](https://steamcommunity.com/app/1284190/announcements/). The Earth-return objective and route planner are NASAFormation systems. The cave shapes and exposed strata are procedural interpretations of [NASA’s lava tube imagery](https://science.nasa.gov/resource/hirise-spots-the-mouth-of-a-martian-lava-tube/) and [Curiosity’s Murray Buttes observations](https://science.nasa.gov/resource/farewell-to-murray-buttes-image-4/).

Godot is distributed under its [MIT license](https://godotengine.org/license/).

## Final-directive incremental upgrade

Inventory now supports splitting and merging stacks with persistent counts. Matching stacks merge by drag/drop or by selecting one and clicking another. Splits auto-compact if incoming pickups need room. Components no longer offer a nonfunctional Use action. The fabricator supports atomic batches of one or five supplies/components with complete batch costs.

Settings include FOV (60–100), invert Y, and a controls reference. Menus release held movement and mining. Nine visual biosphere milestones overlay the existing six machine-unlock stages. Clouds, fictional rain, young vegetation and later woodland progress gradually. At 3,500 Ti, outdoor oxygen comfort unlocks. Existing saves retain unlocks and quests.

This earlier checkpoint is superseded by the completed feature pass below. Read docs/upgrade-checklist.md for scope decisions and docs/upgrade-release.md for tests, limitations and smoke testing.

## Completed upgrade feature pass

Open Backpack → Manage suit equipment to remove and reinstall owned upgrades. Removing a backpack is blocked while cargo exceeds base capacity. Removed equipment is stowed in the suit locker and stays owned across saves.

Field archives can be recovered with E in the landing basin, highlands, dry lakebed and cave country. Read them through J → Field archives. New Decorations blueprints include a survey beacon (E marks its compass location), expedition bench and botanical planter.

F8 opens a free photo camera and freezes simulation. Use WASD, Q/E and Shift to fly, F9 to save a PNG, and F8 or Escape to return. Photos are saved under the game's userdata directory. The camera is for photography and has no collision. Photo mode hides the hand model and HUD.

Settings include Relaxed, Standard and Challenge difficulty, independent effects volume, FOV, inverted Y, reduced motion and three quality profiles. Relaxed prevents radiation storms from directly killing the astronaut; survival needs still matter. Low/Medium reduce 3D resolution and shadow cost while preserving readable UI. The title screen now renders an original astronaut with a single Uzbekistan patch. The launcher icon is an original astronaut/Mars symbol.

Three recent notifications fade in the HUD, with an interpolated biosphere progress bar. Ores use three deterministic geometry variants. Terrain and exposed rock have procedural relief shading. Metal decks and flooded ground have distinct footsteps, and fictional rain has a generated ambient layer.

See docs/upgrade-checklist.md for requirements mapping and docs/upgrade-release.md for validation and known limitations. The original standalone intro movie is unchanged; the in-engine astronaut uses the updated suit patch.


## Restored identity and sky update

The title/pause screen again uses the original NASAFormation logo supplied by the creator, and the Windows launcher and runtime window icon use that same logo. The 3D menu portrait is disabled. Existing equipment, quests and save data remain compatible.

The interface now uses navy panels and cyan accents. The sky adds layered drifting ice veils/clouds, copper and mauve daylight, blue twilight scattering and a richer Milky Way/star presentation at night. Dust storms and fictional terraforming rain remain driven by the existing simulation. These are artistic shader changes, not a new NASA weather feed.
