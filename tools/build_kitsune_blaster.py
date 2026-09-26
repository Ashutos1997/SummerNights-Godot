#!/usr/bin/env python3
"""
build_kitsune_blaster.py - Version 4.0 (Streamlined Hero Asset Pass)
Applies rational design refinements:
1. Low-profile open holographic reflex glass: Unobstructed first-person sightline.
2. Cleaned-up macro shapes: Eliminated noisy micro-greebles in favor of bold Kenney chamfers.
3. Seamless blade integration: Top bayonet blade merges directly into the upper receiver deck.
4. Bold Kyubi core & twin hydro-vials: Clear, readable silhouette from all camera angles.
"""

import struct
import json
import math
import numpy as np

def ensure_ccw(pts):
    n = len(pts)
    area = 0.5 * sum(pts[i][0] * pts[(i + 1) % n][1] - pts[(i + 1) % n][0] * pts[i][1] for i in range(n))
    if area < 0:
        return [list(p) for p in reversed(pts)]
    return [list(p) for p in pts]

def ensure_ccw_pair(pts_start, pts_end):
    n = len(pts_start)
    area = 0.5 * sum(pts_start[i][0] * pts_start[(i + 1) % n][1] - pts_start[(i + 1) % n][0] * pts_start[i][1] for i in range(n))
    if area < 0:
        return [list(p) for p in reversed(pts_start)], [list(p) for p in reversed(pts_end)]
    return [list(p) for p in pts_start], [list(p) for p in pts_end]

def create_extrusion(points_2d, z0, z1, caps=True):
    pts_ccw = ensure_ccw(points_2d)
    n_pts = len(pts_ccw)
    pts = np.array(pts_ccw, dtype=np.float32)
    verts = []
    normals = []
    indices = []
    
    for i in range(n_pts):
        next_i = (i + 1) % n_pts
        p0 = pts[i]
        p1 = pts[next_i]
        
        dx = p1[0] - p0[0]
        dy = p1[1] - p0[1]
        length = math.hypot(dx, dy)
        nx = (dy / length) if length > 1e-6 else 0.0
        ny = (-dx / length) if length > 1e-6 else 1.0
            
        base = len(verts)
        verts.extend([
            [p0[0], p0[1], z0],
            [p1[0], p1[1], z0],
            [p1[0], p1[1], z1],
            [p0[0], p0[1], z1]
        ])
        normals.extend([[nx, ny, 0.0]] * 4)
        indices.extend([base, base + 1, base + 2, base, base + 2, base + 3])
        
    if caps and n_pts >= 3:
        # Front cap (+Z)
        c_front = len(verts)
        center_front = [float(np.mean(pts[:, 0])), float(np.mean(pts[:, 1])), z1]
        verts.append(center_front)
        normals.append([0.0, 0.0, 1.0])
        for p in pts:
            verts.append([p[0], p[1], z1])
            normals.append([0.0, 0.0, 1.0])
        for i in range(n_pts):
            indices.extend([c_front, c_front + 1 + i, c_front + 1 + ((i + 1) % n_pts)])
            
        # Back cap (-Z)
        c_back = len(verts)
        center_back = [float(np.mean(pts[:, 0])), float(np.mean(pts[:, 1])), z0]
        verts.append(center_back)
        normals.append([0.0, 0.0, -1.0])
        for p in pts:
            verts.append([p[0], p[1], z0])
            normals.append([0.0, 0.0, -1.0])
        for i in range(n_pts):
            indices.extend([c_back, c_back + 1 + ((i + 1) % n_pts), c_back + 1 + i])
            
    return verts, normals, indices

def create_tapered_extrusion(pts_start_2d, pts_end_2d, z0, z1, caps=True):
    start_ccw, end_ccw = ensure_ccw_pair(pts_start_2d, pts_end_2d)
    n_pts = len(start_ccw)
    assert len(end_ccw) == n_pts
    verts = []
    normals = []
    indices = []
    
    for i in range(n_pts):
        next_i = (i + 1) % n_pts
        p0_start = np.array([start_ccw[i][0], start_ccw[i][1], z0], dtype=np.float32)
        p1_start = np.array([start_ccw[next_i][0], start_ccw[next_i][1], z0], dtype=np.float32)
        p1_end   = np.array([end_ccw[next_i][0], end_ccw[next_i][1], z1], dtype=np.float32)
        p0_end   = np.array([end_ccw[i][0], end_ccw[i][1], z1], dtype=np.float32)
        
        # Outward normal for quad [p0_start, p1_start, p1_end, p0_end]
        n = np.cross(p1_start - p0_start, p0_end - p0_start)
        norm = np.linalg.norm(n)
        n = n / norm if norm > 1e-6 else np.array([0, 1, 0])
        
        base = len(verts)
        verts.extend([p0_start.tolist(), p1_start.tolist(), p1_end.tolist(), p0_end.tolist()])
        normals.extend([n.tolist()] * 4)
        indices.extend([base, base + 1, base + 2, base, base + 2, base + 3])
        
    if caps and n_pts >= 3:
        c_front = len(verts)
        center_front = [float(np.mean([p[0] for p in end_ccw])), float(np.mean([p[1] for p in end_ccw])), z1]
        verts.append(center_front)
        normals.append([0.0, 0.0, 1.0])
        for p in end_ccw:
            verts.append([p[0], p[1], z1])
            normals.append([0.0, 0.0, 1.0])
        for i in range(n_pts):
            indices.extend([c_front, c_front + 1 + i, c_front + 1 + ((i + 1) % n_pts)])
            
        c_back = len(verts)
        center_back = [float(np.mean([p[0] for p in start_ccw])), float(np.mean([p[1] for p in start_ccw])), z0]
        verts.append(center_back)
        normals.append([0.0, 0.0, -1.0])
        for p in start_ccw:
            verts.append([p[0], p[1], z0])
            normals.append([0.0, 0.0, -1.0])
        for i in range(n_pts):
            indices.extend([c_back, c_back + 1 + ((i + 1) % n_pts), c_back + 1 + i])
            
    return verts, normals, indices

def create_chamfered_box(center_x, center_y, width, height, z0, z1, chamfer=0.03):
    w2 = width / 2.0
    h2 = height / 2.0
    ch = min(chamfer, w2 * 0.45, h2 * 0.45)
    
    pts = [
        [center_x - w2 + ch, center_y - h2],
        [center_x + w2 - ch, center_y - h2],
        [center_x + w2,      center_y - h2 + ch],
        [center_x + w2,      center_y + h2 - ch],
        [center_x + w2 - ch, center_y + h2],
        [center_x - w2 + ch, center_y + h2],
        [center_x - w2,      center_y + h2 - ch],
        [center_x - w2,      center_y - h2 + ch]
    ]
    return create_extrusion(pts, z0, z1, caps=True)

def create_cylinder(center_x, center_y, z0, z1, radius, sides=16):
    verts = []
    normals = []
    indices = []
    
    for i in range(sides):
        ang0 = (i / sides) * 2 * math.pi
        ang1 = ((i + 1) / sides) * 2 * math.pi
        x0, y0 = center_x + math.cos(ang0) * radius, center_y + math.sin(ang0) * radius
        x1, y1 = center_x + math.cos(ang1) * radius, center_y + math.sin(ang1) * radius
        n0 = [math.cos(ang0), math.sin(ang0), 0.0]
        n1 = [math.cos(ang1), math.sin(ang1), 0.0]
        base = len(verts)
        verts.extend([[x0, y0, z0], [x1, y1, z0], [x1, y1, z1], [x0, y0, z1]])
        normals.extend([n0, n1, n1, n0])
        indices.extend([base, base + 1, base + 2, base, base + 2, base + 3])
        
    c_front = len(verts)
    verts.append([center_x, center_y, z1])
    normals.append([0.0, 0.0, 1.0])
    for i in range(sides):
        ang = (i / sides) * 2 * math.pi
        verts.append([center_x + math.cos(ang) * radius, center_y + math.sin(ang) * radius, z1])
        normals.append([0.0, 0.0, 1.0])
    for i in range(sides):
        indices.extend([c_front, c_front + 1 + i, c_front + 1 + ((i + 1) % sides)])
        
    c_back = len(verts)
    verts.append([center_x, center_y, z0])
    normals.append([0.0, 0.0, -1.0])
    for i in range(sides):
        ang = (i / sides) * 2 * math.pi
        verts.append([center_x + math.cos(ang) * radius, center_y + math.sin(ang) * radius, z0])
        normals.append([0.0, 0.0, -1.0])
    for i in range(sides):
        indices.extend([c_back, c_back + 1 + ((i + 1) % sides), c_back + 1 + i])
        
    return verts, normals, indices

class GLTFBuilder:
    def __init__(self):
        self.materials = []
        self.meshes_by_mat = {}
        
    def add_material(self, name, albedo_rgba, metallic=0.0, roughness=0.3, emissive_rgb=None, alpha_mode=None):
        mat_idx = len(self.materials)
        mat = {
            "name": name,
            "pbrMetallicRoughness": {
                "baseColorFactor": albedo_rgba,
                "metallicFactor": metallic,
                "roughnessFactor": roughness
            }
        }
        if emissive_rgb:
            mat["emissiveFactor"] = emissive_rgb
        if alpha_mode:
            mat["alphaMode"] = alpha_mode
        elif len(albedo_rgba) > 3 and albedo_rgba[3] < 1.0:
            mat["alphaMode"] = "BLEND"
        self.materials.append(mat)
        self.meshes_by_mat[mat_idx] = {"verts": [], "normals": [], "indices": []}
        return mat_idx
        
    def add_geometry(self, mat_idx, verts, normals, indices):
        group = self.meshes_by_mat[mat_idx]
        base_v = len(group["verts"])
        group["verts"].extend(verts)
        group["normals"].extend(normals)
        group["indices"].extend([idx + base_v for idx in indices])
        
    def build_glb(self, output_path):
        binary_data = bytearray()
        accessors = []
        buffer_views = []
        primitives = []
        
        for mat_idx, group in self.meshes_by_mat.items():
            if not group["verts"]:
                continue
                
            verts = np.array(group["verts"], dtype=np.float32)
            normals = np.array(group["normals"], dtype=np.float32)
            indices = np.array(group["indices"], dtype=np.uint32)
            
            idx_bytes = indices.tobytes()
            idx_offset = len(binary_data)
            binary_data.extend(idx_bytes)
            while len(binary_data) % 4 != 0: binary_data.append(0)
            
            idx_view = len(buffer_views)
            buffer_views.append({
                "buffer": 0, "byteOffset": idx_offset, "byteLength": len(idx_bytes), "target": 34963
            })
            idx_acc = len(accessors)
            accessors.append({
                "bufferView": idx_view, "byteOffset": 0, "componentType": 5125, "count": len(indices), "type": "SCALAR"
            })
            
            pos_bytes = verts.tobytes()
            pos_offset = len(binary_data)
            binary_data.extend(pos_bytes)
            while len(binary_data) % 4 != 0: binary_data.append(0)
            
            pos_view = len(buffer_views)
            buffer_views.append({
                "buffer": 0, "byteOffset": pos_offset, "byteLength": len(pos_bytes), "target": 34962
            })
            pos_acc = len(accessors)
            accessors.append({
                "bufferView": pos_view, "byteOffset": 0, "componentType": 5126, "count": len(verts), "type": "VEC3",
                "min": verts.min(axis=0).tolist(), "max": verts.max(axis=0).tolist()
            })
            
            norm_bytes = normals.tobytes()
            norm_offset = len(binary_data)
            binary_data.extend(norm_bytes)
            while len(binary_data) % 4 != 0: binary_data.append(0)
            
            norm_view = len(buffer_views)
            buffer_views.append({
                "buffer": 0, "byteOffset": norm_offset, "byteLength": len(norm_bytes), "target": 34962
            })
            norm_acc = len(accessors)
            accessors.append({
                "bufferView": norm_view, "byteOffset": 0, "componentType": 5126, "count": len(normals), "type": "VEC3"
            })
            
            primitives.append({
                "attributes": {"POSITION": pos_acc, "NORMAL": norm_acc},
                "indices": idx_acc,
                "material": mat_idx
            })
            
        gltf = {
            "asset": {"version": "2.0", "generator": "KitsuneBusterHeroAssetV4"},
            "scenes": [{"nodes": [0]}],
            "scene": 0,
            "nodes": [{"name": "blaster_kitsune", "mesh": 0}],
            "meshes": [{"name": "kitsune_mesh", "primitives": primitives}],
            "materials": self.materials,
            "accessors": accessors,
            "bufferViews": buffer_views,
            "buffers": [{"byteLength": len(binary_data)}]
        }
        
        json_bytes = json.dumps(gltf, separators=(',', ':')).encode('utf-8')
        while len(json_bytes) % 4 != 0: json_bytes += b' '
            
        header = struct.pack('<III', 0x46546C67, 2, 12 + 8 + len(json_bytes) + 8 + len(binary_data))
        json_chunk_hdr = struct.pack('<II', len(json_bytes), 0x4E4F534A)
        bin_chunk_hdr = struct.pack('<II', len(binary_data), 0x004E4942)
        
        with open(output_path, 'wb') as f:
            f.write(header)
            f.write(json_chunk_hdr)
            f.write(json_bytes)
            f.write(bin_chunk_hdr)
            f.write(binary_data)
            
        print(f"Generated {output_path} ({len(header) + len(json_chunk_hdr) + len(json_bytes) + len(bin_chunk_hdr) + len(binary_data)} bytes)")

def build_kitsune_blaster(output_path="assets/blaster_kitsune.glb"):
    builder = GLTFBuilder()
    
    # ── PALETTE MATERIALS (Kenney-Balanced 60 / 20 / 12 / 8 %) ──
    # 1. Divine Pearl White (Main Chassis Body)
    m_white = builder.add_material("Mat_PearlWhite", [0.96, 0.96, 0.98, 1.0], metallic=0.06, roughness=0.18)
    # 2. Bold Crimson Red (Integrated Buster Blade Spine & Trim)
    m_red   = builder.add_material("Mat_Crimson", [0.88, 0.10, 0.16, 1.0], metallic=0.14, roughness=0.22)
    # 3. Cyber Gold (Structural Collar Bands & End Caps)
    m_gold  = builder.add_material("Mat_CyberGold", [0.98, 0.76, 0.14, 1.0], metallic=0.50, roughness=0.22)
    # 4. Dark Charcoal Gunmetal (Ergonomic Grip, Internal Barrel, Skeletal Frame)
    m_dark  = builder.add_material("Mat_DarkCharcoal", [0.12, 0.12, 0.16, 1.0], metallic=0.25, roughness=0.50)
    # 5. Glowing Cyan Energy (Twin Water Vials, Reticle Lens, Muzzle Core, Chamber Vials)
    m_cyan  = builder.add_material("Mat_CyanEnergy", [0.25, 0.88, 1.0, 1.0], metallic=0.05, roughness=0.10, emissive_rgb=[0.50, 0.95, 1.0])
    # 6. Translucent Amber-Gold Glass (Revolving Kyubi Cylinder Drum Shell)
    m_trans_gold = builder.add_material("Mat_CyberGoldTranslucent", [0.98, 0.78, 0.16, 0.38], metallic=0.15, roughness=0.15, alpha_mode="BLEND")
    
    # ══════════════════════════════════════════════════════════════
    # 1. CHUNKY ERGONOMIC GRIP & LOWER FRAME
    # ══════════════════════════════════════════════════════════════
    # Solid, comfortable grip (Dark Gunmetal, width = 0.18, height = 0.40)
    v, n, idx = create_chamfered_box(0.0, 0.22, width=0.18, height=0.40, z0=-0.24, z1=-0.06, chamfer=0.04)
    builder.add_geometry(m_dark, v, n, idx)
    
    # Flared Grip Heel Base Plate (Pearl White, width = 0.24)
    v, n, idx = create_chamfered_box(0.0, 0.025, width=0.24, height=0.05, z0=-0.30, z1=-0.04, chamfer=0.02)
    builder.add_geometry(m_white, v, n, idx)
    
    # Bold Side Grip Accents (Crimson inlays on flanks)
    v, n, idx = create_chamfered_box(-0.092, 0.22, width=0.016, height=0.28, z0=-0.22, z1=-0.08, chamfer=0.005)
    builder.add_geometry(m_red, v, n, idx)
    v, n, idx = create_chamfered_box(0.092, 0.22, width=0.016, height=0.28, z0=-0.22, z1=-0.08, chamfer=0.005)
    builder.add_geometry(m_red, v, n, idx)
    
    # Rounded Trigger Guard (Dark Charcoal, width = 0.06)
    v, n, idx = create_chamfered_box(0.0, 0.23, width=0.06, height=0.05, z0=-0.06, z1=0.10, chamfer=0.010)
    builder.add_geometry(m_dark, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.32, width=0.06, height=0.18, z0=0.08, z1=0.12, chamfer=0.010)
    builder.add_geometry(m_dark, v, n, idx)
    
    # Curved Crimson Trigger
    v, n, idx = create_chamfered_box(0.0, 0.30, width=0.04, height=0.12, z0=-0.03, z1=0.02, chamfer=0.008)
    builder.add_geometry(m_red, v, n, idx)
    
    # ══════════════════════════════════════════════════════════════
    # 2. REAR STOCK & TWIN HYDRO-RESERVOIR VIALS
    # ══════════════════════════════════════════════════════════════
    # Lower receiver housing (Pearl White, width = 0.30)
    v, n, idx = create_chamfered_box(0.0, 0.46, width=0.30, height=0.16, z0=-0.30, z1=0.02, chamfer=0.04)
    builder.add_geometry(m_white, v, n, idx)
    
    # Rear Stock Housing (Pearl White, width = 0.28)
    v, n, idx = create_chamfered_box(0.0, 0.50, width=0.28, height=0.20, z0=-0.52, z1=-0.30, chamfer=0.04)
    builder.add_geometry(m_white, v, n, idx)
    
    # Twin Luminous Hydro-Reservoir Glass Tubes (Left & Right water canisters)
    for x_tube in [-0.075, 0.075]:
        v, n, idx = create_cylinder(x_tube, 0.50, z0=-0.50, z1=-0.32, radius=0.045, sides=16)
        builder.add_geometry(m_cyan, v, n, idx)
        v, n, idx = create_cylinder(x_tube, 0.50, z0=-0.51, z1=-0.49, radius=0.052, sides=16)
        builder.add_geometry(m_gold, v, n, idx)
        v, n, idx = create_cylinder(x_tube, 0.50, z0=-0.33, z1=-0.31, radius=0.052, sides=16)
        builder.add_geometry(m_gold, v, n, idx)
        
    # Two Clean, Bold Cooling Notches on Top Stock (Replaces noisy micro-fins)
    for z_fin in [-0.46, -0.36]:
        v, n, idx = create_chamfered_box(0.0, 0.59, width=0.26, height=0.03, z0=z_fin - 0.02, z1=z_fin + 0.02, chamfer=0.008)
        builder.add_geometry(m_red, v, n, idx)
        
    # ══════════════════════════════════════════════════════════════
    # 3. THE REVOLVING KYUBI DRUM (HERO CENTERPIECE, RADIUS 0.205)
    # ══════════════════════════════════════════════════════════════
    # Bulked 24-sided Translucent Cyber Gold Cylinder Drum (Z from 0.04 to 0.32, radius = 0.205)
    # Translucent glass reveals the 9 glowing cyan water bores & central axle inside!
    v, n, idx = create_cylinder(0.0, 0.48, z0=0.04, z1=0.32, radius=0.205, sides=24)
    builder.add_geometry(m_trans_gold, v, n, idx)
    
    # Outer Beveled Gold Rim Bands
    v, n, idx = create_cylinder(0.0, 0.48, z0=0.035, z1=0.065, radius=0.218, sides=24)
    builder.add_geometry(m_gold, v, n, idx)
    v, n, idx = create_cylinder(0.0, 0.48, z0=0.295, z1=0.325, radius=0.218, sides=24)
    builder.add_geometry(m_gold, v, n, idx)
    
    # Heavy Central Axle (Dark Charcoal, radius = 0.065)
    v, n, idx = create_cylinder(0.0, 0.48, z0=0.015, z1=0.345, radius=0.065, sides=16)
    builder.add_geometry(m_dark, v, n, idx)
    
    # 9 Drilled Chamber Bores with Glowing Cyan Water Energy Cores
    for i in range(9):
        ang = (i / 9.0) * 2 * math.pi
        bore_r = 0.145
        bx = math.cos(ang) * bore_r
        by = 0.48 + math.sin(ang) * bore_r
        # Glowing inner core
        v, n, idx = create_cylinder(bx, by, z0=0.05, z1=0.31, radius=0.038, sides=12)
        builder.add_geometry(m_cyan, v, n, idx)
        # Steel rim bezels around mouth
        v, n, idx = create_cylinder(bx, by, z0=0.038, z1=0.052, radius=0.044, sides=12)
        builder.add_geometry(m_dark, v, n, idx)
        v, n, idx = create_cylinder(bx, by, z0=0.308, z1=0.322, radius=0.044, sides=12)
        builder.add_geometry(m_dark, v, n, idx)
        
    # Chunky Pearl White Cylinder Frame Bridges (Cradling the drum with clean 45° bevels)
    # Rear Bridge (Z = 0.00 to 0.04)
    v, n, idx = create_chamfered_box(0.0, 0.48, width=0.32, height=0.30, z0=0.00, z1=0.04, chamfer=0.04)
    builder.add_geometry(m_white, v, n, idx)
    # Front Bridge (Z = 0.32 to 0.36)
    v, n, idx = create_chamfered_box(0.0, 0.48, width=0.32, height=0.30, z0=0.32, z1=0.36, chamfer=0.04)
    builder.add_geometry(m_white, v, n, idx)
    
    # ══════════════════════════════════════════════════════════════
    # 4. UPPER RECEIVER & INTEGRATED TACTICAL DECKS
    # ══════════════════════════════════════════════════════════════
    # Rear Pearl-White Top Deck (Behind drum: Z = -0.32 to 0.00)
    v, n, idx = create_chamfered_box(0.0, 0.63, width=0.28, height=0.12, z0=-0.32, z1=0.00, chamfer=0.04)
    builder.add_geometry(m_white, v, n, idx)
    
    # Rear Recessed Dark Gunmetal Shoulder Panels
    v, n, idx = create_chamfered_box(-0.141, 0.63, width=0.016, height=0.06, z0=-0.24, z1=-0.02, chamfer=0.005)
    builder.add_geometry(m_dark, v, n, idx)
    v, n, idx = create_chamfered_box(0.141, 0.63, width=0.016, height=0.06, z0=-0.24, z1=-0.02, chamfer=0.005)
    builder.add_geometry(m_dark, v, n, idx)
    
    # Lower Frame Connecting Keel Under Cylinder (Cradling the drum from below: Z = 0.00 to 0.36)
    v, n, idx = create_chamfered_box(0.0, 0.28, width=0.16, height=0.06, z0=0.00, z1=0.36, chamfer=0.02)
    builder.add_geometry(m_white, v, n, idx)
    
    # Forward Pearl-White Top Deck (In front of drum: Z = 0.36 to 0.58)
    v, n, idx = create_chamfered_box(0.0, 0.63, width=0.28, height=0.12, z0=0.36, z1=0.58, chamfer=0.04)
    builder.add_geometry(m_white, v, n, idx)
    
    # Forward Recessed Dark Gunmetal Shoulder Panels
    v, n, idx = create_chamfered_box(-0.141, 0.63, width=0.016, height=0.06, z0=0.38, z1=0.54, chamfer=0.005)
    builder.add_geometry(m_dark, v, n, idx)
    v, n, idx = create_chamfered_box(0.141, 0.63, width=0.016, height=0.06, z0=0.38, z1=0.54, chamfer=0.005)
    builder.add_geometry(m_dark, v, n, idx)
    
    # Forward Barrel Shroud Base (Pearl White, width = 0.28)
    v, n, idx = create_chamfered_box(0.0, 0.48, width=0.28, height=0.26, z0=0.36, z1=0.60, chamfer=0.045)
    builder.add_geometry(m_white, v, n, idx)
    
    # ══════════════════════════════════════════════════════════════
    # 5. HYDRO-CANNON BARREL & MUZZLE BRAKE
    # ══════════════════════════════════════════════════════════════
    # Inner Steel Barrel Cylinder (Dark Gunmetal)
    v, n, idx = create_cylinder(0.0, 0.48, z0=0.60, z1=0.96, radius=0.075, sides=16)
    builder.add_geometry(m_dark, v, n, idx)
    
    # Outer Octagonal Heat Shroud (Pearl White, connects flush into muzzle brake)
    v, n, idx = create_chamfered_box(0.0, 0.48, width=0.22, height=0.20, z0=0.60, z1=0.88, chamfer=0.035)
    builder.add_geometry(m_white, v, n, idx)
    
    # Heavy Dual-Port Muzzle Brake (Dark Charcoal Gunmetal, width = 0.20)
    v, n, idx = create_chamfered_box(0.0, 0.48, width=0.20, height=0.18, z0=0.88, z1=0.97, chamfer=0.030)
    builder.add_geometry(m_dark, v, n, idx)
    
    # Muzzle Brake Side Exhaust Cutouts (Crimson accents)
    v, n, idx = create_chamfered_box(-0.102, 0.48, width=0.012, height=0.07, z0=0.90, z1=0.95, chamfer=0.003)
    builder.add_geometry(m_red, v, n, idx)
    v, n, idx = create_chamfered_box(0.102, 0.48, width=0.012, height=0.07, z0=0.90, z1=0.95, chamfer=0.003)
    builder.add_geometry(m_red, v, n, idx)
    
    # Luminous Muzzle Water-Emitter Ring (Glowing Cyan)
    v, n, idx = create_cylinder(0.0, 0.48, z0=0.96, z1=0.99, radius=0.068, sides=16)
    builder.add_geometry(m_cyan, v, n, idx)
    
    # Crimson Muzzle Crown Ring
    v, n, idx = create_cylinder(0.0, 0.48, z0=0.985, z1=1.005, radius=0.062, sides=16)
    builder.add_geometry(m_red, v, n, idx)
    
    # ══════════════════════════════════════════════════════════════
    # 6. SEAMLESS FORGED BUSTER BLADES (TOP BAYONET & UNDER-KEEL)
    # ══════════════════════════════════════════════════════════════
    # ══════════════════════════════════════════════════════════════
    # 6. SEAMLESS FORGED BUSTER BLADES (TOP BAYONET & UNDER-KEEL)
    # ══════════════════════════════════════════════════════════════
    # Recessed Dark Gunmetal Sightline Channel (Behind sight, Z = -0.28 to -0.04)
    # Replaces the view-blocking fin with a sleek, tactical alignment channel
    v, n, idx = create_chamfered_box(0.0, 0.692, width=0.07, height=0.012, z0=-0.28, z1=-0.04, chamfer=0.003)
    builder.add_geometry(m_dark, v, n, idx)
    
    # Inlaid Crimson Trim Ribs flanking the sightline channel
    v, n, idx = create_chamfered_box(-0.046, 0.692, width=0.010, height=0.010, z0=-0.26, z1=-0.05, chamfer=0.002)
    builder.add_geometry(m_red, v, n, idx)
    v, n, idx = create_chamfered_box(0.046, 0.692, width=0.010, height=0.010, z0=-0.26, z1=-0.05, chamfer=0.002)
    builder.add_geometry(m_red, v, n, idx)
    
    # Forward Crimson Spine Crest (Emerged immediately in front of reflex sight: Z = 0.08 to 0.55)
    # Sweeps forward gracefully over the revolving Kyubi drum and barrel base
    spine_pts = [
        [0.0, 0.725],       # Top razor crest
        [0.042, 0.685],     # Right shoulder
        [0.035, 0.650],     # Right base (meets white deck flush)
        [-0.035, 0.650],    # Left base
        [-0.042, 0.685]     # Left shoulder
    ]
    v, n, idx = create_extrusion(spine_pts, z0=0.08, z1=0.55, caps=True)
    builder.add_geometry(m_red, v, n, idx)
    
    # Seamless Top Bayonet Blade (Extends from Z = 0.55 to 1.06, locking over the barrel)
    # Double-beveled diamond blade that emerges directly from the spine crest!
    bayonet_start = [
        [0.0, 0.725],
        [0.042, 0.685],
        [0.0, 0.580],       # Keel hugs top of barrel shroud
        [-0.042, 0.685]
    ]
    bayonet_end = [
        [0.0, 0.640],
        [0.003, 0.615],
        [0.0, 0.590],
        [-0.003, 0.615]
    ]
    v, n, idx = create_tapered_extrusion(bayonet_start, bayonet_end, z0=0.55, z1=1.06, caps=True)
    builder.add_geometry(m_red, v, n, idx)
    
    # Seamless Under-Barrel Stabilizer Blade (Bottom crimson keel from Z = 0.36 to Z = 0.90)
    under_start = [
        [0.0, 0.400],
        [0.036, 0.355],
        [0.0, 0.280],
        [-0.036, 0.355]
    ]
    under_end = [
        [0.0, 0.425],
        [0.003, 0.400],
        [0.0, 0.375],
        [-0.003, 0.400]
    ]
    v, n, idx = create_tapered_extrusion(under_start, under_end, z0=0.36, z1=0.90, caps=True)
    builder.add_geometry(m_red, v, n, idx)
    
    # ══════════════════════════════════════════════════════════════
    # 7. LOW-PROFILE OPEN HOLOGRAPHIC REFLEX SIGHT (CLEAN FPS VIEW)
    # ══════════════════════════════════════════════════════════════
    # Compact sight riser (Dark Gunmetal, sits flush on upper deck at Z = -0.04 to 0.08)
    v, n, idx = create_chamfered_box(0.0, 0.695, width=0.11, height=0.018, z0=-0.04, z1=0.08, chamfer=0.005)
    builder.add_geometry(m_dark, v, n, idx)
    
    # Twin Slender Protective Lens Posts (Left & Right ears, pearl-white)
    v, n, idx = create_chamfered_box(-0.060, 0.745, width=0.016, height=0.085, z0=-0.02, z1=0.06, chamfer=0.004)
    builder.add_geometry(m_white, v, n, idx)
    v, n, idx = create_chamfered_box(0.060, 0.745, width=0.016, height=0.085, z0=-0.02, z1=0.06, chamfer=0.004)
    builder.add_geometry(m_white, v, n, idx)
    
    # Open Frameless Holographic Cyan Reticle Glass Plate
    # Completely open at the top (Y = 0.70 to 0.785), offering 100% crystal-clear sightline!
    reticle_pts = [
        [-0.050, 0.705],
        [0.050,  0.705],
        [0.045,  0.785],
        [-0.045, 0.785]
    ]
    v, n, idx = create_extrusion(reticle_pts, z0=0.015, z1=0.025, caps=True)
    builder.add_geometry(m_cyan, v, n, idx)
    
    # Build the GLB file
    builder.build_glb(output_path)

if __name__ == "__main__":
    build_kitsune_blaster()
