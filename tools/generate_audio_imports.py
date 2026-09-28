import hashlib
import os

files = [
    ("assets/audio/sfx/kitsune_blade_draw.wav", "wav", "AudioStreamWAV", "sample"),
    ("assets/audio/sfx/kitsune_cannon_lock.ogg", "oggvorbisstr", "AudioStreamOggVorbis", "oggvorbisstr"),
    ("assets/audio/sfx/driver_lock.ogg", "oggvorbisstr", "AudioStreamOggVorbis", "oggvorbisstr"),
    ("assets/audio/sfx/driver_overdrive.ogg", "oggvorbisstr", "AudioStreamOggVorbis", "oggvorbisstr"),
    ("assets/audio/sfx/drone_shield_hum.ogg", "oggvorbisstr", "AudioStreamOggVorbis", "oggvorbisstr"),
    ("assets/audio/sfx/perk_hover.wav", "wav", "AudioStreamWAV", "sample"),
    ("assets/audio/sfx/perk_deal.wav", "wav", "AudioStreamWAV", "sample"),
    ("assets/audio/sfx/perk_select.mp3", "mp3", "AudioStreamMP3", "mp3str"),
]

for rel_path, importer, type_name, ext in files:
    import_path = rel_path + ".import"
    base_name = os.path.basename(rel_path)
    # Generate deterministic md5 for imported destination
    h = hashlib.md5(rel_path.encode('utf-8')).hexdigest()
    dest = f"res://.godot/imported/{base_name}-{h}.{ext}"
    
    if importer == "wav":
        content = f"""[remap]

importer="{importer}"
type="{type_name}"
path="{dest}"

[deps]

source_file="res://{rel_path}"
dest_files=["{dest}"]

[params]

force/8_bit=false
force/mono=false
force/max_rate=false
force/max_rate_hz=44100
edit/trim=false
edit/normalize=false
edit/loop_mode=0
edit/loop_begin=0
edit/loop_end=-1
compress/mode=2
"""
    elif importer == "mp3":
        content = f"""[remap]

importer="{importer}"
type="{type_name}"
path="{dest}"

[deps]

source_file="res://{rel_path}"
dest_files=["{dest}"]

[params]

loop=false
loop_offset=0
bpm=0
beat_count=0
bar_beats=4
"""
    else: # oggvorbisstr
        is_loop = "true" if "drone_shield_hum" in rel_path else "false"
        content = f"""[remap]

importer="{importer}"
type="{type_name}"
path="{dest}"

[deps]

source_file="res://{rel_path}"
dest_files=["{dest}"]

[params]

loop={is_loop}
loop_offset=0
bpm=0
beat_count=0
bar_beats=4
"""

    with open(import_path, "w") as f:
        f.write(content)
    print("Created:", import_path)
