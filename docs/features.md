# Summer Nights: Feature Documentation

Master record of all implemented features, mechanics, and systems in *Summer Nights*.

---

## 1. Core Gameplay Loop
* **Objective:** Keep the Sun's heat below 100% until the wave timer expires.
* **Heat Mechanics:** The Sun passively generates heat; reaching 100% triggers Supernova (Game Over).
* **Water Management:** Firing drains water; tank recharges automatically when idle.
* **Combo System:** Continuous hits build a combo multiplier (up to 3.0x), boosting ultimate charge and shifting audio pitch.
* **Scoring:** Points awarded for hits, flare intercepts, and magma evaporation. Multiplied by combo. High scores save locally.
* **Progression:** 6 Normal Mode levels; Endless Mode unlocks afterward. Boss waves occur every 5th wave. Continuous water resistance scales past Wave 100.
* **Transitions:** Cinematic "Dying Ember" fade out, score recap, and seamless reset between waves.

## 2. Weapons & Tools
* **Weapon Wheel (`TAB`):** Slows time to 0.2x. Displays centered 3D weapon previews, archetype tags, responsive cooling/capacity bars, and crit multipliers.
* **Arsenal:**
  * *Standard Blaster:* Balanced starter weapon.
  * *Precision Stream:* Low capacity, high critical multiplier.
  * *Heavy Cannon:* High capacity, massive cooling, rapid drain.
  * *Scatter Nozzle:* Wide spray for multi-target flare intercepts.
  * *Kitsune Buster IX:* Endless Wave 30 unlock (160 cap, 28 cool, 2.2x crit). Grants 100% Awakening meter on first unlock. Mode toggle (`[X]` / `[Y]` / MMB):
    * *Cannon Mode:* Precision stream with revolving 9-vial cylinder.
    * *Blade Mode:* Katana melee strike (60° arc, 8.5m range). Cleaves flares for +15% water, damages drones, and strikes Heat Mirages and the Sun with wave damage scaling.
  * *Gold Weapon Skin:* Unlocked at 50,000 High Score. Solid gold metallic finish with in-game Settings toggle under Display (only visible once 50k points is reached) to preserve original weapon detail if preferred.
* **Ice Burst (Secondary `[R]`):** Freezes heat gain and sun movement for 3s. Features converged crosshair targeting, dynamic homing, and continuous swept-segment anti-tunneling. Unlocked Wave 2 / Level 3.
* **Catastrom (Ultimate `[F]`):** Dunks Sun into ocean to clear wave. Shared Power Up pool at 100% charge. Unlocked Wave 4.
* **Celestial Awakening (Ultimate `[F]`):** 15s super state exclusive to Kitsune Buster IX at 100% charge. 9 hydro tails, infinite water, 2.0x cooling, Creation Aura, and Ethereal Domain filter.

## 3. Rogue-lite Perks (Endless Mode)
* **Drafting:** Choose 1 of 3 randomized perk cards after boss waves. Staggered card deal entrance with rarity badges.
* **Randomized Roll Ranges:** Perks roll within bounded ranges `[min ~ max]` with proportional trade-off scaling on dual-stat perks. Maximum stat rolls display a glowing gold border and `[ MAX ROLL! ]` / `[ 최고 수치! ]` badge.
* **Diminishing Returns & Stacking UI:** Stacking 3 or more copies of the same perk incurs diminishing returns (1st & 2nd = 100%, 3rd = 75%, 4th+ = 55%). Drafting Screen cards display amber stack badges (`[ 3RD STACK · 75% ]` / `[ 3중첩 · 효율 75% ]`) and real-time recalculated effective stats.
* **HUD Tracker:** Top-left active buff icons with stack badges.
* **Stat Caps:** Cooling Power capped at 2.0x, Water Drain bounded 40%–150%, Crit at 3.0x, Heat Resist at 60%, Sun Sway floored at 40%, Tank bounded 50%–250%, Ult floored at 40%.
* **Available Perks:** High Capacity, Precision Optics, Thermal Insulator, Catastrom Flow, Heat Shield, Gravity Anchor, Glass Cannon, Heavy Water, Reckless Haste, Wind Breaker, Sub-Zero Reserve, Blade Cadence.
* **Perk Rarities:** Common (weight 70–100), Uncommon (weight 60), and Rare (Cyan/Blue badge & border, weight 20: Gravity Anchor, Thermal Insulator, Heavy Water).

## 4. Sun Mechanics & Threats
* **Dynamic Movement:** Sun sways horizontally, scaling up to complex Figure-8 patterns on high waves (sway speed capped at 1.3–1.5 for trackable combat).
* **Endgame Durability Scaling:** Post-Wave 20 in Endless Mode, Sun heat capacity scales by $+2.2\%$/wave (`MAX_TEMP * (1.0 + (wave - 20) * 0.022)`), maintaining engaging 20–32s TTK combat against stacked player perks.
* **Reactive Solar Heat Surge (Wave 25+):** Suppressing the Sun below 20% heat for $>6.0$s triggers a 1.2s Thermal Flash warning. Can be disrupted via Ice Blast (`[R]`) or Kitsune Blade, awarding +1,500 pts, a 3.5s Sun freeze stun, and a cyan shockwave ring. If uncountered, the Sun unleashes a multi-layered shockwave (+15% heat recovery, 3 spread flares, 10% water tank evaporation, radial lens distortion ripple, and 3D expanding dual TorusMesh rings).
* **Sunspots:** Glowing critical weakpoints that award bonus cooling and points.
* **Solar Flare Shield:** Endless Boss Waves (15–25). Emissive cyan energy barrier blocking water until shattered with Ice Blast (`[R]`). On Wave 30+, replaced by the Equatorial Solar Driver & Golden Drone Shield.
* **Solar Wind:** Physical crosswind pushing player crosshair (drift intensity capped at 1.75x).
* **Heat Mirage (Boss):** Spawns two decoy suns and a collective overshield across all boss waves with snappy 0.3s elastic pop-in and fast horizontal split lerp. Heat regeneration is throttled by 60% during mirages, and striking the true Sun deals 1.5x bonus damage directly to the mirage overshield.
* **High Heat Warnings:** Steam boils at 75% heat; screen pulses red and heartbeat audio plays at 85%.
* **Supernova:** Reaching 100% heat triggers a supernova cinematic and frameless stats recap.
* **"Paid in Full" Boss Overtime:** On Boss Waves (Levels 5–6, Endless every 5th wave), hitting `0:00` with banked score initiates Overtime instead of instant defeat. Score burns on an accelerating curve as emergency time, score inflow freezes, and Sun heat regen halts. Defeating the boss clears Overtime and unlocks the "Paid in Full" achievement if $\ge 5,000$ score was burned; score hitting 0 causes bankruptcy defeat.

## 5. Dynamic Weather & Encounters
* **Rainstorms:** Downpour grants infinite water and passive sun cooling.
* **Solar Eclipses:** Sky darkens; sun fires rapid Shadow Flares (occurrence chance balanced in late waves to maintain weather variety).
* **Solar Convergence:** Apex Boss encounter (Wave 30+). Equatorial Solar Driver attaches to the Sun's waist (16-ray Sunburst Corona crest, glowing incandescent core, conduits, and drone bays) while orbiting Solar Eye Drones project an invulnerable Golden Shield (throttling Sun heat regen by 50%). Drones show progressive crack damage and award water (+15%/+20%) plus ultimate charge (+5%/+8%) on destruction. Destroying all drones overloads the Driver and shatters the shield. In Phase 2, the Driver enters Overdrive, deploying a lean, fast-paced escort swarm with reactivated Golden Shield.

## 6. Environment & Visuals
* **Dynamic Ocean:** Procedural Gerstner waves, Voronoi caustics, subsurface scattering, and shimmering directional sun reflection glade with wave sparkles.
* **Rogue Waves:** Large waves crash on the island, darkening wet sand.
* **Sky & Atmosphere:** Dynamic sunset-to-twilight transition, forward Mie-scattering volumetric god rays (with serene silver-blue rays in cool twilight), airborne solar heat embers transitioning to twilight firefly motes, Belt of Venus lavender dusk band, aquamarine waterline glow, procedural Milky Way ribbon, shooting stars, and Venus star.
* **Coronal Halo & Heat Waves:** Additive coronal glow and heat ripples that breathe, pulse, and extinguish with sun temperature.
* **Sun Expressions:** Reacts dynamically to hits, crits, charging flares, Catastrom dunks, Solar Driver states (Driver Smirk and Overdrive Fury), and Paid in Full Overtime (procedural "Overtime Shock" with contracted shock pill eyes, high startled brows, round open dropped jaw, and temple sweat bead). Also integrated directly as HUD toast and banner icons.
* **Weapon & First-Person Polish:** Semi-gloss toon shading and warm sunset rim lighting on blaster models and player arms, complemented by live illuminated glass fluid reservoir canisters tracking water capacity and low-water warning pulses.
* **Low-Poly Seagulls:** Procedural 2-joint wing rig, flight physics, and reactive escape behaviors.
* **Retro Filters:** Optional post-processing shaders (Retro Colors, Dithering, PS1 Shading, Heatwave 1984).

## 7. UI & Game Feel
* **Juice:** Screen shake, drop shadows, UI scale bounces, audio ticks, and golden ember bursts on flare parries.
* **Crosshairs:** Dynamic reticles per weapon tracking water capacity. Blade mode uses katana crescent brackets.
* **Menus:** Unified gold borders, 96px margins, Gamepad navigation, fullscreen window initialization, `z_index = 50` layer elevation prioritizing all overlay menus over HUD gameplay elements, categorized Settings sections with even-number body typography, real-time numeric/percentage slider readouts (`100%`, `1.0x`), Title Screen direct Settings modal access with instant language switching, Title Screen polish (horizontal split layout with central hairline divider, semantic stat coloring, hairline mode divider, uniform button styling, muted locked Endless state, desktop `[ESC]` quit prompt, version-stamped footer), localized "PRESS ESC TO CLOSE" guidance prompts on all secondary menus, and standardized 4px Retro Flat Plate styling for Achievement and Buff cards with concentric progress bars (4px track / 3px fill).
* **Filters Screen Polish:** Standardized 16px body typography (`Inter-Medium.ttf` / `Galmuri11.ttf`) and 110x34px toggle buttons matching the Settings design system.
* **Boot Splash:** PS1-inspired intro with progressive golden border tracing and monochrome Godot logo.
* **HUD Notification (Toast) Redesign:** Right-side transient alerts (380x72px) and top-center Achievement & Buff popups (500x72px, dynamic 88px multi-line height) redesigned into Cyberpunk Arcade Plates (4px plate corner radius, 1px accent border, softened shadow, 40x40 recessed icon plates). Adheres to an even-number typography system with body font for category kickers (10px) and descriptions (12px), header font for titles (14px), 1.5px bottom auto-dismiss depletion bars, clean depletion clearance, and staggered individual dismissals.
* **Wave Timer Glide Intro & Title Clarification:** Initial wave timer fades into screen center at wave start (`scale 1.6x`, `0.25s`), holds strictly in place for `2.5s` (allowing clear reading of the live countdown), and glides smoothly across `0.85s` into the top-right HUD timer anchor with zero-pixel handoff (immediately dismissed if any modal menu opens or if paused). Title screen subtitle updated to `"COOL DOWN THE SUN BEFORE TIME RUNS OUT"` / `"제한 시간 내에 태양을 식혀라"` for explicit win/loss condition clarity.
* **Accessibility:** Full Xbox controller support with haptics/aim-assist, "Reduce Motion" toggle, and EN/KR localization.

## 8. Audio
* **Audio Ducking:** 12dB master volume drop on massive impacts (Flares, Dunks).
* **UI Audio:** Consistent -18dB 1800Hz sine sweep ticks on all interactions.
* **Custom SFX:** Dedicated CC0 recordings for drone metal hits/shatters, shield spawn/deflect/break, celestial activate/deactivate, blade slashes/draws, cannon locks, boss overdrive klaxons, and perk drafting suite.
* **Catastrom VO:** Dual-track setup (royalty-free fallback for itch.io exports, original audio for GitHub builds).
