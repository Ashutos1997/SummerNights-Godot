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
  * *Catastrom / Celestial Awakening (Power Up):* Shared pool gauge. Standard weapons render purple Catastrom; Kitsune Buster IX renders cyan Celestial Awakening with active countdown. Dedicated toast alerts at 100%.

### HUD Popup Notifications (Toasts)
* **Dimensions:** 380x72px Cyberpunk Arcade Plates (0px corner radius, 1px accent border `Color(color.r, color.g, color.b, 0.35)`). Symmetrical 16px horizontal margins.
* **Icon Plate:** 40x40px recessed plate (`Color(0.02, 0.02, 0.04, 0.95)`, 1px border `0.45` alpha) with 26x26px centered vector icon.
* **Typography (Even-Number System):**
  * *Kicker Tag (10px):* Category badge (`[ UNLOCK ]`, `[ TRANSCEND ]`, `[ WEATHER EVENT ]`) using body typeface (`Inter-Medium.ttf` EN / `Galmuri11.ttf` KR).
  * *Headline (14px):* Crisp white title with 3px black outline using header typeface (`Kenney Future.ttf` EN / `Galmuri11.ttf` KR).
  * *Action Instruction (12px):* Off-white `Color(0.85, 0.88, 0.92)` label with 2px black outline using body typeface (`Inter-Medium.ttf` EN / `Galmuri11.ttf` KR).
* **Auto-Dismiss Depletion Bar:** 1.5px hairline across the full bottom edge (`offset_left = 0.0`) depleting over 3.5s duration.
* **Stacking Reflow:** Stacked inside a 24px right-aligned `VBoxContainer` (8px separation) with animated height collapse (`custom_minimum_size:y` to 0.0) upon dismissal for physics-grade upward reflow.

### Buttons (StyleBoxFlat)
* **Size:** Minimum `280x52`, font size `22px`, `0px` radius.
* **States:** Normal (40% black bg, 2px gold border), Hover (20% gold bg), Pressed (40% gold bg, bright gold border).
* **Juice (`UIJuice.gd`):** 1.03x hover scale, 0.97x press bounce, -18dB audio ticks.

### Interactive Elements
* **Weapon Wheel:** 6 procedural slices with 12px linear gap spacing, centered 3D previews, and 4px depth shadows. Bottom card displays archetype badges, responsive stat bars, and crit multipliers.
* **Drafting Screen (Perks):** 3-card deal entrance with 6px drop shadows and rarity badges (`[ RARE ]`, `[ UNCOMMON ]`, `[ COMMON ]`). Max rolls feature an enhanced golden border and glowing `[ MAX ROLL! ]` / `[ 최고 수치! ]` badge.
* **Achievement Cards:** 700x100 cards with 64x64 icon plates, progress bars, and cyber gold completion badges.
* **Settings Screen:** 3 categorized sections (`AUDIO`, `GAMEPLAY & CONTROLS`, `DISPLAY & SYSTEM`) using 14px retro badges, 12px VBox separation, 28px category clearance, unified body typography (`Inter-Medium.ttf` EN / `Galmuri11.ttf` KR) with 16px off-white labels (`Color(0.92, 0.92, 0.92, 0.95)`), 14px toggle/language buttons (even number system), and dedicated cyber gold real-time slider numeric readouts (`100%`, `1.0x`). Mirrored 1:1 in Title Screen.
* **Pause Menu:** Flat vertical column layout (280px width, 16px separation, 44px uniform buttons) housing Resume, Settings, Filters, Credits, Achievements, Active Buffs, Controls, and Main Menu with unbroken 8-button focus navigation.
* **Title Screen Layout:** Symmetric horizontal split layout centered on screen (840px × 400px, `alignment = ALIGNMENT_CENTER`). Left column: flush-left title (64px EN / 78px KR with 4px letter-spacing), 60px horizontal hairline divider `Color(1.0, 0.75, 0.15, 0.35)`, subtitle (18px EN / 20px KR), high score (Cyber Gold), best endless wave (Neon Mint). 1px × 280px vertical gold hairline divider centered in 56px margin (28px symmetrical padding). Right column: 240px button stack with 60px hairline grouping gameplay modes (`NORMAL MODE`, `ENDLESS MODE`) from system/meta menus (`ACHIEVEMENTS`, `STATS`, `SETTINGS`), `[LOCKED]` state, `[ESC] QUIT GAME` prompt, and version footer (`v1.7`).
* **Celestial Awakening Presentation:**
  * *World (Layer 0):* Ethereal Domain filter with indigo split-toning and cyan anamorphic flares.
  * *HUD (Layer 10):* Breathing cyan energy vignette, 360° reticle timer ring, and holographic text shadows.
  * *Audio:* CC0 activation swell and deactivation dissipation SFX.
* **Paid in Full Overtime HUD:**
  * *Timer Badge:* Pulsing crimson `[ OVERTIME ]` / `[ 연장전 ]` badge (`Color(1.0, 0.22, 0.22)`) with 0.3s sine pulse loop.
  * *Score Drain:* Warning red font color (`Color(1.0, 0.25, 0.25)`) with subtle 1.08x scale twitches per burn pulse.
  * *Bankruptcy Recap:* Dedicated subtitle (`Color(1.0, 0.35, 0.35)`) on defeat screen: `"BANKRUPT: ALL SCORE DEPLETED"` / `"파산: 점수를 모두 소진했습니다"`.

### Boot Splash & Startup Continuity
* **Window Initialization:** Launches directly in Fullscreen mode with dark background `Color(0.02, 0.01, 0.05, 1)` with stock splash disabled.
* **Branding Sequence:** Monochrome Godot logo with "M A D E   W I T H" gold text, flanked by 2px hairline wings.
* **Frame Tracing:** Dedicated `SplashBorderDrawer` progressively traces the 2px gold frame over 3.0s in sync with `ps1_startup.wav`, transitioning smoothly to the title screen.

## 5. Procedural Sun Expressions & Rays
* **Face Texture:** 128x128 RGBA8 procedural texture with 4px outline, reacting to heat and combat events.
* **Overtime Shock:** Procedural expression featuring contracted pill eyes, high arched startled eyebrows, round open dropped jaw, and a procedural temple sweat droplet bead with pale-amber shock modulate (`Color(2.4, 2.0, 1.4, 0.95)`).
* **Coronal Halo:** Additive coronal glow and heat ripples (`god_rays.gdshader`) that expand and extinguish with sun temperature.

## 6. Post-Processing & Screen Effects
* **Layering:** `retro_postprocess.gdshader` on Layer 0 (behind HUD Layer 10) to preserve UI sharpness.
* **Dynamic Overlays:** Heat Warning (pulsing red border at 85% heat) and Frost Border (icy tint on Ice Burst).
* **Energy Shield FX:** Fresnel glow with ripple rings and impact sparks, relying on dedicated bilingual HUD banner notifications for tactical feedback.
* **Retro Filters:** Mutually exclusive post-processing (Retro Colors, Dithering, PS1 Shading, Heatwave 1984).
