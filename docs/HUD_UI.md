# Summer Nights: HUD UI Layout

Architectural map and layout reference for `HUD.tscn`.

---

## 1. Core Gameplay HUD

### Top-Left
* **LevelLabel:** Current stage display (`LVL 01` or `WAVE 01`).
* **ActivePerksHUD:** 32x32 retro plates tracking drafted perks and stack counts.

### Top-Center
* **SunHeatBar:** Celsius gauge (`HEAT | X°C`). Reaching 100% triggers Supernova.
* **BossEncounterHUD:** Telemetry plate at `y = 86px` (4px radius, 1px gold border). Shows 34x34px icon, two-tier status kicker, 24x24px drone pip wells, and harmonic matrix tethers.
* **Phase2Label:** Warning banner for boss phase transitions.
* **Achievement & Buff Toasts:** 500px centered plates (4px radius, 40x40 icon, 1.5px depletion bar). Slides from top (`y = 24.0` / `y = 106.0`).

### Top-Right
* **TopRightInfo (VBoxContainer):** 24px right-aligned container at `y = 22px` (`offset_bottom = 76px`, 2px separation). Unified 22px typography across both English and Korean.
  * **TimerLabel:** Wave countdown (22px). Intro animation starts centered (`scale 1.6x`, 2.5s hold) and glides (0.85s) into position. Red pulse under 10s. Shows `[ OVERTIME ]` badge during boss overtime.
  * **ScoreLabel:** Live score display (22px). Flashes red during Overtime score burn.
* **Unified Aero-Weather Capsule (`WeatherIconContainer`):** 172x44px telemetry plate at `y = 96px` (4px radius, 1px border). Centered HBox (6px gap):
  * *Vector Arrow:* `◀`, `▶`, or `●` (14px). Bounces 1.25x during gusts.
  * *Speed & Gauge:* 16px knots readout (`19 KTS` / `CALM`) and 3-pip intensity gauge (Tier 1 `<24kts`, Tier 2 `24–35kts`, Tier 3 `≥36kts`). Flashes cyan on surges.
  * *Divider & Icon:* 1px hairline divider and 22x22px weather icon.
* **WeatherTimerLabel:** Eclipse duration timer anchored beneath the weather icon.
* **ToastContainer (VBoxContainer):** 380px notification column at `y = 158px` (8px gap) for combat and unlock alerts with 1.5px depletion bars and staggered reflow.

### Center
* **Crosshair:** Dynamic weapon reticle with 1:1 input. Crosswinds curve water stream over 42m, requiring windage compensation.
  * *Blade Mode:* Katana crescent brackets with tsuba accents.
  * *Celestial Timer:* 360° cyan countdown ring (pulses orange at ≤3.0s).
  * *Thermal Falloff:* Reticle shifts Cyan → Warm Orange (>2s) → Overtime Crimson (>3s) with 12px `[ HEAT FALLOFF ]` steam badge (`icon_spray_falloff.svg`).
* **Damage Numbers:** Floating 3D hit and parry numbers (suppressed on shields).
* **ComboLabel & Callouts:** Combo multiplier (up to 3.0x) and arcade text callouts (`[ REWRITE! ]`, `[ RAINMAKER! ]`, `[ OVERTIME ]`).
* **FlareRings:** 2D telegraph rings for incoming solar flares.

### Bottom-Right (Resource Meters)
* **Resource Plates:** 38x38 dark plates (4px radius) for Water, Ice, and Power Up.
* **Water Bar:** 200x24 blue gauge; red flash below 20%.
* **Ice Bar:** 200x24 cyan gauge with charge notch dividers and numeric counter.
* **Catastrom / Celestial Bar:** 200x24 purple or cyan gauge tracking charge or active timer.

### Bottom-Left
* **Active Weapon Display:** 44px height plate at 24px screen margin with recessed 38x38px icon frame (26x26 vector icon) and 14px/10px localized name and archetype tags.

---

## 2. Screen Overlays (Menus)
* **Z-Index Layering:** All modal menus render at `z_index = 50` above HUD gameplay elements (`z_index = 0`). Opening any menu immediately cancels active timer intros. Screen fades use `z_index = 100`.
* **Styling:** 96px left margin, 24px vertical gap, gold borders, and localized "PRESS ESC TO CLOSE" prompts.
* **PauseScreen (`ESC`):** 280px button stack (Resume, Settings, Filters, Credits, Controls, Achievements, Buffs, Menu). "Main Menu" opens AbandonConfirmModal (440x180px, YES/NO with NO default focus).
* **CreditsScreen:** Autoscrolling bilingual credits with complete asset attributions.
* **AchievementsScreen:** 700x100 card list tracking 14 achievements with progress bars and badges.
* **DraftingScreen (Perks):** 3-card post-boss modal with rarity badges, `[ MAX ROLL! ]` highlights, and stack warning badges.
* **FiltersScreen:** Mutually exclusive post-processing options (Retro Colors, Dithering, PS1 Shading, Heatwave 1984).
* **ControllerScreen:** Keyboard and Xbox layout diagrams with control legends.
* **SettingsScreen:** Symmetrical 4x2 arcade plate (880px, 32px title). Left column: Audio (Music/SFX) & Controls (Sensitivity/Vibration). Right column: Display (Fullscreen/Reduce Motion) & System (Language plate ENG|KOR, Gold Skin).
* **WeaponWheel (`TAB`):** 0.2x slow-mo 6-slice wedge with 3D previews, stat bars, and crit multipliers.
* **End State Screens:** Fullscreen modal overlays (`WinScreen`, `EndScreen`, `LoseScreen`).
  * *WinScreen:* Level complete stats.
  * *LoseScreen:* Wave reached, survival time, score recap, and Overtime bankruptcy subtitle.
  * *EndScreen (Normal Victory):* Hero title (`SUMMER'S OVER`), subtitle, 344px telemetry grid (Levels Cleared, Time, Score), unlock milestones, and Retry/Menu buttons.

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
