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
* **Unified Resource Meters:** All resource rows (Water, Ice, Catastrom) utilize uniform 200x24 gauges with 10px rounded corners. Ice Burst uses a unified cyan-frost bar with discrete vertical notch dividers and an overlaid real-time numeric counter (`charges / max_charges`), avoiding cluttered pill fragmentation at high charge counts. Secondary (Ice Burst) and Ultimate (Catastrom) gauges dynamically remain hidden until unlocked (Wave 2 / Level 3 for Ice, Wave 4 / Level 4 for Catastrom) to prevent peripheral clutter during early waves.

### Buttons (StyleBoxFlat)
* **Size:** Minimum `280x52`, font size `22px`, `0px` radius.
* **States:** 
  * *Normal:* 40% black bg, 2px gold border.
  * *Hover:* 20% gold bg.
  * *Pressed:* 40% gold bg, bright gold border.
* **Juice:** Global Autoload (`UIJuice.gd`) applies 1.03x hover scale, 0.97x press bounce, and -18dB audio ticks.

### Interactive Elements
* **Sliding Toggle Pill:** Binary toggle (EN/KR, Keyboard/Xbox) with a sliding gold highlight block and smooth color lerping.
* **Weapon Wheel:** Procedural wedges drawn via `_draw()` with subtle 4px drop shadows matching global HUD panels and constant 12px linear gap spacing between slices. Plays `-18dB` audio ticks via `UIJuice.play_tick()` on weapon highlight. Features an arcade-style bottom information panel with gold border (unlocked) or steel-grey border (locked), displaying weapon archetype badges, mini progress bars for cooling power and water capacity, and critical multipliers. Typography strictly pairs Kenney Future (gun name) with Inter-Medium (body/stats) in English, and Galmuri11 globally in Korean.
* **Drafting Screen (Perk Cards):** Tactile staggered card deal entrance (`Tween` scale pop and alpha fade) accompanied by rhythmic audio ticks. Features 6px drop shadows and rarity badges (`[ RARE ]`, `[ UNCOMMON ]`, `[ COMMON ]`) with color-tinted borders.
* **Achievement Progress Readouts:** 3-column layout featuring a dedicated status column. Locked achievements show numerical counters (`current / max`) and mini gold progress bars (8px height, 4px corner radii, dark background). Unlocked achievements display a cyber gold completion badge (`[ ✔ COMPLETED ]` / `[ ✔ 완료 ]`).

### Boot Splash & Startup Continuity
* **Engine Window Launch:** Window initializes directly with the theme's dark background `Color(0.02, 0.01, 0.05, 1)` with stock boot splash disabled, avoiding grey screen flashes.
* **Isolated Void & Subtle Ambient Halo:** During startup, an opaque background curtain `Color(0.02, 0.01, 0.05, 1.0)` isolates the branding sequence in a dark void. Centered behind the emblem is a subtle, warm amber/gold radial backlight (`Color(1.0, 0.72, 0.2, 0.09)`) that gently breathes with the synth chord swell, transforming the flat void into an illuminated studio space.
* **Monochrome Emblem & Centered Wing Dividers:** Centered official Godot Engine monochrome white logo (`logo_large_monochrome_dark.png`, 400x162) paired with wide letter-tracked "M A D E   W I T H" in refined gold (`Color(1.0, 0.85, 0.2, 0.95)` at 36px / 32px for KR), flanked on left and right by 2px hairline divider wings (`Color(1.0, 0.85, 0.2, 0.4)`) vertically center-aligned with the text and matching the exact 400px width of the Godot logo. Elements fade in with cubic easing (0.0s - 0.7s), perform a majestic slow camera push-in (`0.96 -> 1.015`), and dissolve out with soft sine easing (2.1s - 2.8s).
* **Golden Frame Tracing:** Dedicated `SplashBorderDrawer` performs progressive vector polyline tracing (`border_progress` 0.0 to 1.0 over 3.0s with quad deceleration) drawing the exact 2px gold border (`Color(1.0, 0.85, 0.2, 0.4)`, 8px radius, 24px screen margin) in sync with `ps1_startup.wav`. At 3.0s, the frame seamlessly handoffs to the permanent `BorderPanel` with zero flicker.
* **Cinematic Curtain Reveal & Staggered Entrance:** As the golden frame completes, the dark curtain smoothly dissolves (`modulate:a` 1.0 -> 0.0 over 0.85s with sine easing), unveiling the sunny 3D beach world in a cinematic bloom while the "SUMMER NIGHTS" title, language toggle, and credit line glide in with staggered cubic easing (0.12s, 0.15s, 0.18s).

## 5. Procedural Sun Expressions
* **Rendering:** 128x128 RGBA8 procedural texture with a 4px dark-orange outline.
* **Expressions:** Changes dynamically based on heat (happy, neutral, annoyed, angry) and events (wince, crit_pain, charging, dread, dizzy).
* **Jitter:** Positional micro-shake applied on water impacts (disabled with Reduce Motion).

## 6. Post-Processing & Screen Effects
* **Layering:** `retro_postprocess.gdshader` runs on Layer 0 (behind HUD on Layer 10) to keep UI crisp.
* **Base Effects:** S-Curve contrast, Synthwave split-toning, vignette, and animated film grain.
* **Dynamic Overlays:** Heat Warning (pulsing red border at 85% heat) and Frost Border (icy blue tint on Ice Burst).
* **Energy Shield & Deflection FX:** Procedural Fresnel energy shield with dynamic shader ripple rings, localized impact glow (`energy_shield.gdshader`), backward water droplet bounce particles (`GPUParticles3D`), and floating electric cyan `DEFLECTED` feedback labels.
* **Retro Filters:** Mutually exclusive options (Retro Colors, Dithering, PS1 Shading, Heatwave 1984).
* **Blur/Dim:** Menus apply a 0.3s tweened blur (up to 2.0) and dim (0.6) to the background scene.

