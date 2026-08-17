# Summer Nights: HUD UI Layout

This document serves as a visual map and architectural breakdown of the `HUD.tscn` scene during live gameplay. It is intended to help developers understand where UI elements are anchored and how they interact.

---

## 1. Core Gameplay HUD Layout

The live gameplay HUD is designed to minimize clutter while keeping critical survival information strictly in the player's peripheral vision.

### Top-Left
*   **`LevelLabel`:** Displays the current game stage (e.g., `LVL 01` for Normal mode, `WAVE 01` for Survival mode).

### Top-Center
*   **`SunHeatBar`:** The most critical UI element. Displays the current temperature of the sun. If this bar fills completely (100%), the player loses.
*   **`Phase2Label`:** A centered warning text that flashes when a boss transitions into Phase 2.

### Top-Right
*   **`TimerLabel`:** Displays the time remaining in the current wave (e.g., `TIME: 0:45`).
*   **`ScoreLabel`:** Located directly beneath the Timer. Displays the live arcade score (e.g., `SCORE: 1,500`). When points are scored, this label scales up and snaps back smoothly, pivoting from the right edge to avoid extending off-screen.
*   **`WeatherIconContainer`:** A persistent, stylized circular icon container located directly beneath the Score. Displays a yellow star for normal weather, and animated exclamation marks for active weather events (Rain / Eclipse).
*   **`WeatherTimerLabel`:** Positioned just below the WeatherIconContainer. Appears during an Eclipse if the "Shadow Walker" achievement is unlocked, displaying a precise countdown until the eclipse ends in a striking red font with a black outline.
*   **`ToastContainer`:** Displays transient slide-down notifications (e.g., "Weapon Unlocked") from the top-right corner.

### Center
*   **`Crosshair`:** The aiming reticle. It dynamically scales up slightly when successfully landing water hits on the sun.
*   **`ComboLabel`:** Positioned slightly offset to the right of the crosshair. Appears when a water stream is held on the sun, displaying the active combo multiplier (e.g., `1.15x COMBO!`). It scales up to 3.0x and fades out when the stream is broken.
*   **`CalloutLabel`:** Positioned just below the ComboLabel. Dynamically injected at runtime to display themed arcade callouts (e.g., "CHILL!", "ICE COLD!") at key combo milestones (1.5x, 2.0x, etc.). Translates text dynamically based on locale.

### Bottom-Right
*   **`resource_container`:** A vertical box container managing player resources:
    *   **Water Bar:** Shows current water tank capacity. Recharges when not shooting.
    *   **Ice Charges:** Displays pip-style dots indicating how many Ice Bursts the player has stored.
    *   **Catastrom Bar:** Shows the ultimate gauge, which fills rapidly via the Combo System.

### Bottom-Left
*   **`UnlockPrompts`:** A square container anchored here. It primarily displays the **Active Weapon Icon** (currently selected gun) during gameplay, injected dynamically via `_setup_weapon_hud`.

---

## 2. Screen Overlays

These elements sit on top of the Core Gameplay HUD and blur/dim the background when active.

### Pause Screen (`pause_screen`)
*   Activated by pressing `ESC`.
*   Blurs the background and pauses the `get_tree().paused` state.
*   Contains the `SettingsScreen` (Volume, Sensitivity, Reduce Motion, Fullscreen, Language toggles), the `CreditsScreen`, the `AchievementsScreen`, and the `ActiveBuffsScreen`.
    *   All these full-screen menus follow a strict unified layout: left-aligned content with a 96px margin, a 40x40 dynamic gold-tinted title icon, a 2px horizontal separator under the title, and exactly 24px of vertical separation between all primary layout components. Menu buttons use an increased size of 280x52.
    *   The **PauseScreen** features a custom broken-border design with an animated procedurally-drawn vector sun graphic situated perfectly within a 320px gap in the bottom-right corner.
    *   The **CreditsScreen** uses a vertically scrolling `ScrollContainer` with a cinematic auto-scroll effect that can be overridden by manual mouse scrolling.
    *   The **AchievementsScreen** uses a vertically scrolling `ScrollContainer` displaying dynamically built panels for all configured achievements, utilizing custom icons sourced from Game-icons.net. It operates completely independently of the game's pause state (PROCESS_MODE_ALWAYS) to ensure its internal UI scrolling physics and animations never freeze when accessed from the Pause menu.

### Weapon Wheel (`WeaponWheel`)
*   Activated by holding `TAB`.
*   Slows time (`Engine.time_scale = 0.1`) instead of fully pausing.
*   Draws procedural wedges using the `_draw()` API based on the number of configured weapons (currently 5). 
*   Weapons can be locked either by level progression or via achievements. Locked wedges are drawn in a flat dark gray (`Color(0.1, 0.1, 0.1, 0.6)`) to visually distinguish them from unlocked yellow/golden wedges.
*   Renders live 3D thumbnails of the weapons into viewports mapped to 2D textures.

### Title Screen (`TitleScreen`)
*   Serves as the main menu and boot sequence.
*   Features a custom 4-second boot animation where a golden line traces the 8px rounded perimeter of the screen while a PS1 synth swells, hiding the static `BorderPanel` until completion.
*   Upon completion, the main UI layout aggressively bounces up from the bottom of the screen.

### End State Screens
*   **`WinScreen`:** Shown upon completing a wave. Displays level stats and loading text.
*   **`EndScreen`:** Shown upon beating the entire game.
*   **`LoseScreen`:** Shown if the Sun hits 100% heat. Displays failure stats and offers Retry/Menu buttons.

---

## 3. Localization Support

All labels within the HUD are dynamically localized in `HUD.gd` via the `_apply_language(lang: String)` function.
*   **English (EN):** Uses `Kenney Future.ttf`
*   **Korean (KR):** Uses `Galmuri11.ttf`. Font sizes are manually boosted (e.g., from 22px to 26px) to match the visual weight of the English pixel font.
