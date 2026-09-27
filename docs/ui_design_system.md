# Summer Nights: UI Design System

Design tokens, color palettes, typography, and component specifications for *Summer Nights*.

---

## 1. Color Palette
* **Primary Accents:** Deep Gold `Color(1.0, 0.75, 0.15, 1.0)`, Bright Yellow `Color(1.0, 0.85, 0.2, 1.0)`.
* **Secondary Accents:** Cyan `Color(0.2, 0.8, 1.0, 1.0)`, Water Blue `Color(0.1, 0.65, 0.95, 1.0)`.
* **Energy Shields:** Cyan Boss Shield `Color(0.2, 0.8, 1.0, 0.9)`, Golden Drone Shield `Color(1.0, 0.82, 0.18, 0.95)`.
* **Backgrounds:** Global Menu `Color(0.02, 0.01, 0.05, 0.96)`, Dark Panel `Color(0.05, 0.02, 0.1, 0.85)`.
* **Controller Highlights:** Gold (Pause), Lime (Weapons), Cyan (Ice Blast), Orange (Power Up), Magenta (Mode Change).

## 2. Corner Radii
* **0px:** Standard buttons (Main Menu, dialog popups).
* **4px:** Retro Flat Plates and Badges (Resource meters, Perks, Stat rows).
* **16px:** Large panels and overlays (Weapon Wheel, Cards).

## 3. Typography
* **English (EN):** `Kenney Future.ttf` (Titles/Headers), `Inter-Medium.ttf` (Body/Labels).
* **Korean (KR):** `Galmuri11.ttf` (Used globally for all Korean text).
* **Styling:** Heavy black outlines (2–3px) and drop shadows for clear sky legibility.

## 4. UI Components

### Global Menus
* **Borders:** 2px gold border `Color(1.0, 0.85, 0.2, 0.4)` with 8px radius and 24px screen margin.
* **Layout:** Strict left-aligned content with a 96px margin (except centered Lose Screen). 24px vertical separation.
* **Titles:** 40x40 gold icons paired with a 2px horizontal separator rule.

### HUD Alignment & Resource Meters
* **Margins:** 24px screen margins for Top-Right info and Bottom-Right resources.
* **Resource Plates:** 38x38 dark plates (4px radii, 1px accent border) for consistent starting coordinates.
* **Gauge Dimensions:** Uniform 200x24 gauges with 10px rounded corners.
  * *Water:* Blue fill, red pulse below 20%.
  * *Ice Burst:* Cyan-frost fill with notch dividers and numeric counter (`charges / max`). Unlocks Wave 2 / Level 3.
  * *Catastrom / Celestial Awakening (Power Up):* Shared pool gauge. Standard weapons render purple Catastrom; Kitsune Buster IX renders cyan Celestial Awakening with active countdown. Reaching 100% triggers a dedicated toast alert.

### Buttons (StyleBoxFlat)
* **Size:** Minimum `280x52`, font size `22px`, `0px` radius.
* **States:** Normal (40% black bg, 2px gold border), Hover (20% gold bg), Pressed (40% gold bg, bright gold border).
* **Juice (`UIJuice.gd`):** 1.03x hover scale, 0.97x press bounce, -18dB audio ticks.

### Interactive Elements
* **Weapon Wheel:** 6 procedural slices with 12px linear gap spacing, centered 3D previews, and 4px depth shadows. Bottom card displays archetype badges, responsive stat bars, and crit multipliers.
* **Drafting Screen (Perks):** 3-card deal entrance with 6px drop shadows and rarity badges (`[ RARE ]`, `[ UNCOMMON ]`, `[ COMMON ]`).
* **Achievement Cards:** 700x100 cards with 64x64 icon plates, progress bars, and cyber gold completion badges.
* **Settings Screen:** 3 categorized sections (`AUDIO`, `GAMEPLAY & CONTROLS`, `DISPLAY & SYSTEM`) using retro badges, 12px VBox separation, 28px category clearance, and 17px off-white body labels (`Color(0.92, 0.92, 0.92, 0.95)`).
* **Game Over Recap:** Frameless 380px stat rows with 32x32 retro plates and milestone badges (`[ NEW BEST! ]`).
* **Celestial Awakening Presentation:**
  * *Layer 0 (World):* "Ethereal Domain" post-process filter with indigo split-toning and anamorphic cyan lens flares.
  * *Layer 10 (HUD):* Breathing cyan energy vignette (`celestial_vignette.gdshader`), 360° reticle timer ring, and holographic text shadows.
  * *Audio:* CC0 activation swell (`celestial_activate.wav`) and deactivation dissipation (`celestial_deactivate.wav`).

### Boot Splash & Startup Continuity
* **Window Initialization:** Launches directly with dark background `Color(0.02, 0.01, 0.05, 1)` with stock splash disabled.
* **Branding Sequence:** Monochrome Godot logo with "M A D E   W I T H" gold text, flanked by 2px hairline wings.
* **Frame Tracing:** Dedicated `SplashBorderDrawer` progressively traces the 2px gold frame over 3.0s in sync with `ps1_startup.wav`, transitioning smoothly to the title screen.

## 5. Procedural Sun Expressions & Rays
* **Face Texture:** 128x128 RGBA8 procedural texture with 4px outline, reacting to heat and combat events.
* **Coronal Halo:** Additive coronal glow and heat ripples (`god_rays.gdshader`) that expand and extinguish with sun temperature.

## 6. Post-Processing & Screen Effects
* **Layering:** `retro_postprocess.gdshader` on Layer 0 (behind HUD Layer 10) to preserve UI sharpness.
* **Dynamic Overlays:** Heat Warning (pulsing red border at 85% heat) and Frost Border (icy tint on Ice Burst).
* **Energy Shield FX:** Fresnel glow with ripple rings and floating cyan `DEFLECTED` combat feedback.
* **Retro Filters:** Mutually exclusive post-processing (Retro Colors, Dithering, PS1 Shading, Heatwave 1984).
