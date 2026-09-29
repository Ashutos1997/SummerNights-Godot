#!/usr/bin/env python3
import math
import numpy as np
from PIL import Image

FACE_SIZE = 128
FACE_COLOR = (255, 255, 255, 255)
OUTLINE_COLOR = (153, 51, 0, 255) # Color(0.6, 0.2, 0.0, 1.0)

def create_face_canvas():
    return np.zeros((FACE_SIZE, FACE_SIZE, 4), dtype=np.uint8)

def draw_circle(img, cx, cy, radius, color):
    for y in range(max(0, cy - radius), min(FACE_SIZE, cy + radius + 1)):
        for x in range(max(0, cx - radius), min(FACE_SIZE, cx + radius + 1)):
            if (x - cx) ** 2 + (y - cy) ** 2 <= radius ** 2:
                img[y, x] = color

def draw_line(img, x1, y1, x2, y2, thickness, color):
    dx = abs(x2 - x1)
    dy = abs(y2 - y1)
    steps = max(dx, dy)
    if steps == 0:
        return
    sx = (x2 - x1) / steps
    sy = (y2 - y1) / steps
    t_half = thickness // 2
    for i in range(steps + 1):
        px = int(x1 + sx * i)
        py = int(y1 + sy * i)
        for tx in range(-t_half, t_half + 1):
            for ty in range(-t_half, t_half + 1):
                fx = px + tx
                fy = py + ty
                if 0 <= fx < FACE_SIZE and 0 <= fy < FACE_SIZE:
                    img[fy, fx] = color

def draw_pill(img, cx, cy, w, h, color):
    r = w // 2
    draw_circle(img, cx, cy - h // 2 + r, r, color)
    draw_circle(img, cx, cy + h // 2 - r, r, color)
    y_start = max(0, cy - h // 2 + r)
    y_end = min(FACE_SIZE, cy + h // 2 - r + 1)
    x_start = max(0, cx - r)
    x_end = min(FACE_SIZE, cx + r + 1)
    for y in range(y_start, y_end):
        for x in range(x_start, x_end):
            img[y, x] = color

def draw_half_circle_bottom(img, cx, cy, radius, color):
    for y in range(max(0, cy), min(FACE_SIZE, cy + radius + 1)):
        for x in range(max(0, cx - radius), min(FACE_SIZE, cx + radius + 1)):
            if (x - cx) ** 2 + (y - cy) ** 2 <= radius ** 2:
                img[y, x] = color

def draw_half_circle_top(img, cx, cy, radius, color):
    for y in range(max(0, cy - radius), min(FACE_SIZE, cy + 1)):
        for x in range(max(0, cx - radius), min(FACE_SIZE, cx + radius + 1)):
            if (x - cx) ** 2 + (y - cy) ** 2 <= radius ** 2:
                img[y, x] = color

def draw_polygon(img, pts, color):
    pts = np.array(pts, dtype=np.int32)
    from matplotlib.path import Path
    path = Path(pts)
    min_x = max(0, int(np.min(pts[:, 0])))
    max_x = min(FACE_SIZE - 1, int(np.max(pts[:, 0])))
    min_y = max(0, int(np.min(pts[:, 1])))
    max_y = min(FACE_SIZE - 1, int(np.max(pts[:, 1])))
    for y in range(min_y, max_y + 1):
        for x in range(min_x, max_x + 1):
            if path.contains_point((x, y)):
                img[y, x] = color

def add_outline(img, thickness, color):
    alpha = img[:, :, 3] > 128
    outline_mask = np.zeros((FACE_SIZE, FACE_SIZE), dtype=bool)
    y_coords, x_coords = np.where(alpha)
    for y, x in zip(y_coords, x_coords):
        for dy in range(-thickness, thickness + 1):
            for dx in range(-thickness, thickness + 1):
                if dx*dx + dy*dy <= thickness*thickness:
                    ny, nx = y + dy, x + dx
                    if 0 <= ny < FACE_SIZE and 0 <= nx < FACE_SIZE:
                        if not alpha[ny, nx]:
                            outline_mask[ny, nx] = True
    res = img.copy()
    res[outline_mask] = color
    return res

# ── Existing Game Expressions ──

def draw_angry(img, cx, cy):
    draw_pill(img, cx - 24, cy - 2, 12, 20, FACE_COLOR)
    draw_pill(img, cx + 24, cy - 2, 12, 20, FACE_COLOR)
    draw_line(img, cx - 38, cy - 32, cx - 12, cy - 22, 8, FACE_COLOR)
    draw_line(img, cx + 38, cy - 32, cx + 12, cy - 22, 8, FACE_COLOR)
    draw_half_circle_top(img, cx, cy + 28, 16, FACE_COLOR)

# ── Refined Driver Expressions ──
# Note: Keep ample spacing (≥12px) between features so 4px outline never merges features into blobs!

def draw_driver_smirk_v2(img, cx, cy):
    # 1. Menacing, sharp predatory kitsune/boss eyes
    # Left eye: angled almond shape (slanted inward)
    pts_l = [
        [cx - 36, cy - 8],   # outer upper peak
        [cx - 16, cy + 1],   # inner corner (slanted down)
        [cx - 22, cy + 7],   # inner lower
        [cx - 36, cy + 2]    # outer lower
    ]
    draw_polygon(img, pts_l, FACE_COLOR)
    # Right eye: angled almond shape
    pts_r = [
        [cx + 36, cy - 8],   # outer upper peak
        [cx + 16, cy + 1],   # inner corner
        [cx + 22, cy + 7],   # inner lower
        [cx + 36, cy + 2]    # outer lower
    ]
    draw_polygon(img, pts_r, FACE_COLOR)
    
    # Sharp piercing slit pupil cutouts
    draw_line(img, cx - 26, cy - 4, cx - 26, cy + 4, 3, (0, 0, 0, 0))
    draw_line(img, cx + 26, cy - 4, cx + 26, cy + 4, 3, (0, 0, 0, 0))
    
    # 2. Sleek, arched demon eyebrows (placed high at cy - 30 to cy - 18)
    draw_line(img, cx - 40, cy - 25, cx - 14, cy - 16, 7, FACE_COLOR)
    draw_line(img, cx + 40, cy - 25, cx + 14, cy - 16, 7, FACE_COLOR)
    # Inner brow downward notch
    draw_line(img, cx - 14, cy - 16, cx - 14, cy - 11, 5, FACE_COLOR)
    draw_line(img, cx + 14, cy - 16, cx + 14, cy - 11, 5, FACE_COLOR)
    
    # 3. Smooth, arrogant villain smirk (confident upturn on right side)
    # 3-segment curve with smooth transitions
    draw_line(img, cx - 16, cy + 27, cx - 2, cy + 28, 6, FACE_COLOR)
    draw_line(img, cx - 2, cy + 28, cx + 12, cy + 25, 6, FACE_COLOR)
    draw_line(img, cx + 12, cy + 25, cx + 22, cy + 18, 6, FACE_COLOR)
    # Small corner accent tick
    draw_line(img, cx + 21, cy + 18, cx + 24, cy + 14, 4, FACE_COLOR)
    
    # 4. Forehead Solar Crest Emblem (matching the 16-ray Driver Corona!)
    # Sharp central diamond jewel
    pts_crest = [
        [cx, cy - 43],
        [cx + 6, cy - 32],
        [cx, cy - 21],
        [cx - 6, cy - 32]
    ]
    draw_polygon(img, pts_crest, FACE_COLOR)
    # Golden radiant crown needles radiating left/right
    draw_line(img, cx - 7, cy - 32, cx - 16, cy - 38, 4, FACE_COLOR)
    draw_line(img, cx + 7, cy - 32, cx + 16, cy - 38, 4, FACE_COLOR)

def draw_driver_fury_v2(img, cx, cy):
    # Phase 2 Overdrive / High Heat Fury:
    # 1. Burning wide angled eyes with diamond core
    pts_l = [
        [cx - 38, cy - 4],
        [cx - 24, cy - 12],
        [cx - 14, cy + 2],
        [cx - 24, cy + 8]
    ]
    draw_polygon(img, pts_l, FACE_COLOR)
    pts_r = [
        [cx + 38, cy - 4],
        [cx + 24, cy - 12],
        [cx + 14, cy + 2],
        [cx + 24, cy + 8]
    ]
    draw_polygon(img, pts_r, FACE_COLOR)
    
    # Piercing pupil cutout
    draw_circle(img, cx - 24, cy - 2, 4, (0, 0, 0, 0))
    draw_circle(img, cx + 24, cy - 2, 4, (0, 0, 0, 0))
    
    # 2. Aggressive heavy brows
    draw_line(img, cx - 42, cy - 28, cx - 12, cy - 18, 8, FACE_COLOR)
    draw_line(img, cx + 42, cy - 28, cx + 12, cy - 18, 8, FACE_COLOR)
    
    # 3. Maniacal wide grin (clenched sharp teeth)
    pts_mouth = [
        [cx - 22, cy + 22],
        [cx + 22, cy + 22],
        [cx + 18, cy + 32],
        [cx - 18, cy + 32]
    ]
    draw_polygon(img, pts_mouth, FACE_COLOR)
    # Tooth line
    draw_line(img, cx - 20, cy + 27, cx + 20, cy + 27, 2, (0, 0, 0, 0))
    draw_line(img, cx - 7, cy + 23, cx - 7, cy + 31, 2, (0, 0, 0, 0))
    draw_line(img, cx + 7, cy + 23, cx + 7, cy + 31, 2, (0, 0, 0, 0))
    
    # 4. Blazing Forehead Crest with 3 coronal rays
    pts_crest = [
        [cx, cy - 44],
        [cx + 7, cy - 31],
        [cx, cy - 18],
        [cx - 7, cy - 31]
    ]
    draw_polygon(img, pts_crest, FACE_COLOR)
    draw_line(img, cx - 8, cy - 34, cx - 18, cy - 41, 4, FACE_COLOR)
    draw_line(img, cx + 8, cy - 34, cx + 18, cy - 41, 4, FACE_COLOR)

def main():
    cx = FACE_SIZE // 2
    cy = FACE_SIZE // 2
    
    c_a = create_face_canvas()
    draw_angry(c_a, cx, cy)
    img_angry = add_outline(c_a, 4, OUTLINE_COLOR)
    
    c_s = create_face_canvas()
    draw_driver_smirk_v2(c_s, cx, cy)
    img_smirk = add_outline(c_s, 4, OUTLINE_COLOR)
    
    c_f = create_face_canvas()
    draw_driver_fury_v2(c_f, cx, cy)
    img_fury = add_outline(c_f, 4, OUTLINE_COLOR)
    
    from PIL import ImageDraw, ImageFont
    
    card_w = FACE_SIZE * 3 + 100
    card_h = FACE_SIZE + 100
    comp = Image.new('RGBA', (card_w, card_h), (20, 24, 34, 255))
    draw = ImageDraw.Draw(comp)
    
    # Title Banner
    draw.text((card_w // 2, 22), "SUMMER NIGHTS • WAVE 30 SOLAR DRIVER FACE EXPRESSIONS", fill=(255, 204, 51, 255), anchor="mm")
    
    # Sub-panels with warm solar backgrounds
    panels = [
        ("STANDARD (Angry)", img_angry, 25),
        ("DRIVER SMIRK (Apex Boss)", img_smirk, FACE_SIZE + 50),
        ("DRIVER FURY (Overdrive)", img_fury, FACE_SIZE * 2 + 75)
    ]
    
    for title, img_arr, px in panels:
        # Solar circular pad
        draw.ellipse([px - 2, 45 - 2, px + FACE_SIZE + 2, 45 + FACE_SIZE + 2], fill=(255, 120, 0, 255), outline=(255, 200, 50, 255), width=2)
        im = Image.fromarray(img_arr)
        comp.paste(im, (px, 45), im)
        draw.text((px + FACE_SIZE // 2, 45 + FACE_SIZE + 24), title, fill=(240, 240, 245, 255), anchor="mm")
        
    comp.save('assets/models/driver_faces_preview.png')
    print('Saved preview to assets/models/driver_faces_preview.png')

if __name__ == '__main__':
    main()
