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
  * *Weapon Shapes:* Unique shapes for each weapon (Standard, Precision, Heavy, Scatter, Gatling, Kitsune Buster IX Cannon, and Kitsune Buster IX Blade mode). In Blade mode, the reticle adopts curved katana crescent brackets ($R = 24\text{px}$), winged golden tsuba crossguard accents, an interior precision pip, and an expanding water-charge ring; blade swings emit a golden-white Foxfire Slash Wave directly along the crosshair aim ray.
  * *Celestial Timer Ring:* During Celestial Awakening, a full 360° depleting cyan ring ($R = 38\text{px}$, $3.5\text{px}$ thick) wraps the reticle clockwise from 12 o'clock with a faint outer glow trail ($R = 40\text{px}$), an expanded diamond bloom accent on the Kitsune reticle, and inline micro-timer readout below. Shifts to orange with faster pulse at $\le 3.0\text{s}$.
* **Celestial Toast & Ethereal Domain Filter:** On activation, a pill-style toast notification (matching achievement/buff pill design) slides in from the top with celestial cyan border/shadow, "POWER UNLEASHED!" header, and "CELESTIAL AWAKENING" / "신성의 각성" title. Auto-dismisses after 4s. Mode also triggers a Layer 0 "Ethereal Domain" post-process filter (0.45s Tokusatsu Henshin spacetime shockwave, horizontal anamorphic cyan lens flares on peak emissives, indigo shadows, optical highlight bloom, edge refraction; strictly mode-exclusive and absent from regular filter menus) grading only the 3D world while HUD Layer 10 stays clean.
* **Damage Numbers & Deflection Feedback:** Floating 3D text showing damage (`-%d`), golden weak-point crits, or electric cyan `DEFLECTED` labels. During Celestial Awakening, damage numbers glow radiant electric cyan (`Color(0.17, 0.90, 1.0)`) with a deep navy outline (`Color(0.04, 0.22, 0.38)`).
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
* **Active Weapon Display:** Glowing vector crosshair with elemental background and localized weapon name. Toggling modes on the Kitsune Buster IX dynamically displays `[CANNON]` vs `[BLADE]` (`[포격 모드]` vs `[검 모드]`). During Celestial Awakening, gains `[AWAKENED · CANNON]` / `[AWAKENED · BLADE]` (`[신성 · 포격]` / `[신성 · 검]`) badges with breathing cyan border glow. Top-Left/Top-Right labels project holographic cyan shadows (`Color(0.17, 0.90, 1.0, 0.3)`).

---

## 2. Screen Overlays (Menus)
* **Unified Menu Styling:** All full-screen menus use a 96px left margin, 24px vertical separation, golden borders, dark background dim, and standard 280x52 buttons.
* **PauseScreen (`ESC` or Auto-Pause):** Freezes the 3D scene tree (`get_tree().paused = true`). Includes Settings, Filters, Controls, Credits, Achievements, and Buffs. Features a broken-border design with an animated sun. The Credits screen features an autoscrolling bilingual listing with complete 1:1 third-party asset attributions (including Kitsune Buster IX Cannon & Blade 3D models, celestial slash SFX, Godot Engine branding, procedural boot splash, coronal halo, stats plates, and Celestial Awakening audio), audio/visual systems, and non-profit fan project disclaimers matching README documentation.
* **Achievements Screen:** 3-column retro list showing status readouts across all 13 achievements inside an autoscrolling container. Icons are housed in 64x64 retro flat plates (gold border unlocked, steel border locked with mystery silhouette). Locked achievements display live numerical counters (`current / max`) and mini gold progress bars (8px, 4px radii); completed achievements display a cyber gold completion badge.
* **Drafting Screen (Perks):** Post-boss upgrade modal. Features staggered card entrance animations, audio deal ticks, 6px drop shadows, and rarity tags (`[ RARE ]`, `[ UNCOMMON ]`, `[ COMMON ]`).
* **FiltersScreen:** Mutually exclusive post-processing options (Retro Colors, Dithering, PS1 Shading, Heatwave 1984).
* **ControllerScreen:** Sliding toggle between Keyboard and Xbox layouts.
* **SettingsScreen:** Features 3 categorized sections (`AUDIO`, `GAMEPLAY & CONTROLS`, `DISPLAY & SYSTEM`) using tactile retro plate badges (`4px` radii, gold border), trailing hairline rules, refined vertical spacing (12px VBox separation, 28px section clearance, 22px title gap), 28px title, and 17px off-white row label typography (`Color(0.92, 0.92, 0.92, 0.95)`).
* **WeaponWheel (`TAB`):** Slows time to 0.2x. Draws procedural wedges for up to 6 weapons with subtle 4px drop shadows matching global HUD visor depth, constant 12px linear gap spacing between slices, and plays button hover tick audio on selection. Features an arcade-style bottom info card with archetype badges, a faint golden hairline divider (`Color(1.0, 0.85, 0.2, 0.28)`), cooling power and capacity mini-gauge bars, and critical multipliers, styled with Kenney Future headers and Inter-Medium body text in English (Galmuri11 in Korean). Hazard timers pause while open.
* **TitleScreen:** Main menu featuring custom "Made with Godot" boot splash with isolated void presentation, progressive golden frame tracing, monochrome engine branding, synchronized PS1 synth boot audio, cinematic curtain reveal, Quit confirmation, Lifetime Stats (with gold monochrome icon plates), Best Endless Wave and Time title banner ("BEST ENDLESS: WAVE X (MM:SS)"), and Achievement progress list.
* **End State Screens:** Win, End, and Lose screens. Lose screen is centered to emphasize the Supernova cinematic. Features a clean frameless stats flow (32x32 retro plates with gold monochrome icons, localized labels, values, and milestone badges) for Wave Reached, Survival Time, and Final Score without nested box containers, persisting `best_wave` and `best_survival_time` alongside `high_score`. *(Known Issue: End-of-run Win and Lose screens currently render darker than intended; under active investigation.)*

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
* **Celestial Energy Vignette Aura & Audio Cues:** On Celestial Awakening, a full-screen shader-driven radial vignette (`celestial_vignette.gdshader`) fades in around screen edges in breathing electric cyan (`Color(0.17, 0.90, 1.0)`, alpha 0.25, 3 rad/s pulse; shifts to amber at $\le 3.0\text{s}$) alongside synchronized anime Henshin activation audio (`celestial_activate.wav` by TheLittleCrow) and a decelerating cooldown dissipation SFX (`celestial_deactivate.wav` by bevibeldesign). HUD elements (gold typography, retro plates) remain completely untouched.
