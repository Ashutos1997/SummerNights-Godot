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
* **Weapon Wheel:** Slows time to 0.2x to swap weapons with subtle 4px depth shadows, uniform 12px gap spacing, and hover tick audio. Displays 3D weapon previews centered in each slice (Kitsune Buster IX uses its compact blaster model for clean slice fit). Features an arcade-style bottom readout panel with archetype badges, cooling power/water capacity mini-gauge bars, and critical hit multipliers. Firing is blocked during swap animations. Hazard timers pause while open.
* **Available Weapons:**
  * *Standard Blaster:* Balanced.
  * *Precision Stream:* Low capacity, high critical multiplier.
  * *Heavy Cannon:* High capacity, massive cooling, rapid drain.
  * *Scatter Nozzle:* Wide spray for multi-target intercepts.
  * *Kitsune Buster IX:* High-tier celestial buster unlocked at Endless Wave 30 (160 cap, 28 cooling power, 14/s recharge) with seamless dual-mode transformation:
    * *Cannon Mode:* Continuous high-precision stream with extended faceted barrel, tri-prong magnetic focus muzzle calipers, dynamic pulsating hydro-coolant lines, and translucent revolving Kyubi chamber with 9 breathing cyan vials (automatic continuous spin acceleration on fire and blade slash with smooth viscous spin-down; liquid slosh inertia with pitch/yaw tilt and fluid displacement responding to camera angular momentum; surges to 10 rad/s while firing; shifts to warning amber at <25% water; overcharges with radiant bloom during Celestial Awakening), holding the line against Wave 30 heat regen (28°C/s) with a 2.2x crit multiplier.
    * *Blade Mode:* Heavenly Katana melee transformation with authentic curved Katana sori (1.37m reach, 7.6cm tapering height), mirror-polished tamahagane steel finish, undulating luminescent Hamon tempering ribbon, stepped gold Habaki with bronze Seppa spacers, cyan plasma cutting edge, sculpted multi-layered fox-flame tsuba crossguard, 60° sweeping melee arc (8.5m range), solar flare parry with 15% water refund, and direct cooling strike on Sun ($8.5\text{ base} \times \text{crit} \times \text{cooling}$). Projects a razor-sharp golden-white Celestial Foxfire Slash Wave with trailing spark embers toward the crosshair for clear emission feedback. Toggled with `[X]`, Middle Mouse, or Controller `[X]` with fluid real-time mechanical transformation (revolving Kyubi cylinder spin, barrel retraction, unfolding tsuba wings, telescoping blade, and dynamic Katana guard stance morph).
* **Ice Burst (Secondary):** Instantly freezes sun heat generation and movement. Unlocked on Wave 2 (Endless) / Level 3 (Campaign). Tracked via a unified 200x24 cyan-frost meter with discrete charge notches and numerical counter.
* **Catastrom (Ultimate):** Grab the sun and dunk it into the ocean to instantly clear the wave. Triggered with `[F]` on standard weapons 1-5 from a shared Power Up charge pool. Unlocked on Wave 4 (Endless) / Level 4 (Campaign) with a dedicated unlock banner toast; charge gain is disabled until unlocked. Triggering Catastrom drains the shared charge pool to 0%.
* **Celestial Awakening (Nine Tails):** 15-second super state exclusive to the Kitsune Buster IX triggered with `[F]` when the shared Power Up charge reaches 100% (replaces Catastrom entirely while wielding Kitsune; Kitsune cannot trigger Catastrom). Fills via Sun water hits, sunspot crits, flare parries, and blade strikes into the unified Power Up pool; swapping between weapons preserves the exact charge level across both modes. When equipped, the HUD gauge dynamically swaps to a radiant cyan Celestial Awakening meter with a dedicated starburst icon (`meter_celestial.svg`), displaying charging progress, a pulsing ready prompt, and active remaining duration. Triggering either Catastrom or Celestial Awakening resets the shared pool to 0%, requiring a fresh recharge. Generates 9 procedural cyan/white hydro-ribbon tails cascading from an overhead celestial canopy (staggered bloom, traveling waves, 3D twist, aim inertia). While active, transforms Cannon fire into a 9-stream converging helical hydro-cannon with infinite capacity (tank locked at 100%), 2.0x cooling power, and a 5.5m Creation Aura that vaporizes incoming solar flares with `+REWRITE!` combat feedback. In Blade Mode, empowers strikes with 1.5x damage, cleaves incoming solar flares, and projects an empowered Celestial Foxfire Slash Wave with expanded wingspan and intensified core luminescence. Triggers a dedicated "Ethereal Domain" 3D post-processing filter (0.45s expanding Tokusatsu Henshin spacetime shockwave, horizontal anamorphic cyan lens flares on peak emissives, deep midnight indigo shadows, optical highlight bloom, and peripheral spacetime refraction) rendered on Layer 0 below the HUD (strictly mode-exclusive and unavailable in standard filter menus). Features a breathing cyan energy vignette aura (`celestial_vignette.gdshader`) with drifting procedural particle motes around screen edges (shifts to amber at ≤3.0s), a full 360° depleting crosshair timer ring ($R = 38\text{px}$) with kitsune bloom diamond accent, cyan-tinted floating damage numbers, breathing weapon plate border glow, and holographic cyan text shadows on LVL/TIME/SCORE. Swapping away from the Kitsune Buster immediately deactivates the awakening.

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
* **Solar Convergence — Orbital Ocular Swarm (Phase 1):** Apex Boss Wave mechanic (Wave 20+) deploying 6–8 stylized arcade Solar Eye drones orbiting the Sun's perimeter at an expanded non-clipping orbital radius ($R = 12.4\text{m} - 13.8\text{m}$, speed $0.85 - 1.15\text{ rad/s}$). Designed in the game's vibrant retro anime aesthetic featuring radiant Sun-Gold & Pearl Ivory armor plates, warm bronze chassis, incandescent glowing amber-gold solar pupil with breathing pulsation, active cyan plasma thrusters, toon shading, and golden sunset rim lighting. While drones are active, the Sun is completely shielded from direct cooling damage (`_on_shield_deflect`). Drone HP scales dynamically with wave progression ($35.0 + \text{Wave} \times 3.5$, 140 HP at Wave 30). Destroying a drone vents trapped coolant, refunding **+15% water tank capacity** (+20% on Ice Shatter) and awarding points. Ice Blast triggers a **6.5m cryogenic AOE shockwave** shattering all drones within blast range. Debug toggle with `[O]`.

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
* **Achievements & Buffs:** 13 unlockable achievements with live HUD progress tracking, 64x64 retro flat plates with mystery silhouettes, permanent stat buffs, and lifetime stat tracking.
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
* **Celestial Awakening SFX:** Dedicated CC0 audio cues featuring an anime Henshin ki-charge swell (`celestial_activate.wav` by TheLittleCrow) on activation and a decelerating sci-fi cooldown dissipation (`celestial_deactivate.wav` by bevibeldesign) on deactivation or timer expiry, with mutual playback cancellation.
* **Celestial Slash SFX:** Dedicated CC0 sword swing audio (`celestial_slash.wav` by Nomagician) with dynamic pitch scaling for Kitsune Blade melee slashes.
* **Catastrom VO:** Royalty-free fallback for itch.io exports, original audio for GitHub builds.
