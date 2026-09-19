# Summer Nights: HUD UI Layout

This document serves as a visual map and architectural breakdown of the `HUD.tscn` scene during gameplay.

---

## 1. Core Gameplay HUD
Designed to minimize clutter while keeping survival info in the player's peripheral vision.

### Top-Left
* **LevelLabel:** Current stage (e.g., `LVL 01` or `WAVE 01`).
* **ActivePerksHUD:** Grid of 32x32 retro plates tracking drafted Rogue-lite perks. Duplicates stack with an "xN" badge.

### Top-Center
* **SunHeatBar:** Critical UI. Live Celsius readout (`HEAT | X°C`). Fills up to 100% (Game Over).
* **Phase2Label:** Warning text for boss transitions.

### Top-Right
* **TopRightInfo (VBoxContainer):** Ensures perfect right-alignment.
  * **TimerLabel:** Wave time remaining. Pulses red and bounces when <10s.
  * **ScoreLabel:** Live arcade score. Scales up on scoring points.
* **WeatherIconContainer:** Persistent icon showing active weather (Normal, Rain, Eclipse).
* **WeatherTimerLabel:** Shows precise eclipse countdown (requires "Shadow Walker" achievement).
* **ToastContainer:** Deferred transient notifications (e.g., weapon unlocks, catastrom unlock, and shield shatter tactical prompts).

### Center
* **Crosshair:** Dynamic diegetic reticle. Scales on hits. Inner ring tracks water capacity. Flashes red when empty, green on critical hits.
  * *Weapon Shapes:* Unique shapes for each weapon (Standard, Precision, Heavy, Scatter, Gatling).
* **Damage Numbers & Deflection Feedback:** Floating 3D text showing damage (`-%d`), golden weak-point crits, or electric cyan `DEFLECTED` labels when firing at an active Solar Flare Shield.
* **ComboLabel & Callouts:** Displays combo multiplier (up to 3.0x) and arcade text (e.g., "CHILL!").
* **FlareRings:** 2D diegetic charging rings projecting the sun's 3D radius to telegraph incoming flares.

### Bottom-Right (Resource Meters)
* **Retro Flat Plates:** 38x38 dark plates (4px radii) housing vector icons.
  * *Water:* Cyan border. Flashes red below 20%. Always visible.
  * *Ice Burst:* Frost border. Dims when empty. Hidden on Wave 1 / Level 1-2 (unless bonus charges held); unlocks on Wave 2 / Level 3.
  * *Catastrom:* Purple border. Pulses gold when ready. Hidden on Waves 1-3 / Levels 1-3; unlocks on Wave 4 / Level 4 with a dedicated toast notification.
* **Water Bar:** Oceanic blue gauge.
* **Ice Bar:** Cyan-frost gauge matching Water & Catastrom dimensions (200x24), featuring etched divider notches per charge and an overlaid numeric counter (e.g., 10 / 10). Dims when depleted. Only displays when unlocked or charges are available.
* **Catastrom Bar:** Purple gauge. Flashes "MAX READY!" at 100%. Only visible and actively charging from Wave 4+ or Level 4+.

### Bottom-Left
* **Active Weapon Display:** Glowing vector crosshair with elemental background and localized weapon name.

---

## 2. Screen Overlays (Menus)
* **Unified Menu Styling:** All full-screen menus use a 96px left margin, 24px vertical separation, golden borders, dark background dim, and standard 280x52 buttons.
* **PauseScreen (`ESC` or Auto-Pause):** Freezes the 3D scene tree (`get_tree().paused = true`). Includes Settings, Filters, Controls, Credits, Achievements, and Buffs. Features a broken-border design with an animated sun. The Credits screen features an autoscrolling bilingual listing with complete third-party asset attributions, procedural systems, and non-profit fan project disclaimers.
* **Achievements Screen:** 3-column retro list showing status readouts. Locked achievements display live numerical counters (`current / max`) and mini gold progress bars (8px, 4px radii); completed achievements display a cyber gold completion badge.
* **Drafting Screen (Perks):** Post-boss upgrade modal. Features staggered card entrance animations, audio deal ticks, 6px drop shadows, and rarity tags (`[ RARE ]`, `[ UNCOMMON ]`, `[ COMMON ]`).
* **FiltersScreen:** Mutually exclusive post-processing options (Retro Colors, Dithering, PS1 Shading, Heatwave 1984).
* **ControllerScreen:** Sliding toggle between Keyboard and Xbox layouts.
* **WeaponWheel (`TAB`):** Slows time to 0.2x. Draws procedural wedges for 5 weapons with subtle 4px drop shadows matching global HUD visor depth and plays button hover tick audio on selection. Hazard timers pause while open.
* **TitleScreen:** Main menu with a 4-second PS1 synth boot animation. Includes Quit confirmation, Lifetime Stats, and Achievement progress list.
* **End State Screens:** Win, End, and Lose screens. Lose screen is centered to emphasize the Supernova cinematic.

---

## 3. Localization
* **English (EN):** `Kenney Future.ttf`
* **Korean (KR):** `Galmuri11.ttf` (upscaled slightly to match English visual weight).

---

## 4. CanvasLayer Hierarchy
* **Layer 0:** Full-screen `ColorRect` running post-processing shaders over the 3D world.
* **Layer 10:** Main `HUD.tscn` and `TitleScreen.tscn`. Keeps UI completely crisp and unaffected by retro shaders.

---

## 5. UI Architecture
* **UIJuice.gd (Autoload):** Automatically applies 1.03x hover scale bounces and -18dB audio ticks to all buttons and sliders game-wide.
* **Global Z-Depth:** `HUD.gd` dynamically injects a 4px black drop shadow into all UI panels and stylized labels to create a layered "3D visor" effect.
