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
*   **Weapon Wheel:** Holding the weapon wheel key slows time and opens a sleek UI to swap weapons.
*   **Available Weapons:**
    *   **Standard Blaster:** Balanced water usage and cooling power. (Unlocked Level 1)
    *   **Precision Stream:** Low capacity, fast drain, but massive critical hit multipliers. (Unlocked Level 2)
    *   **Heavy Cannon:** Huge capacity and high cooling power, but drains water rapidly. (Unlocked Level 3)
    *   **Scatter Nozzle:** Wide spread, excellent for intercepting multiple solar flares at once, but lacks pinpoint cooling. (Unlocked Level 4)
*   **Ice Charges (Secondary Fire):** Powerful, instant-cooling projectiles with limited charges. Earn charges over time or when defeating boss waves.
*   **Catastrom Ultimate:** Fills up by continuously watering the sun. When at 100% (Level 4+), press [F] to physically grab the sun and violently drag it down into the ocean for an instant wave clear.

## 3. Sun Mechanics & Threats
*   **Dynamic Movement:** The Sun sways horizontally. On higher waves, it begins to weave in a "Figure-8" pattern.
*   **Sunspots (Critical Heat Vents):** Periodically, a glowing white-hot sunspot will appear on the Sun's surface. Hitting this specific point with the water stream (especially with the Precision Stream) grants massive critical cooling bonuses and huge score multipliers.
*   **Solar Flares:** The Sun periodically spits fiery projectiles towards the screen. The player must intercept them with the water stream before they hit; otherwise, they cause a massive heat spike. Intercepting a flare spawns physical Magma Debris that crashes onto the beach, scaring away seagulls and persisting until the player evaporates it with their water gun.
*   **Solar Wind:** A physical force emitted by the Sun that pushes the player's crosshair away, requiring them to actively fight the mouse to maintain aim.
*   **Two-Phase Bosses:** Boss waves (e.g., Wave 5) have two phases. Depleting the timer triggers Phase 2, which resets the timer and immediately spikes the heat to a critical level (e.g., 60%).
*   **Heat Mirage Overshield (Endless Mode):** Every 5th wave in Endless mode, the sun spawns two decoy mirages that scramble positions. The mirages project a collective golden Overshield protecting the main sun from all damage. You must shoot down the mirages (shrinking them with water) to shatter the shield before you can resume cooling the main sun!
*   **Multi-Flare Shotgun (Endless Mode Wave 10+):** Deep into Endless mode, the sun will begin spitting multiple flares simultaneously in a shotgun spread pattern (2 flares starting at Wave 10, 3 flares starting at Wave 15). This forces the player to rapidly switch targets or strategically use the Scatter Nozzle/Ice Burst.

## 4. Dynamic Weather Events
Weather events trigger based on a dynamic probability system tied to the current wave (configured via `GameState.LEVEL_CONFIG`'s `weather_weights`). Level 1 favors Rain or no weather, while Boss waves almost guarantee an Eclipse. In Endless/Survival Mode, the weights dynamically shift over time to make Eclipses increasingly common.

*   **Rainstorms:** A massive downpour begins. Ambient lighting cools, and the Sun's heat begins to slowly drop. The player's water tank rapidly refills, allowing for infinite firing during the storm.
*   **Solar Eclipses:** The sky drops into a moody twilight and the Sun becomes a dark silhouette with a bright corona. The Sun stops passively generating heat, but it begins rapidly firing high-speed, dark purple "Shadow Flares" that must be intercepted.

## 5. Environment & Level Design
*   **Dynamic Ocean:** The stylized ocean uses depth-based tinting, scrolling foam lines, and procedurally generated rogue waves that occasionally roll in from the horizon towards the island.
*   **Dynamic Sky & Day/Night Cycle:** The sky uses custom shaders for sun/moon positioning, moving clouds, and stars. The scene transitions between daylight (bright blues) and night (deep purples) based on the wave progress.
*   **Foliage & Props:** Low-poly stylized foliage (palms, bushes, rocks) scattered via GDScript.
*   **Sun Expressions:** The 2D face on the Sun reacts to events (getting angry, taking damage, critical states).
*   **Heat Distortion:** A screen-space shader applies heat shimmer/refraction over the environment, which intensifies as the Sun gets hotter.
*   **Seagull Interactions:** Shooting the background seagulls with water causes them to squawk (pitch-shifted SFX), drop a burst of feathers, and rapidly flee higher into the sky.
*   **Decorative Layers:**
    *   **Cloud Layer:** Stylized 3D clouds that float across the sky.
    *   **Seagull Layer:** Flocks of seagulls that fly in the distance.
*   **Particle Effects:** Splashes for water hitting the sun, shattered chunks for the Catastrom dunk, shattered ice particles for ice blasts, and steam plumes.

## 6. UI, Juice, & Game Feel
*   **Custom Crosshair:** A dynamic cursor that scales up on hits.
*   **Screen Shake:** The camera violently shakes during critical moments (e.g., Phase 2 transitions, high heat, solar flare impacts, Catastrom dunks).
*   **Hit Feedback:** The crosshair flashes and scales upon successful hits (`projectile_hit` events) and critical hits.
*   **Dynamic UI Elements:**
    *   Temperature/Heat Bar (Sun Heat).
    *   Water Tank Bar.
    *   Ice Charge indicators.
    *   Catastrom Ultimate notification toasts.
    *   Wave Timer and live Score counter (which formats and scales dynamically for juice).
*   **Startup Sequence:** The Title Screen features a dynamic "tech demo" boot sequence. It plays a custom synth audio that swells over 4 seconds, while a golden border procedurally draws itself around the perimeter. At the peak of the audio swell, the UI aggressively bounces up into place and the audio smoothly fades out while the ambient ocean fades in.
*   **Global Overlays:** Full-screen menus (Title, Pause, Settings, Credits) are unified by a sleek golden border and an ultra-dark background dimming effect to eliminate visual clutter.
*   **Accessibility & Settings:**
    *   Reduce Motion toggle (disables screen shake and intensive UI flashing).
    *   Mouse Sensitivity slider.
    *   Fullscreen toggle.
    *   Language selection (English and Korean).

## 7. Audio
*   **Synthesized UI Sounds:** Programmatically generated sine-wave "ticks" and "whooshes" for UI navigation and the weapon wheel.
*   **Gameplay SFX:** 
    *   Continuous water shooting loop.
    *   Solar flare interception sound.
    *   Catastrom voice-over and massive water dunk splash.
    *   Critical warnings.

---

*(Note: The Shop System was temporarily removed in a previous iteration and is currently disabled.)*


