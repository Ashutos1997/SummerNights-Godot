#!/usr/bin/env python3
"""
build_kitsune_unified.py - Generates an enhanced, articulated, transforming Kitsune Buster IX GLB.
Celestial Polish Upgrades:
- Authentic Katana curvature (sori), kissaki chisel tip, fuller, and glowing cyan plasma cutting edge.
- Sculpted multi-layered fox-flame Tsuba crossguard wings with golden quill crests and cyan energy conduits.
- Skeletonized receiver chassis with an open sightline window exposing the 9-vial Kyubi revolving cylinder.
- Angled aerodynamic mecha fox-ear cowl fins flanking the holographic reflex sight.
- Vented octagonal barrel shroud with dual-port compensator and side exhaust gills.
- Preserves exact node hierarchy and animation pivots for Main.gd compatibility.
"""

import os
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
        c_front = len(verts)
        center_front = [float(np.mean(pts[:, 0])), float(np.mean(pts[:, 1])), z1]
        verts.append(center_front)
        normals.append([0.0, 0.0, 1.0])
        for p in pts:
            verts.append([p[0], p[1], z1])
            normals.append([0.0, 0.0, 1.0])
        for i in range(n_pts):
            indices.extend([c_front, c_front + 1 + i, c_front + 1 + ((i + 1) % n_pts)])
            
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
    verts = []
    normals = []
    indices = []
    
    for i in range(n_pts):
        next_i = (i + 1) % n_pts
        p0_start = np.array([start_ccw[i][0], start_ccw[i][1], z0], dtype=np.float32)
        p1_start = np.array([start_ccw[next_i][0], start_ccw[next_i][1], z0], dtype=np.float32)
        p1_end   = np.array([end_ccw[next_i][0], end_ccw[next_i][1], z1], dtype=np.float32)
        p0_end   = np.array([end_ccw[i][0], end_ccw[i][1], z1], dtype=np.float32)
        
        n = np.cross(p1_start - p0_start, p0_end - p0_start)
        length = np.linalg.norm(n)
        norm_v = (n / length).tolist() if length > 1e-6 else [0.0, 1.0, 0.0]
        
        base = len(verts)
        verts.extend([p0_start.tolist(), p1_start.tolist(), p1_end.tolist(), p0_end.tolist()])
        normals.extend([norm_v] * 4)
        indices.extend([base, base + 1, base + 2, base, base + 2, base + 3])
        
    if caps and n_pts >= 3:
        pts_f = np.array(end_ccw, dtype=np.float32)
        c_front = len(verts)
        center_front = [float(np.mean(pts_f[:, 0])), float(np.mean(pts_f[:, 1])), z1]
        verts.append(center_front)
        normals.append([0.0, 0.0, 1.0])
        for p in end_ccw:
            verts.append([p[0], p[1], z1])
            normals.append([0.0, 0.0, 1.0])
        for i in range(n_pts):
            indices.extend([c_front, c_front + 1 + i, c_front + 1 + ((i + 1) % n_pts)])
            
        pts_b = np.array(start_ccw, dtype=np.float32)
        c_back = len(verts)
        center_back = [float(np.mean(pts_b[:, 0])), float(np.mean(pts_b[:, 1])), z0]
        verts.append(center_back)
        normals.append([0.0, 0.0, -1.0])
        for p in start_ccw:
            verts.append([p[0], p[1], z0])
            normals.append([0.0, 0.0, -1.0])
        for i in range(n_pts):
            indices.extend([c_back, c_back + 1 + ((i + 1) % n_pts), c_back + 1 + i])
            
    return verts, normals, indices

def create_chamfered_box(center_x, center_y, width, height, z0, z1, chamfer=0.02):
    hw = width * 0.5
    hh = height * 0.5
    c = min(chamfer, hw * 0.45, hh * 0.45)
    pts = [
        [center_x - hw + c, center_y - hh],
        [center_x + hw - c, center_y - hh],
        [center_x + hw,     center_y - hh + c],
        [center_x + hw,     center_y + hh - c],
        [center_x + hw - c, center_y + hh],
        [center_x - hw + c, center_y + hh],
        [center_x - hw,     center_y + hh - c],
        [center_x - hw,     center_y - hh + c]
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

def create_lofted_poly(cross_sections, caps=True):
    """
    Lofts a sequence of 3D polygonal slices together.
    cross_sections: list of N slices, each slice is list of [X, Y, Z] points ordered CCW.
    """
    n_slices = len(cross_sections)
    if n_slices < 2:
        return [], [], []
        
    n_pts = len(cross_sections[0])
    verts = []
    normals = []
    indices = []
    
    for s in range(n_slices - 1):
        s0 = cross_sections[s]
        s1 = cross_sections[s + 1]
        for i in range(n_pts):
            next_i = (i + 1) % n_pts
            p00 = np.array(s0[i], dtype=np.float32)
            p01 = np.array(s0[next_i], dtype=np.float32)
            p11 = np.array(s1[next_i], dtype=np.float32)
            p10 = np.array(s1[i], dtype=np.float32)
            
            # Normal for quad
            norm = np.cross(p01 - p00, p10 - p00)
            norm_len = np.linalg.norm(norm)
            norm_v = (norm / norm_len).tolist() if norm_len > 1e-6 else [0.0, 1.0, 0.0]
            
            base = len(verts)
            verts.extend([p00.tolist(), p01.tolist(), p11.tolist(), p10.tolist()])
            normals.extend([norm_v] * 4)
            indices.extend([base, base + 1, base + 2, base, base + 2, base + 3])
            
    if caps and n_pts >= 3:
        # Front cap (last slice)
        last_s = cross_sections[-1]
        c_front = len(verts)
        center_f = np.mean(last_s, axis=0).tolist()
        verts.append(center_f)
        # Approximate forward normal
        f_norm = (np.array(last_s[0]) - np.array(cross_sections[-2][0]))
        f_norm_len = np.linalg.norm(f_norm)
        f_norm_v = (f_norm / f_norm_len).tolist() if f_norm_len > 1e-6 else [0.0, 0.0, 1.0]
        normals.append(f_norm_v)
        for p in last_s:
            verts.append(p)
            normals.append(f_norm_v)
        for i in range(n_pts):
            indices.extend([c_front, c_front + 1 + i, c_front + 1 + ((i + 1) % n_pts)])
            
        # Back cap (first slice)
        first_s = cross_sections[0]
        c_back = len(verts)
        center_b = np.mean(first_s, axis=0).tolist()
        verts.append(center_b)
        b_norm = [-v for v in f_norm_v]
        normals.append(b_norm)
        for p in first_s:
            verts.append(p)
            normals.append(b_norm)
        for i in range(n_pts):
            indices.extend([c_back, c_back + 1 + ((i + 1) % n_pts), c_back + 1 + i])
            
    return verts, normals, indices

class MultiNodeGLTFBuilder:
    def __init__(self):
        self.materials = []
        self.nodes = [] # List of {"name", "translation", "rotation", "scale", "mesh_idx", "children"}
        self.meshes = [] # List of list of primitives: [{"mat_idx", "verts", "normals", "indices"}]
        
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
        return mat_idx

    def create_mesh(self, name):
        mesh_idx = len(self.meshes)
        self.meshes.append([])
        return mesh_idx

    def add_mesh_primitive(self, mesh_idx, mat_idx, verts, normals, indices):
        v = np.array(verts, dtype=np.float32)
        n = np.array(normals, dtype=np.float32)
        idx = np.array(indices, dtype=np.uint32)
        self.meshes[mesh_idx].append({
            "mat_idx": mat_idx,
            "verts": v,
            "normals": n,
            "indices": idx
        })

    def add_node(self, name, mesh_idx=None, translation=None, rotation=None, scale=None, children=None):
        node_idx = len(self.nodes)
        node_dict = {"name": name}
        if mesh_idx is not None:
            node_dict["mesh"] = mesh_idx
        if translation is not None:
            node_dict["translation"] = translation
        if rotation is not None:
            node_dict["rotation"] = rotation
        if scale is not None:
            node_dict["scale"] = scale
        if children is not None:
            node_dict["children"] = children
        self.nodes.append(node_dict)
        return node_idx

    def build_glb(self, output_path):
        binary_data = bytearray()
        accessors = []
        buffer_views = []
        gltf_meshes = []
        
        for m_idx, primitives_data in enumerate(self.meshes):
            mesh_prims = []
            for prim in primitives_data:
                mat_idx = prim["mat_idx"]
                verts = prim["verts"]
                normals = prim["normals"]
                indices = prim["indices"]
                
                # Indices accessor
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
                    "bufferView": idx_view, "byteOffset": 0, "componentType": 5125, "count": len(indices), "type": "SCALAR",
                    "min": [int(indices.min())], "max": [int(indices.max())]
                })
                
                # Position accessor
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
                
                # Normal accessor
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
                
                mesh_prims.append({
                    "attributes": {"POSITION": pos_acc, "NORMAL": norm_acc},
                    "indices": idx_acc,
                    "material": mat_idx
                })
            gltf_meshes.append({"primitives": mesh_prims})
            
        gltf = {
            "asset": {"version": "2.0", "generator": "UnifiedKitsuneBuilderEnhanced"},
            "scenes": [{"nodes": [0]}],
            "scene": 0,
            "nodes": self.nodes,
            "meshes": gltf_meshes,
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

def build_unified_kitsune(output_path="assets/blaster_kitsune_unified.glb"):
    builder = MultiNodeGLTFBuilder()
    
    # ── PALETTE MATERIALS ──
    # Pearl white ceramic armour
    m_white = builder.add_material("Mat_PearlWhite", [0.96, 0.96, 0.98, 1.0], metallic=0.08, roughness=0.16)
    # Shinto lacquer crimson
    m_red   = builder.add_material("Mat_Crimson", [0.88, 0.10, 0.16, 1.0], metallic=0.14, roughness=0.20)
    # Celestial polished cyber-gold
    m_gold  = builder.add_material("Mat_CyberGold", [0.98, 0.78, 0.16, 1.0], metallic=0.70, roughness=0.18)
    # Deep tactical charcoal alloy
    m_dark  = builder.add_material("Mat_DarkCharcoal", [0.10, 0.11, 0.14, 1.0], metallic=0.30, roughness=0.45)
    # Radiant celestial cyan energy (high emissive bloom)
    m_cyan  = builder.add_material("Mat_CyanEnergy", [0.22, 0.90, 1.0, 1.0], metallic=0.05, roughness=0.10, emissive_rgb=[0.80, 1.40, 1.60])
    # Translucent amber/gold Kyubi drum glass
    m_trans_gold = builder.add_material("Mat_CyberGoldTranslucent", [0.98, 0.80, 0.18, 0.38], metallic=0.20, roughness=0.12, alpha_mode="BLEND")
    # Frosted cyan energy conduits
    m_trans_cyan = builder.add_material("Mat_CyanTranslucent", [0.25, 0.92, 1.0, 0.45], metallic=0.10, roughness=0.10, emissive_rgb=[0.40, 0.80, 1.0], alpha_mode="BLEND")

    # ══════════════════════════════════════════════════════════════
    # 1. CHASSIS MESH (Root Body, Fixed Coordinates)
    # ══════════════════════════════════════════════════════════════
    mesh_chassis = builder.create_mesh("Mesh_Chassis")
    
    # Ergonomic Grip & Braided Tsuka Wrap Pattern
    v, n, idx = create_chamfered_box(0.0, 0.22, width=0.17, height=0.38, z0=-0.24, z1=-0.06, chamfer=0.04)
    builder.add_mesh_primitive(mesh_chassis, m_dark, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.025, width=0.23, height=0.05, z0=-0.28, z1=-0.04, chamfer=0.02)
    builder.add_mesh_primitive(mesh_chassis, m_gold, v, n, idx)
    
    # Diamond Relief Wrap Accents (Tsuka-Ito cords)
    for z_wrap in [-0.20, -0.15, -0.10]:
        v, n, idx = create_chamfered_box(0.0, 0.22, width=0.185, height=0.035, z0=z_wrap - 0.015, z1=z_wrap + 0.015, chamfer=0.008)
        builder.add_mesh_primitive(mesh_chassis, m_red, v, n, idx)
        for side in [-0.093, 0.093]:
            v, n, idx = create_chamfered_box(side, 0.22, width=0.012, height=0.025, z0=z_wrap - 0.012, z1=z_wrap + 0.012, chamfer=0.004)
            builder.add_mesh_primitive(mesh_chassis, m_gold, v, n, idx)
            
    # Trigger Guard & Crimson Beveled Trigger
    v, n, idx = create_chamfered_box(0.0, 0.23, width=0.06, height=0.04, z0=-0.06, z1=0.10, chamfer=0.010)
    builder.add_mesh_primitive(mesh_chassis, m_dark, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.32, width=0.06, height=0.16, z0=0.08, z1=0.12, chamfer=0.010)
    builder.add_mesh_primitive(mesh_chassis, m_dark, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.30, width=0.036, height=0.12, z0=-0.03, z1=0.02, chamfer=0.008)
    builder.add_mesh_primitive(mesh_chassis, m_red, v, n, idx)
    
    # Stock Housing & Twin Hydro-Reservoirs with Golden Rings
    v, n, idx = create_chamfered_box(0.0, 0.46, width=0.30, height=0.16, z0=-0.30, z1=0.02, chamfer=0.04)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.50, width=0.28, height=0.20, z0=-0.54, z1=-0.30, chamfer=0.04)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    
    # Twin Hydro-Canisters
    for xt in [-0.075, 0.075]:
        v, n, idx = create_cylinder(xt, 0.50, z0=-0.52, z1=-0.32, radius=0.045, sides=16)
        builder.add_mesh_primitive(mesh_chassis, m_cyan, v, n, idx)
        v, n, idx = create_cylinder(xt, 0.50, z0=-0.53, z1=-0.51, radius=0.052, sides=16)
        builder.add_mesh_primitive(mesh_chassis, m_gold, v, n, idx)
        v, n, idx = create_cylinder(xt, 0.50, z0=-0.33, z1=-0.31, radius=0.052, sides=16)
        builder.add_mesh_primitive(mesh_chassis, m_gold, v, n, idx)
        # Vertical level-gauge sight glass
        v, n, idx = create_chamfered_box(xt * 1.55, 0.50, width=0.014, height=0.014, z0=-0.48, z1=-0.36, chamfer=0.003)
        builder.add_mesh_primitive(mesh_chassis, m_gold, v, n, idx)
        
    for z_fin in [-0.48, -0.38]:
        v, n, idx = create_chamfered_box(0.0, 0.59, width=0.26, height=0.025, z0=z_fin - 0.015, z1=z_fin + 0.015, chamfer=0.006)
        builder.add_mesh_primitive(mesh_chassis, m_red, v, n, idx)

    # ── SKELETONIZED CYLINDER RECEIVER & SIGHTLINE APERTURE ──
    # Left & Right Arch Brackets with Viewing Port (Allows seeing Kyubi drum in First-Person)
    # Lower Keel Rails
    v, n, idx = create_chamfered_box(0.0, 0.28, width=0.16, height=0.06, z0=0.00, z1=0.36, chamfer=0.02)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.29, width=0.18, height=0.02, z0=0.02, z1=0.34, chamfer=0.006)
    builder.add_mesh_primitive(mesh_chassis, m_gold, v, n, idx)
    
    # Rear Cradle & Torii Post (Z = 0.00 to 0.04)
    v, n, idx = create_chamfered_box(0.0, 0.48, width=0.32, height=0.28, z0=0.00, z1=0.04, chamfer=0.04)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.48, width=0.33, height=0.04, z0=0.005, z1=0.035, chamfer=0.01)
    builder.add_mesh_primitive(mesh_chassis, m_red, v, n, idx)
    
    # Forward Collar Cradle (Z = 0.32 to 0.36)
    v, n, idx = create_chamfered_box(0.0, 0.48, width=0.32, height=0.28, z0=0.32, z1=0.36, chamfer=0.04)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.48, width=0.33, height=0.04, z0=0.325, z1=0.355, chamfer=0.01)
    builder.add_mesh_primitive(mesh_chassis, m_red, v, n, idx)
    
    # Left & Right Longitudinal Reinforcing Struts with Sightline Windows
    for side_x in [-0.155, 0.155]:
        # Upper structural spar
        v, n, idx = create_chamfered_box(side_x, 0.60, width=0.025, height=0.04, z0=0.04, z1=0.32, chamfer=0.008)
        builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
        v, n, idx = create_chamfered_box(side_x, 0.60, width=0.028, height=0.015, z0=0.06, z1=0.30, chamfer=0.004)
        builder.add_mesh_primitive(mesh_chassis, m_red, v, n, idx)
        # Lower structural spar
        v, n, idx = create_chamfered_box(side_x, 0.36, width=0.025, height=0.04, z0=0.04, z1=0.32, chamfer=0.008)
        builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
        # Angled reinforcement diagonal struts
        v, n, idx = create_chamfered_box(side_x, 0.48, width=0.022, height=0.05, z0=0.16, z1=0.20, chamfer=0.006)
        builder.add_mesh_primitive(mesh_chassis, m_gold, v, n, idx)

    # Forward Deck & Collar Base (Z = 0.36 to 0.60)
    v, n, idx = create_chamfered_box(0.0, 0.63, width=0.28, height=0.12, z0=0.36, z1=0.58, chamfer=0.04)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.48, width=0.28, height=0.26, z0=0.36, z1=0.60, chamfer=0.045)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    # Gold collar ring at barrel/blade exit interface
    v, n, idx = create_cylinder(0.0, 0.48, z0=0.575, z1=0.60, radius=0.115, sides=20)
    builder.add_mesh_primitive(mesh_chassis, m_gold, v, n, idx)

    # ── KITSUNE FOX-EAR COWL FINS (Upper Receiver Flanks) ──
    # Angled mecha fox ears flanking the sightline
    for ear_side in [-1, 1]:
        # Left Ear (ear_side = -1), Right Ear (ear_side = 1)
        bx = ear_side * 0.105
        tip_x = ear_side * 0.155
        # 3D points forming a swept triangular mecha ear
        ear_base = [
            [bx - ear_side * 0.02, 0.68, -0.06],
            [bx + ear_side * 0.02, 0.68, -0.06],
            [bx + ear_side * 0.02, 0.68, 0.08],
            [bx - ear_side * 0.02, 0.68, 0.08]
        ]
        ear_mid = [
            [bx * 1.15 - ear_side * 0.015, 0.77, -0.04],
            [bx * 1.15 + ear_side * 0.015, 0.77, -0.04],
            [bx * 1.15 + ear_side * 0.015, 0.77, 0.04],
            [bx * 1.15 - ear_side * 0.015, 0.77, 0.04]
        ]
        ear_tip = [
            [tip_x - ear_side * 0.005, 0.85, -0.02],
            [tip_x + ear_side * 0.005, 0.85, -0.02],
            [tip_x + ear_side * 0.005, 0.85, 0.01],
            [tip_x - ear_side * 0.005, 0.85, 0.01]
        ]
        v, n, idx = create_lofted_poly([ear_base, ear_mid, ear_tip], caps=True)
        builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
        
        # Inner ear crimson bevel accent
        inner_base = [
            [bx, 0.69, -0.04],
            [bx + ear_side * 0.015, 0.69, -0.04],
            [bx + ear_side * 0.015, 0.69, 0.05],
            [bx, 0.69, 0.05]
        ]
        inner_tip = [
            [tip_x - ear_side * 0.005, 0.82, -0.01],
            [tip_x + ear_side * 0.005, 0.82, -0.01],
            [tip_x + ear_side * 0.005, 0.82, 0.01],
            [tip_x - ear_side * 0.005, 0.82, 0.01]
        ]
        v, n, idx = create_lofted_poly([inner_base, inner_tip], caps=True)
        builder.add_mesh_primitive(mesh_chassis, m_red, v, n, idx)
        
        # Cyan energy line running up outer ear ridge
        v, n, idx = create_chamfered_box(bx * 1.05, 0.76, width=0.008, height=0.09, z0=0.065, z1=0.075, chamfer=0.002)
        builder.add_mesh_primitive(mesh_chassis, m_cyan, v, n, idx)

    # ── HOLOGRAPHIC REFLEX SIGHT ──
    v, n, idx = create_chamfered_box(0.0, 0.695, width=0.11, height=0.018, z0=-0.04, z1=0.08, chamfer=0.005)
    builder.add_mesh_primitive(mesh_chassis, m_dark, v, n, idx)
    v, n, idx = create_chamfered_box(-0.060, 0.745, width=0.016, height=0.085, z0=-0.02, z1=0.06, chamfer=0.004)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    v, n, idx = create_chamfered_box(0.060, 0.745, width=0.016, height=0.085, z0=-0.02, z1=0.06, chamfer=0.004)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.785, width=0.136, height=0.015, z0=-0.02, z1=0.06, chamfer=0.003)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    
    # Holographic Cyan Reticle Emitter Glass
    reticle_pts = [[-0.048, 0.705], [0.048, 0.705], [0.045, 0.775], [-0.045, 0.775]]
    v, n, idx = create_extrusion(reticle_pts, z0=0.015, z1=0.025, caps=True)
    builder.add_mesh_primitive(mesh_chassis, m_trans_cyan, v, n, idx)
    # Central glowing diamond Kitsune pip inside the glass
    v, n, idx = create_chamfered_box(0.0, 0.740, width=0.012, height=0.012, z0=0.018, z1=0.022, chamfer=0.004)
    builder.add_mesh_primitive(mesh_chassis, m_cyan, v, n, idx)

    # ══════════════════════════════════════════════════════════════
    # 2. REVOLVING CYLINDER MESH (Pivot at X=0.0, Y=0.48, Z=0.18)
    # Coordinates centered locally around (0, 0, 0)
    # ══════════════════════════════════════════════════════════════
    mesh_cylinder = builder.create_mesh("Mesh_Cylinder")
    
    # Translucent Drum Outer Casing (Local Z from -0.14 to +0.14)
    v, n, idx = create_cylinder(0.0, 0.0, z0=-0.14, z1=0.14, radius=0.205, sides=24)
    builder.add_mesh_primitive(mesh_cylinder, m_trans_gold, v, n, idx)
    
    # Dual Gold Rim Bands with 9 Scalloped Notches
    v, n, idx = create_cylinder(0.0, 0.0, z0=-0.148, z1=-0.118, radius=0.218, sides=24)
    builder.add_mesh_primitive(mesh_cylinder, m_gold, v, n, idx)
    v, n, idx = create_cylinder(0.0, 0.0, z0=0.118, z1=0.148, radius=0.218, sides=24)
    builder.add_mesh_primitive(mesh_cylinder, m_gold, v, n, idx)
    
    # Central Mechanical Axle & Turbine Hub
    v, n, idx = create_cylinder(0.0, 0.0, z0=-0.165, z1=0.165, radius=0.065, sides=16)
    builder.add_mesh_primitive(mesh_cylinder, m_dark, v, n, idx)
    # Gold Turbine Spindle Blades inside the core
    for tb in range(6):
        tb_ang = (tb / 6.0) * math.pi
        v, n, idx = create_chamfered_box(0.0, 0.0, width=0.12, height=0.014, z0=-0.12, z1=0.12, chamfer=0.003)
        # Rotate manually by math
        cos_tb, sin_tb = math.cos(tb_ang), math.sin(tb_ang)
        v_rot = []
        for pt in v:
            rx = pt[0] * cos_tb - pt[1] * sin_tb
            ry = pt[0] * sin_tb + pt[1] * cos_tb
            v_rot.append([rx, ry, pt[2]])
        n_rot = []
        for norm in n:
            rx = norm[0] * cos_tb - norm[1] * sin_tb
            ry = norm[0] * sin_tb + norm[1] * cos_tb
            n_rot.append([rx, ry, norm[2]])
        builder.add_mesh_primitive(mesh_cylinder, m_gold, v_rot, n_rot, idx)

    # 9 Fluted Water Bores with Cyan Vials & Dark Collars
    for i in range(9):
        ang = (i / 9.0) * 2 * math.pi
        bore_r = 0.145
        bx = math.cos(ang) * bore_r
        by = math.sin(ang) * bore_r
        # Glowing Cyan Celestial Liquid Vial
        v, n, idx = create_cylinder(bx, by, z0=-0.13, z1=0.13, radius=0.038, sides=14)
        builder.add_mesh_primitive(mesh_cylinder, m_cyan, v, n, idx)
        # Brushed Dark Alloy Collars (Front & Back)
        v, n, idx = create_cylinder(bx, by, z0=-0.144, z1=-0.126, radius=0.044, sides=14)
        builder.add_mesh_primitive(mesh_cylinder, m_dark, v, n, idx)
        v, n, idx = create_cylinder(bx, by, z0=0.126, z1=0.144, radius=0.044, sides=14)
        builder.add_mesh_primitive(mesh_cylinder, m_dark, v, n, idx)
        # Gold Retaining Rings on Vials
        v, n, idx = create_cylinder(bx, by, z0=-0.01, z1=0.01, radius=0.042, sides=14)
        builder.add_mesh_primitive(mesh_cylinder, m_gold, v, n, idx)

    # ══════════════════════════════════════════════════════════════
    # 3. BARREL ASSEMBLY MESH (Pivot at X=0.0, Y=0.48, Z=0.55)
    # Coordinates relative to Z=0.55 (Cannon configuration)
    # ══════════════════════════════════════════════════════════════
    mesh_barrel = builder.create_mesh("Mesh_BarrelAssembly")
    
    # Inner Steel Rifled Barrel (local Z=0.05 to 0.44)
    v, n, idx = create_cylinder(0.0, 0.0, z0=0.05, z1=0.44, radius=0.075, sides=18)
    builder.add_mesh_primitive(mesh_barrel, m_dark, v, n, idx)
    
    # Outer Octagonal Shroud (local Z=0.05 to 0.34)
    v, n, idx = create_chamfered_box(0.0, 0.0, width=0.22, height=0.20, z0=0.05, z1=0.34, chamfer=0.038)
    builder.add_mesh_primitive(mesh_barrel, m_white, v, n, idx)
    
    # Longitudinal Vented Heat Gills (Left & Right Flanks)
    for side_x in [-0.112, 0.112]:
        for vent_z in [0.10, 0.17, 0.24]:
            # Recessed glowing cyan plasma vent
            v, n, idx = create_chamfered_box(side_x, 0.0, width=0.008, height=0.065, z0=vent_z - 0.022, z1=vent_z + 0.022, chamfer=0.002)
            builder.add_mesh_primitive(mesh_barrel, m_cyan, v, n, idx)
            # Dark louver grille cover
            v, n, idx = create_chamfered_box(side_x * 0.99, 0.0, width=0.004, height=0.060, z0=vent_z - 0.004, z1=vent_z + 0.004, chamfer=0.001)
            builder.add_mesh_primitive(mesh_barrel, m_dark, v, n, idx)
            
    # Dual-Port Compensator Muzzle Brake (local Z=0.34 to 0.44)
    v, n, idx = create_chamfered_box(0.0, 0.0, width=0.205, height=0.185, z0=0.34, z1=0.44, chamfer=0.032)
    builder.add_mesh_primitive(mesh_barrel, m_dark, v, n, idx)
    # Side Muzzle Baffle Ports
    for side_x in [-0.105, 0.105]:
        v, n, idx = create_chamfered_box(side_x, 0.0, width=0.012, height=0.075, z0=0.36, z1=0.42, chamfer=0.004)
        builder.add_mesh_primitive(mesh_barrel, m_red, v, n, idx)
        
    # Luminous Cyan Plasma Muzzle Ring & Gold Crown
    v, n, idx = create_cylinder(0.0, 0.0, z0=0.435, z1=0.455, radius=0.068, sides=18)
    builder.add_mesh_primitive(mesh_barrel, m_cyan, v, n, idx)
    v, n, idx = create_cylinder(0.0, 0.0, z0=0.450, z1=0.465, radius=0.064, sides=18)
    builder.add_mesh_primitive(mesh_barrel, m_gold, v, n, idx)
    
    # Top Bayonet Crest (local Z=0.0 to 0.52)
    bayonet_s = [[0.0, 0.725 - 0.48], [0.042, 0.685 - 0.48], [0.0, 0.580 - 0.48], [-0.042, 0.685 - 0.48]]
    bayonet_m = [[0.0, 0.690 - 0.48], [0.024, 0.655 - 0.48], [0.0, 0.585 - 0.48], [-0.024, 0.655 - 0.48]]
    bayonet_e = [[0.0, 0.640 - 0.48], [0.003, 0.615 - 0.48], [0.0, 0.590 - 0.48], [-0.003, 0.615 - 0.48]]
    v, n, idx = create_lofted_poly([
        [[p[0], p[1], 0.0] for p in bayonet_s],
        [[p[0], p[1], 0.32] for p in bayonet_m],
        [[p[0], p[1], 0.52] for p in bayonet_e]
    ], caps=True)
    builder.add_mesh_primitive(mesh_barrel, m_red, v, n, idx)
    
    # Under-Barrel Stabilizer Keel (local Z=-0.19 to 0.36)
    under_s = [[0.0, 0.400 - 0.48], [0.036, 0.355 - 0.48], [0.0, 0.280 - 0.48], [-0.036, 0.355 - 0.48]]
    under_e = [[0.0, 0.425 - 0.48], [0.003, 0.400 - 0.48], [0.0, 0.375 - 0.48], [-0.003, 0.400 - 0.48]]
    v, n, idx = create_tapered_extrusion(under_s, under_e, z0=-0.19, z1=0.36, caps=True)
    builder.add_mesh_primitive(mesh_barrel, m_red, v, n, idx)

    # ══════════════════════════════════════════════════════════════
    # 4. SCULPTED FOX-FLAME TSUBA WINGS (Pivots at X=±0.12, Y=0.52, Z=0.59)
    # Multi-layered flame quillons that fan out majestically in Blade Mode!
    # ══════════════════════════════════════════════════════════════
    # Left Wing (TsubaLeft): Swept outward toward negative X
    mesh_tsuba_l = builder.create_mesh("Mesh_TsubaLeft")
    
    # Layer 1: Crimson Flame Wing Blade
    pts_wing_l = [
        [0.00,  0.035],
        [-0.07, 0.075],
        [-0.15, 0.088],
        [-0.23, 0.055],
        [-0.26, 0.010],
        [-0.19, -0.025],
        [-0.12, -0.045],
        [0.00,  -0.035]
    ]
    v, n, idx = create_extrusion(pts_wing_l, z0=-0.025, z1=0.035, caps=True)
    builder.add_mesh_primitive(mesh_tsuba_l, m_red, v, n, idx)
    
    # Layer 2: Polished Cyber-Gold Crest Ridge along top quillon
    pts_crest_l = [
        [-0.02, 0.040],
        [-0.08, 0.082],
        [-0.16, 0.096],
        [-0.24, 0.062],
        [-0.265, 0.020],
        [-0.23, 0.032],
        [-0.15, 0.065],
        [-0.06, 0.050]
    ]
    v, n, idx = create_extrusion(pts_crest_l, z0=-0.015, z1=0.028, caps=True)
    builder.add_mesh_primitive(mesh_tsuba_l, m_gold, v, n, idx)
    
    # Layer 3: Cyan Energy Conduit Channel
    v, n, idx = create_chamfered_box(-0.11, 0.015, width=0.12, height=0.016, z0=-0.026, z1=0.036, chamfer=0.004)
    builder.add_mesh_primitive(mesh_tsuba_l, m_cyan, v, n, idx)
    
    # Right Wing (TsubaRight): Mirrored outward toward positive X
    mesh_tsuba_r = builder.create_mesh("Mesh_TsubaRight")
    
    pts_wing_r = [[-p[0], p[1]] for p in reversed(pts_wing_l)]
    v, n, idx = create_extrusion(pts_wing_r, z0=-0.025, z1=0.035, caps=True)
    builder.add_mesh_primitive(mesh_tsuba_r, m_red, v, n, idx)
    
    pts_crest_r = [[-p[0], p[1]] for p in reversed(pts_crest_l)]
    v, n, idx = create_extrusion(pts_crest_r, z0=-0.015, z1=0.028, caps=True)
    builder.add_mesh_primitive(mesh_tsuba_r, m_gold, v, n, idx)
    
    v, n, idx = create_chamfered_box(0.11, 0.015, width=0.12, height=0.016, z0=-0.026, z1=0.036, chamfer=0.004)
    builder.add_mesh_primitive(mesh_tsuba_r, m_cyan, v, n, idx)

    # ══════════════════════════════════════════════════════════════
    # 5. BLADE ASSEMBLY MESH (Pivot at X=0.0, Y=0.52, Z=0.60)
    # Mastercrafted Japanese Katana:
    # - Polished stepped gold Habaki collar
    # - Authentic curved Katana spine (Sori curvature)
    # - Chisel tip (Kissaki) with swept ridge lines
    # - Inlaid fuller groove (Bo-Hi) with radiant Cyan Plasma
    # - Radiant Cyan Plasma cutting edge & Crimson reinforced spine
    # ══════════════════════════════════════════════════════════════
    mesh_blade = builder.create_mesh("Mesh_BladeAssembly")
    
    # ── STEPPED GOLD HABAKI (COLLAR) (local Z = 0.00 to 0.045) ──
    v, n, idx = create_chamfered_box(0.0, 0.0, width=0.10, height=0.17, z0=0.0, z1=0.035, chamfer=0.015)
    builder.add_mesh_primitive(mesh_blade, m_gold, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.0, width=0.088, height=0.155, z0=0.035, z1=0.046, chamfer=0.012)
    builder.add_mesh_primitive(mesh_blade, m_gold, v, n, idx)
    # Diagonal engraved groove across Habaki
    v, n, idx = create_chamfered_box(0.0, 0.0, width=0.092, height=0.012, z0=0.016, z1=0.024, chamfer=0.003)
    builder.add_mesh_primitive(mesh_blade, m_dark, v, n, idx)

    # ── AUTHENTIC CURVED KATANA BLADE BODY (Lofted along Sori Curve) ──
    # Total blade length = 1.28m!
    # Sori curvature: Y rises gracefully along Z: y_sori(z) = 0.065 * ((z - 0.04) / 1.24) ** 1.7
    n_blade_slices = 12
    blade_slices_white = []
    blade_slices_cyan_edge = []
    blade_slices_crimson_spine = []
    blade_slices_fuller = []
    
    z_min = 0.045
    z_max = 1.28
    
    for s_idx in range(n_blade_slices):
        t = s_idx / (n_blade_slices - 1) # 0.0 at base to 1.0 at tip
        cur_z = z_min + t * (z_max - z_min)
        
        # Sori height rise
        y_cur = 0.065 * (t ** 1.7)
        
        # Taper factors: width and height gently decrease toward tip
        w_taper = max(0.08, 1.0 - 0.42 * t)
        h_taper = max(0.12, 1.0 - 0.32 * t)
        
        # Dimensions at current slice
        hw_shinogi = 0.022 * w_taper  # Widest ridge half-width
        hw_edge    = 0.002            # Sharp cutting edge half-width
        hw_spine   = 0.014 * w_taper  # Reinforced spine half-width
        
        y_spine_top = y_cur + 0.14 * h_taper
        y_shinogi   = y_cur + 0.01 * h_taper
        y_edge      = y_cur - 0.12 * h_taper
        
        # For Kissaki (tip region: t >= 0.85), edge sharply curves up to meet spine!
        if t >= 0.85:
            tip_t = (t - 0.85) / 0.15
            y_edge += tip_t * 0.22 * h_taper
            hw_shinogi *= (1.0 - tip_t * 0.85)
            hw_spine   *= (1.0 - tip_t * 0.80)
            
        # 1. Main White Ceramic/Steel Blade Body (Diamond / Shinogi-Zukuri Cross Section)
        poly_body = [
            [0.0,         y_spine_top, cur_z],
            [hw_shinogi,  y_shinogi,   cur_z],
            [0.0,         y_edge,      cur_z],
            [-hw_shinogi, y_shinogi,   cur_z]
        ]
        blade_slices_white.append(poly_body)
        
        # 2. Glowing Cyan Plasma Cutting Edge Ribbon
        poly_edge = [
            [hw_shinogi * 0.35, y_shinogi - 0.02 * h_taper, cur_z],
            [hw_edge,           y_edge,                     cur_z],
            [-hw_edge,          y_edge,                     cur_z],
            [-hw_shinogi * 0.35, y_shinogi - 0.02 * h_taper, cur_z]
        ]
        blade_slices_cyan_edge.append(poly_edge)
        
        # 3. Crimson Reinforced Spine Runner (Back of Blade)
        poly_spine = [
            [0.0,        y_spine_top + 0.012 * h_taper, cur_z],
            [hw_spine,   y_spine_top - 0.015 * h_taper, cur_z],
            [0.0,        y_spine_top - 0.025 * h_taper, cur_z],
            [-hw_spine,  y_spine_top - 0.015 * h_taper, cur_z]
        ]
        blade_slices_crimson_spine.append(poly_spine)
        
        # 4. Inlaid Cyan Energy Fuller (Bo-Hi) running along upper cheek
        if t <= 0.82:
            fuller_y = y_shinogi + 0.045 * h_taper
            poly_fuller = [
                [hw_shinogi * 0.95,  fuller_y + 0.015, cur_z],
                [hw_shinogi * 1.05,  fuller_y,         cur_z],
                [hw_shinogi * 0.95,  fuller_y - 0.015, cur_z],
                [-hw_shinogi * 0.95, fuller_y - 0.015, cur_z],
                [-hw_shinogi * 1.05, fuller_y,         cur_z],
                [-hw_shinogi * 0.95, fuller_y + 0.015, cur_z]
            ]
            blade_slices_fuller.append(poly_fuller)

    # Loft Blade Meshes
    v, n, idx = create_lofted_poly(blade_slices_white, caps=True)
    builder.add_mesh_primitive(mesh_blade, m_white, v, n, idx)
    
    v, n, idx = create_lofted_poly(blade_slices_cyan_edge, caps=True)
    builder.add_mesh_primitive(mesh_blade, m_cyan, v, n, idx)
    
    v, n, idx = create_lofted_poly(blade_slices_crimson_spine, caps=True)
    builder.add_mesh_primitive(mesh_blade, m_red, v, n, idx)
    
    if len(blade_slices_fuller) >= 2:
        v, n, idx = create_lofted_poly(blade_slices_fuller, caps=True)
        builder.add_mesh_primitive(mesh_blade, m_cyan, v, n, idx)

    # ══════════════════════════════════════════════════════════════
    # HIERARCHY NODES (Preserves exact node IDs & names for Main.gd)
    # ══════════════════════════════════════════════════════════════
    # Node 0: Root
    # Node 1: Chassis (mesh 0)
    # Node 2: Cylinder (mesh 1, trans [0.0, 0.48, 0.18])
    # Node 3: BarrelAssembly (mesh 2, trans [0.0, 0.48, 0.55])
    # Node 4: TsubaLeft (mesh 3, trans [-0.12, 0.52, 0.59])
    # Node 5: TsubaRight (mesh 4, trans [0.12, 0.52, 0.59])
    # Node 6: BladeAssembly (mesh 5, trans [0.0, 0.52, 0.60])
    
    builder.add_node("KitsuneRoot", children=[1, 2, 3, 4, 5, 6])
    builder.add_node("Chassis", mesh_idx=mesh_chassis)
    builder.add_node("Cylinder", mesh_idx=mesh_cylinder, translation=[0.0, 0.48, 0.18])
    builder.add_node("BarrelAssembly", mesh_idx=mesh_barrel, translation=[0.0, 0.48, 0.55])
    builder.add_node("TsubaLeft", mesh_idx=mesh_tsuba_l, translation=[-0.12, 0.52, 0.59])
    builder.add_node("TsubaRight", mesh_idx=mesh_tsuba_r, translation=[0.12, 0.52, 0.59])
    builder.add_node("BladeAssembly", mesh_idx=mesh_blade, translation=[0.0, 0.52, 0.60])
    
    builder.build_glb(output_path)

if __name__ == "__main__":
    build_unified_kitsune()
