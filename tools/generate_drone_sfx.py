import wave
import struct
import math
import random

SAMPLE_RATE = 44100

def create_drone_hit():
    # 0.14 seconds: crisp metallic ping + fluid thud + hot sizzle
    duration = 0.14
    total_samples = int(SAMPLE_RATE * duration)
    samples = []
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        
        # 1. Metallic transient ping (dual resonant frequencies: 1650 Hz & 3120 Hz)
        ping_env = math.exp(-t * 45.0)
        ping = (math.sin(2.0 * math.pi * 1650.0 * t) * 0.6 + 
                math.sin(2.0 * math.pi * 3120.0 * t) * 0.4) * ping_env
        
        # 2. Low hydro thud (180 Hz punch decaying fast)
        thud_env = math.exp(-t * 60.0)
        thud = math.sin(2.0 * math.pi * 180.0 * (1.0 - t * 2.0) * t) * thud_env * 0.5
        
        # 3. Superheated steam hiss / sizzle (filtered noise burst)
        sizzle_env = math.exp(-t * 28.0) * (1.0 - math.exp(-t * 200.0))
        noise = (random.random() * 2.0 - 1.0) * sizzle_env * 0.35
        
        val = (ping * 0.55 + thud * 0.30 + noise * 0.25)
        # Soft clipping
        val = math.tanh(val * 1.6)
        samples.append(val)
        
    return samples

def create_drone_shatter():
    # 0.75 seconds: Deep mechanical core rupture + metallic casing crunch + steam blast
    duration = 0.75
    total_samples = int(SAMPLE_RATE * duration)
    samples = []
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        
        # 1. Heavy sub-bass implosion (85 Hz diving to 35 Hz)
        f_sub = 85.0 * math.exp(-t * 3.5) + 35.0
        sub_env = math.exp(-t * 7.0)
        sub = math.sin(2.0 * math.pi * f_sub * t) * sub_env * 0.7
        
        # 2. Jagged metallic crunch / tear (FM metallic distortion)
        mod = math.sin(2.0 * math.pi * 320.0 * t) * 4.0
        f_metal = 950.0 + mod * 120.0
        crunch_env = math.exp(-t * 12.0)
        crunch = math.sin(2.0 * math.pi * f_metal * t) * crunch_env * 0.45
        
        # 3. Shrapnel scatter (metallic bell clicks)
        shrapnel = 0.0
        for delay, freq in [(0.02, 2200), (0.05, 3400), (0.09, 1850), (0.14, 2700), (0.21, 1450)]:
            if t > delay:
                dt = t - delay
                shrapnel += math.sin(2.0 * math.pi * freq * dt) * math.exp(-dt * 30.0) * 0.2
                
        # 4. Vapor decompression whoosh (filtered white noise)
        whoosh_env = math.exp(-t * 5.0) * (1.0 - math.exp(-t * 50.0))
        whoosh = (random.random() * 2.0 - 1.0) * whoosh_env * 0.4
        
        val = sub * 0.45 + crunch * 0.35 + shrapnel * 0.25 + whoosh * 0.35
        val = math.tanh(val * 1.8)
        samples.append(val)
        
    return samples

def create_drone_ice_shatter():
    # 0.90 seconds: Glacial crack + high-frequency crystalline frost cascade + frozen shrapnel
    duration = 0.90
    total_samples = int(SAMPLE_RATE * duration)
    samples = []
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        
        # 1. Initial sharp cryo-crack transient (high-passed snap)
        snap_env = math.exp(-t * 60.0)
        snap = math.sin(2.0 * math.pi * 4200.0 * t) * snap_env * 0.6
        
        # 2. Glacial sub-rumble boom (65 Hz diving to 25 Hz)
        boom_f = 65.0 * math.exp(-t * 4.0) + 25.0
        boom_env = math.exp(-t * 5.5)
        boom = math.sin(2.0 * math.pi * boom_f * t) * boom_env * 0.65
        
        # 3. Multi-harmonic crystal ice fracture chime cascade
        chimes = 0.0
        freqs = [1950.0, 2600.0, 3450.0, 4800.0, 6200.0]
        for idx, freq in enumerate(freqs):
            delay = idx * 0.018
            if t > delay:
                dt = t - delay
                decay = 18.0 + idx * 4.0
                chimes += math.sin(2.0 * math.pi * freq * dt) * math.exp(-dt * decay) * 0.22
                
        # 4. Frost shatter gravel/debris scatter (bursting granular noise)
        debris_env = math.exp(-t * 6.5) * (1.0 - math.exp(-t * 120.0))
        debris = (random.random() * 2.0 - 1.0) * debris_env * 0.4
        
        val = snap * 0.35 + boom * 0.40 + chimes * 0.45 + debris * 0.30
        val = math.tanh(val * 1.7)
        samples.append(val)
        
    return samples

def save_wav(filename, samples):
    with wave.open(filename, 'w') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        
        # Normalize to 90% full scale
        max_amp = max(abs(s) for s in samples) if samples else 1.0
        scale = 0.92 / max(max_amp, 0.0001)
        
        data = bytearray()
        for s in samples:
            int_val = int(max(-32767, min(32767, s * scale * 32767)))
            data.extend(struct.pack('<h', int_val))
        wf.writeframes(data)
    print(f"Generated: {filename} ({len(samples)} samples)")

if __name__ == "__main__":
    save_wav("assets/audio/sfx/drone_hit.wav", create_drone_hit())
    save_wav("assets/audio/sfx/drone_shatter.wav", create_drone_shatter())
    save_wav("assets/audio/sfx/drone_ice_shatter.wav", create_drone_ice_shatter())
