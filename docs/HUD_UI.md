# Summer Nights: HUD UI Layout

Architectural map and layout reference for `HUD.tscn`.

---

## 1. Core Gameplay HUD

### Top-Left
* **LevelLabel:** Current stage (e.g., `LVL 01` or `WAVE 01`).
* **ActivePerksHUD:** Grid of 32x32 retro plates tracking drafted perks. Stacks display an "xN" badge.

### Top-Center
* **SunHeatBar:** Celsius readout (`HEAT | X°C`). Fills up to 100% (Supernova Game Over).
* **Phase2Label:** Warning text for boss transitions.
* **Achievement & Buff Toasts:** 500px Cyberpunk Arcade Plates (4px radius, 1px cyber hairline, softened shadow) sliding down to `y = 24.0` (or `y = 106.0` when stacked) with recessed 40x40 icon plates, bilingual 3-tier typography (10px kicker, 14px title, 12px description with dynamic 88px multi-line height), and 1.5px auto-dismiss depletion countdown bars with upward float dismissal.

### Top-Right
* **TopRightInfo (VBoxContainer):** Strict 24px right-aligned container.
  * **TimerLabel:** Wave time remaining. At wave/level start, fades into screen center (`scale 1.6x`), holds for `2.5s` (allowing clear reading of the live countdown), and glides smoothly over `0.85s` (`TRANS_QUAD` / `TRANS_SINE`) directly into its top-right HUD anchor. Suppressed immediately if any modal menu is open or if paused. Pulses red and bounces when <10s. In Boss Overtime ("Paid in Full"), displays pulsing crimson `[ OVERTIME ]` / `[ 연장전 ]` badge.
  * **ScoreLabel:** Live arcade score. Scales up on score events; flashes warning red during Overtime score drain.
* **WeatherIconContainer:** Persistent icon showing active weather (Normal sun with solar gold modulate, Rain, Eclipse with silver-blue crescent, Coronal Eclipse with custom `eclipse-flare.svg` in ultraviolet).
* **WeatherTimerLabel:** Precise eclipse countdown (requires "Shadow Walker" achievement).
* **ToastContainer (VBoxContainer):** 380px right-docked notification column (24px screen margin, 8px separation). Renders Cyberpunk Arcade Plate alerts (weapon unlocks, Catastrom/Celestial ready, weather events, Solar Disruptions [Thermal Barrier, Flare Barrage], Solar Convergence Infinity Lattice, Harmonic Matrix, Interceptor Escorts, shield prompts, drone caches) with recessed 40x40 icon plates, 3-tier bilingual typography (`Kenney Future` headers / `Inter-Medium` & `Galmuri11` body), 1.5px bottom depletion countdown bars, and automatic upward reflow.

### Center
* **Crosshair:** Dynamic reticle scaling on hits. Inner ring tracks water capacity. Flashes red when empty, green on crits.
  * *Weapon Shapes:* Unique geometry per weapon. Blade Mode uses katana crescent brackets with tsuba accents.
  * *Celestial Timer Ring:* 360° depleting cyan ring with micro-timer countdown. Pulses orange at ≤3.0s.
* **Damage Numbers:** Floating 3D text for hits, golden crits, and parry feedback. Suppressed on energy shields in favor of dedicated HUD banner notifications. Electric cyan during Celestial Awakening.
* **ComboLabel & Callouts:** Displays combo multiplier (up to 3.0x) and arcade text (e.g., "CHILL!").
* **FlareRings:** 2D diegetic charging rings telegraphing incoming flares.

### Bottom-Right (Resource Meters)
* **Retro Flat Plates:** 38x38 dark plates (4px radii) housing vector icons.
  * *Water:* Cyan border. Flashes red below 20%. Always visible.
  * *Ice Burst:* Frost border. Dims when empty. Unlocks Wave 2 / Level 3.
  * *Catastrom / Celestial Awakening:* Dynamic 200x24 gauge. Standard weapons display purple Catastrom plate; Kitsune Buster IX displays cyan Celestial Awakening plate with countdown. Dedicated toast alerts at 100%.
* **Water Bar:** Oceanic blue gauge (200x24).
* **Ice Bar:** Cyan-frost gauge with charge notches and numeric counter (`charges / max`).
* **Catastrom / Celestial Bar:** Purple or luminous cyan gauge tracking 0%–100% charge or active duration.

### Bottom-Left
* **Active Weapon Display:** Glowing vector icon and localized name. Kitsune Buster IX dynamically displays `[CANNON]` vs `[BLADE]` (`[AWAKENED]` prefix during super).

---

## 2. Screen Overlays (Menus)
* **Z-Index Layering:** All modal menus (`PauseScreen`, `DraftingScreen`, `SettingsScreen`, `FiltersScreen`, `ControllerScreen`, `CreditsScreen`, `AchievementsScreen`, `BuffsScreen`, `WeaponWheel`, `WinScreen`, `EndScreen`, `LoseScreen`) render at `z_index = 50`, strictly above all HUD gameplay elements (`z_index = 0`). Opening any menu immediately dismisses active timer intro animations. Screen transition fades render at `z_index = 100`.
* **Unified Styling:** All menus use a 96px left margin, 24px vertical separation, golden borders, dark dim, uniform Back buttons, and localized "PRESS ESC TO CLOSE" / "닫으려면 ESC를 누르세요" guidance prompts.
* **PauseScreen (`ESC`):** Pauses tree. Clean vertical layout (280px width, 16px separation, 44px uniform buttons) housing Resume, Settings, Filters, Credits, Controls, Achievements, Buffs, and Main Menu with unbroken 8-button focus navigation.
* **CreditsScreen:** Autoscrolling bilingual listing with complete 1:1 asset attributions.
* **AchievementsScreen:** Scrollable retro list tracking 14 achievements on 700x100 cards (4px Retro Flat Plate radius, 64x64 icon plates, concentric 4px/3px progress bars), live counters, gold completion badges, and [ESC] close prompt.
* **DraftingScreen (Perks):** Post-boss modal. Staggered card deal entrance with rarity badges, `[ MAX ROLL! ]` golden highlights, and amber stack badges (`[ 3RD STACK · 75% ]` / `[ 3중첩 · 효율 75% ]`) with live recalculated effective descriptions when stacking $\ge 2$ copies.
* **FiltersScreen:** Mutually exclusive post-processing options (Retro Colors, Dithering, PS1 Shading, Heatwave 1984) with standardized 16px body typography (`Inter-Medium.ttf` / `Galmuri11.ttf`) and 110x34px toggle buttons.
* **ControllerScreen:** Keyboard/Xbox layout toggle with unified "Power Up" labels for `[F]` and `[RB]`, and Mode Change (`[X]` Keyboard / `[Y]` Xbox, magenta highlight).
* **SettingsScreen:** 3 categorized sections (`AUDIO`, `GAMEPLAY & CONTROLS`, `DISPLAY & SYSTEM` with Fullscreen, conditional Gold Weapon Skin toggle unlocked at 50k points, and Language) using 14px retro badges, 16px body font row labels (`Inter-Medium.ttf` / `Galmuri11.ttf`), 14px toggle buttons (even number system), and real-time numeric/percentage readouts (`100%`, `1.0x`).
* **WeaponWheel (`TAB`):** Slows time to 0.2x. 6-slice procedural wedge with 3D previews, stat bars, and crit multipliers.
* **TitleScreen:** Main menu with custom Godot boot splash, clarified subtitle ("COOL DOWN THE SUN BEFORE TIME RUNS OUT" / "제한 시간 내에 태양을 식혀라"), semantic stat coloring (Cyber Gold High Score, Neon Mint Wave Record), crisp stationary typography, direct access to full dedicated Settings modal, 24px stats breathing space, hairline mode divider, uniform button styling, desktop `[ESC]` quit guidance, and version-stamped footer.
* **End State Screens:** Frameless stats flow for Wave Reached, Survival Time, and Score; displays dedicated bankruptcy subtitle if defeated in Overtime.

---

## 3. Localization
* **English (EN):** `Kenney Future.ttf` (Headers), `Inter-Medium.ttf` (Body).
* **Korean (KR):** `Galmuri11.ttf` (Used globally for all KR text).

---

## 4. CanvasLayer Hierarchy
* **Layer 0:** Full-screen `ColorRect` running 3D post-processing shaders over the world.
* **Layer 10:** Main `HUD.tscn` and menus. Keeps UI completely crisp and unaffected by retro shaders.

---

## 5. UI Architecture
* **UIJuice.gd (Autoload):** Applies 1.03x hover bounces and -18dB audio ticks to all buttons and sliders.
* **Global Z-Depth:** Dynamically injects 4px black drop shadows into all panels and stylized labels.
* **Celestial Vignette:** Radial cyan vignette (`celestial_vignette.gdshader`) active during Celestial Awakening.
