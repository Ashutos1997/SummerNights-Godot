# Summer Nights: Feature Documentation

This document serves as the master record for all currently implemented features, mechanics, and systems in the *Summer Nights* project. It should be updated whenever a new feature is added to maintain a single source of truth.

---

## 1. Core Gameplay Loop
*   **Objective:** Cool the Sun to prevent it from reaching 100% heat before the wave timer runs out.
*   **Heat Mechanics:** The Sun passively generates heat. If heat reaches 100%, the player loses.
*   **Water Management:** The player has a limited water tank that drains when shooting. It recharges automatically when not firing.
*   **Water Stream Combo & Scoring:** Continuously tracking the Sun with water builds a combo multiplier that scales up to 3.0x, significantly boosting Catastrom Ultimate charging speed.
*   **Scoring System:** Points are dynamically awarded for continuous hits, intercepting Solar Flares (500 base points), and evaporating Magma Debris (150 base points). All points are heavily multiplied by the active Combo meter, making long, accurate streams extremely lucrative. Your High Score is persistently saved between sessions.
*   **Wave Progression:** The game progresses through increasingly difficult waves (longer timers, faster heat generation, more aggressive sun movement). Boss waves occur every 5 waves (e.g., Wave 5).
*   **Game Modes:**
    *   **Normal Mode:** Standard level progression.
    *   **Endless/Survival Mode:** Infinite waves to see how long the player can survive.

## 2. Weapons & Tools
*   **Weapon Wheel:** Holding the weapon wheel key slows time and opens a sleek UI to swap weapons. Fully supports Gamepad thumbstick aiming and release-to-equip mechanics. Water tank capacity maintains its current percentage seamlessly across weapon swaps without visual artifacting. To prevent exploits, hazard timers (like Solar Wind or Eclipses) pause entirely while the wheel is open, forcing players to confront the hazards rather than wait them out, while the level timer continues to drain.
*   **Available Weapons:**
    *   **Standard Blaster:** Balanced water usage and cooling power. (Unlocked Level 1)
    *   **Precision Stream:** Low capacity, fast drain, but massive critical hit multipliers. (Unlocked Level 2)
    *   **Heavy Cannon:** Huge capacity and high cooling power, but drains water rapidly. (Unlocked Level 3)
    *   **Scatter Nozzle:** Wide spread, excellent for intercepting multiple solar flares at once, but lacks pinpoint cooling. (Unlocked Level 4)
    *   **Tidal Gatling:** A massive heavy burst weapon with extreme cooling power and water drain, but a very punishing recharge rate. (Unlocked via "Arcade Legend" Achievement)
*   **Ice Charges (Secondary Fire):** Powerful, instant-cooling projectiles with limited charges. Earn charges over time or when defeating boss waves.
*   **Catastrom Ultimate:** Fills up by continuously watering the sun. When at 100% (Level 4+), press [F] to physically grab the sun and violently drag it down into the ocean for an instant wave clear.

## 3. Sun Mechanics & Threats
*   **Dynamic Movement:** The Sun sways horizontally. On higher waves, it begins to weave in a "Figure-8" pattern.
*   **Sunspots (Critical Heat Vents):** Periodically, a glowing white-hot sunspot will appear on the Sun's surface. Hitting this specific point with the water stream (especially with the Precision Stream) grants massive critical cooling bonuses and huge score multipliers.
*   **Solar Flares:** The Sun periodically spits fiery projectiles towards the screen. The player must intercept them with the water stream before they hit; otherwise, they cause a massive heat spike. Intercepting a flare spawns physical Magma Debris that crashes onto the beach, scaring away seagulls and persisting until the player evaporates it with their water gun.
*   **Solar Wind:** A physical force emitted by the Sun that pushes the player's crosshair away, requiring them to actively fight the mouse to maintain aim. The island's foliage (trees and bushes) will violently bend and sway in the direction of the wind to visually telegraph the hazard's intensity.
*   **Two-Phase Bosses:** Boss waves (e.g., Wave 5) have two phases. Depleting the timer triggers Phase 2, which resets the timer and immediately spikes the heat to a critical level (e.g., 60%).
*   **Heat Mirage Overshield (Endless Mode):** Every 5th wave in Endless mode, the sun spawns two decoy mirages that scramble positions. The mirages project a collective golden Overshield protecting the main sun from all damage. You must shoot down the mirages (shrinking them with water) to shatter the shield before you can resume cooling the main sun!
*   **Multi-Flare Shotgun (Endless Mode Wave 10+):** Deep into Endless mode, the sun will begin spitting multiple flares simultaneously in a shotgun spread pattern (2 flares starting at Wave 10, 3 flares starting at Wave 15). This forces the player to rapidly switch targets or strategically use the Scatter Nozzle/Ice Burst.
*   **High Heat Steam:** When the sun's temperature exceeds 75%, it begins to furiously boil off thick plumes of steam. The steam visually intensifies as the heat climbs toward 100%, serving as a clear physical warning of impending doom.
*   **Supernova Cinematic (Game Over):** If the sun reaches 100% heat, the standard Game Over screen is replaced by a dramatic Supernova event. The sun violently expands while the screen shakes, triggering a blinding white evaporation flash that smoothly transitions into the Lose menu.

## 4. Dynamic Weather Events
Weather events trigger based on a dynamic probability system tied to the current wave (configured via `GameState.LEVEL_CONFIG`'s `weather_weights`). Level 1 favors Rain or no weather, while Boss waves almost guarantee an Eclipse. In Endless/Survival Mode, the weights dynamically shift over time to make Eclipses increasingly common.

*   **Rainstorms:** A massive downpour begins. Ambient lighting cools, and the Sun's heat begins to slowly drop. The player's water tank rapidly refills, allowing for infinite firing during the storm.
*   **Solar Eclipses:** The sky drops into a moody twilight and the Sun becomes a dark silhouette with a bright corona. The Sun stops passively generating heat, but it begins rapidly firing high-speed, dark purple "Shadow Flares" that must be intercepted.

## 5. Environment & Level Design
*   **Dynamic Ocean:** Procedural water material (`water.gdshader`) completely overhauled with physical Gerstner waves for steep, dynamic crests, depth-based color absorption, edge intersection foam, procedural Voronoi surface caustics that scroll across the open ocean, and fake subsurface scattering (SSS) that dynamically highlights wave crests based on height and view angle.
    *   **Rogue Waves:** Randomly spawned giant surfing waves that travel towards the shore, adding unpredictable, dynamic motion to the ocean surface. They spawn off-mesh and dynamically swell in height to create a cinematic, realistic build-up. All rogue waves are guaranteed to be massive high-tide waves. When a rogue wave crashes, it temporarily turns the island's sand dark and glossy (perfectly synchronized to the wave's exact speed and impact time), slowly drying off over several seconds for enhanced immersion.
*   **Sky & Weather:** Procedural sky shader featuring smooth time-of-day gradients, atmospheric fog, dynamic clouds, and a stylized sun. The scene transitions between daylight (bright blues) and night (deep purples) based on the wave progress.
*   **Foliage & Props:** Low-poly stylized foliage (palms, bushes, rocks) scattered via GDScript.
*   **PBR Beach Sand:** The island's ground uses a high-quality CC0 PBR material (diffuse, normal, roughness maps) heavily tinted with a warm sunset tone to maintain a smooth, stylized aesthetic. Its emission dynamically fades to match dark ambient lighting during severe weather events (e.g., Rainstorms, Eclipses) while having a completely matte finish (`specular = 0.0`) for a realistic dry-sand feel.
*   **Sun Expressions:** The 2D face on the Sun reacts to events (getting angry, taking damage, critical states).
*   **Heat Distortion:** A screen-space shader applies heat shimmer/refraction over the environment, which intensifies as the Sun gets hotter.
*   **Seagull Interactions:** Shooting the background seagulls with water causes them to squawk (pitch-shifted SFX), drop a burst of feathers, and rapidly flee higher into the sky.
*   **Decorative Layers:**
    *   **Cloud Layer:** Stylized 3D clouds that float across the sky.
    *   **Seagull Layer:** Flocks of seagulls that fly in the distance.
    *   **Fireflies:** A procedural particle system that dynamically spawns drifting, glowing low-poly bugs (ArrayMeshes) across the beach foreground to enhance the cozy sunset aesthetic.
*   **Particle Effects:** Splashes for water hitting the sun and the environment (e.g. missing the sun and hitting the sand/ocean 100% of the time), fiery orange sparks for intercepted solar flares, shattered chunks for the Catastrom dunk, shattered ice particles for ice blasts, and steam plumes. All dynamically generated particles are emissive, reacting strongly to the WorldEnvironment.
*   **Atmospherics & Post-Processing:**
    *   **Retro Shader:** A global screen shader applying film grain, vignette, and synthwave color grading (S-curve contrast and complementary split-toning).
    *   **Cinematic Bloom:** The `WorldEnvironment` utilizes soft additive bloom, causing the sun and emissive particles to visibly bleed light into the environment.

## 6. UI, Juice, & Game Feel
*   **Dynamic Crosshair:** A custom diegetic cursor that scales up on hits. It features a translucent blue radial ring that visually tracks the current water tank capacity. The ring and crosshair instantly flash red when the tank is empty, and flash lime-green when landing critical hits on sunspots.
*   **Screen Shake:** The camera violently shakes during critical moments (e.g., Phase 2 transitions, high heat, solar flare impacts, Catastrom dunks).
*   **Hit Feedback:** The crosshair flashes and scales upon successful hits (`projectile_hit` events) and critical hits.
*   **Dynamic UI Elements:**
    *   Temperature/Heat Bar (Sun Heat).
    *   Water Tank Bar.
    *   Ice Charge indicators.
    *   Catastrom Ultimate notification toasts.
    *   Wave Timer and live Score counter (which formats and scales dynamically for juice).
    *   Dynamic Arcade Combo Callouts at key multiplier milestones (e.g., "CHILL!", "ICE COLD!").
*   **Achievements System:** An in-game achievements gallery is available from both the Title Screen and the Pause Menu. The game tracks gameplay milestones and unlocks achievements dynamically, presenting a custom animated UI Toast with audio. Locked achievements clearly display their full titles and unlock conditions while remaining visually greyed-out.
    *   **Meaningful Rewards:** Unlocking achievements provides tangible gameplay bonuses (e.g., unlocking Endless Mode, Catastrom charge buffs, combo decay grace periods, heat resistance buffs, eclipse warning timers, weapon handling buffs, and flare interception buffs).
    *   **Active Buffs Menu:** A dedicated menu accessible from the Pause Screen dynamically displays a real-time list of all currently active perks, stat upgrades, and achievement rewards based on your High Score and progression. Similar to achievements, locked buffs display their full names and requirements while remaining greyed-out.
*   **Startup Sequence:** The Title Screen features a dynamic "tech demo" boot sequence. It plays a custom synth audio that swells over 4 seconds, while a golden border procedurally draws itself around the perimeter. At the peak of the audio swell, the UI aggressively bounces up into place and the audio smoothly fades out while the ambient ocean fades in.
*   **Menu Overlays:** Standard menus (Pause, Settings, Controls, Credits, Achievements, Buffs) are unified by a sleek golden border (with the Pause Screen uniquely featuring an animated procedurally-drawn sun situated in a broken bottom-right gap), an ultra-dark background dimming effect, consistent left-aligned typography with 96px interior margins, exactly 24px vertical layout separation, uniform title dividers, and dynamic gold-tinted title icons. The HUD's root `CanvasLayer` is set to `PROCESS_MODE_ALWAYS` so it remains interactive while the entire scene tree is paused.
    *   **Controller Keybindings:** The Controls screen displays a visual graphic of a keyboard and Xbox controller that perfectly align symmetrically with the menu using dynamic layout spacers (`size_flags_horizontal = 3`). Cleanly colored keys map directly to a fully translated vertical legend column to the left of the graphic, providing an intuitive, at-a-glance reference for all game actions.
*   **Lose Screen Exception:** Unlike the standard left-aligned menus, the Lose Screen (Game Over) features a perfectly centered layout to emphasize the dramatic Supernova cinematic transition, but utilizes the exact same 280x52 button styling, typography scaling, and golden borders as the rest of the UI.
*   **Accessibility & Settings:**
    *   Reduce Motion toggle (disables screen shake and intensive UI flashing).
    *   Mouse Sensitivity slider.
    *   Vibration toggle (enables/disables controller haptics during combat).
    *   Fullscreen toggle (enabled by default for optimal font legibility).
    *   Language selection (English and Korean).
    *   Automatic Pause on Window Unfocus (prevents losing a run when Alt-Tabbing). Pausing fully freezes the entire scene tree (`get_tree().paused`), halting all processing including clouds, wave shaders, physics, animations, and particles.

## 7. Audio
*   **Synthesized UI Sounds:** Programmatically generated sine-wave "ticks" and "whooshes" for UI navigation and the weapon wheel.
*   **Gameplay SFX:** 
    *   Continuous water shooting loop.
    *   Solar flare interception sound.
    *   Catastrom voice-over (Kamen Rider) for GitHub builds, and a royalty-free cinematic impact sound for itch.io builds (via the `safe_audio` export tag), alongside a massive water dunk splash.
    *   Critical warnings.

---

*(Note: The Shop System was temporarily removed in a previous iteration and is currently disabled.)*


