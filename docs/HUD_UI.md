# Summer Nights: HUD UI Layout

Architectural map and layout reference for `HUD.tscn`.

---

## 1. Core Gameplay HUD

### Top-Left
* **LevelLabel:** Current stage display (`LVL 01` or `WAVE 01`).
* **ActivePerksHUD:** 32x32 retro plates tracking drafted perks and stack counts.

### Top-Center
* **SunHeatBar:** Celsius gauge (`HEAT | X°C`). Reaching 100% triggers Supernova.
* **Phase2Label:** Warning banner for boss phase transitions.
* **Achievement & Buff Toasts:** 500px centered plates (4px radius, 40x40 icon, 1.5px depletion bar). Slides from top (`y = 24.0` / `y = 106.0`).

### Top-Right
* **TopRightInfo (VBoxContainer):** 24px right-aligned container.
  * **TimerLabel:** Wave countdown. Intro animation starts centered (`scale 1.6x`, 2.5s hold) and glides (0.85s) into position. Red pulse under 10s. Shows `[ OVERTIME ]` badge during boss overtime.
  * **ScoreLabel:** Live score display. Flashes red during Overtime score burn.
* **WeatherIconContainer:** Persistent weather indicator (Normal, Rain, Eclipse, Coronal Eclipse).
* **WeatherTimerLabel:** Eclipse duration timer.
* **ToastContainer (VBoxContainer):** 380px notification column (8px gap) for combat and unlock alerts with 1.5px depletion bars and staggered reflow.

### Center
* **Crosshair:** Dynamic weapon reticle tracking water tank.
  * *Blade Mode:* Katana crescent brackets with tsuba accents.
  * *Celestial Timer:* 360° cyan countdown ring (pulses orange at ≤3.0s).
* **Damage Numbers:** Floating 3D hit and parry numbers (suppressed on shields).
* **ComboLabel & Callouts:** Combo multiplier (up to 3.0x) and arcade text callouts.
* **FlareRings:** 2D telegraph rings for incoming solar flares.

### Bottom-Right (Resource Meters)
* **Resource Plates:** 38x38 dark plates (4px radius) for Water, Ice, and Power Up.
* **Water Bar:** 200x24 blue gauge; red flash below 20%.
* **Ice Bar:** 200x24 cyan gauge with charge notch dividers and numeric counter.
* **Catastrom / Celestial Bar:** 200x24 purple or cyan gauge tracking charge or active timer.

### Bottom-Left
* **Active Weapon Display:** Vector icon and localized name (`[CANNON]` / `[BLADE]` / `[AWAKENED]`).

---

## 2. Screen Overlays (Menus)
* **Z-Index Layering:** All modal menus render at `z_index = 50` above HUD gameplay elements (`z_index = 0`). Opening any menu immediately cancels active timer intros. Screen fades use `z_index = 100`.
* **Styling:** 96px left margin, 24px vertical gap, gold borders, and localized "PRESS ESC TO CLOSE" prompts.
* **PauseScreen (`ESC`):** 280px vertical button stack (Resume, Settings, Filters, Credits, Controls, Achievements, Buffs, Menu).
* **CreditsScreen:** Autoscrolling bilingual credits with complete asset attributions.
* **AchievementsScreen:** 700x100 card list tracking 14 achievements with progress bars and badges.
* **DraftingScreen (Perks):** 3-card post-boss modal with rarity badges, `[ MAX ROLL! ]` highlights, and stack warning badges.
* **FiltersScreen:** Mutually exclusive post-processing options (Retro Colors, Dithering, PS1 Shading, Heatwave 1984).
* **ControllerScreen:** Keyboard and Xbox layout diagrams with control legends.
* **SettingsScreen:** 3 sections (`AUDIO`, `GAMEPLAY & CONTROLS`, `DISPLAY & SYSTEM`) with even-number typography and live slider readouts.
* **WeaponWheel (`TAB`):** 0.2x slow-mo 6-slice wedge with 3D previews, stat bars, and crit multipliers.
* **End State Screens:** Fullscreen modal overlays (`WinScreen`, `EndScreen`, `LoseScreen`) with content container rendered above `BorderPanel` to eliminate drop shadow dimming.
  * *WinScreen:* Level complete breakdown with loading status.
  * *LoseScreen:* Wave reached, survival time, score recap, and bankruptcy subtitle if defeated in Overtime.
  * *EndScreen (Normal Victory):* Hero title (`SUMMER'S OVER`), lore subtitle, diamond divider, milestone unlock tag, 344px telemetry grid (`LEVELS CLEARED 6 / 6`, `CLEAR TIME`, `FINAL SCORE`), and dual 160x44px buttons (`PlayAgainBtn`, `MenuBtn`).

---

## 3. Localization
* **English (EN):** `Kenney Future.ttf` (Headers), `Inter-Medium.ttf` (Body).
* **Korean (KR):** `Galmuri11.ttf` (Universal KR font).

---

## 4. CanvasLayer Hierarchy
* **Layer 0:** Fullscreen post-processing shaders over 3D world.
* **Layer 10:** Main `HUD.tscn` and UI overlays (unaffected by 3D shaders).

---

## 5. UI Architecture
* **UIJuice.gd (Autoload):** 1.03x hover bounce and -18dB audio ticks on all buttons and sliders.
* **Global Z-Depth:** Injects 4px black drop shadows into panels and stylized labels.
* **Celestial Vignette:** Radial cyan screen vignette during Celestial Awakening.
