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
*   **`TopRightInfo` (VBoxContainer):** A container anchoring the top-right text elements to ensure perfect right-alignment of their bounding boxes.
    *   **`TimerLabel`:** Displays the time remaining in the current wave (e.g., `TIME: 0:45`).
    *   **`ScoreLabel`:** Displays the live arcade score (e.g., `SCORE: 1,500`). When points are scored, this label scales up and snaps back smoothly, pivoting from the right edge to avoid extending off-screen.
*   **`WeatherIconContainer`:** A persistent, stylized circular icon container located directly beneath the Score. Displays a yellow star for normal weather, and animated exclamation marks for active weather events (Rain / Eclipse).
*   **`WeatherTimerLabel`:** Positioned just below the WeatherIconContainer. Appears during an Eclipse if the "Shadow Walker" achievement is unlocked, displaying a precise countdown until the eclipse ends in a striking red font with a black outline.
*   **`ToastContainer`:** Displays transient slide-down notifications (e.g., "Weapon Unlocked", "Ice Burst Unlocked") from the top-right corner. During level transitions, these notifications are deferred and will only appear after the next level has fully loaded and the screen has faded in. The Ice Burst unlock notification features the matching crisp snowflake vector icon (`meter_ice.svg`) tinted in icy cyan.

### Center
*   **`Crosshair` (`DynamicCrosshair.tscn`):** The aiming reticle. It has been extracted into a standalone scene. It dynamically scales up slightly when successfully landing water hits on the sun. It also features a procedurally drawn vector ring (`_draw()`) that visually tracks the current water tank capacity. The ring will cleanly pulse a high-contrast orange when the tank drops below 25% to serve as a low water warning. The ring and crosshair flash red when entirely empty, and lime-green when landing critical hits on sunspots.
    *   **Per-Weapon Crosshair Shapes:** `set_weapon_style(id)` is called from `Main.gd` via `HUD.gd`'s `notify_weapon_style()` on every weapon swap. The PNG `CrosshairImage` node is hidden for all non-standard weapons. Shapes: **Standard** (dot + ring PNG), **Precision** (tight `+` cross + center dot, tight 22px ring), **Heavy** (thick bracket corners at ±18px, wide 34px ring), **Scatter** (3 diverging angled lines at -35°/0°/35°, wide 36px ring), **Tidal Gatling** (8-segment spinning dashed ring, spins at 60°/s idle, 180°/s while firing).
*   **`ComboLabel`:** Positioned slightly offset to the right of the crosshair. Appears when a water stream is held on the sun, displaying the active combo multiplier (e.g., `1.15x COMBO!`). It scales up to 3.0x and fades out when the stream is broken.
*   **`CalloutLabel`:** Positioned just below the ComboLabel. Dynamically injected at runtime to display themed arcade callouts (e.g., "CHILL!", "ICE COLD!") at key combo milestones (1.5x, 2.0x, etc.). Translates text dynamically based on locale.
*   **`FlareRings` (`scripts/FlareRings.gd`):** A custom diegetic 2D vector HUD overlay attached to the HUD canvas. Projects the Sun's 3D mesh radius into screen space, drawing an outer glow, background track, bright orange-yellow fill arc, leading dot, and cardinal tick marks over the 0.6s Solar Flare charge window. Works in tandem with the Sun's dynamic `"charging"` facial expression (wide strained eyes, sharp brows, fiery glow) to clearly telegraph incoming flare attacks.

### Bottom-Right
*   **`resource_container`:** A vertical box container managing player resources, anchored with a 24px right margin to align flush with the Top-Right Info container:
    *   **Retro Flat Plates (`IconPlate`):** Each resource meter is anchored by a 38x38 retro flat dark plate (`Color(0, 0, 0, 0.45)`, 4px corner radius, 1px accent border) housing a crisp, centered vector icon with a `6px` internal margin (reducing icon size to 26x26 to provide balanced breathing room and prevent visual claustrophobia), directly mirroring the retro-arcade shape language of the Active Perks Tracker:
        *   **Water Meter Plate:** Cyan border (`Color(0.2, 0.8, 1.0, 0.6)`) with droplet icon (`meter_water.svg` by Yudhi Restu Pebriyanto) tinted `Color(0.4, 0.9, 1.0)`. Features an active peripheral warning state: when tank capacity drops below 20%, the plate border and droplet flash warning red (`Color(1.0, 0.3, 0.3, 0.9)`).
        *   **Ice Burst Meter Plate:** Crystal frost border (`Color(0.55, 0.9, 1.0, 0.6)`) with snowflake icon (`meter_ice.svg` by Jaya99) tinted `Color(0.5, 0.85, 1.0)`. Dims to 0.45 alpha when charges are depleted to clearly signal empty state.
        *   **Catastrom Ultimate Plate:** Catastrom purple border (`Color(0.8, 0.4, 1.0, 0.6)`) with sun drag icon (`meter_catastrom.svg` by balyanbinmalkan) tinted `Color(0.8, 0.4, 1.0)`. Seamlessly pulses bright gold (`Color(1.0, 0.85, 0.2)`) when the gauge reaches 100%.
    *   **Water Bar:** Shows current water tank capacity in oceanic blue (`progress_blue.png`). Recharges when not shooting. Smoothly lerps to changes, but instantly snaps its visual value if its maximum capacity changes (e.g., when switching weapons) to prevent visual artifacting. Flashes red during low water.
    *   **Discrete Ice Charge Cells:** Inside `IceBarContainer`, charges are dynamically rendered as discrete segmented cells using crystalline frost white (`progress_white.png` tinted `Color(0.55, 0.9, 1.0)` with a 4px gap), dividing the 200px width equally. Each cell corresponds to one stored Ice Burst charge, completely eliminating ambiguous fractional bar percentages.
    *   **Catastrom Bar & "MAX READY!" State:** Shows the ultimate gauge in rich purple (`progress_red.png` tinted `Color(0.6, 0.0, 1.0)`). When charged to 100%, an animated arcade `ReadyLabel` (`Kenney Future` / `Galmuri11`, gold text with 3px black outline) pulses directly inside the bar ("MAX READY!" in EN / "준비 완료!" in KR).

### Bottom-Left
*   **`UnlockPrompts`:** A square container anchored here. It primarily displays the **Active Weapon Icon** (currently selected gun) during gameplay, injected dynamically via `_setup_weapon_hud`.

---

## 2. Screen Overlays

These elements sit on top of the Core Gameplay HUD and blur/dim the background when active.

### Pause Screen (`pause_screen`)
*   Activated by pressing `ESC` or automatically triggered when the application window loses focus (e.g., Alt-Tabbing).
*   Blurs the background and sets `get_tree().paused = true`, fully freezing the entire scene tree (clouds, ocean waves/shaders, physics, animations, particles). The HUD's root `CanvasLayer` uses `PROCESS_MODE_ALWAYS` to remain interactive. All exit paths (Resume, Retry, Main Menu) correctly unpause the tree before transitioning.
*   Contains the `SettingsScreen` (Volume, Sensitivity, Reduce Motion, Vibration, Fullscreen, Language toggles), the `FiltersScreen` (Retro Colors and visual filter toggles), the `ControllerScreen` (Controls), the `CreditsScreen`, the `AchievementsScreen`, and the `ActiveBuffsScreen`.
    *   All these full-screen menus follow a strict unified layout: left-aligned content with a 96px margin, a 40x40 dynamic gold-tinted title icon, a 2px horizontal separator under the title, and exactly 24px of vertical separation between all primary layout components. Menu buttons (including all BACK buttons) uniformly use a standard size of 280x52 and share identical visual styling across 4 interaction states (Normal, Hover, Pressed, Disabled).
    *   The **PauseScreen** features a custom broken-border design with an animated procedurally-drawn vector sun graphic situated perfectly within a 320px gap in the bottom-right corner.
    *   The **CreditsScreen** uses a vertically scrolling `ScrollContainer` with a cinematic auto-scroll effect that can be overridden by manual mouse scrolling.
    *   The **AchievementsScreen** uses a vertically scrolling `ScrollContainer` displaying dynamically built panels for all configured achievements, utilizing custom icons sourced from Game-icons.net. Locked achievements clearly display their full titles and unlock descriptions but are visually greyed out to indicate their locked status. It operates completely independently of the game's pause state (PROCESS_MODE_ALWAYS) to ensure its internal UI scrolling physics and animations never freeze when accessed from the Pause menu.

### Filters Screen (`FiltersScreen`)
*   Accessed from the Pause Screen via the "FILTERS" button. Uses a gold-tinted 3D glasses icon (`3d-glasses.png`) in its title.
*   Houses visual post-processing toggles, separating graphic customization from the core Settings screen. Filter toggles are mutually exclusive (only one can be active at a time):
    *   **Retro Colors:** PS1-style 15-bit color depth reduction posterization (32 levels per RGB channel).
    *   **Dithering:** 4x4 Bayer ordered cross-hatch dithering matrix for classic vintage console shading.
    *   **Heatwave 1984:** Sun-bleached 35mm / Kodachrome vintage film simulation with warm halation and analog celluloid grain.
*   Adheres strictly to the unified layout: 40x40 gold title icon, 2px horizontal divider, high-contrast toggle buttons (OFF/ON states), standard 280x44 BACK button, and animated "PRESS ESC TO CLOSE" prompt. Fully translated in English and Korean.

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
*   **Stats Menu:** An interactive overlay matching the `Achievements` menu design, showcasing persistent data like Total Water Sprayed, Solar Flares Intercepted, Seagulls Shooed, Supernovas (deaths), Highest Score, and Unlocked Achievements dynamically pulled from `GameState.gd`.

### End State Screens
*(Note: All end state screens (Win, End, Lose) utilize the unified `StyleBoxFlat_border` golden overlay to align with the global menu aesthetic.)*
*   **`WinScreen`:** Shown upon completing a wave. Displays level complete text and loading text. The presentation uses a multi-stage cinematic fade sequence: the screen fades to black, the WinScreen loads behind the overlay, the overlay fades out to reveal the menu, the player reads it, and then the screen fades to black again for the environment reset before finally fading into the next level. This exact cinematic sequence is also utilized in Endless Mode during Boss Waves to present the Drafting Screen.
*   **`EndScreen`:** Shown upon beating the entire game (Normal Mode). Features a distinct text hierarchy separating the subtitle, final level statistics, and a bright cyan `UnlockPrompt` that notifies the player they have unlocked Endless Mode.
*   **`LoseScreen`:** Shown if the Sun hits 100% heat. Instead of an immediate popup, this triggers a dramatic Supernova cinematic (massive sun expansion, screen shake, blinding flash) that fades into the menu. Features a fully opaque background to block HDR bleed, a perfectly centered vertical layout for dramatic emphasis, and offers Retry/Menu buttons styled exactly like the Pause menu.

---

## 3. Localization Support

All labels within the HUD are dynamically localized in `HUD.gd` via the `_apply_language(lang: String)` function.
*   **English (EN):** Uses `Kenney Future.ttf`
*   **Korean (KR):** Uses `Galmuri11.ttf`. Font sizes are manually boosted (e.g., from 22px to 26px) to match the visual weight of the English pixel font.

---

## 4. CanvasLayer Hierarchy

To correctly manage drawing order between the 3D world, global post-processing effects, and the 2D UI, the game utilizes multiple `CanvasLayer` nodes:
*   **Layer 0 (Post-Processing):** A full-screen `ColorRect` is dynamically injected at runtime behind the HUD. It runs `retro_postprocess.gdshader`, capturing the `SCREEN_TEXTURE` (which is the 3D game world) and applying color grading, film grain, and dynamic gameplay borders (e.g., Heat Warning, Frost Border).
*   **Layer 10 (HUD):** The main `HUD.tscn` root operates at layer 10. This ensures that UI elements, crosshairs, and text remain crisp, legible, and completely unaffected by the retro shader.

---

## 5. Global UI Interactions (`UIJuice.gd`)

To prevent the massive procedural UI scripts (`HUD.gd` and `TitleScreen.gd`) from being bloated with hundreds of manual signal connections for hover effects and audio feedback, the project uses a global Autoload (`UIJuice.gd`). 
*   It operates in `PROCESS_MODE_ALWAYS` and hooks into the `SceneTree.node_added` signal.
*   Any `Button` or `Slider` that enters the tree automatically receives dynamic scale tweens (1.03x hover, 0.97x press) and an `-18 dB` 1800Hz sine sweep audio tick on interaction. This ensures a consistent, juicy arcade feel across all menus without polluting the layout logic.
