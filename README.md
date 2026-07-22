[한국어](README.ko.md)

# Summer Nights

A 3D arcade shooter built in Godot 4. Cool down the Sun before the heat overwhelms you.

---

## Gameplay Video

[![Gameplay Video](https://img.youtube.com/vi/3JcN-FylmtI/maxresdefault.jpg)](https://youtu.be/3JcN-FylmtI)

---

## 🎮 Gameplay
- **Defeat the Sun:** Water the sun to drop its temperature down to 0 before the timer expires! The sun gradually recovers heat over time.
- **5-Level Difficulty:** Each level gets harder with shorter timers, aggressive sun movement (sway and figure-8 paths), and increased heat regeneration.
- **Level 5 Boss Phase:** The final level features a two-phase encounter where the sun regains heat and speeds up.
- **Lose Condition:** If the timer reaches 0 before the sun is defeated, you lose the level and must retry.
- **Strategic Heat Vents:** The sun has a white-hot critical vent on its surface. Hitting this spot directly cools the sun **2.4x faster**.
- **Solar Flares (Fireballs):** The sun periodically launches fiery solar flares towards you. You must intercept them mid-air by tracking them with the water stream for 0.33s. Destroying a flare rewards an instant **+30% Water Tank refill**.
- **Ice Burst:** Starting in Level 3, unlock the powerful Ice Burst mechanic! Build up 3 charges over time and right-click (or press R) to fire a freezing shard at the sun, completely stopping all sun movement and heat regeneration for 3 seconds.

---

## Controls

| Input | Action |
|---|---|
| Move mouse | Aim the water cannon |
| Left click (hold) | Fire water spray |
| Right click / R | Fire Ice Burst (when charged) |
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
| SFX - Ice Shoot | urupin (Freesound) | CC0 |
| SFX - Ice Hit | antonsoederberg (Freesound) | CC0 |
| VFX - Ice Blast Projectile & Particles | Procedural Godot Primitives | - |
| Procedural Clouds and Seagulls | Hand-crafted GDScript | - |
| Sun Face Expressions | Procedural Godot Image draw API | - |
