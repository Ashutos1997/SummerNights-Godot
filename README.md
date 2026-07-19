[한국어](README.ko.md)

# Summer Nights

A 3D arcade shooter built in Godot 4. Cool down the Sun before the heat overwhelms you.

---

## Gameplay Video

[![Summer Nights - Gameplay](https://img.youtube.com/vi/83qUFqmobwE/maxresdefault.jpg)](https://youtu.be/83qUFqmobwE)

---


You stand on a tropical beach armed with a water cannon. The Sun sits on the horizon, constantly heating up. Blast it with water to cool it down across 5 levels of difficulty.

- The sky shifts dynamically from red to orange to blue as the Sun cools.
- Solar Heat Vents appear on the Sun's surface for critical cooling bonuses.
- The Sun launches Solar Flare Embers in parabolic arcs. Intercept them mid-air with water to earn +30% Water Tank refills.

---

## Controls

| Input | Action |
|---|---|
| Move mouse | Aim the water cannon |
| Left click (hold) | Fire water spray |
| ESC | Open Settings / Credits |

---

## Features

- Water tank resource management with drain and recharge cycle
- Solar heat vents with critical cooling and steam geyser effects
- Solar flare projectiles in parabolic arcs, interceptable for water refills
- Procedural drifting 3D low-poly clouds (CloudLayer.gd)
- Circling low-poly seagulls with wing flapping animation (SeagullLayer.gd)
- Wind sway on palm trees and bushes
- Custom GLSL shaders for sky, heat haze, and ocean ripples
- WCAG 2.1 AA/AAA compliant UI with high-contrast mode, reduce motion, and adjustable sensitivity
- Exported as Universal Binary (macOS Intel + Apple Silicon) and Windows .exe

---

## Running the Project

1. Open Godot 4.7.1 (stable)
2. In the Project Manager, click Import
3. Navigate to this folder and select `project.godot`
4. Click Import & Edit, then press F5 to run

---

## Project Structure

```
SummerNights-Godot/
├── project.godot
├── scenes/
│   ├── TitleScreen.tscn
│   ├── LoadingScreen.tscn
│   ├── Main.tscn
│   └── HUD.tscn
├── scripts/
│   ├── Main.gd               - Core game loop, solar flares, vents, environment
│   ├── HUD.gd                - HUD, settings, credits, crosshair, victory screens
│   ├── CloudLayer.gd         - Procedural drifting 3D clouds
│   ├── SeagullLayer.gd       - Animated low-poly seagulls
│   ├── GameState.gd          - Autoload state (level, volume, accessibility)
│   └── LoadingScreen.gd      - Loading screen transitions
└── assets/
    ├── summer_night_sky.gdshader
    ├── heat_haze.gdshader
    ├── stylized_water.gdshader
    ├── models/
    ├── pirate/
    └── audio/
```

---

## Tech Stack

| Area | Technology |
|---|---|
| Engine | Godot Engine 4.7.1 (stable) |
| Rendering | Forward+ (Metal / Vulkan) |
| Language | GDScript |
| Post-FX | SSAO, SSIL, SSR, Volumetric Fog, Bloom |

---

## Credits

0% GenAI. All assets are hand-crafted, CC0 open-source, or procedural GDScript.

| Asset | Author | License |
|---|---|---|
| 3D Sun Model - PS1 Style Low Poly Sun | albert_buscio (Sketchfab) | CC0 |
| 3D Gun Model - 3D Blaster | Kenney | CC0 |
| Palm Trees, Rocks, Sand - Pirate Pack | Kenney | CC0 |
| Stylized Sky Shader | MinionsArt | CC0 |
| Stylized Water Shader | Jtfinlay | MIT |
| Heat Haze Screen Distortion | MinionsArt | CC0 |
| Font - Kenney Future | Kenney | CC0 |
| Font - Galmuri11 (Korean Support) | quiple | SIL OFL |
| UI Pack Adventure | Kenney | CC0 |
| SFX - 40 CC0 Water/Splash/Slime | OpenGameArt | CC0 |
| SFX - Water Gun Shot | belanhud (Freesound) | CC0 |
| SFX - UI Audio Pack | Kenney | CC0 |
| Procedural Clouds and Seagulls | Hand-crafted GDScript | - |
