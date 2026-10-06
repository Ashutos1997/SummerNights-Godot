# Summer Nights: UI Design System

Design tokens, color palettes, typography, and component specifications for *Summer Nights*.

---

## 1. Color Palette
* **Primary Accents:** Deep Gold `Color(1.0, 0.75, 0.15, 1.0)`, Bright Yellow `Color(1.0, 0.85, 0.2, 1.0)`.
* **Secondary Accents:** Cyan `Color(0.2, 0.8, 1.0, 1.0)`, Water Blue `Color(0.1, 0.65, 0.95, 1.0)`.
* **Hazard & Alert:** Amber Stack Warning `Color(1.0, 0.75, 0.2, 0.95)`, Overtime Crimson `Color(1.0, 0.22, 0.22)`.
* **Shields:** Boss Cyan `Color(0.2, 0.8, 1.0, 0.9)`, Golden Drone `Color(1.0, 0.82, 0.18, 0.95)`.
* **Atmospheric:** Rainstorm Cyan `Color(0.4, 0.85, 1.0)`, Lunar Silver `Color(0.85, 0.95, 1.0)`, Coronal Ultraviolet `Color(0.95, 0.35, 1.0)`, Prominence Magenta `Color(1.0, 0.20, 0.90)`.
* **Backgrounds:** Global Modal `Color(0.02, 0.01, 0.05, 0.96)`, Dark Panel `Color(0.05, 0.02, 0.1, 0.85)`.
* **Controller:** Gold (Pause), Lime (Weapons), Cyan (Ice), Orange (Power Up), Magenta (Mode).

## 2. Corner Radii
* **0px:** Standard buttons (Main Menu, dialogs, Back buttons).
* **3px:** Progress Bar fill (`4px` track - `1px` padding).
* **4px:** Retro Flat Plates and Badges (Meters, Perks, Stats, Toasts, Cards).
* **8px:** Global menu modal frames (2px gold border).
* **16px:** Radial panels (Weapon Wheel).

## 3. Typography
* **English (EN):** `Kenney Future.ttf` (Headers), `Inter-Medium.ttf` (Body).
* **Korean (KR):** `Galmuri11.ttf` (Universal KR font).
* **Outlines:** 2–3px black outlines with drop shadows.

## 4. UI Components

### Global Menus
* **Layering:** Modal menus render at `z_index = 50`. Transitions use `z_index = 100`.
* **Frames:** 2px gold border `Color(1.0, 0.85, 0.2, 0.4)` with 8px radius and 24px screen margin.
* **Layout:** Left-aligned 96px margin (except centered Win/End/Lose). 24px vertical separation.

### Resource Meters
* **Plates:** 38x38 dark plates (4px radius, 1px border) with 24px screen margins.
* **Gauges:** 200x24 with 10px rounded corners.
  * *Water:* Blue fill; red pulse below 20%.
  * *Ice Burst:* Cyan-frost fill with notch dividers and counter.
  * *Power Up:* Shared gauge (Purple Catastrom or Cyan Celestial).

### Popup Notifications (Toasts)
* **Form Factor:** Cyberpunk Arcade Plates (4px radius, 1px accent border, softened shadow).
* **Alerts (380x72px):** Right-docked with 3.5s depletion bar, 0.45s slide-fade, and staggered exit.
* **Popups (500x72–88px):** Centered popups for Achievements and Buffs sliding from `y = -100` to `y = 24.0` / `106.0`.
* **Icon Plate:** Recessed 40x40px plate with 26x26 vector icon.
* **Typography:** 10px kicker tag, 14px header title, 12px description.

### Buttons (StyleBoxFlat)
* **Size:** Minimum `280x52` (or `160x44` in dual clusters), font `22px` (or `16–17px`), `0px` radius.
* **States:** Normal (40% black, 2px gold border), Hover (20% gold), Pressed (40% gold).
* **Juice (`UIJuice.gd`):** 1.03x hover scale, 0.97x press bounce, -18dB audio ticks.

### Interactive Elements
* **Weapon Wheel:** 6 slices, 12px gap, 3D previews, stat bars, and crit multipliers.
* **Drafting Screen:** 3-card deal entrance with rarity badges, `[ MAX ROLL! ]` highlights, and stack warning badges.
* **Achievement Cards:** 700x100 cards (4px radius, 64x64 icon plate, concentric progress bars).
* **Settings Screen:** 3 categorized sections (`AUDIO`, `GAMEPLAY & CONTROLS`, `DISPLAY & SYSTEM`) with even-number typography and live slider readouts (`100%`, `1.0x`).
* **Pause Menu:** Flat 280px vertical column (16px gap, 44px uniform buttons).
* **Title Screen:** Symmetrical horizontal split (840x400) with 340px vertical divider, twin 144x52 stats cards, and mode buttons.
* **Timer Glide Intro:** Center countdown (`scale 1.6x`, 2.5s hold) glides (0.85s) into top-right anchor.
* **Overtime HUD:** Pulsing crimson `[ OVERTIME ]` badge, red score burn feedback, and bankruptcy recap subtitle.
* **Victory Recap ("SUMMER'S OVER"):**
  * *Title:* Single-line 56px EN / 50px KR Cyber Gold with 10px shadow outline.
  * *Subtitle:* 14px EN / 15px KR off-white with 2px outline.
  * *Divider:* Twin 48x1.5px amber hairlines flanking 11px diamond symbol `◇`.
  * *Milestone Tag:* 12px EN / 13px KR Neon Cyan with 4px shadow outline.
  * *Telemetry Grid (344px):* Levels Cleared (`6 / 6`), Clear Time (`MM:SS`), Final Score climax (22px EN / 19px KR Cyber Gold).
  * *Buttons (344px):* Dual 160x44px buttons (`[ PLAY AGAIN ]`, `[ MAIN MENU ]`) with 24px gap.

### Boot Splash
* **Mode:** Launches in fullscreen with dark background `Color(0.02, 0.01, 0.05, 1)`.
* **Sequence:** Monochrome Godot logo with gold lettering, progressively tracing 2px border over 3.0s.

## 5. Procedural Expressions & Effects
* **Sun Face:** 128x128 procedural texture with 4px outline.
* **Overtime Shock:** Contracted pill eyes, arched brows, open jaw, and temple sweat droplet.
* **Coronal Halo:** Additive coronal glow and heat ripples (`god_rays.gdshader`).
* **Post-Processing:** `retro_postprocess.gdshader` on Layer 0 (behind HUD Layer 10).
* **Retro Filters:** Retro Colors, Dithering, PS1 Shading, Heatwave 1984.
