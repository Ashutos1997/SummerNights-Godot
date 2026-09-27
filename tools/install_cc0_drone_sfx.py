import shutil
import os

src_breaking = "/Users/ashj/.gemini/antigravity-ide/brain/e2b8cc3e-1b57-4579-91d4-5008b80a2449/scratch/sfx_download/breaking"
src_metal = "/Users/ashj/.gemini/antigravity-ide/brain/e2b8cc3e-1b57-4579-91d4-5008b80a2449/scratch/sfx_download/metal_wood"
dest_dir = "/Users/ashj/Desktop/Projects/SummerNights-Godot/assets/audio/sfx"

mappings = [
    (os.path.join(src_metal, "metal_hit_01.ogg"), os.path.join(dest_dir, "drone_metal_hit_01.ogg")),
    (os.path.join(src_metal, "metal_hit_02.ogg"), os.path.join(dest_dir, "drone_metal_hit_02.ogg")),
    (os.path.join(src_breaking, "bfh1_metal_hit_01.ogg"), os.path.join(dest_dir, "drone_metal_hit_03.ogg")),
    (os.path.join(src_breaking, "bfh1_metal_hit_03.ogg"), os.path.join(dest_dir, "drone_metal_hit_04.ogg")),
    (os.path.join(src_metal, "metal_slam_01.ogg"), os.path.join(dest_dir, "drone_shatter_metal.ogg")),
    (os.path.join(src_breaking, "bfh1_glass_breaking_02.ogg"), os.path.join(dest_dir, "drone_shatter_glass.ogg")),
    (os.path.join(src_breaking, "bfh1_glass_breaking_01.ogg"), os.path.join(dest_dir, "drone_ice_shatter_glass.ogg"))
]

for src, dst in mappings:
    if os.path.exists(src):
        shutil.copyfile(src, dst)
        print(f"Copied: {src} -> {dst} ({os.path.getsize(dst)} bytes)")
    else:
        print(f"Missing source: {src}")
