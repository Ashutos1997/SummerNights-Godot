# Summer Nights: Feature Documentation

Master record of implemented features, mechanics, and systems in *Summer Nights*.

---

## 1. Core Gameplay Loop
* **Objective:** Keep the Sun's heat below 100% until the wave timer expires.
* **Heat:** Passively generates heat; reaching 100% triggers Supernova (Game Over).
* **Water:** Firing drains water tank; recharges automatically when idle.
* **Combo:** Consecutive hits scale multiplier (up to 3.0x), boosting ultimate charge and audio pitch.
* **Scoring:** Points for hits, flare intercepts, and magma evaporation, scaled by combo. High scores save locally.
* **Progression:** 6 Normal Mode levels; Endless Mode unlocks on completion. Bosses occur every 5 waves.
* **Transitions:** "Dying Ember" fade out, score recap, and seamless wave resets.

## 2. Weapons & Tools
* **Weapon Wheel (`TAB`):** 0.2x slow-mo. Shows 3D preview, archetype tags, cooling/capacity stats, and crit multipliers.
* **Arsenal:**
  * *Standard Blaster:* Balanced starter weapon.
  * *Precision Stream:* High crit multiplier, low capacity.
  * *Heavy Cannon:* High capacity, heavy cooling, rapid drain.
  * *Scatter Nozzle:* Wide spray for multi-target flare intercepts.
  * *Kitsune Buster IX:* Endless Wave 30 unlock (160 cap, 28 cool, 2.2x crit). Mode toggle (`[X]` / `[Y]` / MMB):
    * *Cannon Mode:* Precision stream with revolving 9-vial cylinder.
    * *Blade Mode:* Katana slash (60° arc, 8.5m range). Cleaves flares for +15% water, damages drones and Sun.
  * *Gold Weapon Skin:* Unlocked at 50k High Score. Toggle under Settings > Display.
* **Ice Burst (`[R]`):** Freezes heat gain and Sun movement for 3s. Unlocked Level 3 / Wave 2.
* **Catastrom (`[F]`):** Dunks Sun into ocean to clear wave. Shared meter at 100% charge. Unlocked Wave 4.
* **Celestial Awakening (`[F]`):** 15s super mode for Kitsune Buster IX (9 hydro tails, infinite water, 2.0x cooling).

## 3. Rogue-lite Perks (Endless Mode)
* **Drafting:** Choose 1 of 3 perk cards after boss waves. Rarity tiers: Common, Uncommon, Rare.
* **Roll Ranges:** Randomized stat rolls within `[min ~ max]`. Max rolls show `[ MAX ROLL! ]` gold badge.
* **Diminishing Returns:** Stacking 3+ copies scales efficiency (1st/2nd = 100%, 3rd = 75%, 4th+ = 55%) with amber stack badge.
* **Tracker:** Top-left active buff icons with stack badges.
* **Stat Caps:** Cooling (2.0x), Drain (40%–150%), Crit (3.0x), Heat Resist (60%), Sway (floor 40%), Tank (50%–250%), Ult (floor 40%), Refill (40%–150%), Base Cooling (floor 50%).
* **Perk Pool:** High Capacity, Precision Optics, Thermal Insulator, Catastrom Flow, Heat Shield, Gravity Anchor, Glass Cannon, Heavy Water, Reckless Haste, Wind Breaker, Sub-Zero Reserve, Blade Cadence, Solar Overclock, High-Pressure Bore, Hyper-Focus, Deep Reservoir.

## 4. Sun Mechanics & Threats
* **Movement:** Horizontal sway and Figure-8 paths (speed capped at 1.3–1.5).
* **Durability Scaling:** Post-Wave 20 Endless scales heat capacity by +2.2%/wave (`MAX_TEMP * (1.0 + (wave - 20) * 0.022)`).
* **Thermal Falloff:** Spraying a single spot for >3.0s degrades cooling efficiency to 70%. Moving aim (distance >= 1.0) or releasing trigger resets to 100%.
* **Sunspots:** Glowing critical weakpoints awarding bonus cooling and points.
* **Solar Flare Shield:** Cyan energy barrier (Endless Waves 15–25) shattered by Ice Blast (`[R]`).
* **Solar Disruptions (Wave 6+):** Random micro-events (40%–60% chance) in non-boss waves:
  * *Thermal Barrier:* Cyan shield deflecting water; dissolves or shatters via Ice Blast for +1,000 pts.
  * *Flare Barrage:* Rapid volley of 5–7 solar flares across wide angles.
* **Solar Wind:** Physical crosswind pushing crosshair (drift capped at 1.75x).
* **Heat Mirage (Boss):** Spawns 2 decoys and overshield. Real Sun takes 1.5x damage to overshield; heat regen cut by 60%.
* **Overtime ("Paid in Full"):** Boss Waves (Levels 5–6, Endless every 5th) hitting `0:00` burn score as life support. Defeating boss clears Overtime; zero score triggers bankruptcy defeat.

## 5. Dynamic Weather & Encounters
* **Rainstorms:** Grants infinite water and passive Sun cooling.
* **Solar Eclipse (Cold Stasis):** Lunar eclipse halting heat regen with -2.0°/s passive cooling and obsidian flares.
* **Coronal Eclipse (Wave 45+):** Deep twilight, cloaked sunspots revealed by water/parries/ice, and +50% cooling on illuminated weakpoints.
* **Solar Convergence (Wave 30+):** Equatorial Solar Driver boss encounter:
  * *Wave 30–35:* Horizontal ring with 6 Solar Eye Drones projecting invulnerable Golden Shield.
  * *Wave 40+ ("Infinity Lattice"):* 8 drones in counter-rotating dual tilted planes ($\pm 33^\circ$) forming an interlocking 3D double helix. Phase 2 deploys 6 Overdrive escorts.
  * *Wave 50+ ("Harmonic Matrix"):* 2 Harmonic Anchor pairs project dual-frequency resonance. Breaking both pairs collapses shield (+1,500 pts, +50% water, +15% ult) and stuns drones for 3.5s.
  * *Wave 55 & 60+ ("Interceptor Escorts"):* Arc Cyan armor drones (120 HP) that body-block spray aimed at the Sun or orbital drones. Wave 55 deploys 1; Wave 60+ deploys 2.

## 6. Environment & Visuals
* **Ocean:** Procedural Gerstner waves, caustics, and anisotropic sunset specular reflection glade.
* **Sky & Atmosphere:** Dynamic twilight gradient, forward Mie scattering god rays, drifting heat embers / twilight fireflies, and Milky Way ribbon.
* **Sun Expressions:** Procedural faces reacting to hits, crits, dunks, Driver states, and Overtime Shock.
* **Weapons:** Toon-shaded viewmodels with glass fluid reservoirs tracking water levels.
* **Retro Filters:** Post-processing shaders (Retro Colors, Dithering, PS1 Shading, Heatwave 1984).

## 7. UI & Game Feel
* **Menus:** Gold borders, 96px margins, Gamepad navigation, fullscreen default, and `z_index = 50` elevation.
* **Settings:** 3 categorized sections (`AUDIO`, `GAMEPLAY & CONTROLS`, `DISPLAY & SYSTEM`) with even-number typography and real-time numeric readouts.
* **Toasts & Popups:** Cyberpunk Arcade Plates (4px radius, 1px border, 40x40 icon plates, 1.5px depletion bars).
* **Timer Glide Intro:** Round-start timer displays in screen center (`scale 1.6x`, 2.5s hold), then glides (0.85s) into top-right HUD anchor.
* **Title Screen:** Symmetrical horizontal split (title, stats cards, mode buttons, version footer).
* **Victory Recap ("SUMMER'S OVER"):** Normal Mode completion modal (hero title, lore subtitle, diamond divider, milestone unlock tag, 344px telemetry grid for Levels Cleared `5 / 5`, Clear Time, Final Score, and Play Again / Menu buttons).
* **Accessibility:** Full controller support with aim assist, "Reduce Motion" toggle, and EN/KR localization.

## 8. Audio
* **Ducking:** 12dB master drop on massive impacts (Flares, Dunks).
* **UI Audio:** Consistent -18dB 1800Hz sine ticks on all interactions.
* **Custom SFX:** CC0 audio for drones, shields, kitsune weapon, overdrive alarms, and perk drafting.
* **Catastrom VO:** Dual-track setup (royalty-free fallback for itch.io release builds, original audio for local development branch).
