# Summer Nights: Feature Documentation

This document serves as the master record for all currently implemented features, mechanics, and systems in the *Summer Nights* project.

---

## 1. Core Gameplay Loop
* **Objective:** Keep the Sun's heat below 100% until the wave timer expires.
* **Heat Mechanics:** The Sun generates heat passively; 100% heat results in a Game Over.
* **Water Management:** Shooting drains the water tank; it recharges automatically when idle.
* **Combo System:** Continuous hits build a Combo multiplier (up to 3.0x), boosting ultimate charge rate and shifting water pitch.
* **Scoring:** Points awarded for continuous hits, intercepting Solar Flares, and evaporating Magma. Multiplied by Combo meter. High scores are saved.
* **Progression:** Waves increase in difficulty (duration, heat rate, sun movement). Boss waves occur every 5th wave.
* **Level Transitions:** Cinematic "Dying Ember" fade out, results screen, and seamless reset between waves.
* **Game Modes:** 
  * *Normal Mode:* 6 standard progression levels.
  * *Endless Mode:* Infinite survival mode (Unlocked after completing Normal Mode).

## 2. Weapons & Tools
* **Weapon Wheel:** Slows time to 0.2x to swap weapons with subtle 4px depth shadows. Firing is blocked during swap animations. Hazard timers pause while open.
* **Available Weapons:**
  * *Standard Blaster:* Balanced.
  * *Precision Stream:* Low capacity, high critical multiplier.
  * *Heavy Cannon:* High capacity, massive cooling, rapid drain.
  * *Scatter Nozzle:* Wide spray for multi-target intercepts.
  * *Tidal Gatling:* Extreme cooling/drain burst weapon.
* **Ice Burst (Secondary):** Instantly freezes sun heat generation and movement.
* **Catastrom (Ultimate):** Grab the sun and dunk it into the ocean to instantly clear the wave.

## 3. Rogue-lite Perks (Endless Mode)
* **Drafting:** After every boss wave, choose 1 of 3 randomized perks.
* **Active HUD:** Track drafted perks in the top-left HUD (duplicates stack visually).
* **Perks Include:** High Capacity (+15% Water), Precision Optics (+15% Crit), Thermal Insulator (+10% Cooling), Catastrom Flow (+15% Ult Charge), Heat Shield (+5% Resist), Gravity Anchor (Reduces Sun Sway), Glass Cannon, Heavy Water, Reckless Haste.

## 4. Sun Mechanics & Threats
* **Dynamic Movement:** Sun sways horizontally, adopting complex "Figure-8" patterns on higher waves.
* **Sunspots:** Glowing critical weakpoints that offer massive cooling and points when hit.
* **Solar Flares:** Fireballs that must be intercepted. Missing triggers scaling heat/water penalties and breaks combos.
* **Solar Wind:** Physical wind that pushes player crosshairs sideways.
* **Heat Mirage (Boss):** Spawns two decoy suns and a collective Overshield that must be broken.
* **High Heat Warnings:** Sun boils steam at 75% heat; screen pulses red and heartbeat plays at 85% heat.
* **Supernova (Game Over):** Reaching 100% heat triggers a dramatic supernova explosion cinematic.

## 5. Dynamic Weather
* **Rainstorms:** Massive downpour provides infinite water and passive sun cooling.
* **Solar Eclipses:** Sky darkens, sun fires rapid "Shadow Flares" that must be intercepted.

## 6. Environment & Visuals
* **Dynamic Ocean:** Procedural Gerstner waves, Voronoi caustics, and subsurface scattering.
* **Rogue Waves:** Massive waves crash onto the island, temporarily darkening the wet sand.
* **Sky & Atmosphere:** Day/night cycles, parallax clouds, procedural starfields, and cinematic bloom.
* **Sun Expressions:** Sun face reacts dynamically to being hit, critical hits, charging flares, and Catastrom dunks.
* **Seagulls & Fireflies:** React dynamically to weather events (Rain, Eclipse, Wind).
* **Retro Filters:** Optional post-processing shaders (Retro Colors, Dithering, PS1 Shading, Heatwave 1984).

## 7. UI & Game Feel
* **Juice:** Screen shake on impacts, dynamic drop shadows, scaling/bouncing UI elements, UI audio ticks.
* **Crosshairs:** Dynamic diegetic crosshairs for each weapon that track water capacity visually.
* **Achievements & Buffs:** In-game achievement tracking that unlocks permanent buffs and tracks lifetime stats.
* **Menus:** Unified golden borders, 96px margins, centered/left-aligned layouts, and full Gamepad navigation.
* **Accessibility:** Full Xbox Controller support with haptics/aim-assist, "Reduce Motion" setting, and EN/KR localization.

## 8. Audio
* **Audio Ducking:** 12dB master volume drop on massive impacts (Flares, Dunks) for shockwave effect.
* **Synthesized UI Sounds:** Consistent -18dB 1800Hz sine sweep ticks for all UI interactions.
* **Catastrom VO:** Royalty-free fallback for itch.io exports, original audio for GitHub builds.
