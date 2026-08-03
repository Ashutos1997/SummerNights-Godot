# Summer Nights: Feature Documentation

This document serves as the master record for all currently implemented features, mechanics, and systems in the *Summer Nights* project. It should be updated whenever a new feature is added to maintain a single source of truth.

---

## 1. Core Gameplay Loop
*   **Objective:** Cool the Sun to prevent it from reaching 100% heat before the wave timer runs out.
*   **Heat Mechanics:** The Sun passively generates heat. If heat reaches 100%, the player loses.
*   **Water Management:** The player has a limited water tank that drains when shooting. It recharges automatically when not firing.
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
*   **Ice Charges (Secondary Fire):** Powerful, instant-cooling projectiles with limited charges. Recharged upon defeating boss waves.

## 3. Sun Mechanics & Threats
*   **Dynamic Movement:** The Sun sways horizontally. On higher waves, it begins to weave in a "Figure-8" pattern.
*   **Solar Flares:** The Sun periodically spits fiery projectiles towards the screen. The player must intercept them with the water stream before they hit; otherwise, they cause a massive heat spike.
*   **Solar Wind:** A physical force emitted by the Sun that pushes the player's crosshair away, requiring them to actively fight the mouse to maintain aim.
*   **Two-Phase Bosses:** Boss waves (e.g., Wave 5) have two phases. Depleting the timer triggers Phase 2, which resets the timer and immediately spikes the heat to a critical level (e.g., 60%).

## 4. Dynamic Weather Events
Weather events can randomly trigger mid-wave, forcing the player to adapt:
*   **Rainstorms:** A massive downpour begins. Ambient lighting cools, and the Sun's heat begins to slowly drop. The player's water tank rapidly refills, allowing for infinite firing during the storm.
*   **Solar Eclipses:** The sky drops into a moody twilight and the Sun becomes a dark silhouette with a bright corona. The Sun stops passively generating heat, but it begins rapidly firing high-speed, dark purple "Shadow Flares" that must be intercepted.

## 5. Visuals & Environment
*   **Dynamic Sky & Lighting:** The sky gradient, sun color (albedo/emission), and ambient lighting transition dynamically from afternoon to sunset as the wave progresses.
*   **Sun Expressions:** The 2D face on the Sun reacts to events (getting angry, taking damage, critical states).
*   **Heat Distortion:** A screen-space shader applies heat shimmer/refraction over the environment, which intensifies as the Sun gets hotter.

## 6. Testing / Dev Mode
Clicking `[DEV]` on the Title Screen starts the game in Developer Mode (starts at Wave 5). The following hotkeys become available:
*   `[R]` - Instantly trigger a Rainstorm
*   `[E]` - Instantly trigger a Solar Eclipse
*   `[W]` - Skip current wave
*   **Decorative Layers:**
    *   **Cloud Layer:** Stylized 3D clouds that float across the sky.
    *   **Seagull Layer:** Flocks of seagulls that fly in the distance.
*   **Particle Effects:** Splashes for water hitting the sun, shattered ice particles for ice blasts, and steam plumes.

## 5. UI, Juice, & Game Feel
*   **Custom Crosshair:** A dynamic cursor that scales up on hits.
*   **Screen Shake:** The camera violently shakes during critical moments (e.g., Phase 2 transitions, high heat, solar flare impacts).
*   **Hit Feedback:** The crosshair flashes and scales upon successful hits (`projectile_hit` events) and critical hits.
*   **Dynamic UI Elements:**
    *   Temperature/Heat Bar (Sun Heat).
    *   Water Tank Bar.
    *   Ice Charge indicators.
    *   Wave Timer.
*   **Accessibility & Settings:**
    *   Reduce Motion toggle (disables screen shake and intensive UI flashing).
    *   Mouse Sensitivity slider.
    *   Fullscreen toggle.
    *   Language selection (English and Korean).

## 6. Audio
*   **Synthesized UI Sounds:** Programmatically generated sine-wave "ticks" and "whooshes" for UI navigation and the weapon wheel.
*   **Gameplay SFX:** 
    *   Continuous water shooting loop.
    *   Solar flare interception sound.
    *   Critical warnings.

---

*(Note: The Shop System was temporarily removed in a previous iteration and is currently disabled.)*
