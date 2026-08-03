# Summer Nights: UI Design System

This document outlines the UI design system, color palette, typography guidelines, and specific component styles used in the Godot 4 implementation of *Summer Nights*.

## 1. Color Palette

### Primary Accents (Golden / Solar)
- **Primary Text / Main Accent:** `Color(1.0, 0.75, 0.15, 1.0)` (Deep Golden Yellow)
- **Bright Accent (Highlights):** `Color(1.0, 0.85, 0.2, 1.0)` (Bright Yellow)
- **Title Highlights (Weapon Wheel):** `Color(1.0, 0.95, 0.5, 1.0)` (Pale Gold)

### Secondary Accents (Cooling / Ice / Water)
- **Cyan Accent (Survival Mode):** `Color(0.2, 0.8, 1.0, 1.0)`
- **Water UI Bars:** `Color(0.1, 0.65, 0.95, 1.0)`

### Backgrounds & Panels
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

All in-game UI uses the custom font (loaded via `.ttf` and applied programmatically).

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

---

## 4. UI Component Styles

### Buttons (StyleBoxFlat)

Buttons use a sleek, semi-transparent flat style with thick borders.

*   **Corner Radius:** `0px` (Standard buttons)

*   **Normal State:**
    *   Background: `Color(0, 0, 0, 0.4)`
    *   Border: `Color(1.0, 0.85, 0.2, 0.6)`
    *   Border Width: `2px` (All sides)
    *   Content Margins: `Left/Right: 16px`, `Top/Bottom: 8px`
*   **Hover State:**
    *   Background: `Color(1.0, 0.75, 0.15, 0.2)`
*   **Pressed State:**
    *   Background (Normal Mode): `Color(1.0, 0.8, 0.2, 0.4)`
    *   Background (Endless Mode): `Color(0.2, 0.8, 1.0, 0.4)`
*   **Focus State:**
    *   `StyleBoxEmpty` (Removes default Godot focus rectangle)

### Panels & Overlays (Weapon Wheel Style)

Panels like the Weapon Wheel info box use a distinct, rounded "sleek" aesthetic.

*   **Background:** `Color(0.05, 0.02, 0.1, 0.85)`
*   **Borders:**
    *   Color: `Color(1.0, 0.9, 0.3, 1.0)`
    *   Width: `2px` (All sides)
*   **Corner Radius:** `16px` (All corners)
*   **Content/Expand Margins:** `Left/Right: 16px`, `Top/Bottom: 8px`

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
