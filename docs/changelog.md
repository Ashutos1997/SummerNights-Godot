# Changelog

All notable changes to the Summer Nights project will be documented in this file.

## [v1.8] - WIP
*(Note: Releases are exclusively maintained on itch.io starting from v1.8)*

### Improved
* Export & Release Streamlining: Retired GitHub binary releases to eliminate multi-track confusion; itch.io is now the sole official release platform starting from v1.8, with Godot export presets pruned and updated to v1.8.
* Documentation & README Streamlining: Consolidated gameplay and feature overviews in both English and Korean READMEs into a concise Key Features section while preserving full credits, third-party asset licenses, and 1:1 bilingual structure.

### Fixed
* Weapon Wheel Time Scale Trapping: Fixed softblock where closing the weapon wheel via pause menu or round completion left `Engine.time_scale` permanently at 0.2x slow motion.
* Run State Leaks on Retry/Menu: Fixed bug where retrying or returning to menu from a defeat retained old score, perks, and stat multipliers instead of performing a clean run reset.
* Dev Mode Endless Progression Softblock: Fixed issue where dev mode was trapped on Wave 1 because wave counter increments were mistakenly gated behind non-dev mode.
* Ray Depth Division Safety: Added mathematical safeguards against division by zero in camera ray depth calculations when aiming at extreme view angles.
* Catastrom State & Resume Guard: Fixed lingering Catastrom drag state on round loss and prevented premature timer ticks when unpausing outside active gameplay.
* Title Modal Input Consistency: Supported both `ui_pause` and `ui_cancel` to ensure keyboard ESC and gamepad cancel reliably close all title screen modals.

---

## [v1.7] - 2026-10-09
*(Note: Releases unified to v1.7 across both GitHub and itch.io)*

### Added
* Interceptor Escorts (Wave 55 & 60+): Armored fighter drones (120 HP) that body-block spray aimed at the Sun or orbital drones (1 on Wave 55, 2 on Wave 60+).
* Harmonic Matrix Shield (Wave 50+): 2 Harmonic Anchor drone pairs projecting dual-frequency resonance. Breaking both collapses shield (+1,500 pts, +50% water, +15% ult) and stuns drones for 3.5s.
* Infinity Lattice Formation (Wave 40+): 8 drones in counter-rotating dual tilted planes ($\pm 33^\circ$) weaving a 3D double helix across both hemispheres. Phase 2 deploys 6 Overdrive escorts.
* Endgame Durability Scaling: Post-Wave 20 Endless scales Sun heat capacity by +2.2%/wave (`MAX_TEMP * (1.0 + (wave - 20) * 0.022)`).
* New Trade-off Perks:
  * *Solar Overclock:* +30%–40% cooling power, +25%–35% faster solar flares.
  * *High-Pressure Bore:* +18%–30% cooling power, +12%–20% water drain.
  * *Hyper-Focus:* +20%–35% crit damage, -12%–20% base cooling.
  * *Deep Reservoir:* +25%–45% tank capacity, -15%–25% refill rate.
* Solar Disruptions (Wave 6+): Random micro-events (40%–60% chance) in non-boss waves:
  * *Thermal Barrier:* Cyan shield deflecting water; shatters via Ice Blast for +1,000 pts.
  * *Flare Barrage:* Rapid volley of 5–7 solar flares across wide angles.
* Coronal Eclipse Weather (Wave 45+): Deep twilight hazard with cloaked sunspots revealed by water/parries/ice, and +50% cooling on illuminated weakpoints.
* Weather Differentiation: Distinct visual and combat identities for Normal Eclipse (Cold Stasis, -2.0°/s passive cooling) vs. Coronal Eclipse (apex combat, cloaked weakpoints).
* Continuous Spray Thermal Falloff: Spraying one spot for >3.0s degrades cooling efficiency to 70%. Moving aim (distance >= 1.0) or releasing trigger resets to 100%.
* Perk Diminishing Returns: Stacking 3+ copies scales efficiency (1st/2nd = 100%, 3rd = 75%, 4th+ = 55%) with amber stack badge alerts.
* Wave Timer Glide Intro: Round-start timer displays in screen center (`scale 1.6x`, 2.5s hold), then glides (0.85s) into top-right HUD anchor.
* Title Screen Subtitle Clarification: Subtitle updated to `"COOL DOWN THE SUN BEFORE TIME RUNS OUT"` / `"제한 시간 내에 태양을 식혀라"`.
* "Paid in Full" Boss Overtime: Reaching `0:00` on Boss Waves burns banked score as life support. Defeating the boss clears Overtime; zero score triggers bankruptcy defeat.
* Overtime Shock Sun Expression: Procedural expression featuring contracted pill eyes, arched brows, open jaw, and temple sweat bead.
* "Paid in Full" Achievement: Unlocked by defeating a Boss during Overtime after burning $\ge 5,000$ score.
* HUD Overtime Telemetry: Pulsing crimson `[ OVERTIME ]` badge, red score drain feedback, and bankruptcy defeat subtitle.

### Improved
* Modal Menu Z-Ordering: Elevated all modal overlays to `z_index = 50` above HUD gameplay elements (`z_index = 0`); opening any menu immediately dismisses active timer intros.
* Boss UI Clarity: Removed top-center announcement banner on Wave 30 and boss waves to keep combat view clear.
* Achievement & Buff Card Radii: Standardized card panels to 4px Retro Flat Plate rule with concentric 3px progress bar fills.
* Toast & Notification Redesign: Overhauled right-side toasts (380x72px) and top-center popups (500x72–88px) into Cyberpunk Arcade Plates with even-number typography, recessed 40x40 icon plates, and staggered exits.
* Title Screen Split Layout: Symmetrical horizontal layout (840x400) with 340px vertical divider, twin 144x52 stats cards, 64px EN / 78px KR titles, and mode button stack.
* Atmospheric Horizon Bloom: Replaced sharp sky horizon line with smooth Gaussian bloom, eliminating the "tube" seam artifact.
* Fullscreen Default: Configured default fullscreen display mode across boots and platforms.
* Settings & Filters Polish: Standardized to 16px body font, 14px toggles, 110x34px buttons, and real-time numeric slider readouts (`100%`, `1.0x`).
* Title Screen Settings Modal: Added direct access to 3-category settings with live language toggle and `[ESC]` close.
* Secondary Menus Close Guidance: Added localized "PRESS ESC TO CLOSE" prompts across all secondary menus.
* Visual Polish Suite: Volumetric god rays with Mie scattering, anisotropic sunset ocean reflection glade, drifting heat embers / fireflies, and toon-shaded viewmodels with fluid reservoir indicators.
* Scatter Nozzle Orientation: Corrected 180° inverted viewmodel rotation.
* Victory Recap Screen ("SUMMER'S OVER"): Redesigned Normal Mode victory completion screen with single-line Cyber Gold hero title, lore subtitle, diamond divider, milestone unlock tag, 344px telemetry grid (`LEVELS CLEARED 6 / 6`, `CLEAR TIME`, `FINAL SCORE`), and dual 160x44px buttons (`Play Again`, `Main Menu`).
* Version Synchronization: Unified release numbering to v1.7 across GitHub and itch.io export presets.

### Fixed
* Fullscreen End Screen Dimming: Fixed dark overlay bug by reparenting content containers above `BorderPanel`, exempting modal screens from global drop shadows, and restoring 100% luminance typography.


---

## [v1.5.6] - 2026-09-30
*(Note: This release corresponds to v1.6 on itch.io)*

### Added
* Kitsune Buster IX: Tokusatsu-inspired celestial water blaster with 6-way weapon wheel integration, revolving 9-vial cylinder, and diamond reticle (unlocked at Endless Wave 30).
* Dual-Mode Switch: Real-time mechanical transformation between Cannon and Blade modes via `[X]` / Controller `[Y]` / MMB.
* Kitsune Blade Melee & Parry: 60° melee slash that cleaves solar flares for +15% water parry refund and damages/shatters Solar Eye Drones.
* Celestial Awakening Super State: 15s super state triggered at 100% Power Up charge with 9 procedural hydro-tails, infinite water, 2.0x cooling, Creation Aura, and Ethereal Domain screen filter.
* Power Up Dynamic HUD Gauge: Shared charge pool with dedicated purple Catastrom plate for standard weapons and cyan Celestial Awakening plate for Kitsune Buster IX.
* Solar Convergence Encounter: Wave 30+ apex boss encounter featuring the Equatorial Solar Driver buckle, 6–8 orbiting Solar Eye Drones, multi-tier procedural crack damage, and a 10m Golden Drone Shield.
* 4 New Achievements: Added "Endurance" (Wave 25), "Marathon Runner" (Wave 50), "Arsenal Expert" (5 weapons used), and "The Highlight" (Trigger Celestial Awakening).
* Best Endless Wave Tracking: High-score tracking for highest Endless Wave reached on Title Screen and game over recap.
* Custom Audio: CC0 sound effects for Celestial Awakening activation/deactivation and rubberduck CC0 drone impact/shatter SFX.
* Controls Legends: Added mode change legends (`[X]` Keyboard / `[Y]` Xbox) with magenta highlight, and unified controller "Power Up" labels.
* CC0 Audio Integration: Added open-source sound effects for Kitsune Blade unsheathe, Cannon lock, Tokusatsu Driver clamp, Phase 2 Overdrive surge alarm, Golden Drone Shield ambient hum, and Rogue-lite Perk drafting suite (card deal, hover, and perk selection chimes). Synced credits across READMEs and in-game Credits screen.
* Solar Convergence Phase 2 Swarm: When Phase 2 triggers on Wave 30+, the Equatorial Driver enters Overdrive, deploying an enraged drone swarm with reactivated Golden Shield.
* Kitsune Blade Flare Cleaving Bugfix: Cleaved fireballs/flares now immediately detonate into water explosions, queue free, and award water parry refunds instead of passing through the player.
* Endless Perks Rebalance & New Perks: Reduced overpowered flat cooling perks (Thermal Insulator down to +6% cooling with -10% water drain; Heavy Water down to +15% cooling with -15% ult charge) and capped cooling power multiplier at 2.0x. Added 3 new tactical perks: "Wind Breaker" (-60% solar wind crosshair drift), "Sub-Zero Reserve" (+1 ice blast charge capacity & wave refill), and "Blade Cadence" (+20% Kitsune Blade slash arc & +25% parry refund).
* Dynamic Perk Roll Ranges & Max Roll Badge: All 12 wave drafting perks now roll within dynamic randomized ranges ([min ~ max]) with proportional trade-off scaling and a glowing golden [ MAX ROLL! ] visual badge for maximum stat rolls.

### Known Issues (Critical)
* Fullscreen End-of-Run Dimming: Win ("Cool Down") and Lose ("The Sun Won") screens render at low brightness in fullscreen mode (under active investigation).

### Improved
* Level 6 Final Boss Balancing: Rebalanced Normal Mode Level 6 by reducing Phase 2 heat from 100 to 70, lowering heat regen from 8.5 to 7.8, reducing figure-8 sway speed from 1.8 to 1.6, adding a 20% rain chance for water recovery, and increasing starting ice charges from 6 to 7.
* Rogue-lite Perk Balancing: Reduced Gravity Anchor sway reduction from -15% to -10% per stack. Reclassified cooling power perks ("Thermal Insulator" and "Heavy Water") as Rare (weight 20, blue frame/badge) to prevent easy cooling stack exploits.
* Drone Shield Audio Polish: Added automatic volume ducking to the Solar Convergence drone shield ambient hum; plays an audible entrance cue before smoothly easing down to an unobtrusive background bed (-22 dB).
* Gold Weapon Skin Settings Toggle: Added an in-game toggle under the "DISPLAY & SYSTEM" settings category (visible only after reaching 50,000 points) allowing players to turn the Solid Gold weapon skin on or off to preserve original weapon detail.
* Kitsune Buster Barrel Symmetry: Symmetrized top and bottom barrel assemblies with matching pearl-white trays, dual coolant conduits, gold brackets, and aerodynamic cowls, removing floating front sight geometry.
* Energy Shield Combat Feedback: Removed floating "DEFLECTED" 3D text when hitting the Solar Flare Shield (blue shield) and Golden Drone Shield, keeping visual clarity on the boss and relying on dedicated bilingual HUD banner notifications.
* Equatorial Solar Driver Model Polish: Redesigned the boss buckle with an iconic 16-ray Sunburst Corona central crest (elongated North/South crown rays, incandescent amber spine conduits, crimson intercardinal rays, and a glowing solar pupil core) flanked by swept aerodynamic solar wing cowls, dual horizontal conduits with bracket clamps, radiator louvers, and lateral drone docking bays.
* Wave 30 Solar Driver Face Expressions: Added procedural boss face expressions for the Sun when the Equatorial Driver is equipped—including "Driver Smirk" (arrogant Tokusatsu boss smirk with predatory slanted almond eyes, slit pupils, arched demon brows, and a forehead coronal crest) and "Driver Fury" (Phase 2 Overdrive battle grin with wide diamond eyes, clenched teeth, and radiant flare crown) with radiant golden modulate glow.
* Twilight & Summer Night Sky Overhaul: Revamped low-heat and boss victory skybox aesthetics from a flat blue wash into a multi-tier anime twilight gradient (deep sapphire zenith, Belt of Venus lavender-pink dusk band, and luminous aquamarine horizon waterline glow). Added procedural Summer Milky Way stardust nebula ribbon, periodic shooting star meteors, a brilliant 4-point crystalline Evening Star (Venus), and dynamic moonlit silver-cyan rim lighting on both 2D and 3D drifting clouds (`CloudLayer.gd`), smoothly harmonized with cool twilight volumetric fog, softened directional lighting, and moonlit ocean specular reflections.
* Solar Convergence (Wave 30+) Boss Balancing: Rebalanced the apex boss encounter for punchier, fairer pacing. Halved Solar Eye Drone HP scaling (Wave 30 down from 140 to 64 HP; Phase 2 down to 44.8 HP), deployed a leaner 4-drone Overdrive escort in Phase 2 (down from 6), halved Sun heat regeneration while the Golden Drone Shield is actively protecting the Sun, lowered Phase 2 starting heat from 150 to 90 HP, and added +5% Catastrom / Celestial Awakening charge refund per drone kill (+8% on Ice Shatter).
* Deep Endless Mode Balancing (Wave 30+): Comprehensively rebalanced late-game survival scaling to eliminate impossible difficulty walls. Lowered heat regeneration ceiling from 45.0 to 26.0°C/s (harmonizing with the 2.0x player cooling cap), capped Sun sway speed at 1.3–1.5 rad/s to maintain humanly trackable combat, relaxed minimum flare spawn cooldown from 2.5s to 4.0s, capped solar wind drift at 1.75x (down from 2.5x), restricted the cyan shield exclusively to Waves 15–25 to prevent overlapping with the Solar Driver on Wave 30+, and added extra banked timer leniency on apex boss waves (up to 135s).
* Post-Wave 30 Systemic Balance Polish: Applied wave damage scaling to Kitsune Blade direct strikes against the Sun (eliminating the severe damage drop-off in blade mode post-Wave 30), fixed flare spawn intervals resetting to level-based delays in Survival Mode so flare cadence scales smoothly, and capped late-game survival weather weights so rainstorms and calm weather continue to appear alongside solar eclipses.
* Balanced Heat Mirages & Snappy Pop-In: Re-enabled Heat Mirage decoy events across all boss encounters (Wave 5, 10, 15, 20, 25, 30, 35, 40...) with comprehensive combat balancing: upgraded decoy entrance with snappy 0.3s elastic pop-in tweens, high-pitch energy whoosh SFX, steam bursts, and quadrupled split translation speed (delta * 5.5 down from sluggish 1.5). Reduced boss wave readiness delay to 1.5s and cycle cooldown to 8–12s (down from 16s), removed arbitrary frame delay checks, throttles Sun heat regen by 60% during mirages, caps overshield HP (25–120 HP), equips decoy 3D Solar Driver buckles when equipped, and awards 1.5x bonus damage directly to the mirage overshield when striking the true Sun.
* Bespoke UI Vector Icons (SVG Integration): Replaced generic star placeholder icons across the game with bespoke vector icons: "Extra Ice Charge" perk (`ice-spear.svg`), "Sub-Zero Reserve" perk (`thermometer-cold.svg`), clear/calm weather indicator (`sun.svg` with radiant solar gold modulate), weapon unlock toasts (`padlock-open.svg`), drone swarm neutralized toasts (`delivery-drone.svg`), and drone ice shatter toasts (`shatter.svg` with electric cyan modulate).
* Vector Icons & Credits Sync: Added Game-icons.net (Lorc, Delapouite, CC BY 3.0) attribution for newly integrated UI and perk vector icons across READMEs and in-game HUD Credits screen.
* Solar Driver & Phase 2 Toast Face Icons: Integrated the Sun boss's procedural expressions as dedicated high-contrast HUD toast icons—the arrogant "Driver Smirk" (`driver_smirk.png`) for Solar Driver Equipped / Deployed and the Wave 30 Convergence banner, and the fierce "Driver Fury" (`driver_fury.png`) for the Phase 2 Overdrive Swarm entrance.
* Export Presets Versioning: Updated build version numbers across Godot export presets—set to v1.6 for itch.io releases and v1.5.6 for GitHub releases, synchronized with project configuration.

### Fixed
* Kitsune Blade Heat Mirage Damage: Fixed Kitsune Blade melee slash failing to detect and damage Heat Mirages; slash now detects decoy suns, chunks mirage HP, and triggers reactive flinch and steam particles.
* Kitsune Buster Model Centering: Centered the circular muzzle aperture, Katana blade, crossguard Tsuba wings, and cannon barrel along the unified Y=0.48 bore axis within a symmetrical receiver face.
* Level Transition Input Guards: Locked weapon inputs during fade transitions to prevent premature wave clears.
* Weapon Wheel Overlay: Ensured background dim overlay hides immediately when transitioning to menus.
* Dawn Breaks Achievement Requirement: Corrected unlock requirement and progress tracking from Level 5 to Level 6 to match the full 6-level Normal Mode campaign.
* Phase 2 Solar Driver Persistence: Fixed an issue where the Equatorial Solar Driver detached and vanished upon entering Wave 30 Phase 2 due to drone clearing callbacks overriding buckle visibility; the driver now remains equipped, visible, and energized throughout Phase 2 Overdrive.
* Ice Burst Hit Reliability: Fixed an issue where Ice Burst failed to freeze the sun even when aimed correctly due to muzzle-to-camera parallax offset, sun sway flight delay, and discrete frame tunneling. Projectiles now accurately converge at the sun's depth, home dynamically on the moving sun when targeted, and use continuous swept-segment collision.
* Catastrom & Celestial Meter Background Switching: Fixed an issue where switching between normal weapons and Kitsune Buster IX when the Power Up meter was fully charged updated the ready text and font color immediately, but the progress bar background tint remained stuck on the previous weapon's color palette (purple or cyan). The meter fill tint now updates immediately on weapon switch and smoothly pulses via continuous sine-wave interpolation.


## [v1.5.5] - 2026-09-22
*(Note: This release corresponds to v1.5 on itch.io)*

### Added
* Solar Flare Shield: Procedural boss shield on Endless Wave 15+ that nullifies water damage until shattered with Ice Blast (`[R]`).
* Shield Visuals & Audio: Custom Fresnel pulse shader, impact ripples, deflection sparks, bouncing water droplets, and CC0 shatter/materialize SFX.
* Shield Tactical Cue: Bilingual prompt and HUD meter flash alerting players to shatter the shield with Ice Blast.
* Custom Boot Splash: Bespoke "Made with Godot" intro with golden frame drawing, monochrome Godot logo, PS1 synth swell, and curtain bloom.

### Improved
* Stat Hard Caps: Clamped player Cooling Power (3.5x) and Crit Damage (3.0x) to prevent runaway scaling in Endless Mode.
* Perk Scaling Safety: Added upper and lower safety bounds across all drafting perks to keep deep runs challenging and exploit-free.
* Late Wave Scaling: Added soft water resistance at Wave 100+, raised Sun heat regen ceiling to 45.0, and tuned sway amplitude.
* HUD Credits Sync: Aligned in-game credits screen 1:1 with README attributions in both English and Korean.

### Fixed
* HUD Meter Gating: Hidden Ice Blast and Catastrom meters on Wave 1 until naturally unlocked at Waves 2 and 4.
* Catastrom Lock: Prevented early charge accumulation and activation before reaching Wave 4 / Level 4.

## [v1.5.4] - 2026-09-16
*(Note: This release corresponds to v1.4 on itch.io)*

### Fixed
* UI Filter Bleed: Fixed retro filters applying to the start screen.
* Pause Guards: Prevented pausing during screen transitions or game over.
* Hazard Cleanup: Cleared remaining hazards on level transitions.
* Heat Bar Sync: Fixed sub-pixel rounding so temperature correctly resets to 100°C instead of 99°C.
* Wave Timer Pulse: Fixed an infinite tween leak when timers reset.
* Beach Wave Traversal: Fixed rogue beach waves prematurely collapsing and cutting off mid-beach by extending travel across the island, maintaining swell crest height across the entire shoreline, and preventing early tween interruption.
* Rock Solid Achievement: Fixed the "Rock Solid" achievement not unlocking when shooting or evaporating magma rock debris with water.

### Improved
* Temp Readout: Added live Celsius temperature reading to the heat bar.
* Timer Polish: Low-time wave timer now pulses red and bounces.
* HUD Shadows: Added 4px drop shadow to all HUD panels.
* Weapon Wheel Pointer: Added directional arrow for wheel selection.
* Left Weapon HUD: Expanded bottom-left weapon icon to include localized name and elemental color tinting.
* Weapon Swap Animations: Added physical swap animations.
* Crosshair Bounce: Crosshair scales up briefly on weapon swap.
* Solar Flare Penalties: Missing flares resets combo and applies scaling heat/water penalties.
* Gatling Alignment: Nudged Tidal Gatling 3D model leftwards (-0.15) for center alignment.
* Title Screen Camera: Fine-tuned distance, height, and FOV for a more cinematic perspective.
* Ocean Audio: Processed ambient track to loop seamlessly without a sharp cut.
* Ocean Cross-Swells: Added horizontal distant background waves with a timing lock to prevent clashing with shoreline waves.
* Weapon Wheel Shadows: Added subtle 4px drop shadows to floating wedges and selector needle matching the HUD visor depth.
* Weapon Wheel Pointer Animation: Added smooth morphing transition between the center neutral dot and the directional chevron pointer, with physical scaling, shadow tracking, and color preservation.
* Weapon Wheel Audio: Added button hover tick sound when highlighting weapons on the wheel.
* Drafting Screen Polish: Added tactile staggered card entrance animation, sequential audio ticks, drop shadows, and rarity badges (Common, Uncommon, Rare) with matching border tints.
* Achievement Progress Readouts: Added dedicated right-side progress column with mini gold progress bars and numerical counters (`current / max`) for locked achievements in both Pause and Title menus, and completed badges for unlocked achievements.
* Ice Burst Meter Polish: Replaced crowded discrete pill buttons with a unified 200x24 cyan-frost meter featuring discrete notch dividers and real-time numeric counter (`charges / max`), creating visual harmony across all resource bars.
* Active Buff Card Typography: Unified Active Buff card text sizing with Achievement cards (title reduced to 24px and body description to 15px with 2px vertical separation).
* HUD Credits Screen: Added missing audio attributions (Ice Shoot, Ice Hit, Ocean Waves), procedural systems (Ice VFX, Magma Debris, Solar Wind Hazard, Stream Combo & Sun Expressions), and bilingual fan-project disclaimers to 100% mirror README documentation.

---

## [v1.5.3] - 2026-09-12
*(Note: This release corresponds to v1.3 on itch.io)*

### Added
* Filters Menu: Added Retro Colors, Dithering, PS1 Shading, Heatwave 1984.

### Improved
* Retro Filters: Improved visual fidelity, NTSC chroma delay, quantization, PS1 low-res, and halation.
* Resource HUD: Upgraded to dark retro flat plates.
* Ice Burst: Replaced progress bar with discrete segmented charge cells.
* Catastrom UI: "MAX READY!" text pulses when ultimate is ready.
* Icons: Updated Ice Burst toast and filter menu icons.
* Weather: Clouds react to Rain/Eclipses; seagulls hide or panic based on weather.
* Ice Burst Polish: Added screen frost effect and cyan sun color shift.
* Level Transitions: Added cinematic "Dying Ember" fade out and delay.
* Flare Telegraphs: Flares show a 2D charging ring before launching.
* Audio Ducking: Heavy bass ducking on major impacts and dunks.
* Sun Expressions: Sun reacts dynamically to damage, charging, and dunks.

### Fixed
* HUD Alignment: Grouped and aligned all right-side HUD elements perfectly.
* Visual Glitches: Fixed flare ring clipping, particle coverage, menu spacing, and rogue waves in transitions.

---

## [v1.5.2] - 2026-09-07
*(Note: This release corresponds to v1.2 on itch.io)*

### Added
* Stats: Lifetime tracking for Water Sprayed and Deaths in the main menu.
* Crosshairs: Unique procedural crosshairs for each weapon.
* Draft Perks: Added Glass Cannon, Heavy Water, Reckless Haste.

### Improved
* UI Polish: Added global button hover bounce and UI audio ticks.
* Game Over UI: Added gold borders and improved layout to End screens.
* High Heat Warning: Added red border and heartbeat sound at 85% heat.
* Flare Impacts: Enhanced camera shake, flash, and explosion audio.
* Low Water: Crosshair pulses orange below 25%.
* Accessibility: Reduced motion support for all new UI pulses.
* Controller Friction: Added aim-assist slow-down when hovering the sun.

---

## [v1.5.1] - 2026-09-02
*(Note: This release corresponds to v1.1 on itch.io)*

### Added
* Rogue-lite Perks: Draft 1 of 3 perks after every boss wave.
* Perks HUD: Real-time active buff tracker on the top left.
* Perks: Added 'Gravity Anchor' to reduce sun sway.
* Procedural Fireflies: Reacts dynamically to weather events.
* Achievement UI: Show progress trackers in menus.

### Improved
* Sky Aesthetics: Parallax clouds and twinkling starfields.
* Weapon Wheel: Shows exact unlock conditions for locked weapons.
* Polish: Better island breeze sway, water splashes, and water shader steepness.

### Fixed
* Logic Bugs: Fixed Shadow Walker achievement, missing localization, screenshot freeze, MacOS focus pause, engine lockup on pause, and fullscreen start issues.

---

## [v1.5.0]

### Added
* Tutorial: First-time shooting tutorial prompt.
* Auto-Pause: Game pauses automatically when window loses focus.
* Dynamic Ring: Crosshair ring visually tracks water capacity.

### Fixed
* Pause State: Ensured the entire scene tree correctly freezes on pause.

---

## [v1.4.0]

### Added
* Controller Support: Full Xbox gamepad input for aiming, shooting, and UI.
* Controller Haptics: Immersion vibration for gameplay events.
* Water Shader: Procedural Gerstner waves, Voronoi foam, and subsurface scattering.
* Graphics: PBR sand texture, synthwave post-processing, cinematic bloom.
* Audio: Added safe royalty-free audio fallback for itch.io exports.

### Fixed
* Mac Export: Fixed Ad-Hoc code signing issues on MacOS builds.
* Visual Fixes: Corrected sand reflectivity, distant horizon fog, shiny sand highlights, and flare explosion color.
* Rogue Waves: Made cinematic and synchronized with wet sand.
* Exploit: Pausing weapon wheel no longer skips hazard timers.

---

## [v1.3.0] - 2026-08-21

### Added
* Tidal Gatling: 5th weapon unlocked via achievement.
* Combo Callouts: Floating text for high combo multipliers.
* Achievements: In-game gallery with custom icons and toast notifications.
* Buffs Menu: Tracks active high score rewards.
* Boot Sequence: PS1-style synth boot screen.
* Weather: Rogue waves crash onto the island; High heat boils steam from sun.
* Supernova: Cinematic supernova explosion on Game Over.

### Improved
* Menus: Unified UI styling (borders, margins, gaps, buttons).
* Consistency: Reduced Motion support, itch.io safe export icons, island foliage reacts to wind.

### Fixed
* Fixes: Sand material color, retry button logic, weapon model disappearance, pause exploits, and menu layout bugs.

---

## [v1.2.0] - 2026-08-14

### Added
* UI: Sliding language toggle button.
* Level 6: Added final Normal Mode level with constant Eclipses.
* Heat Mirage: Survival Mode boss mechanic with clones and Overshields.
* Endless Scaling: Multi-flares in deep runs.

### Improved
* Balance: Capped heat scaling at wave 15; Combo 2.0x+ regenerates water.
* Flow: 2.5s breather delay between levels; Weather persists across waves.
* Catastrom: Clears active weather when used.

### Fixed
* Fixes: Title audio loop, transition level timer, missing translations.

---

## [v1.1.0] - 2026-08-08

### Added
* Catastrom Ultimate: Grab and dunk the sun into the ocean.
* Precision Stream: High water drain, rapid cooling alternate fire.
* Scoring: Arcade combo multiplier scoring system.
* Heat Mirage: Shell game mechanic to confuse targeting.

### Improved
* Weather: Probability shifts based on survival time.
* Debris: Magma debris stays on beach and can be evaporated.
* Credits: Auto-scrolling cinematic credits screen.

---

## [v1.0.0] - 2026-07-19 (Initial Release)

### Added
* Core Loop: Survive 5 waves, cool the 3D sun.
* Weapons: 4 blasters and Ice Burst secondary.
* Hazards: Solar flares, solar wind, magma debris.
* Weather: Rainstorms, Solar Eclipses.
* Visuals: 3D stylized ocean, day/night cycle, procedural sun expressions.
* Accessibility: English/Korean localization, Reduce Motion setting.

---

## [v1.8] - WIP
*(참고: v1.8부터 itch.io가 단독 공식 릴리스 배포처로 운영됩니다)*

### 개선됨 (Improved)
* 배포 정책 및 프리셋 단일화: 다중 트랙 배포 혼선을 방지하기 위해 GitHub 바이너리 릴리스를 정리하고, v1.8부터 itch.io를 단독 공식 배포처로 유지하며 고도 내보내기 프리셋을 v1.8로 갱신.
* 문서 및 README 개편: 영문 및 한국어 README의 중복 설명을 핵심 특징(Key Features) 항목으로 정갈하게 압축하고, 전체 크레딧 및 서드파티 라이선스와 1:1 다국어 구조 유지.

### 수정됨 (Fixed)
* 무기 휠 일시정지 슬로우 모션 고착 버그 수정: 일시정지나 라운드 종료로 무기 휠이 즉시 닫힐 때 `Engine.time_scale`이 0.2배속으로 영구 고착되던 소프트블록 해결.
* 재시도 및 메뉴 복귀 시 런 상태 누수 해결: 패배 후 재시도하거나 메인 메뉴로 복귀할 때 이전 런의 점수, 퍽, 능력치 배율이 초기화되지 않고 유지되던 버그 수정.
* 개발자 모드 엔들리스 1웨이브 고착 수정: 개발자 모드에서 웨이브 카운트 증가 로직이 누락되어 1웨이브에 갇히던 소프트블록 수정.
* 광선 깊이 0 나누기 방지: 극단적인 시야각 조준 시 카메라 광선 Z축 0 나누기로 인한 잠재적 오류 방지.
* 카타스트롬 드래그 및 재개 가드: 라운드 패배 시 카타스트롬 드래그 잔존 상태를 정리하고, 게임플레이 외 상태에서 일시정지 해제 시 타이머 오작동 방지.
* 타이틀 모달 취소 입력 일관화: `ui_pause`와 `ui_cancel`을 모두 지원하여 키보드 ESC 및 게임패드 취소 버튼으로 모든 모달 창이 정상적으로 닫히도록 개선.

---

## [v1.7] - 2026-10-09
*(참고: 이번 릴리스부터 GitHub 및 itch.io 배포 버전 번호가 v1.7로 통일 동기화됩니다)*

### 추가됨 (Added)
* 요격 호위 드론 (Interceptor Escorts, 55 & 60웨이브 이상): 태양 본체나 궤도 드론으로 향하는 물줄기를 능동 차단하는 120 HP 고속 장갑 호위기 추가 (55웨이브 1기, 60웨이브 이상 2기).
* 조화 매트릭스 방어막 (Harmonic Matrix, 50웨이브 이상): 2쌍의 조화 앵커 드론이 투사하는 이중 주파수 공명 무적 방어막. 두 앵커 파괴 시 방어막 붕괴(+1,500점, +50% 물, +15% 궁극기) 및 드론 3.5초 기절.
* 무한 격자 드론 편대 (Infinity Lattice, 40웨이브 이상): 8기의 드론이 이중 경사 궤도($\pm 33^\circ$)를 돌며 3D 이중 나선 형성. 2페이즈에서는 6기의 고속 폭주 호위대 출격.
* 후반 엔드리스 태양 체력 스케일링: 20웨이브 이후 태양 열기 용량이 웨이브당 +2.2%씩 확장(`MAX_TEMP * (1.0 + (wave - 20) * 0.022)`).
* 신규 트레이드오프 퍽 4종:
  * *태양 오버클럭:* 냉각력 +30%~40%, 플레어 발사 빈도 +25%~35% 가속.
  * *고압 보어:* 냉각력 +18%~30%, 물 소모량 +12%~20%.
  * *극초점:* 치명타 피해 +20%~35%, 기본 냉각력 -12%~20%.
  * *심층 저수조:* 물탱크 용량 +25%~45%, 충전 속도 -15%~25%.
* 태양 교란 마이크로 이벤트 (6웨이브 이상): 보스전 외 일반 웨이브에서 40%~60% 확률로 발생하는 돌발 이벤트:
  * *열기 방벽:* 물줄기를 도탄시키는 시안 보호막. 얼음 폭발로 즉시 분쇄 가능 (+1,000점).
  * *플레어 폭격:* 5~7발의 솔라 플레어를 연속 발사하는 고밀도 탄막 급습.
* 코로나 일식 기상 이변 (45웨이브 이상): 심층 벨벳 보라빛 황혼 속 은폐 흑점을 조명(물 분사/패링/결빙) 시 노출시키며, 조명된 약점에 +50% 증폭 냉각 피해 적용.
* 일식 환경 차별화: 일반 개기일식(한랭 정지, 매초 -2.0° 자연 냉각)과 45웨이브 코로나 일식(최고위 전투, 은폐 흑점)의 시각 및 전투 메커니즘 분리.
* 지속 분사 열 감쇠: 한 지점에 3.0초 이상 연속 사격 시 냉각 효율이 70%까지 점진 감소. 조준 이동(거리 >= 1.0) 또는 사격 중단 시 100% 즉시 회복.
* 퍽 중첩 효율 감쇠: 동일 퍽 3개 이상 중첩 시 감쇠 적용 (1·2번째 100%, 3번째 75%, 4번째 이상 55%) 및 호박색 중첩 배지 안내.
* 웨이브 타이머 글라이드 인트로: 웨이브 시작 시 화면 중앙에 나타난 타이머(`scale 1.6x`, 2.5초 유지)가 우측 상단 HUD 슬롯으로 부드럽게 글라이드 안착(0.85초).
* 타이틀 부제목 명확화: 메인 메뉴 부제목을 `"제한 시간 내에 태양을 식혀라"` / `"COOL DOWN THE SUN BEFORE TIME RUNS OUT"`으로 변경.
* "완납 (Paid in Full)" 보스전 연장전: 보스 웨이브 `0:00` 도달 시 누적 점수를 소모하며 연장전 돌입. 보스 격파 시 생존, 점수 고갈 시 파산 패배.
* 연장전 경악 태양 표정: 연장전 돌입 시 축소된 동공, 치켜뜬 눈썹, 벌어진 턱, 관자놀이 땀방울 연출.
* "완납" 신규 업적: 연장전에서 5,000점 이상 소모 후 보스 격파 시 달성.
* HUD 연장전 UI: 진홍색 `[ 연장전 ]` 타이머 배지, 붉은 점수 소모 연출, 전용 파산 패배 자막 구현.

### 개선됨 (Improved)
* 모달 메뉴 Z-색인 계층화: 모든 모달 메뉴를 `z_index = 50`으로 격상하여 HUD 요소 상단 렌더링 보장. 메뉴 진입 시 진행 중인 타이머 비행 인트로 즉시 정리.
* 보스전 UI 시야 정리: 30웨이브 및 보스전 화면 상단 공지 배너를 제거하여 교전 시야 확보.
* 업적 및 버프 카드 곡률 표준화: 카드 모서리를 4px 레트로 플랫 플레이트 규격으로 통일하고, 진행도 바에 3px 동심원 채우기 반경 적용.
* 토스트 알림 전면 개편: 우측 토스트(380x72px) 및 상단 팝업(500x72~88px)을 사이버 아케이드 플레이트로 개편 (짝수 타이포그래피, 40x40 오목 아이콘 플레이트, 순차 시차 퇴장).
* 타이틀 화면 분할 레이아웃 대칭화: 840x400 대칭 분할 레이아웃 적용 (340px 수직 구분선, 쌍둥이 144x52 텔레메트리 카드, 한국어 78px / 영문 64px 타이틀, 모드 버튼 스택).
* 지평선 대기 블룸: 하늘 셰이더 지평선을 가우시안 블룸으로 개편하여 인위적인 경계 이음새 제거.
* 기본 전체화면 실행: 모든 플랫폼 첫 실행 및 부팅 시 기본 전체화면 적용.
* 설정 및 필터 화면 폴리시: 16px 본문 서체, 14px 토글, 110x34px 버튼, 실시간 슬라이더 수치 표시(`100%`, `1.0x`) 통일.
* 타이틀 설정 모달 연동: 메인 화면에서 3대 설정 카테고리 즉시 접근 및 실시간 언어 전환 지원.
* 보조 메뉴 닫기 안내 통일: 모든 보조 메뉴에 "닫으려면 ESC를 누르세요" 14px 안내 문구 배치.
* 시각 연출 강화: 전방 미 산란 갓 레이, 바다 노을 수면 반사광, 대기 부유 태양 불씨/반딧불이, 수냉 잔량 캐니스터가 장착된 툰 셰이딩 1인칭 무기 모델.
* 산탄 노즐 방향 수정: 180도 반대로 뒤집혀 있던 모델 회전 보정.
* 일반 모드 승리 완료 화면 ("여름은 끝났다"): 단일 라인 사이버 골드 히어로 타이틀, 로어 서브타이틀, 다이아몬드 구분선, 무한 모드 해금 배지, 344px 텔레메트리 그리드(`클리어 단계 6 / 6`, `클리어 시간`, `최종 점수`), 및 160x44px 듀얼 버튼(`다시 하기`, `메인 메뉴`)으로 전면 리뉴얼.
* 버전 번호 통일: GitHub 및 itch.io 배포 번호를 v1.7로 일치 동기화.

### 수정됨 (Fixed)
* 결과 화면 전체화면 어두워짐 수정: 컨테이너를 `BorderPanel` 상단으로 재배치하고, 전역 그림자 주입 예외 처리 및 100% 광도 타이포그래피 복원.


---

## [v1.5.6] - 2026-09-30
*(참고: 이 릴리스는 itch.io의 v1.6 버전에 해당합니다)*

### 추가됨 (Added)
* 6번째 비밀 무기 (구미호 버스터 IX): 6분할 무기 휠 연동, 9개 바이알 회전식 실린더 챔버, 전용 다이아몬드 조준선을 갖춘 특촬풍 신성 수압 블래스터 추가 (엔들리스 30웨이브 해금).
* 듀얼 모드 변형: `[X]` 키 / 컨트롤러 `[Y]` / 마우스 휠 클릭으로 포격 모드와 검 모드를 실시간 기계식 애니메이션 및 조준선 모핑과 함께 즉시 전환.
* 구미호 검 근접 베기 및 패링: 태양 플레어를 절단하여 +15% 물탱크를 환급받고 궤도 드론을 타격/파괴하는 60° 근접 베기 구현.
* 신성의 각성 (궁극기): 파워 업 100% 완충 시 발동되는 15초 슈퍼 상태. 9개 수류 리본 꼬리, 무한 수조, 2.0배 냉각력, 창조의 오라 및 에테리얼 도메인 필터 적용.
* 파워 업 공유 풀 및 동적 게이지: 카타스트롬과 신성의 각성을 단일 파워 업 충전 풀로 연동; 무기 전환 시 충전량이 보존되며 HUD 게이지가 퍼플(1~5번 총기)과 사이언(구미호 버스터)으로 실시간 전환.
* 태양 수렴 보스 인카운터: 적도 솔라 드라이버 버클, 6~8기의 궤도 솔라 아이 드론, 단계별 절차적 균열 손상 및 10m 황금 드론 방어막이 등장하는 30웨이브 이상 정점 보스전 추가.
* 신규 업적 4종: "인내심"(25웨이브), "마라톤 주자"(50웨이브), "무기 전문가"(5개 무기 사용), "클라이맥스"(신성의 각성 최초 발동) 추가 및 실시간 진행도 추적 지원.
* 엔들리스 최고 웨이브 추적: 생존 시간과 함께 최고 웨이브(`best_wave`)를 영구 저장하여 타이틀 화면 표시 및 게임 오버 신기록 배지 연동.
* 신규 CC0 효과음: 신성의 각성 발동/종료 사운드 및 궤도 드론 피격/파괴 효과음 적용.
* 조작 안내 및 범례 개선: 조작 안내 화면에 마젠타 하이라이트의 모드 전환(`[X]` 키보드 / `[Y]` Xbox) 범례를 추가하고 "파워 업" 명칭 통합.
* CC0 오픈소스 오디오 적용 및 크레딧 동기화: 구미호 검 발도음, 캐논 잠금음, 적도 드라이버 버클 체결음, 2페이즈 오버드라이브 경보음, 황금 방어막 앰비언스 험, 로그라이크 퍽 드래프트 사운드 3종(카드 딜링, 호버, 선택) 추가 및 README, HUD 크레딧 화면에 1:1 동기화.
* 태양 수렴 2페이즈 드론 군체 재출현: 30웨이브 이상 보스전에서 2페이즈 진입 시 적도 드라이버가 폭주 상태로 전환되며, 정예 드론 군체와 황금 방어막이 재배치되어 결전 난이도 강화.
* 구미호 검 플레어 절단 버그 수정: 근접 베기 및 여우불 참격 투사체에 적중한 태양 플레어가 통과하지 않고 즉시 수류 폭발과 함께 소멸하며 패링 물 환급이 정상 적용되도록 수정.
* 엔들리스 특성 밸런스 조정 및 신규 특성 3종: 과도했던 냉각력 특성 수치 조정(열 절연체: 냉각력 +6% 및 물 소모 -10%, 중수: 냉각력 +15% 및 궁극기 -15%) 및 냉각력 배율 상한을 2.0배로 제한. 전술적 선택지를 넓히는 신규 특성 3종("바람막이": 태양풍 조준 흔들림 -60%, "극저온 예비탄": 얼음 폭발 최대치 +1회 및 매 웨이브 1회 보충, "검의 운율": 구미호 검 베기 범위 +20% 및 패링 물 환급 +25%) 추가.
* 무작위 특성 수치 범위 및 최고 수치 배지: 12종의 웨이브 특성이 고유한 수치 범위([최소 ~ 최대]) 내에서 무작위로 결정되며, 페널티 특성은 정비례 스케일링이 적용됩니다. 최대 수치 획득 시 화려한 황금 테두리와 [ 최고 수치! ] 배지가 표시됩니다.

### 알려진 문제 (Known Issues - Critical)
* 전체화면 라운드 종료 화면 밝기 저하: 일반 및 무한 모드 모두에서 승리("Cool Down") 및 패배("The Sun Won") 화면이 어둡게 렌더링되는 현상 (원인 추적 중).

### 개선됨 (Improved)
* 6레벨 최종 보스 밸런스 조정: 일반 모드 6레벨의 난이도를 완화하기 위해 2페이즈 체력을 100에서 70으로 경감, 열 회복 속도를 8.5에서 7.8로 완화, 8자 이동 속도를 1.8에서 1.6으로 감속, 수분 보충을 위한 20% 강우 확률 추가 및 시작 얼음 충전을 6회에서 7회로 증량.
* 로그라이크 특성 밸런스 조정: '중력 닻'의 태양 흔들림 속도 감소율을 -15%에서 -10%로 완화. 냉각력 특성('열 절연체', '중수')을 희귀 등급(가중치 20, 파란색 테두리/배지)으로 재분류하여 냉각력 무한 중첩 방지.
* 드론 방어막 사운드 완화: 태양 수렴 드론 방어막 배경 앰비언스 사운드에 자동 볼륨 감쇠(Ducking) 적용; 첫 출현 시 명확하게 재생된 뒤 귀에 피로감을 주지 않는 잔잔한 배경 음량(-22 dB)으로 부드럽게 감쇠.
* 황금 무기 스킨 설정 토글 추가: 총기의 원래 디테일을 감상할 수 있도록 '화면 및 시스템' 설정 카테고리에 스킨 토글 옵션 추가 (50,000점 달성 후 해금되어 설정창에 등장).
* 구미호 버스터 총열 상하 대칭화: 상단 총열과 하단 언더트레이의 외형을 펄 화이트 트레이, 듀얼 냉각 도관, 골드 브래킷 및 테이퍼드 카울로 대칭 일치시키고 공중에 떠 있던 가늠쇠 블록을 제거.
* 에너지 실드 타격 피드백 정돈: 태양 플레어 실드(청록색 실드) 및 황금 드론 방어막 타격 시 나타나던 "DEFLECTED" 3D 텍스트를 모두 제거하여 보스 시야를 확보하고 전용 다국어 HUD 배너 알림에 집중하도록 개선.
* 적도 솔라 드라이버 3D 모델 개선: 보스 버클 중앙에 16줄기 3D 태양광 코로나 문장(상하 황금 왕관 광선, 발광 앰버 도관 침, 진홍빛 광선 및 백열 태양 동공 코어)을 신설하고, 좌우 플랭크에 스웹트 솔라 윙 카울, 듀얼 앰버 플라즈마 도관과 클램프 브래킷, 방열 루버 슬롯 및 정밀 드론 도킹 베이를 추가하여 보스전 조형미 강화.
* 30웨이브 솔라 드라이버 전용 표정 추가: 적도 드라이버 장착 시 태양의 절차적 전용 보스 표정 2종 추가—"드라이버 스머크(Driver Smirk)"(포식자풍 아몬드 슬릿 눈, 아치형 악마 눈썹, 이마 태양관 문장과 오만한 비대칭 미소) 및 "드라이버 퓨리(Driver Fury)"(2페이즈 오버드라이브 광기 어린 다이아몬드 개안, 악문 이빨 그리메이스와 방사형 플레어 왕관) 및 전용 황금 발광 모듈레이트 적용.
* 황혼 및 '썸머 나이트' 하늘 배경 전면 개편: 태양 냉각 및 체력 소진 시 나타나던 단조로운 파란 하늘을 풍성한 멀티 티어 애니메이션 황혼 그라데이션(심우주 사파이어 천정, 금성의 띠 라벤더 핑크 더스크 밴드, 수평선 아쿠아마린 워터라인 글로우)으로 개편. 절차적 여름 은하수 성간 리본, 주기적인 유성(별똥별), 4방향 결정체 개밥바라기별(금성)을 추가하고, 2D 하늘 및 3D 부유 구름(`CloudLayer.gd`)에 달빛 실버-사이언 림 라이팅을 연동하였으며, 부드러운 박명 안개, 달빛 지향광 및 바다 표면의 은빛 반사광과 완벽하게 조화를 이루도록 개선.
* 태양 수렴(30웨이브+) 보스전 밸런스 조정: 결전 난이도와 피로도를 완화하여 박진감 넘치는 템포로 개편. 솔라 아이 드론 체력 대폭 하향(30웨이브 기준 140 HP에서 64 HP로 감소, 2페이즈 44.8 HP), 2페이즈 폭주 드론 군체를 6기에서 날렵한 4기 호위 편대로 축소, 황금 방어막이 활성화된 동안 태양의 자연 열 회복 속도를 50%로 감쇠, 2페이즈 체력을 150에서 90 HP로 경감, 드론 파괴 시 물 환급 외에도 궁극기/신성의 각성 게이지를 +5%(얼음 분쇄 시 +8%) 환급하도록 개선.
* 심층 무한 모드 밸런스 전면 개편 (30웨이브 이후): 후반부 생존 모드의 불합리한 난이도 벽을 허물기 위해 전반적인 성장 곡선 재조정. 태양의 자연 열 회복 속도 상한을 45.0에서 26.0°C/s로 대폭 완화(플레이어의 2.0배 냉각력 상한과 조화), 태양의 8자 회전 속도 상한을 1.3~1.5 rad/s로 제한하여 추적 가능한 아케이드 조준감 유지, 플레어 최소 생성 주기 하한을 2.5초에서 4.0초로 완화, 태양풍 조준선 밀림 배율 상한을 2.5배에서 1.75배로 완화, 청록색 플레어 방어막을 15~25웨이브 전용으로 제한하여 30웨이브 이후 솔라 드라이버와 중첩되는 현상 제거, 정점 보스 웨이브 타이머 누적 한도를 135초로 증량.
* 30웨이브 이후 게임 전반 밸런스 시스템 정돈: 구미호 검의 태양 직접 타격에 웨이브 피해 계수(`wave_dmg_mult`)를 연동하여 검 모드 사용 시 냉각 피해가 급감하던 현상을 정상화, 생존 모드에서 플레어 생성 주기가 레벨 기반 타이머로 초기화되던 현상을 수정하여 웨이브 비례 템포 유지, 장기 생존 시 일식 확률 상한을 설정하여 후반부에도 폭우(무한 물) 및 맑은 날씨가 고르게 출현하도록 기상 밸런스 개선.
* 전 보스 웨이브 열기 신기루 밸런스 및 팝인 반응성 개선: 모든 보스전(5, 10, 15, 20, 25, 30, 35, 40웨이브...)에 열기 신기루가 균형 있고 날렵하게 등장하도록 시스템 전면 개편. 분신 생성 시 0.3초 탄성 팝인 트윈, 고음 에너지 효과음, 증기 버스트 및 4배 빨라진 수평 전개 속도(`delta * 5.5`)를 적용하여 답답한 이동 지연을 해소. 보스전 진입 대기시간을 1.5초로 단축하고 재발동 쿨다운을 8~12초로 완화하였으며, 불필요한 프레임 확률 체크를 제거하여 즉각 반응하도록 개선. 신기루 전개 중 태양 열 회복 60% 감쇠, 신기루 방어막 체력 상한(25~120 HP), 솔라 드라이버 장착 시 3D 버클 동기화, 진품 태양 타격 시 1.5배 보너스 피해 적용.
* 맞춤형 UI 벡터 아이콘 적용 (SVG 연동): 게임 전반에 임시로 사용되던 별(Star) 플레이스홀더 아이콘을 전용 벡터 SVG 아이콘으로 교체: "추가 얼음 충전" 특성(`ice-spear.svg`), "극저온 예비탄" 특성(`thermometer-cold.svg`), 맑음/평온 날씨 표시기(`sun.svg` 및 황금빛 모듈레이트), 무기 해금 토스트(`padlock-open.svg`), 드론 군체 무력화 토스트(`delivery-drone.svg`), 드론 결빙 분쇄 토스트(`shatter.svg` 및 일렉트릭 사이언 모듈레이트).
* 벡터 아이콘 및 크레딧 동기화: 신규 UI 및 퍽 벡터 아이콘에 대한 Game-icons.net (Lorc, Delapouite, CC BY 3.0) 라이선스 표기를 영문/한국어 README 및 인게임 HUD 크레딧 화면에 1:1 동기화 반영.
* 솔라 드라이버 및 2페이즈 전용 표정 토스트 아이콘: 보스 전용 절차적 표정을 고대비 HUD 알림 아이콘으로 연동—솔라 드라이버 장착/전개 및 30웨이브 수렴 감지 배너에는 오만한 "드라이버 스머크"(`driver_smirk.png`)를, 2페이즈 폭주 진입 알림에는 "드라이버 퓨리"(`driver_fury.png`)를 각각 적용.
* 내보내기 프리셋 버전 번호 갱신: 고도 엔진 내보내기 프리셋의 빌드 번호를 프로젝트 구성에 맞춰 itch.io 배포용은 v1.6으로, GitHub 배포용은 v1.5.6으로 각각 갱신 반영.

### 수정됨 (Fixed)
* 구미호 검 신기루 타격 버그 수정: 구미호 검 근접 베기가 열기 신기루를 타격하지 못하던 현상 수정; 신기루를 조준하여 베었을 때 신기루 체력 게이지가 정상 감소하고 피격 반응 및 이펙트가 발생하도록 개선.
* 구미호 버스터 3D 모델 중심축 정렬: 대칭형 리시버 전면부와 통합 Y=0.48 중심축을 기준으로 원형 총구 개구부, 카타나 칼날, 코등이(츠바) 날개 및 캐넌 총열의 정렬을 완벽하게 일치하도록 수정.
* 레벨 전환 입력 잠금: 화면 페이드 전환 중 무기 입력을 잠금 처리하여 조기 클리어 방지.
* 무기 선택 휠 오버레이: 메뉴 전환 및 휠 종료 시 배경 블러/딤 오버레이가 즉시 숨겨지도록 수정.
* 새벽이 밝다 업적 레벨 요건 수정: 일반 모드 6개 전체 레벨 캠페인에 맞춰 업적 해금 요건 및 진행도 표시를 레벨 5에서 레벨 6으로 수정.
* 2페이즈 솔라 드라이버 유지 버그 수정: 30웨이브 2페이즈 진입 시 드론 초기화 콜백이 버클 가시성을 덮어씌워 적도 솔라 드라이버가 해제 및 소멸하던 현상 수정; 2페이즈 오버드라이브 중에도 드라이버가 정상 장착 및 발광 상태를 유지하도록 개선.
* 얼음 폭발 타격 판정 개선 및 버그 수정: 조준선이 태양을 정확히 겨누었음에도 총구-카메라 간 시차(Parallax), 비행 시간 중 태양 이동, 고속 프레임 터널링 현상으로 인해 얼음 폭발이 빗나가던 현상 수정. 태양 평면 깊이에 수렴하는 정확한 조준점 연산, 조준 시 태양 동적 유도(Homing), 연속 스윕 세그먼트 충돌 판정을 적용하여 타격 신뢰도 완벽 보장.
* 카타스트롬 및 신성의 각성 게이지 배경색 전환 버그 수정: 파워 업 게이지가 100% 완충된 상태에서 일반 무기 5종과 구미호 버스터 IX 간에 무기를 전환할 때, 준비 텍스트와 글자 색상은 즉시 변경되었으나 게이지 배경 채움 색상이 이전 무기의 색상(보라색 또는 청록색)으로 멈춰 있던 현상 수정. 무기 전환 즉시 게이지 색상이 변경되며 부드러운 사인파 펄스로 맥동하도록 개선.


## [v1.5.5] - 2026-09-22
*(참고: 이 릴리스는 itch.io의 v1.5 버전에 해당합니다)*

### 추가됨 (Added)
* 태양 플레어 실드: 무한 모드 15웨이브 이상 보스에 등장하며, 얼음 폭발(`[R]`)로 파괴하기 전까지 물 피해를 완전 무효화하는 에너지 실드 추가.
* 실드 비주얼 및 오디오: 프레넬 펄스 셰이더, 물방울 튕김 파티클, 충격 리플 및 전용 생성/파괴 효과음 적용.
* 실드 전술 알림: 실드 피격 시 아이스 버스트 게이지 점멸 및 파괴 유도 다국어 토스트 알림 추가.
* 커스텀 부트 스플래시: 골드 프레임 드로잉, 모노크롬 고도 엔진 로고, PS1 신스 사운드 및 커튼 리빌 연출을 갖춘 인트로 화면 추가.

### 개선됨 (Improved)
* 능력치 하드 캡: 무한 모드 밸런스 붕괴를 방지하기 위해 냉각력(3.5배) 및 치명타 피해(3.0배) 상한선 적용.
* 퍽 스케일링 안전 경계: 후반 무한 모드에서 모든 특성에 상·하한선을 두어 익스플로잇 방지 및 긴장감 유지.
* 후반 웨이브 스케일링: 100웨이브 이후 물 소프트 저항 도입, 태양 최대 열기 재생 상한 상향(45.0), 흔들림 진폭 최적화.
* 크레딧 동기화: 게임 내 크레딧 화면을 README 문서와 1:1로 일치시키고 다국어 표기 보강.

### 수정됨 (Fixed)
* 자원 HUD 표시 오류: 무한 모드 1웨이브에서 아직 미해금된 아이스 버스트 및 카타스트롬 게이지가 보이던 문제 수정.
* 카타스트롬 잠금 제어: 4웨이브 / 레벨 4 이전에는 게이지 충전 및 스킬 발동이 되지 않도록 수정.

## [v1.5.4] - 2026-09-16
*(참고: 이 릴리스는 itch.io의 v1.4 버전에 해당합니다)*

### 수정됨 (Fixed)
* UI 필터 누출: 타이틀 화면에 레트로 필터가 적용되던 문제 수정.
* 일시정지 보호: 화면 전환 및 게임 오버 시 일시정지를 막아 멈춤 방지.
* 투사체 정리: 레벨 전환 시 남아있는 위험 요소 초기화.
* 열기 게이지 동기화: 게이지 초기화 시 99°C가 아닌 100°C로 정확히 표시되도록 수정.
* 웨이브 타이머 펄스: 타이머 초기화 시 알파 펄스 트윈이 영구 지속되던 누수 수정.
* 해변 파도 연출: 파도가 해변 중간에서 갑자기 사라지거나 끊기던 문제를 해결하여, 섬 전체를 완전히 가로질러 덮치도록 이동 거리와 높이 트윈 타이밍을 정상화하고 조기 종료 인터럽트를 방지.
* 단단한 바위 업적: 물총으로 마그마 파편을 쏘거나 증발시켜도 "단단한 바위(Rock Solid)" 업적이 해금되지 않던 문제 수정.

### 개선됨 (Improved)
* 온도 표시: 열기 게이지에 실시간 섭씨 온도 추가.
* 타이머 폴리싱: 시간이 부족할 때 타이머가 붉게 깜박이며 튕기는 애니메이션 추가.
* HUD 그림자: 모든 HUD 패널에 4px 드롭 섀도우 추가.
* 무기 휠 포인터: 휠 선택 방향을 알려주는 화살표 추가.
* 좌측 무기 HUD: 좌측 하단 아이콘에 무기 이름과 원소 색상 표시 추가.
* 무기 교체 애니메이션: 물리적인 무기 교체 애니메이션 추가.
* 크로스헤어 바운스: 무기 교체 시 크로스헤어 크기 일시적 증가.
* 태양 플레어 페널티: 플레어 충돌 시 콤보 초기화 및 진행도 비례 열기/물 증발 페널티 적용.
* 개틀링 정렬: 타이달 개틀링 3D 모델 중심축 미세 조정 (-0.15).
* 타이틀 화면 카메라: 거리, 높이 및 시야각(FOV)을 조정하여 더 시네마틱한 연출 적용.
* 바다 오디오: 끊김 현상 없이 자연스럽게 반복되도록 앰비언트 트랙 믹싱 처리.
* 바다 크로스 스웰: 해안가 파도와 겹치지 않도록 타이밍 잠금이 적용된 원경 가로 파도 추가.
* 무기 휠 그림자: HUD 바이저 깊이감과 일치하도록 플로팅 웨지 및 선택 화살표에 은은한 4px 드롭 섀도우 추가.
* 무기 휠 포인터 애니메이션: 중앙 중립 도트와 방향성 셰브론 포인터 간의 물리적 스케일링, 그림자 추적 및 색상 유지가 적용된 부드러운 모핑 전환 애니메이션 추가.
* 무기 휠 효과음: 무기 휠에서 각 무기 슬라이스를 호버/선택할 때 버튼 호버 틱 사운드 재생 추가.
* 특성 드래프트 연출: 카드 딜링 순차 등장 애니메이션, 효과음 틱, 드롭 섀도우 및 등급별 태그(일반, 고급, 희귀)와 테두리 틴트 추가.
* 업적 진행도 표시: 일시정지 및 타이틀 메뉴의 잠긴 업적에 미니 골드 진행도 바와 수치 카운터(`현재 / 최대`)가 포함된 전용 상태 열 및 완료 배지 추가.
* 얼음 폭발 게이지 개선: 다수의 충전 보유 시 답답하게 보이던 개별 알약 형태의 버튼들을 물/카타스트롬과 대칭을 이루는 200x24 일체형 사이언 프로스트 게이지로 개편하고, 미세 눈금 분할선 및 실시간 수치 카운터(`현재 / 최대`) 적용.
* 활성 버프 카드 타이포그래피: 활성 버프 카드의 텍스트 크기를 업적 카드와 일치하도록 통일(제목 24px, 설명 15px 및 2px 수직 간격 적용).
* HUD 크레딧 화면: 누락되었던 효과음(얼음 발사음, 얼음 피격음, 바다 파도 앰비언스), 절차적 시스템(얼음 폭발 VFX, 마그마 파편, 태양풍, 물줄기 콤보 및 태양 표정), 그리고 비영리 팬 제작물 면책 조항을 추가하여 README 문서와 100% 일치하도록 보완.

---

## [v1.5.3] - 2026-09-12
*(참고: 이 릴리스는 itch.io의 v1.3 버전에 해당합니다)*

### 추가됨 (Added)
* 필터 메뉴: 레트로 색상, 디더링, PS1 셰이딩, 폭염 1984 필터 추가.

### 개선됨 (Improved)
* 레트로 필터: 그래픽 개선, NTSC 크로마 지연, 픽셀화, 할레이션 퀄리티 강화.
* 자원 HUD: 다크 레트로 플랫 패널 디자인으로 개편.
* 얼음 폭발: 게이지를 개별 충전 칸 디자인으로 교체.
* 카타스트롬 UI: 궁극기 충전 시 "준비 완료!" 텍스트 깜박임 연출.
* 아이콘: 얼음 폭발 알림 및 필터 메뉴 아이콘 업데이트.
* 날씨 반응: 비/일식에 구름 색상이 변하며 갈매기가 날씨에 따라 행동함.
* 얼음 폭발 폴리싱: 사용 시 화면 서리 효과 및 태양 색상 청록색 변화.
* 레벨 전환: "잔불" 페이드 아웃 연출 및 시네마틱 딜레이 추가.
* 플레어 전조 증상: 발사 전 2D 충전 링 표시.
* 오디오 더킹: 큰 타격이나 궁극기 덩크 시 강력한 베이스 오디오 더킹 적용.
* 태양 표정: 피격, 충전, 궁극기 피격 시 동적 표정 추가.

### 수정됨 (Fixed)
* HUD 정렬: 우측 HUD 요소 간격 및 우측 정렬 통일.
* 시각적 오류 수정: 플레어 링 잘림, 파티클 범위, 메뉴 간격, 전환 중 파도 생성 버그 수정.

---

## [v1.5.2] - 2026-09-07
*(참고: 이 릴리스는 itch.io의 v1.2 버전에 해당합니다)*

### 추가됨 (Added)
* 통계: 물 분사량 및 총 사망 횟수 영구 추적 메뉴 추가.
* 크로스헤어: 무기마다 고유한 모양의 동적 크로스헤어 적용.
* 드래프트 퍽: 유리 대포, 중수, 무모한 가속 퍽 추가.

### 개선됨 (Improved)
* UI 폴리싱: 모든 버튼 호버 바운스 및 상호작용 오디오 틱 소리 추가.
* 게임 오버 UI: 종료 화면에 금빛 테두리 및 레이아웃 개선.
* 고열 경고: 온도 85% 초과 시 붉은 화면 테두리와 심장 박동음 추가.
* 플레어 충돌: 카메라 흔들림, 플래시, 폭발 오디오 강화.
* 물 부족: 물탱크 25% 이하 시 크로스헤어 주황색 깜박임.
* 접근성: 모든 새로운 펄스 효과에 '움직임 감소' 옵션 완벽 지원.
* 컨트롤러 마찰력: 태양 조준 시 조준선 느려짐(에임 어시스트) 적용.

---

## [v1.5.1] - 2026-09-02
*(참고: 이 릴리스는 itch.io의 v1.1 버전에 해당합니다)*

### 추가됨 (Added)
* 로그라이트 퍽: 보스 웨이브 이후 3개의 퍽 중 하나 선택 (드래프팅).
* 퍽 HUD: 좌측 상단에 실시간 활성화 버프 트래커 추가.
* 신규 퍽: 태양 흔들림을 줄이는 '중력 닻' 추가.
* 절차적 반딧불이: 날씨에 동적으로 반응하는 반딧불이 입자.
* 업적 UI: 메뉴에서 누적 업적 진행도 표시 기능.

### 개선됨 (Improved)
* 하늘 미학: 다층 시차 구름 및 반짝이는 별밭 추가.
* 무기 휠: 잠긴 무기의 정확한 해금 조건 명시.
* 폴리싱: 해변 산들바람 흔들림, 물보라 파티클, 물 셰이더 파도 가파름 개선.

### 수정됨 (Fixed)
* 로직 버그: 그림자 걷는 자 업적 버그, 누락된 번역, 스크린샷 멈춤, MacOS 포커스 및 엔진 멈춤 문제 완벽 수정.

---

## [v1.5.0]

### 추가됨 (Added)
* 튜토리얼: 첫 플레이 시 조준 및 사격 안내 팝업.
* 자동 일시정지: 게임 창 포커스를 잃을 때 자동 일시정지 되도록 개선.
* 동적 링: 크로스헤어 주위에 물탱크 용량을 실시간 링으로 표시.

### 수정됨 (Fixed)
* 일시정지 상태: 일시정지 시 전체 씬 트리가 올바르게 멈추도록 버그 수정.

---

## [v1.4.0]

### 추가됨 (Added)
* 컨트롤러 지원: 조준, 사격, UI 탐색 등 Xbox 게임패드 완벽 호환.
* 컨트롤러 진동: 게임플레이 주요 이벤트에 진동(햅틱 피드백) 추가.
* 물 셰이더: 절차적 거스트너 파도, 보로노이 거품, 표면하 산란 효과 도입.
* 그래픽: PBR 모래 텍스처, 신스웨이브 포스트 프로세싱, 시네마틱 블룸.
* 오디오: itch.io 배포를 위한 저작권 무료 대체 오디오 파일 추가.

### 수정됨 (Fixed)
* Mac 배포: MacOS 빌드의 Ad-Hoc 코드 서명 호환성 문제 해결.
* 시각 수정: 모래 반사율, 원경 안개, 플레어 폭발 색상 등 다수 그래픽 버그 수정.
* 돌발 파도: 파도를 시네마틱하게 변경하고 젖은 모래 효과와 시각적 동기화.
* 꼼수 방지: 무기 휠을 켜고 일시정지로 위험 요소 시간을 넘기는 꼼수 방지.

---

## [v1.3.0] - 2026-08-21

### 추가됨 (Added)
* 타이달 개틀링: 업적 달성 시 해금되는 5번째 헤비 무기.
* 콤보 콜아웃: 높은 콤보 도달 시 역동적으로 떠오르는 텍스트 연출.
* 업적: 인게임 갤러리와 커스텀 아이콘 알림 기능이 있는 업적 시스템 추가.
* 버프 메뉴: 활성화된 하이스코어 보상 버프를 추적하는 메뉴 추가.
* 부팅 시퀀스: 타이틀 화면에 PS1 스타일 씬스 사운드와 테두리 애니메이션 도입.
* 기상 효과: 해변을 강타하는 돌발 파도 및 고열 시 태양 증기 방출 시각 효과.
* 초신성: 타임 오버 시 시네마틱 초신성 폭발 화면 적용.

### 개선됨 (Improved)
* 메뉴: 여백, 테두리, 버튼, 간격 등 전반적인 UI 통일 디자인 구축.
* 일관성: 모션 감소 호환 및 바람에 흔들리는 섬 식물 등 개선.

### 수정됨 (Fixed)
* 버그 수정: 모래 질감 색상 버그, 재시작 버튼 로직, 무기 휠 악용 꼼수, 메뉴 레이아웃 정렬 수정.

---

## [v1.2.0] - 2026-08-14

### 추가됨 (Added)
* UI: 슬라이딩 애니메이션이 적용된 언어 토글 버튼 추가.
* 레벨 6: 일식이 지속되는 일반 모드 최종 레벨 추가.
* 열기 신기루: 환영과 보호막을 소환하는 생존 모드 보스 패턴.
* 무한 스케일링: 극후반 무한 모드(웨이브 10 이상)에서 다중 플레어 산탄 발사 등장.

### 개선됨 (Improved)
* 밸런스: 무한 모드 열기 재생을 웨이브 15로 상한 캡 적용; 2.0x 콤보 이상 시 물 점진적 재생 기능 추가.
* 흐름: 레벨 간 2.5초 지연(숨고르기) 시간 부여; 날씨가 웨이브를 넘어 지속되도록 개선.
* 카타스트롬: 궁극기 사용 시 현재 날씨 이벤트를 강제 맑음 처리.

### 수정됨 (Fixed)
* 버그 수정: 타이틀 오디오 루프 오류, 전환 중 타이머 작동 버그, 번역 누락 수정.

---

## [v1.1.0] - 2026-08-08

### 추가됨 (Added)
* 카타스트롬 궁극기: 게이지 충전 시 태양을 잡아 바다에 던져 덩크슛하는 기능.
* 정밀 스트림: 물 소모가 매우 크고 냉각이 빠른 보조 발사 무기.
* 점수 시스템: 콤보에 비례하여 증가하는 아케이드 점수 시스템 추가.
* 열기 신기루: 환영을 만들어 혼란을 주는 신기루 보스 메커니즘.

### 개선됨 (Improved)
* 날씨: 무한 모드 생존 시간에 따라 일식 기상 확률이 동적으로 증가.
* 파편: 마그마 잔해가 해변에 남아 직접 물을 쏴서 증발시킬 수 있도록 개선.
* 크레딧: 자동 스크롤되는 시네마틱 크레딧 화면 적용.

---

## [v1.0.0] - 2026-07-19 (초기 출시)

### 추가됨 (Added)
* 핵심 루프: 5웨이브 연속 생존, 3D 태양 냉각 메커니즘.
* 무기: 4종의 물총(Blaster)과 얼음 폭발(Ice Burst) 보조 공격.
* 위험 요소: 태양 플레어, 태양풍 돌풍, 마그마 파편 비.
* 날씨: 폭우(물 무한), 개기 일식(시야 차단).
* 시각 효과: 3D 양식화 바다 셰이더, 밤낮 주기 조명 변화, 절차적 3D 표정.
* 접근성: 영어 및 한국어 이중 언어 지원, 모션 감소(Reduce Motion) 옵션 제공.
