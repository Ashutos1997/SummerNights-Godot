#!/usr/bin/env python3
import math
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection

def render_celestial_tails_improved(output_png):
    tail_count = 9
    segments_per_tail = 32
    
    # Ethereal Celestial Fox Palette
    cyan_mantle = np.array([0.15, 0.80, 1.00, 0.45])
    bright_cyan = np.array([0.35, 0.92, 1.00, 0.70])
    white_core  = np.array([1.00, 1.00, 1.00, 0.95])
    
    anim_time = 1.65
    
    # Simulate staggered blooming (Center tail bloomed first, outer tails blooming with elastic overshoot)
    stagger_progress = [
        0.85, # Tail 0 (Far left)
        0.92, # Tail 1
        0.98, # Tail 2
        1.05, # Tail 3 (Overshoot pop!)
        1.08, # Tail 4 (Center Crown - Full peak)
        1.05, # Tail 5 (Overshoot pop!)
        0.98, # Tail 6
        0.92, # Tail 7
        0.85  # Tail 8 (Far right)
    ]

    # Camera parameters: FOV 75 deg, aspect 16:9
    fov_y = math.radians(75)
    aspect = 16.0 / 9.0
    f_y = 1.0 / math.tan(fov_y / 2.0)
    f_x = f_y / aspect

    fig = plt.figure(figsize=(24, 10), facecolor='#06080e')

    # View 1: First-Person Camera View
    ax1 = fig.add_subplot(1, 2, 1, facecolor='#030408')
    ax1.set_title("1. First-Person View (Staggered Dynamic Eruption & Fluid Wave Flow)", color='#F0E6D2', fontsize=14, fontweight='bold', pad=14)
    ax1.set_xlim(-1.05, 1.05)
    ax1.set_ylim(-1.05, 1.05)
    ax1.set_aspect('equal')
    ax1.axhline(0, color='#1e293b', linestyle='--', linewidth=0.8, alpha=0.5)
    ax1.axvline(0, color='#1e293b', linestyle='--', linewidth=0.8, alpha=0.5)

    # Reticle Zone
    circle = plt.Circle((0, 0), 0.32, color='#38bdf8', fill=False, linestyle=':', linewidth=1.5, alpha=0.5)
    ax1.add_patch(circle)
    ax1.plot([0, 0.08, 0, -0.08, 0], [0.08, 0, -0.08, 0, 0.08], color='#38bdf8', linewidth=1.8)
    ax1.text(0, -0.38, "UNOBSTRUCTED COMBAT RETICLE ZONE", color='#38bdf8', fontsize=9, ha='center', fontweight='bold', alpha=0.8)

    # View 2: 3D Spatial Geometry
    ax2 = fig.add_subplot(1, 2, 2, projection='3d', facecolor='#06080e')
    ax2.set_title("2. 3D Spatial Geometry (Overhead Living Celestial Canopy)", color='#F0E6D2', fontsize=14, fontweight='bold', pad=14)

    all_polys = []
    all_colors = []

    # Simulated aim lag (aiming slightly right, so tails drift slightly left)
    aim_lag_x = 0.25
    aim_lag_y = 0.10

    # Living breathing rhythm
    breathe = math.sin(anim_time * 2.0) * 0.04

    for i in range(tail_count):
        t_norm = (float(i) - 4.0) / 4.0
        abs_t = abs(t_norm)
        tail_bloom = stagger_progress[i]

        tail_3d_pts_left = []
        tail_3d_pts_right = []
        tail_colors = []
        screen_pts_left = []
        screen_pts_right = []

        fan_spread = t_norm * math.radians(46.0 + abs_t * 6.0)
        base_y = 0.88 + (1.0 - abs_t) * 0.28 + breathe

        for seg in range(segments_per_tail + 1):
            s = float(seg) / float(segments_per_tail)

            # High overhead origin cascading into upper sky
            forward_reach = 0.18 - s * 1.38
            y_descent = (s ** 1.32) * (0.36 + abs_t * 0.42)
            
            # Subtle upward fox-tail hook at the tip
            tip_curl = 0.0
            if s > 0.72:
                tip_curl = ((s - 0.72) / 0.28) ** 1.7 * 0.14
            y_pos = base_y - y_descent + tip_curl

            # Lateral spread with gentle curve
            x_pos = t_norm * 0.22 + math.sin(fan_spread) * (s * 1.58 + (s ** 1.45) * 0.32)
            z_pos = forward_reach

            # Multi-octave traveling wave flow (liquid energy flowing down to tips)
            flow_k1 = 4.4
            flow_k2 = 8.8
            wave1 = math.sin(anim_time * 3.6 - s * flow_k1 + i * 0.72) * (0.048 * s * s)
            wave2 = math.cos(anim_time * 5.4 - s * flow_k2 + i * 1.15) * (0.016 * s * s)
            wave_z = math.sin(anim_time * 2.2 + i * 0.50) * (0.035 * s)

            # Apply aim inertia lag (drag opposite to aim)
            inertia_x = -aim_lag_x * 0.12 * (s ** 1.2)
            inertia_y = -aim_lag_y * 0.08 * (s ** 1.2)

            spine_pt = np.array([
                (x_pos + wave1 + inertia_x) * tail_bloom,
                (y_pos + wave2 + inertia_y) * tail_bloom,
                (z_pos + wave_z)
            ])

            # Refined calligraphic width: thin root, gentle mid swelling, tapering to fine ethereal tip
            width = (math.sin(s * math.pi) ** 0.88 * 0.082 + 0.010) * tail_bloom
            if s > 0.85:
                width *= ((1.0 - s) / 0.15) ** 0.82

            # Billboard side vector perpendicular to camera view ray
            cam_dir = spine_pt
            cam_dist = np.linalg.norm(cam_dir)
            if cam_dist > 1e-4:
                cam_dir = cam_dir / cam_dist
            
            up_ref = np.array([0, 1, 0])
            side_vec = np.cross(cam_dir, up_ref)
            side_norm = np.linalg.norm(side_vec)
            if side_norm > 1e-4:
                side_vec = (side_vec / side_norm) * (width * 0.5)
            else:
                side_vec = np.array([1, 0, 0]) * (width * 0.5)

            v_left = spine_pt + side_vec
            v_right = spine_pt - side_vec

            # Delicate semi-transparent water gradient:
            # Feathered root -> Electric cyan body -> Luminous pure white tip
            if s < 0.28:
                m = s / 0.28
                col = (1.0 - m) * cyan_mantle + m * bright_cyan
                col[3] = (0.20 + m * 0.50) * min(1.0, tail_bloom)
            elif s < 0.78:
                m = (s - 0.28) / 0.50
                col = (1.0 - m) * bright_cyan + m * white_core
                col[3] = 0.78 * min(1.0, tail_bloom)
            else:
                m = (s - 0.78) / 0.22
                col = white_core.copy()
                col[3] = (1.0 - m * 0.35) * 0.88 * min(1.0, tail_bloom)

            tail_3d_pts_left.append(v_left)
            tail_3d_pts_right.append(v_right)
            tail_colors.append(col)

            # Perspective projection into camera view
            if -spine_pt[2] > 0.10:
                p_left_x = (v_left[0] / (-v_left[2])) * f_x
                p_left_y = (v_left[1] / (-v_left[2])) * f_y
                p_right_x = (v_right[0] / (-v_right[2])) * f_x
                p_right_y = (v_right[1] / (-v_right[2])) * f_y
                screen_pts_left.append([p_left_x, p_left_y])
                screen_pts_right.append([p_right_x, p_right_y])

        # Draw 3D Triangles
        for seg in range(len(tail_3d_pts_left) - 1):
            quad = [
                tail_3d_pts_left[seg],
                tail_3d_pts_left[seg + 1],
                tail_3d_pts_right[seg + 1],
                tail_3d_pts_right[seg]
            ]
            all_polys.append(quad)
            all_colors.append(tail_colors[seg])

        # Draw 2D Projected Ribbons
        if len(screen_pts_left) > 1:
            poly_pts = screen_pts_left + screen_pts_right[::-1]
            poly_arr = np.array(poly_pts)
            alpha_val = min(0.68, tail_colors[len(tail_colors)//2][3])
            color_rgb = tail_colors[len(tail_colors)//2][:3]
            ax1.fill(poly_arr[:, 0], poly_arr[:, 1], color=color_rgb, alpha=alpha_val, edgecolor=color_rgb, linewidth=0.8)

    # 3D Collection
    poly3d = Poly3DCollection(all_polys, facecolors=all_colors, edgecolors='none', alpha=0.85)
    ax2.add_collection3d(poly3d)

    ax2.set_xlim(-1.8, 1.8)
    ax2.set_ylim(-0.2, 1.6)
    ax2.set_zlim(-1.5, 0.4)
    ax2.set_xlabel('X (Lateral Wings)', color='#94a3b8', labelpad=8)
    ax2.set_ylabel('Y (Height)', color='#94a3b8', labelpad=8)
    ax2.set_zlabel('Z (Forward in View)', color='#94a3b8', labelpad=8)
    ax2.tick_params(colors='#64748b')
    ax2.view_init(elev=22, azim=-50)

    # HUD Visor Overlay Mockup
    ax1.text(0, 0.94, "[ CELESTIAL AWAKENING: NINE TAILS ]", color='#ffd700', fontsize=12, ha='center', fontweight='bold')
    ax1.text(0, 0.86, "★ NOW, HERE COMES THE HIGHLIGHT! ★", color='#ffffff', fontsize=9.5, ha='center', alpha=0.9)

    plt.tight_layout()
    plt.savefig(output_png, dpi=160, bbox_inches='tight')
    plt.close()
    print(f"Rendered improved dynamic tails preview to {output_png}")

if __name__ == '__main__':
    render_celestial_tails_improved('/Users/ashj/.gemini/antigravity-ide/brain/e2b8cc3e-1b57-4579-91d4-5008b80a2449/celestial_tails_dynamic.png')
