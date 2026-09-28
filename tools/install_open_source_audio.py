import os
import shutil

mappings = [
    (
        "/Users/ashj/.gemini/antigravity-ide/brain/e2b8cc3e-1b57-4579-91d4-5008b80a2449/scratch/rpg_sound_pack/RPG Sound Pack/battle/sword-unsheathe2.wav",
        "assets/audio/sfx/kitsune_blade_draw.wav"
    ),
    (
        "/Users/ashj/.gemini/antigravity-ide/brain/e2b8cc3e-1b57-4579-91d4-5008b80a2449/scratch/sfx_download/metal_wood/lock_open_01.ogg",
        "assets/audio/sfx/kitsune_cannon_lock.ogg"
    ),
    (
        "/Users/ashj/.gemini/antigravity-ide/brain/e2b8cc3e-1b57-4579-91d4-5008b80a2449/scratch/sfx_download/metal_wood/metal_slam_01.ogg",
        "assets/audio/sfx/driver_lock.ogg"
    ),
    (
        "/Users/ashj/.gemini/antigravity-ide/brain/e2b8cc3e-1b57-4579-91d4-5008b80a2449/scratch/sci-fi_sounds/Audio/spaceEngineLarge_002.ogg",
        "assets/audio/sfx/driver_overdrive.ogg"
    ),
    (
        "/Users/ashj/.gemini/antigravity-ide/brain/e2b8cc3e-1b57-4579-91d4-5008b80a2449/scratch/sci-fi_sounds/Audio/forceField_000.ogg",
        "assets/audio/sfx/drone_shield_hum.ogg"
    ),
    (
        "/Users/ashj/.gemini/antigravity-ide/brain/e2b8cc3e-1b57-4579-91d4-5008b80a2449/scratch/UI_SFX_Set/rollover2.wav",
        "assets/audio/sfx/perk_hover.wav"
    ),
    (
        "/Users/ashj/.gemini/antigravity-ide/brain/e2b8cc3e-1b57-4579-91d4-5008b80a2449/scratch/UI_SFX_Set/rollover1.wav",
        "assets/audio/sfx/perk_deal.wav"
    ),
    (
        "/Users/ashj/.gemini/antigravity-ide/brain/e2b8cc3e-1b57-4579-91d4-5008b80a2449/scratch/Digital_SFX_Set/powerUp7.mp3",
        "assets/audio/sfx/perk_select.mp3"
    )
]

for src, dst in mappings:
    if os.path.exists(src):
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copyfile(src, dst)
        print(f"Copied: {src} -> {dst} ({os.path.getsize(dst)} bytes)")
    else:
        print(f"Error: missing source {src}")
