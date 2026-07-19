# 🌅 Summer Nights

> A vibrant 3D arcade water-gun shooter built in Godot 4 — cool down a relentless summer sun before the heat overwhelms you!

---

## 🎮 Gameplay

You stand on a tropical beach island armed with a high-powered water cannon. The giant glowing Sun sits on the horizon, constantly heating up. **Blast it with water to cool it down** across 5 scaling levels of difficulty.

- The **sky shifts dynamically** from scorching red → golden orange → cool dusk blue as the Sun cools.
- White-hot **Solar Heat Vents** appear on the Sun's surface for 2.4× critical cooling bonuses.
- The Sun launches **fiery Solar Flare Embers** in parabolic arcs — intercept them mid-air with water to earn **+30% Water Tank** refills!

---

## 🕹️ Controls

| Input | Action |
|---|---|
| Move mouse | Aim the water cannon |
| Left click (hold) | Fire continuous water spray |
| ESC | Open Settings / Credits |

---

## ✨ Features

- 🌊 Water tank resource management — drain & recharge cycle with sputtering prevention
- ☀️ White-hot solar heat vents with critical cooling & steam geyser effects
- ☄️ Solar flare ember projectiles in parabolic arcs — intercept for water refills
- ☁️ Procedural drifting 3D low-poly clouds (`CloudLayer.gd`)
- 🕊️ Circling low-poly seagulls with wing flapping animation (`SeagullLayer.gd`)
- 🌴 Dynamic wind sway on tropical palm trees and bushes
- 🎨 Custom GLSL shaders — sunset sky, heat haze distortion, stylized ocean ripples
- ♿ WCAG 2.1 AA/AAA compliant UI — high-contrast mode, reduce motion, adjustable sensitivity
- 🖥️ Exported as Universal Binary (macOS Intel + Apple Silicon) and Windows `.exe`

---

## 🚀 Running the Project

1. Open **Godot 4.7.1** (stable)
2. In the Project Manager, click **Import**
3. Navigate to this folder and select **`project.godot`**
4. Click **Import & Edit**, then press **F5** (or ▶ Play) to run

---

## 🗂️ Project Structure

```
SummerNights-Godot/
├── project.godot
├── scenes/
│   ├── TitleScreen.tscn      ← Title menu
│   ├── LoadingScreen.tscn    ← Root loading overlay
│   ├── Main.tscn             ← 3D gameplay scene
│   └── HUD.tscn              ← 2D UI layer
├── scripts/
│   ├── Main.gd               ← Core game loop, solar flares, vents, environment
│   ├── HUD.gd                ← HUD, settings, credits, crosshair, victory screens
│   ├── CloudLayer.gd         ← Procedural drifting 3D clouds
│   ├── SeagullLayer.gd       ← Animated low-poly seagulls
│   ├── GameState.gd          ← Autoload state (level, volume, accessibility)
│   └── LoadingScreen.gd      ← Smooth loading screen transitions
└── assets/
    ├── summer_night_sky.gdshader
    ├── heat_haze.gdshader
    ├── stylized_water.gdshader
    ├── models/               ← sun_lowpoly.glb
    ├── pirate/               ← Palm trees, rocks, sand (Kenney CC0)
    └── audio/                ← 100% CC0 SFX
```

---

## 🎨 Tech Stack

| Area | Technology |
|---|---|
| Engine | Godot Engine 4.7.1 (stable) |
| Rendering | Forward+ (Metal / Vulkan) |
| Language | GDScript |
| Post-FX | SSAO, SSIL, SSR, Volumetric Fog, Bloom |

---

## 📦 Credits & Assets

> **0% GenAI** — all assets are hand-crafted, CC0 open-source, or procedural GDScript.

| Asset | Author | License |
|---|---|---|
| 3D Sun Model — PS1 Style Low Poly Sun | albert_buscio (Sketchfab) | CC0 |
| 3D Gun Model — 3D Blaster | Kenney | CC0 |
| Palm Trees, Rocks, Sand — Pirate Pack | Kenney | CC0 |
| Stylized Sky Shader | MinionsArt | CC0 |
| Stylized Water Shader | Jtfinlay | MIT |
| Heat Haze Screen Distortion | MinionsArt | CC0 |
| Font — Kenney Future | Kenney | CC0 |
| UI Pack Adventure | Kenney | CC0 |
| SFX — 40 CC0 Water/Splash/Slime | OpenGameArt | CC0 |
| SFX — Water Gun Shot | belanhud (Freesound) | CC0 |
| SFX — UI Audio Pack | Kenney | CC0 |
| Procedural 3D Clouds & Seagulls | Hand-crafted GDScript | — |
