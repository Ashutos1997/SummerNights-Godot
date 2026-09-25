# Summer Nights: Feature Documentation

This document serves as the master record for all currently implemented features, mechanics, and systems in the *Summer Nights* project.

---

## 1. Core Gameplay Loop
* **Objective:** Keep the Sun's heat below 100% until the wave timer expires.
* **Heat Mechanics:** The Sun generates heat passively; 100% heat results in a Game Over.
* **Water Management:** Shooting drains the water tank; it recharges automatically when idle.
* **Combo System:** Continuous hits build a Combo multiplier (up to 3.0x), boosting ultimate charge rate and shifting water pitch.
* **Scoring:** Points awarded for continuous hits, intercepting Solar Flares, and evaporating Magma. Multiplied by Combo meter. High scores are saved.
* **Progression:** Waves increase in difficulty (duration, heat rate, sun movement). Boss waves occur every 5th wave. Continuous water damage receives soft resistance scaling at Wave 100+ to combat endless trigger-holding.
* **Level Transitions:** Cinematic "Dying Ember" fade out, results screen, and seamless reset between waves.
* **Game Modes:** 
  * *Normal Mode:* 6 standard progression levels.
  * *Endless Mode:* Infinite survival mode (Unlocked after completing Normal Mode).

## 2. Weapons & Tools
* **Weapon Wheel:** Slows time to 0.2x to swap weapons with subtle 4px depth shadows, uniform 12px gap spacing, and hover tick audio. Features an arcade-style bottom readout panel with archetype badges, cooling power/water capacity mini-gauge bars, and critical hit multipliers. Firing is blocked during swap animations. Hazard timers pause while open.
* **Available Weapons:**
  * *Standard Blaster:* Balanced.
  * *Precision Stream:* Low capacity, high critical multiplier.
  * *Heavy Cannon:* High capacity, massive cooling, rapid drain.
  * *Scatter Nozzle:* Wide spray for multi-target intercepts.
  * *Tidal Gatling:* Extreme cooling/drain burst weapon.
* **Ice Burst (Secondary):** Instantly freezes sun heat generation and movement. Unlocked on Wave 2 (Endless) / Level 3 (Campaign). Tracked via a unified 200x24 cyan-frost meter with discrete charge notches and numerical counter.
* **Catastrom (Ultimate):** Grab the sun and dunk it into the ocean to instantly clear the wave. Unlocked on Wave 4 (Endless) / Level 4 (Campaign) with a dedicated unlock banner toast; charge gain is disabled until unlocked.

## 3. Rogue-lite Perks (Endless Mode)
* **Drafting:** After every boss wave, choose 1 of 3 randomized perks. Features staggered card deal entrance animation with sound ticks, 6px drop shadows, and rarity tags (`[ RARE ]`, `[ UNCOMMON ]`, `[ COMMON ]`).
* **Active HUD:** Real-time active buff tracker on the top-left HUD (duplicates stack visually).
* **Stat Caps & Safety Bounds:** Hard caps and floors maintain high-wave balance (Cooling Power capped at 3.5x, Crit Damage at 3.0x, Heat Resistance capped at 60%, Sun Sway floored at 40% speed, Water Tank bounded between 50%-250%, and Catastrom charge floored at 40%).
* **Perks Include:** High Capacity (+15% Water), Precision Optics (+15% Crit), Thermal Insulator (+10% Cooling), Catastrom Flow (+15% Ult Charge), Heat Shield (+5% Resist), Gravity Anchor (Reduces Sun Sway), Glass Cannon, Heavy Water, Reckless Haste.

## 4. Sun Mechanics & Threats
* **Dynamic Movement:** Sun sways horizontally, adopting complex "Figure-8" patterns on higher waves. Speed and heat scaling continue progressively up to Wave 50.
* **Sunspots:** Glowing critical weakpoints that offer massive cooling and points when hit.
* **Solar Flare Shield:** In Endless Mode, appears exclusively on Boss Waves starting at Wave 15 (Waves 15, 20, 25, 30...). The Sun periodically generates an emissive procedural energy shield (Fresnel glow with subtle hexagonal tech grid) that completely nullifies water damage. Accompanied by an elastic scale-up spawn tween and materialize audio (`shield_spawn.wav`). When struck by water, the shield produces localized expanding shockwave ripples in the shader, backward-deflecting water splash particles (`GPUParticles3D`), floating `"DEFLECTED"` combat feedback, and dedicated hydro-repellent water deflection audio (`shield_deflect.wav`), prompting the player to shatter it using Ice Blast (`[R]`). Shattering triggers outward fragmentation particles, hit-stop screen shake, and dedicated CC0 shatter audio (`shield_break.ogg`).
* **Solar Wind:** Physical wind that pushes player crosshairs sideways.
* **Heat Mirage (Boss):** Spawns two decoy suns and a collective Overshield that must be broken.
* **High Heat Warnings:** Sun boils steam at 75% heat; screen pulses red and heartbeat plays at 85% heat.
* **Supernova (Game Over):** Reaching 100% heat triggers a dramatic supernova explosion cinematic followed by a clean frameless stats recap (32x32 retro plates with gold monochrome icons, localized labels, values, and milestone badges). *(Known Issue: End-of-run Win and Lose screens currently render darker than intended; under active investigation.)*

## 5. Dynamic Weather
* **Rainstorms:** Massive downpour provides infinite water and passive sun cooling.
* **Solar Eclipses:** Sky darkens, sun fires rapid "Shadow Flares" that must be intercepted.

## 6. Environment & Visuals
* **Dynamic Ocean:** Procedural Gerstner waves, Voronoi caustics, and subsurface scattering.
* **Rogue Waves:** Massive waves crash onto the island, temporarily darkening the wet sand.
* **Sky & Atmosphere:** Day/night cycles, depth-parallax drifting clouds, procedural starfields, and bloom.
* **Coronal Halo & Heat Waves:** Unshaded additive coronal halo with concentric heat ripples and stylized low-poly corona ring that dynamically breathe, pulse, and extinguish as the Sun cools down (100°C to 0°C).
* **Sun Expressions:** Sun face reacts dynamically to damage, critical hits, charging flares, and Catastrom dunks.
* **Articulated Low-Poly Seagulls:** Procedural seagulls with 2-joint wing rigging (aerodynamic folding), flight physics, orbital banking, beach foraging, and reactive escape behaviors.
* **Retro Filters:** Optional post-processing shaders (Retro Colors, Dithering, PS1 Shading, Heatwave 1984).

## 7. UI & Game Feel
* **Juice:** Screen shake on impacts, dynamic drop shadows, bouncing UI elements, UI audio ticks, and golden ember bursts on flare interceptions.
* **Crosshairs:** Dynamic diegetic crosshairs for each weapon that track water capacity visually.
* **Achievements & Buffs:** 12 unlockable achievements with live HUD progress tracking, 64x64 retro flat plates with mystery silhouettes, permanent stat buffs, and lifetime stat tracking.
* **Endless Wave & Best Wave Tracking:** Persistent tracking of highest Endless wave reached, displayed on Title Screen, Stats modal, and Game Over screen.
* **Menus:** Unified golden borders, 96px margins, centered/left-aligned layouts, full Gamepad navigation, and compact categorized Settings sections with tactile retro plate badges and off-white row typography.
* **Custom "Made with Godot" Boot Splash:** Bespoke intro sequence with golden border drawing, monochrome Godot logo, PS1 synth swell audio, and curtain reveal.
* **Accessibility:** Full Xbox Controller support with haptics/aim-assist, "Reduce Motion" setting, and EN/KR localization.

## 8. Audio
* **Audio Ducking:** 12dB master volume drop on massive impacts (Flares, Dunks) for shockwave effect.
* **Synthesized UI Sounds:** Consistent -18dB 1800Hz sine sweep ticks for all UI interactions.
* **Shield Materialize SFX:** Dedicated CC0 energy shield spawn audio (`shield_spawn.wav` by bart) with subtle pitch randomization playing as the procedural shield materializes.
* **Shield Deflection SFX:** Dedicated hydro-repellent barrier deflection audio (`shield_deflect.wav`) featuring a punchy water impact slap and rapid droplet dispersal with zero glass/metallic ringing, throttled for rapid-fire automatic weapons.
* **Shield Shatter SFX:** Dedicated CC0 high-impact shatter audio (`shield_break.ogg` by IgnasD) with subtle pitch randomization upon Ice Blast shield break.
* **Catastrom VO:** Royalty-free fallback for itch.io exports, original audio for GitHub builds.
