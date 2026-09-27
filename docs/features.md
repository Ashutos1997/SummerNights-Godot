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
  * *Kitsune Buster IX:* Endless Wave 30 pinnacle unlock (160 cap, 28 cooling, 14/s recharge, 2.2x crit). Toggles with `[X]` / MMB:
    * *Cannon Mode:* Precision stream with revolving 9-vial Kyubi cylinder, liquid slosh inertia, and dynamic vial pulsation.
    * *Blade Mode:* Katana melee strike (60° arc, 8.5m range, 8.5 cooling). Cleaves solar flares for +15% water parry refund and damages/shatters Solar Eye Drones (~2 hits, 1-hit core crit/Awakened). Emits a golden Foxfire slash wave.
* **Ice Burst (Secondary `[R]`):** Freezes heat gain and sun movement. Unlocked Wave 2 / Level 3. Tracked via a 200x24 notched meter.
* **Catastrom (Ultimate `[F]`):** Dunks the Sun into the ocean to clear the wave. Triggered from shared Power Up pool at 100% charge with purple toast alert ("CATASTROM READY"). Unlocked Wave 4.
* **Celestial Awakening (Ultimate `[F]`):** 15s super state exclusive to Kitsune Buster IX at 100% charge. Reaching 100% shows cyan toast alert ("CELESTIAL AWAKENING READY"). Swapping weapons preserves charge. Spawns 9 hydro-ribbon tails, infinite water, 2.0x cooling, 5.5m flare-clearing Creation Aura, Ethereal Domain filter, and 360° reticle timer ring.

## 3. Rogue-lite Perks (Endless Mode)
* **Drafting:** Choose 1 of 3 randomized perk cards after boss waves. Staggered card deal entrance with rarity badges.
* **HUD Tracker:** Top-left active buff icons with stack badges.
* **Stat Caps:** Cooling Power capped at 3.5x, Crit at 3.0x, Heat Resist at 60%, Sun Sway floored at 40%, Tank bounded 50%–250%, Ult floored at 40%.
* **Available Perks:** High Capacity, Precision Optics, Thermal Insulator, Catastrom Flow, Heat Shield, Gravity Anchor, Glass Cannon, Heavy Water, Reckless Haste.

## 4. Sun Mechanics & Threats
* **Dynamic Movement:** Sun sways horizontally, scaling up to complex Figure-8 patterns on high waves.
* **Sunspots:** Glowing critical weakpoints that award bonus cooling and points.
* **Solar Flare Shield:** Endless Boss Waves (15+). Emissive energy barrier blocking water. Shattered with Ice Blast (`[R]`).
* **Solar Wind:** Physical crosswind pushing player crosshair.
* **Heat Mirage (Boss):** Spawns two decoy suns and a collective overshield.
* **High Heat Warnings:** Steam boils at 75% heat; screen pulses red and heartbeat audio plays at 85%.
* **Supernova:** Reaching 100% heat triggers a supernova cinematic and frameless stats recap.

## 5. Dynamic Weather & Encounters
* **Rainstorms:** Downpour grants infinite water and passive sun cooling.
* **Solar Eclipses:** Sky darkens; sun fires rapid Shadow Flares.
* **Solar Convergence — Orbital Ocular Swarm (Phase 1):** Apex Boss Wave (Wave 20+). 6–8 Solar Eye Drones orbit the Sun ($R = 11.8\text{m}–12.8\text{m}$, Sun at $Y = 13.5$), shielding it from direct water cooling. Features multi-tier crack damage: Stage 1 hairline fissures (≤65% HP) and Stage 2 solar amber fractures with leaking coolant steam (≤35% HP, strobe ≤18%). Plating preserves Sun-Gold & Pearl Ivory without red tinting. Destroying a drone vents coolant (+15% water tank, +20% on Ice Shatter). Ice Blast triggers a 6.5m AOE shatter. Debug toggle: `[O]`.
* **Solar Convergence — Equatorial Solar Driver & Planetary Belt (Milestone 2):** Custom low-poly 3D Driver & Belt model (`assets/models/solar_driver.glb`, $R \approx 7.15\text{m}$) mounted to the Sun's lower waist ($Y = -3.85\text{m}$, tilted 14° towards the beach camera, keeping the face completely clear). Features an obsidian chassis, beveled Sun-Gold frames, Shinto crimson inlays, lateral eye-drone docking bays ($X = \pm 1.95\text{m}$) with cyan LED alignment rails, and a breathing amber iris core. Includes authentic Tokusatsu wearing (dual ribbon sweep + magnetic buckle slam + shockwave flash + screen shake) and taking off (unlatch click + buckle spring pop + ribbon peel dissolution) animations. Debug toggle: `[L]`.
* **Solar Convergence — The Sun's Henshin Escalation (Milestone 3):** Apex transformation sequence triggered when the player destroys all orbital eye drones (or via `[P]` debug trigger). The Sun reels in shock, scales up in solar fury, and snaps its Equatorial Planetary Driver shut. Culminates in the slam assembly of the monolithic **Kamen Rider Apex Helmet** (`assets/models/solar_helmet.glb`, featuring solid cranial dome, high-rising Sun-Gold V-crest horns, faceted ruby compound eye visors, and a 4-tier horizontal crusher mouth plate fully encapsulating the Sun's face) with hydraulic clamp lock, cheek steam blasts, radial shockwaves, and clean HUD. Debug trigger: `[P]`.

## 6. Environment & Visuals
* **Dynamic Ocean:** Procedural Gerstner waves, Voronoi caustics, and subsurface scattering.
* **Rogue Waves:** Large waves crash on the island, darkening wet sand.
* **Sky & Atmosphere:** Day/night cycles, parallax depth clouds, starfields, and bloom.
* **Coronal Halo & Heat Waves:** Additive coronal glow and heat ripples that breathe, pulse, and extinguish with sun temperature.
* **Sun Expressions:** Reacts dynamically to hits, crits, charging flares, and Catastrom dunks.
* **Low-Poly Seagulls:** Procedural 2-joint wing rig, flight physics, and reactive escape behaviors.
* **Retro Filters:** Optional post-processing shaders (Retro Colors, Dithering, PS1 Shading, Heatwave 1984).

## 7. UI & Game Feel
* **Juice:** Screen shake, drop shadows, UI scale bounces, audio ticks, and golden ember bursts on flare parries.
* **Crosshairs:** Dynamic reticles per weapon tracking water capacity. Blade mode uses katana crescent brackets.
* **Achievements:** 13 unlockable achievements with live HUD progress tracking, retro plates, and permanent stat buffs.
* **Menus:** Unified gold borders, 96px margins, Gamepad navigation, and categorized Settings sections.
* **Boot Splash:** PS1-inspired intro with progressive golden border tracing and monochrome Godot logo.
* **Accessibility:** Full Xbox controller support with haptics/aim-assist, "Reduce Motion" toggle, and EN/KR localization.

## 8. Audio
* **Audio Ducking:** 12dB master volume drop on massive impacts (Flares, Dunks).
* **UI Audio:** Consistent -18dB 1800Hz sine sweep ticks on all interactions.
* **Custom SFX:** Dedicated CC0 recordings for drone metal hits/shatters, shield spawn/deflect/break, celestial activate/deactivate, and blade slashes.
* **Catastrom VO:** Dual-track setup (royalty-free fallback for itch.io exports, original audio for GitHub builds).
