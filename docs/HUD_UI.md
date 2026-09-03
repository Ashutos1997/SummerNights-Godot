# Summer Nights: HUD UI Layout

This document serves as a visual map and architectural breakdown of the `HUD.tscn` scene during live gameplay. It is intended to help developers understand where UI elements are anchored and how they interact.

---

## 1. Core Gameplay HUD Layout

The live gameplay HUD is designed to minimize clutter while keeping critical survival information strictly in the player's peripheral vision.

### Top-Left
*   **`LevelLabel`:** Displays the current game stage (e.g., `LVL 01` for Normal mode, `WAVE 01` for Survival mode).
*   **`ActivePerksHUD`:** Positioned immediately below the `LevelLabel`. This dynamically generated `HFlowContainer` tracks all Rogue-lite perks the player has drafted in Endless Mode using a grid of 32x32 icons. Duplicate perks stack into a single icon with a small "xN" badge.

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
*   **`Crosshair` (`DynamicCrosshair.tscn`):** The aiming reticle. It has been extracted into a standalone scene. It dynamically scales up slightly when successfully landing water hits on the sun. It also features a procedurally drawn vector ring (`_draw()`) that visually tracks the current water tank capacity. The ring and crosshair flash red when empty, and lime-green when landing critical hits on sunspots.
*   **`ComboLabel`:** Positioned slightly offset to the right of the crosshair. Appears when a water stream is held on the sun, displaying the active combo multiplier (e.g., `1.15x COMBO!`). It scales up to 3.0x and fades out when the stream is broken.
*   **`CalloutLabel`:** Positioned just below the ComboLabel. Dynamically injected at runtime to display themed arcade callouts (e.g., "CHILL!", "ICE COLD!") at key combo milestones (1.5x, 2.0x, etc.). Translates text dynamically based on locale.

### Bottom-Right
*   **`resource_container`:** A vertical box container managing player resources:
    *   **Water Bar:** Shows current water tank capacity. Recharges when not shooting. Smoothly lerps (interpolates) to changes, but instantly snaps its visual value if its maximum capacity changes (e.g., when switching weapons) to prevent visual artifacting.
    *   **Ice Charges:** Displays pip-style dots indicating how many Ice Bursts the player has stored.
    *   **Catastrom Bar:** Shows the ultimate gauge, which fills rapidly via the Combo System.

### Bottom-Left
*   **`UnlockPrompts`:** A square container anchored here. It primarily displays the **Active Weapon Icon** (currently selected gun) during gameplay, injected dynamically via `_setup_weapon_hud`.

---

## 2. Screen Overlays

These elements sit on top of the Core Gameplay HUD and blur/dim the background when active.

### Pause Screen (`pause_screen`)
*   Activated by pressing `ESC` or automatically triggered when the application window loses focus (e.g., Alt-Tabbing).
*   Blurs the background and sets `get_tree().paused = true`, fully freezing the entire scene tree (clouds, ocean waves/shaders, physics, animations, particles). The HUD's root `CanvasLayer` uses `PROCESS_MODE_ALWAYS` to remain interactive. All exit paths (Resume, Retry, Main Menu) correctly unpause the tree before transitioning.
*   Contains the `SettingsScreen` (Volume, Sensitivity, Reduce Motion, Vibration, Fullscreen, Language toggles), the `ControllerScreen` (Controls), the `CreditsScreen`, the `AchievementsScreen`, and the `ActiveBuffsScreen`.
    *   All these full-screen menus follow a strict unified layout: left-aligned content with a 96px margin, a 40x40 dynamic gold-tinted title icon, a 2px horizontal separator under the title, and exactly 24px of vertical separation between all primary layout components. Menu buttons (including all BACK buttons) uniformly use a standard size of 280x52 and share identical visual styling across 4 interaction states (Normal, Hover, Pressed, Disabled).
    *   The **PauseScreen** features a custom broken-border design with an animated procedurally-drawn vector sun graphic situated perfectly within a 320px gap in the bottom-right corner.
    *   The **CreditsScreen** uses a vertically scrolling `ScrollContainer` with a cinematic auto-scroll effect that can be overridden by manual mouse scrolling.
    *   The **AchievementsScreen** uses a vertically scrolling `ScrollContainer` displaying dynamically built panels for all configured achievements, utilizing custom icons sourced from Game-icons.net. Locked achievements clearly display their full titles and unlock descriptions but are visually greyed out to indicate their locked status. It operates completely independently of the game's pause state (PROCESS_MODE_ALWAYS) to ensure its internal UI scrolling physics and animations never freeze when accessed from the Pause menu.

### Controller Screen (`ControllerScreen`)
*   Accessed from the Pause Screen via the "CONTROLS" button. Uses a dedicated `console-controller.svg` icon in its title.
*   Features a premium "Sliding Toggle Pill" (matching Language settings) to switch seamlessly between Keyboard and Xbox controller legend graphics.
*   Displays a large visual graphic of the selected input layout. Keys and buttons are highlighted with specific colors mapping to abilities (e.g., Yellow for Pause, Green for Weapons, Blue for Ice Blast, Orange for Catastrom, Grey for Aiming/Movement).
*   A vertical legend column sits perfectly aligned to the left of the layout graphic. Both the graphic and the legend are encapsulated in a dynamically stretching row using `size_flags_horizontal = 3` spacers, guaranteeing perfect symmetrical alignment against the menu's top and bottom dividers regardless of inner content size. It utilizes fully translated text in both English and Korean.

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
*   **Quit Popup:** Pressing `ESC` triggers a confirmation modal asking "DO YOU WANT TO QUIT?". Uses a 90% opacity dark overlay, a 24px golden border, and implements the secondary button state for the "YES" action to prevent accidental quitting.

### End State Screens
*   **`WinScreen`:** Shown upon completing a wave. Displays level stats and loading text.
*   **`EndScreen`:** Shown upon beating the entire game.
*   **`LoseScreen`:** Shown if the Sun hits 100% heat. Instead of an immediate popup, this triggers a dramatic Supernova cinematic (massive sun expansion, screen shake, blinding flash) that fades into the menu. Features a fully opaque background to block HDR bleed, a perfectly centered vertical layout for dramatic emphasis, and offers Retry/Menu buttons styled exactly like the Pause menu.

---

## 3. Localization Support

All labels within the HUD are dynamically localized in `HUD.gd` via the `_apply_language(lang: String)` function.
*   **English (EN):** Uses `Kenney Future.ttf`
*   **Korean (KR):** Uses `Galmuri11.ttf`. Font sizes are manually boosted (e.g., from 22px to 26px) to match the visual weight of the English pixel font.

---

## 4. CanvasLayer Hierarchy

To correctly manage drawing order between the 3D world, global post-processing effects, and the 2D UI, the game utilizes multiple `CanvasLayer` nodes:
*   **Layer 0 (Post-Processing):** A full-screen `ColorRect` is dynamically injected at runtime behind the HUD. It runs `retro_postprocess.gdshader`, capturing the `SCREEN_TEXTURE` (which is the 3D game world) and applying color grading and film grain.
*   **Layer 10 (HUD):** The main `HUD.tscn` root operates at layer 10. This ensures that UI elements, crosshairs, and text remain crisp, legible, and completely unaffected by the retro shader.
