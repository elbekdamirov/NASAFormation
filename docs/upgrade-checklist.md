# NASAFormation final upgrade acceptance

This is an in-place Godot 4.4.1 Windows upgrade. Native GDScript tests and rendered journeys replace browser-only tooling. Historical save directories and resource/build IDs remain compatible. New build IDs are appended.

| Phase | Implementation | Acceptance |
| --- | --- | --- |
| A Stabilize | Atomic saves, v1-to-v2 migration, backup recovery, validated split layouts, modal held-input release, staged startup screen | Native save migration/recovery and modal tests |
| B Core loop | Collision, finite/replenishing mining, atomic single/batch crafting, split/merge/use/drop/transfer, construction cancellation/refund, shared power, recovery crates | Native logic and rendered campaign checks |
| C Graphics | Original distinct ores with three deterministic variants, procedural PBR finishes, strata and relief shading, multiple survey zones/caves/wrecks, continuous sky/wetness/water/growth, machine fittings | Ore atlas, cave/terrain/world screenshots; retained continuous distant terrain |
| D Immersion | Procedural articulated astronaut and hands, mining/pickup/build/jump/landing poses, material footsteps, original music/effects and rain, FOV/invert/motion controls | Rendered collision, jumping, ramp and mining; state-pose checks |
| E UI | HUD, three-message fading queue, animated stage meter, equipment silhouette and stow/reinstall, batch recipe explorer, placement hologram, machine panels, controls reference | Equipment ownership/cargo invariants; 1366×768 and 1920×1080 screenshots |
| F Living world | Nine presentation milestones over six compatible unlock stages, young plant growth and later woodland, rain, filling basin, final outdoor oxygen comfort, Relaxed/Standard/Challenge | Threshold/interpolation, powered outputs and biosphere screenshots |
| G Finish | Astronaut/Mars title composition, accurate single flag patch, simplified 32/64/256 icon, narrated/skippable intro, state tutorial, planner, Storm Salvage, powered wreck and return mission, archives, Decorations, photo mode, credits | Native/rendered checks and short profiling/menu churn report; extracted package validation |

## Scope decisions

- Preserve the existing Windows engine and campaign rather than build a browser port. Browser zoom/WebGL fallback/React-specific tests do not apply.
- The nine biosphere milestones are an original compressed fictional progression. The six recipe unlock milestones keep saved campaigns compatible.
- Equipment is stowed in a suit locker rather than converted into resource inventory items. Ownership persists and prevents double crafting. Cargo prevents removal of an overfilled backpack.
- Decorations are intentionally cosmetic except the survey beacon's navigation interaction. No combat or proprietary Planet Crafter assets.
- The art remains original procedural indie art. Premium quality and likeness to a commercial reference are subjective; this is not photorealism or a pixel-perfect copy.
- Rain/clouds and dust are implemented; meteor showers were optional and are not part of this campaign.
- The existing standalone intro movie is retained; in-engine suit/branding changes do not re-encode that video.

## Verification limits

Native logic suite currently passes 79 checks. New rendered suite includes equipment ownership, archive persistence, photo return, notification limits and menu churn. Final extracted-package results and profiling go in upgrade-release.md and outputs/full-upgrade-evidence.

No claim of flawless gameplay, cross-hardware 60 FPS, a multi-hour soak, or inspection of the inaccessible supplied reference video. A short local profile and repeated-menu node-count check are recorded. Physics interpolation warnings can appear during scripted test teleports. Real user saves are not used by test runs.
