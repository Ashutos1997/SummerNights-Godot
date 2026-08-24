# Summer Nights: UI Design System

This document outlines the UI design system, color palette, typography guidelines, and specific component styles used in the Godot 4 implementation of *Summer Nights*.

## 1. Color Palette

### Primary Accents (Golden / Solar)
- **Primary Text / Main Accent:** `Color(1.0, 0.75, 0.15, 1.0)` (Deep Golden Yellow)
- **Bright Accent (Highlights):** `Color(1.0, 0.85, 0.2, 1.0)` (Bright Yellow)
- **Title Highlights (Weapon Wheel):** `Color(1.0, 0.95, 0.5, 1.0)` (Pale Gold)

### Secondary Accents (Cooling / Ice / Water)
- **Cyan Accent (Survival Mode):** `Color(0.2, 0.8, 1.0, 1.0)`
- **Water UI Bars:** `Color(0.1, 0.65, 0.95, 1.0)` (Features smooth internal value lerping, but must bypass lerp and instantly snap its visual representation whenever the maximum capacity changes to prevent UI flashing).

### Controller Highlights (Keybindings)
- **Pause / Gold:** `Color(1.0, 0.843, 0.0, 1.0)` (Yellow)
- **Weapons / Lime:** `Color(0.5, 0.9, 0.1, 1.0)` (Lime Green)
- **Ice Blast / Cyan:** `Color(0.31, 0.765, 0.969, 1.0)` (Blue)
- **Catastrom / Orange:** `Color(1.0, 0.427, 0.0, 1.0)` (Orange)

### Backgrounds & Panels
- **Global Menu Background:** `Color(0.02, 0.01, 0.05, 0.96)` (Extremely dark, almost solid black for full-screen pause/settings menus)
- **Dark Panel Background:** `Color(0.05, 0.02, 0.1, 0.85)` (Very dark, slightly purple-tinted black for UI panels)
- **Standard UI Background:** `Color(0.0, 0.0, 0.0, 0.4)` (Semi-transparent black)

### Text & Outlines
- **Primary Text:** White or Gold (depending on hierarchy)
- **Muted Text / Credits:** `Color(1.0, 1.0, 1.0, 0.7)`
- **Shadows / Outlines:** `Color.BLACK` or `Color(0, 0, 0, 0.8)`

---

## 2. Corner Radius System

To maintain a consistent shape language across the game, corner rounding follows strict rules based on component size and function:

*   **Small / Standard Buttons:** `0px` (Square corners, used for Main Menu buttons, simple prompts)
*   **Large Panels & Cards:** `16px` (Highly rounded corners, used for Weapon Wheel, large UI overlays, etc. to create a sleek and premium aesthetic)

---

## 3. Typography

The game uses custom fonts loaded via `.ttf` and applied programmatically depending on the UI context and the active language setting.

*   **English (EN):**
    *   **Titles & Headers:** `Kenney Future.ttf` (Bold, squared-off arcade look)
    *   **Body Text & Descriptions:** `Inter-Medium.ttf` (Clean, highly legible sans-serif for paragraphs)
*   **Korean (KR):**
    *   **All Text:** `Galmuri11.ttf` (Retro pixel-art aesthetic that natively supports full KR characters while maintaining the game's style)

### Text Outlines and Shadows
To ensure legibility against the bright, 3D sun background, heavy outlines and drop shadows are applied to all text.

*   **Main Titles (e.g., Title Screen):**
    *   Size: `72px`
    *   Outline Size: `8px` (Black)
    *   Shadow Offset: `x: 4, y: 4`
    *   Shadow Color: `Color(0, 0, 0, 0.8)`
    *   Shadow Outline Size: `12px`
*   **Subtitles:**
    *   Size: `18px` (EN) / `20px` (KR)
    *   Outline Size: `4px` (Black)
*   **Buttons:**
    *   Size: `18px` (EN) / `20px` (KR)
    *   Outline Size: `2px` (Black)
*   **Warning Timers (e.g., Eclipse Countdown):**
    *   Size: `24px`
    *   Text Color: `Color(1, 0, 0, 1)` (Red)
    *   Outline Size: `4px` (Black)

---

## 4. UI Component Styles

### Global Menu Borders
All full-screen menus (Title Screen, Pause Screen, Settings, Credits, etc.) are unified by a consistent golden border overlay to tie the visual language together:
*   **Padding / Offset:** 24px from all screen edges
*   **Border Width:** 2px (All sides)
*   **Border Color:** `Color(1.0, 0.85, 0.2, 0.4)`
*   **Corner Radius:** 8px
*   **Fade Animation:** Menus tween the entire screen node (`self.modulate:a`) seamlessly over 0.5s rather than fading individual components out-of-sync.
*   **Startup Animation:** The Title Screen border features a custom `_draw()` sequence that procedurally traces the 8px rounded rectangle perimeter over 4.0 seconds to sync with the boot audio, perfectly matching the final `StyleBoxFlat`.

### Menu Interiors
All menus (Pause, Settings, Credits, Achievements, Buffs) follow a strict internal layout logic:
*   **Alignment:** Content is always left-aligned (anchored to the left) with a `96px` margin from the global border. *(Exception: The Lose Screen features a perfectly centered layout to emphasize the dramatic Game Over Supernova cinematic transition.)*
*   **Vertical Flow:** All primary interior components (e.g., Title Row, Divider, Body Content) are separated by exactly `24px` of vertical spacing to ensure perfect visual rhythm across all menus.
*   **Title Icons:** Each menu title is preceded by a `40x40` icon (`TextureRect` using Game-icons.net SVGs/PNGs) wrapped in a `TitleRow` HBoxContainer (separation `12px`). The icons are dynamically tinted to exactly match the gold color of their respective titles.
*   **Title Separator:** An `HSeparator` sits directly beneath the TitleRow.
    *   **Color:** `Color(1.0, 0.88, 0.3, 0.35)`
    *   **Thickness:** `2px`
*   **Edge Alignment:** When aligning nested child elements (e.g., the controls graphic and legend) to the outer edges of the main menu boundaries, expanding spacers (`size_flags_horizontal = 3`) are utilized within an HBoxContainer to guarantee perfect, responsive left/right symmetry against the top and bottom dividers.

### Buttons (StyleBoxFlat)

Buttons use a sleek, semi-transparent flat style with thick borders.

*   **Corner Radius:** `0px` (Standard buttons)
*   **Menu Buttons Sizing:** `custom_minimum_size = Vector2(280, 52)` with font size `22px`

*   **Normal State:**
    *   Background: `Color(0, 0, 0, 0.4)`
    *   Border: `Color(1.0, 0.85, 0.2, 0.6)`
    *   Border Width: `2px` (All sides)
    *   Content Margins: `Left/Right: 16px`, `Top/Bottom: 8px`
*   **Hover State:**
    *   Background: `Color(1.0, 0.75, 0.15, 0.2)`
    *   Border: Same as Normal
*   **Pressed (Click) State:**
    *   Background: `Color(1.0, 0.85, 0.2, 0.4)`
    *   Border: `Color(1.0, 0.9, 0.3, 1.0)`
*   **Disabled State:**
    *   Background: `Color(0, 0, 0, 0.2)`
    *   Border: `Color(0.5, 0.5, 0.5, 0.5)`
*   **Focus State:**
    *   Background: `Color(0, 0, 0, 0)`
    *   Border: `Color(1.0, 0.85, 0.2, 1.0)`
    *   Border Width: `2px`
    *   Corner Radius: `6px`

### Panels & Overlays (Weapon Wheel Style)

Panels like the Weapon Wheel info box use a distinct, rounded "sleek" aesthetic.

*   **Background:** `Color(0.05, 0.02, 0.1, 0.85)`
*   **Borders:**
    *   Color: `Color(1.0, 0.9, 0.3, 1.0)`
    *   Width: `2px` (All sides)
*   **Corner Radius:** `16px` (All corners)
*   **Content/Expand Margins:** `Left/Right: 16px`, `Top/Bottom: 8px`

### Toast Notifications (Catastrom Popup)

Transient popups that slide in from the top of the screen to notify the player of critical events (e.g., Catastrom Ultimate ready).

*   **Background & Borders:** Inherits the "Panels & Overlays" style.
*   **Icon:** Includes a `32x32` pixel icon (e.g., Catastrom logo).
*   **Text & Accent:** Uses the Bright Accent `Color(1.0, 0.85, 0.2, 1.0)`.
*   **Animation:** Uses a Sine ease-out tween to slide the `position.y` onto the screen and hold for 3 seconds before sliding back up.

### Achievement Icons

All achievements utilize thematic, open-source vector graphics from Game-icons.net (CC BY 3.0). These are imported as crisp PNGs to maintain consistency with the arcade aesthetic.

### Sliding Toggle Pill

A sleek, modern binary toggle used for premium settings like the Language switch (EN/KR) and the Controls device selector (Keyboard/Xbox).

*   **Container:** Uses a flat `ColorRect` background `Color(0, 0, 0, 0.4)` and a `ReferenceRect` golden border `Color(1.0, 0.85, 0.2, 0.6)` with `2px` width.
*   **Labels:** Uses an `HBoxContainer` spanning the entire rect, containing two labels with equal size flags. Text is completely borderless.
*   **Highlight Block:** A solid `ColorRect` using the Bright Accent `Color(1.0, 0.85, 0.2, 1.0)` that covers exactly half the toggle.
*   **Animation:** When clicked, a parallel Tween smoothly interpolates the Highlight Block's `position.x` to the opposite side over `0.25s` with `TRANS_SINE` easing, while simultaneously tweening the font color of the active label to black `Color(0, 0, 0, 1.0)` and the inactive label to gold `Color(1.0, 0.85, 0.2, 1.0)` for high contrast.

### Screen Overlays (Blur / Dim)

When a menu or overlay is shown (e.g., Pause, Weapon Wheel), the screen behind it is blurred and dimmed using a custom screen-reading shader.

*   **Shader Parameters:**
    *   `blur_amount`: Transitions from `0.0` to `2.0`
    *   `dim_amount`: Transitions from `0.0` to `0.6`
*   **Transition Duration:** `0.3s` (Tweened)

---

## 5. Animation & Polish

*   **UI Tick Audio:** When clicking buttons or opening menus, a synthesized 1800Hz sine sweep UI tick plays at `-18 dB`.
*   **Prompts (e.g., "Click to Continue"):** Use a Sine ease-in-out tween looping to pulse the alpha between `0.7` and `1.0` over `1.2s`.
*   **Weapon Wheel:** Selected wedge stroke turns from dark brown (`Color(0.4, 0.35, 0.2, 0.8)`) to bright gold (`Color(1.0, 0.9, 0.3, 1.0)`).
*   **Combo UI:** The combo multiplier fades in and out dynamically.
*   **Combo Callouts:** Arcade-style floating text callouts for combo milestones. The text rapidly scales up to 1.2x and snaps back with a slight random rotation tilt to emphasize the impact, before fading out.
*   **Live Score Counter:** When the score increases, the score label rapidly interpolates to the new value. It scales up to `1.2x` and snaps back to `1.0x` over `0.2s`, pivoting from the right edge to prevent the text from scaling off the screen.

## 6. Global Post-Processing & Screen Effects
To unify the arcade aesthetic, a global post-processing shader (`retro_postprocess.gdshader`) is applied dynamically at runtime to a CanvasLayer sitting at `layer = 0` (behind the `layer = 10` UI elements).

*   **Color Grading:** S-Curve contrast boost combined with Synthwave split-toning (deep blue/purple shadows and warm golden highlights).
*   **Film Grain:** Animated noise added to the screen to simulate retro CRT/film quality. It automatically switches to a static noise pattern when the 'Reduce Motion' accessibility setting is enabled to prevent rapid flickering.
*   **Vignette:** A soft, darkened edge vignette (`intensity: 0.4`, `opacity: 0.5`) focuses the player's attention on the center of the screen.
