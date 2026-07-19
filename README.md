# Summer Nights - Godot 4 Project

## How to Open

1. Open the **Godot.app** on your Desktop
2. In the Project Manager, click **"Import"**
3. Navigate to this folder: `Desktop/Projects/SummerNights-Godot/`
4. Select the **`project.godot`** file and click **"Import & Edit"**
5. Press **F5** (or the Play button ▶) to run the game

## Controls
- **Move mouse** → Aim the water gun
- **Left click** → Shoot a water blast at the sun
- **Goal**: Cool the sun down to 0% to win!

## Project Structure
```
SummerNights-Godot/
├── project.godot       ← Godot project config (open this!)
├── scenes/
│   ├── GameScene.tscn  ← Main game scene
│   └── WaterBlast.tscn ← Projectile scene
├── scripts/
│   ├── GameScene.gd    ← Game loop + temperature logic
│   ├── WaterGun.gd     ← Mouse-tracking gun
│   ├── Sun.gd          ← Bobbing, glowing sun target
│   └── WaterBlast.gd   ← Projectile physics
└── assets/
    ├── sun_pixel.png   ← From Summer Essentials sprite pack
    ├── rifle.png       ← From Kenney Shooting Gallery (CC0)
    └── laser_blue.png  ← From Kenney Space Shooter Redux (CC0)
```

## Assets
All CC0 (Public Domain):
- **Summer Essentials** spritesheet (pixel sun icon)
- **Kenney Shooting Gallery** (rifle.png)
- **Kenney Space Shooter Redux** (laser_blue.png)
- **UI Assets**: Kenney UI Pack — kenney.nl/assets/ui-pack — CC0
- **Crosshair**: Kenney Crosshair Pack — kenney.nl — CC0
- **Font**: Kenney Pixel — kenney.nl/assets/kenney-fonts — CC0

SFX: 40 CC0 Water/Splash/Slime SFX — opengameart.org/content/40-cc0-water-splash-slime-sfx — CC0
SFX: Kenney UI Audio — kenney.nl/assets/ui-audio — CC0

3D Gun Model: "3D Blaster Model" by Kenney (kenney.nl) — CC0

3D Sun Model: "PS1 Style Low Poly Sun" by albert_buscio
  sketchfab.com/3d-models/ps1-style-low-poly-sun-9f2b6f87811242b8b6313b42667122cf
  Textures: solarsystemscope.com (copyright free)
  License: verify on Sketchfab page before use

Sky Shader: "Stylized Sky Shader" inspired by MinionsArt (CC0)
  patreon.com/posts/making-stylized-27402644

Water Shader: "Stylized Water Shader" inspired by Jtfinlay (MIT)
  github.com/Jtfinlay/stylized-water-shader

Heat Haze Shader: "Heat Haze Screen Distortion" inspired by MinionsArt (CC0)
  patreon.com/posts/making-stylized-27402644

SFX: Water Gun Shot by belanhud
  freesound.org/people/belanhud/sounds/537941/
  License: CC0 1.0 Universal (Public Domain)

SFX: Kenney Impact Sounds
  kenney.nl/assets/impact-sounds — CC0

SFX: Kenney Interface Sounds
  kenney.nl/assets/interface-sounds — CC0

SFX: Spraying water loop
  pixabay.com — Royalty-free, no attribution required
