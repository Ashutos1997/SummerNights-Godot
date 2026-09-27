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
  * *Kitsune Buster IX:* Endless Wave 30 pinnacle unlock (160 cap, 28 cooling, 14/s recharge, 2.2x crit). Toggles with `[X]` / Controller `[Y]` / MMB:
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
* **Solar Convergence — Equatorial Driver & Orbital Swarm:** Apex Boss Encounter (Wave 20+ / toggle `[O]` or `[L]`). When the swarm initiates, the **Equatorial Solar Driver Buckle** rushes in laterally from the side flank and slams onto the Sun's waist ($Y = -3.85\text{m}$, tilted 14°, leaving the Sun's expressive 2D cartoon face completely visible and unobstructed) with a magnetic `CLACK!`, flaring its breathing amber core as golden planetary belt ribbons sweep around the equator. **Simultaneously**, 6–8 Solar Eye Drones deploy outward from the belt into coronal orbit ($R = 14.6\text{m}–16.0\text{m}$), and a radiant 10m **Golden Drone Shield** envelops the Sun. Shooting the Sun deflects attacks with golden ripples and prompts a tactical warning ("SHOOT THE DRONES FIRST!"). Drones feature multi-tier crack damage (≤65% hairline fissures, ≤35% glowing fractures with coolant steam) and grant +15% water refund upon destruction (+20% on Ice Shatter). Neutralizing all drones overloads the Driver and shatters the golden shield, leaving the Sun vulnerable to direct cooling.

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
