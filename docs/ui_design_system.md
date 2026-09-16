# Summer Nights: UI Design System

This document outlines the UI design system, color palette, typography, and component styles for *Summer Nights*.

---

## 1. Color Palette
* **Primary Accents:** Deep Gold `Color(1.0, 0.75, 0.15, 1.0)`, Bright Yellow `Color(1.0, 0.85, 0.2, 1.0)`.
* **Secondary Accents:** Cyan `Color(0.2, 0.8, 1.0, 1.0)`, Water Blue `Color(0.1, 0.65, 0.95, 1.0)`.
* **Backgrounds:** Global Menu `Color(0.02, 0.01, 0.05, 0.96)`, Dark Panel `Color(0.05, 0.02, 0.1, 0.85)`.
* **Controller Highlights:** Gold (Pause), Lime (Weapons), Cyan (Ice Blast), Orange (Catastrom).

## 2. Corner Radii
* **0px:** Standard buttons (Main Menu, popups).
* **4px:** Retro Flat Plates and Badges (Resource meters, Perks).
* **16px:** Large panels and cards (Weapon Wheel, Overlays).

## 3. Typography
* **English (EN):** `Kenney Future.ttf` (Titles/Headers), `Inter-Medium.ttf` (Body).
* **Korean (KR):** `Galmuri11.ttf` (Used globally for all KR text).
* **Styling:** All text uses heavy black outlines and drop shadows to ensure legibility against the bright 3D sky.

## 4. UI Components

### Global Menus
* **Borders:** All full-screen menus use a 2px golden border `Color(1.0, 0.85, 0.2, 0.4)` with an 8px radius and 24px screen margin.
* **Layout:** Strict left-aligned content with a 96px margin (except the centered Lose Screen). Exactly 24px vertical spacing between elements.
* **Titles:** Use 40x40 dynamically tinted gold icons and a 2px horizontal separator.

### HUD Alignment
* **Right-Edge:** Top-Right info (Timer, Score) and Bottom-Right resources (Meters) use a strict 24px right-aligned screen margin.
* **Resource Plates:** 38x38 dark plates (4px radii, 1px accent border) ensure consistent horizontal starting coordinates regardless of language.

### Buttons (StyleBoxFlat)
* **Size:** Minimum `280x52`, font size `22px`, `0px` radius.
* **States:** 
  * *Normal:* 40% black bg, 2px gold border.
  * *Hover:* 20% gold bg.
  * *Pressed:* 40% gold bg, bright gold border.
* **Juice:** Global Autoload (`UIJuice.gd`) applies 1.03x hover scale, 0.97x press bounce, and -18dB audio ticks.

### Interactive Elements
* **Sliding Toggle Pill:** Binary toggle (EN/KR, Keyboard/Xbox) with a sliding gold highlight block and smooth color lerping.
* **Weapon Wheel:** Procedural wedges drawn via `_draw()` with subtle 4px drop shadows matching global HUD panels. Locked weapons are dark gray, unlocked are gold.

## 5. Procedural Sun Expressions
* **Rendering:** 128x128 RGBA8 procedural texture with a 4px dark-orange outline.
* **Expressions:** Changes dynamically based on heat (happy, neutral, annoyed, angry) and events (wince, crit_pain, charging, dread, dizzy).
* **Jitter:** Positional micro-shake applied on water impacts (disabled with Reduce Motion).

## 6. Post-Processing & Screen Effects
* **Layering:** `retro_postprocess.gdshader` runs on Layer 0 (behind HUD on Layer 10) to keep UI crisp.
* **Base Effects:** S-Curve contrast, Synthwave split-toning, vignette, and animated film grain.
* **Dynamic Overlays:** Heat Warning (pulsing red border at 85% heat) and Frost Border (icy blue tint on Ice Burst).
* **Retro Filters:** Mutually exclusive options (Retro Colors, Dithering, PS1 Shading, Heatwave 1984).
* **Blur/Dim:** Menus apply a 0.3s tweened blur (up to 2.0) and dim (0.6) to the background scene.
