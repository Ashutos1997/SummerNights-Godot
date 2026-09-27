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

### Top-Right
* **TopRightInfo (VBoxContainer):** Strict 24px right-aligned container.
  * **TimerLabel:** Wave time remaining. Pulses red and bounces when <10s.
  * **ScoreLabel:** Live arcade score. Scales up on score events.
* **WeatherIconContainer:** Persistent icon showing active weather (Normal, Rain, Eclipse).
* **WeatherTimerLabel:** Precise eclipse countdown (requires "Shadow Walker" achievement).
* **ToastContainer:** Deferred transient alerts (weapon unlocks, Catastrom/Celestial ready, shield prompts).

### Center
* **Crosshair:** Dynamic reticle scaling on hits. Inner ring tracks water capacity. Flashes red when empty, green on crits.
  * *Weapon Shapes:* Unique geometry per weapon. Blade Mode uses katana crescent brackets ($R = 24\text{px}$) with tsuba accents.
  * *Celestial Timer Ring:* 360° depleting cyan ring ($R = 38\text{px}$) with diamond accent and micro-timer countdown. Pulses orange at $\le 3.0\text{s}$.
* **Damage Numbers:** Floating 3D text for hits, golden crits, and cyan/gold `DEFLECTED` feedback. Electric cyan during Celestial Awakening.
* **ComboLabel & Callouts:** Displays combo multiplier (up to 3.0x) and arcade text (e.g., "CHILL!").
* **FlareRings:** 2D diegetic charging rings telegraphing incoming flares.

### Bottom-Right (Resource Meters)
* **Retro Flat Plates:** 38x38 dark plates (4px radii) housing vector icons.
  * *Water:* Cyan border. Flashes red below 20%. Always visible.
  * *Ice Burst:* Frost border. Dims when empty. Unlocks Wave 2 / Level 3.
  * *Catastrom / Celestial Awakening (Power Up):* Dynamic plate with 200x24 gauge powered by a shared pool. Standard weapons use purple border, `meter_catastrom.svg`, and "[F] CATASTROM READY!" at 100%. Kitsune Buster IX uses cyan border, `meter_celestial.svg`, and "[F] CELESTIAL AWAKEN!" with active countdown. Reaching 100% displays a matching toast alert.
* **Water Bar:** Oceanic blue gauge (200x24).
* **Ice Bar:** Cyan-frost gauge with charge notches and numeric counter (`charges / max`).
* **Catastrom / Celestial Bar:** Purple or luminous cyan gauge tracking 0%–100% charge or active duration.

### Bottom-Left
* **Active Weapon Display:** Glowing vector icon and localized name. Kitsune Buster IX dynamically displays `[CANNON]` vs `[BLADE]` (`[AWAKENED]` prefix during super).

---

## 2. Screen Overlays (Menus)
* **Unified Styling:** All menus use a 96px left margin, 24px vertical separation, golden borders, dark dim, and 280x52 buttons.
* **PauseScreen (`ESC`):** Pauses tree. Houses Settings, Filters, Controls, Credits, Achievements, and Buffs.
* **CreditsScreen:** Autoscrolling bilingual listing with complete 1:1 asset attributions.
* **AchievementsScreen:** 3-column retro list tracking 13 achievements with live counters and gold badges.
* **DraftingScreen (Perks):** Post-boss modal. Staggered card deal entrance with rarity badges.
* **FiltersScreen:** Mutually exclusive post-processing options (Retro Colors, Dithering, PS1 Shading, Heatwave 1984).
* **ControllerScreen:** Keyboard/Xbox layout toggle with unified "Power Up" labels for `[F]` and `[RB]`, and Mode Change (`[X]` Keyboard / `[Y]` Xbox, magenta highlight).
* **SettingsScreen:** 3 categorized sections (`AUDIO`, `GAMEPLAY & CONTROLS`, `DISPLAY & SYSTEM`) using retro badges and off-white row labels.
* **WeaponWheel (`TAB`):** Slows time to 0.2x. 6-slice procedural wedge with 3D previews, stat bars, and crit multipliers.
* **TitleScreen:** Main menu with custom Godot boot splash, high score, and Best Endless Wave display.
* **End State Screens:** Frameless stats flow for Wave Reached, Survival Time, and Score.

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
