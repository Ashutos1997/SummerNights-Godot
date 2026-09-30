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
* **HUD Tracker:** Top-left active buff icons with stack badges.
* **Stat Caps:** Cooling Power capped at 2.0x, Water Drain bounded 40%–150%, Crit at 3.0x, Heat Resist at 60%, Sun Sway floored at 40%, Tank bounded 50%–250%, Ult floored at 40%.
* **Available Perks:** High Capacity, Precision Optics, Thermal Insulator, Catastrom Flow, Heat Shield, Gravity Anchor, Glass Cannon, Heavy Water, Reckless Haste, Wind Breaker, Sub-Zero Reserve, Blade Cadence.
* **Perk Rarities:** Common (weight 70–100), Uncommon (weight 60), and Rare (Cyan/Blue badge & border, weight 20: Gravity Anchor, Thermal Insulator, Heavy Water).

## 4. Sun Mechanics & Threats
* **Dynamic Movement:** Sun sways horizontally, scaling up to complex Figure-8 patterns on high waves (sway speed capped at 1.3–1.5 for trackable combat).
* **Sunspots:** Glowing critical weakpoints that award bonus cooling and points.
* **Solar Flare Shield:** Endless Boss Waves (15–25). Emissive cyan energy barrier blocking water until shattered with Ice Blast (`[R]`). On Wave 30+, replaced by the Equatorial Solar Driver & Golden Drone Shield.
* **Solar Wind:** Physical crosswind pushing player crosshair (drift intensity capped at 1.75x).
* **Heat Mirage (Boss):** Spawns two decoy suns and a collective overshield across all boss waves with snappy 0.3s elastic pop-in and fast horizontal split lerp. Heat regeneration is throttled by 60% during mirages, and striking the true Sun deals 1.5x bonus damage directly to the mirage overshield.
* **High Heat Warnings:** Steam boils at 75% heat; screen pulses red and heartbeat audio plays at 85%.
* **Supernova:** Reaching 100% heat triggers a supernova cinematic and frameless stats recap.

## 5. Dynamic Weather & Encounters
* **Rainstorms:** Downpour grants infinite water and passive sun cooling.
* **Solar Eclipses:** Sky darkens; sun fires rapid Shadow Flares (occurrence chance balanced in late waves to maintain weather variety).
* **Solar Convergence:** Apex Boss encounter (Wave 30+). Equatorial Solar Driver attaches to the Sun's waist (16-ray Sunburst Corona crest, glowing incandescent core, conduits, and drone bays) while orbiting Solar Eye Drones project an invulnerable Golden Shield (throttling Sun heat regen by 50%). Drones show progressive crack damage and award water (+15%/+20%) plus ultimate charge (+5%/+8%) on destruction. Destroying all drones overloads the Driver and shatters the shield. In Phase 2, the Driver enters Overdrive, deploying a lean, fast-paced escort swarm with reactivated Golden Shield.

## 6. Environment & Visuals
* **Dynamic Ocean:** Procedural Gerstner waves, Voronoi caustics, and subsurface scattering.
* **Rogue Waves:** Large waves crash on the island, darkening wet sand.
* **Sky & Atmosphere:** Dynamic sunset-to-twilight transition with Belt of Venus lavender-pink dusk band, luminous aquamarine waterline glow, procedural Milky Way stardust ribbon, periodic shooting stars, crystalline Evening Star (Venus), moonlit silver-cyan rimmed clouds, and temperature-reactive ocean specular reflection.
* **Coronal Halo & Heat Waves:** Additive coronal glow and heat ripples that breathe, pulse, and extinguish with sun temperature.
* **Sun Expressions:** Reacts dynamically to hits, crits, charging flares, Catastrom dunks, and equips dedicated Apex Boss expressions (Driver Smirk and Overdrive Fury with forehead coronal crests) during Wave 30+ Solar Convergence. Also integrated directly as HUD toast and banner icons for Driver Equipped and Phase 2 Overdrive events.
* **Low-Poly Seagulls:** Procedural 2-joint wing rig, flight physics, and reactive escape behaviors.
* **Retro Filters:** Optional post-processing shaders (Retro Colors, Dithering, PS1 Shading, Heatwave 1984).

## 7. UI & Game Feel
* **Juice:** Screen shake, drop shadows, UI scale bounces, audio ticks, and golden ember bursts on flare parries.
* **Crosshairs:** Dynamic reticles per weapon tracking water capacity. Blade mode uses katana crescent brackets.
* **Achievements:** 13 unlockable achievements with live HUD progress tracking, retro plates, and permanent stat buffs.
* **Menus:** Unified gold borders, 96px margins, Gamepad navigation, fullscreen window initialization, categorized Settings sections with even-number body typography, real-time numeric/percentage slider readouts (`100%`, `1.0x`), Title Screen direct Settings modal access with instant language switching, balanced Title Screen vertical distribution with standardized button spacing, and localized "PRESS ESC TO CLOSE" guidance prompts on all secondary menus.
* **Filters Screen Polish:** Standardized 16px body typography (`Inter-Medium.ttf` / `Galmuri11.ttf`) and 110x34px toggle buttons matching the Settings design system.
* **Boot Splash:** PS1-inspired intro with progressive golden border tracing and monochrome Godot logo.
* **Accessibility:** Full Xbox controller support with haptics/aim-assist, "Reduce Motion" toggle, and EN/KR localization.

## 8. Audio
* **Audio Ducking:** 12dB master volume drop on massive impacts (Flares, Dunks).
* **UI Audio:** Consistent -18dB 1800Hz sine sweep ticks on all interactions.
* **Custom SFX:** Dedicated CC0 recordings for drone metal hits/shatters, shield spawn/deflect/break, celestial activate/deactivate, blade slashes/draws, cannon locks, boss overdrive klaxons, and perk drafting suite.
* **Catastrom VO:** Dual-track setup (royalty-free fallback for itch.io exports, original audio for GitHub builds).
