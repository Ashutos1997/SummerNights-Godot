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
    m_white      = builder.add_material("Mat_PearlWhite", [0.96, 0.96, 0.98, 1.0], metallic=0.08, roughness=0.14)
    # Shinto lacquer crimson
    m_red        = builder.add_material("Mat_Crimson", [0.88, 0.10, 0.16, 1.0], metallic=0.14, roughness=0.18)
    # Celestial polished cyber-gold
    m_gold       = builder.add_material("Mat_CyberGold", [0.98, 0.78, 0.16, 1.0], metallic=0.75, roughness=0.16)
    # Deep tactical charcoal gunmetal
    m_dark       = builder.add_material("Mat_DarkCharcoal", [0.10, 0.11, 0.14, 1.0], metallic=0.35, roughness=0.38)
    # Radiant celestial cyan energy (high emissive bloom)
    m_cyan       = builder.add_material("Mat_CyanEnergy", [0.22, 0.92, 1.0, 1.0], metallic=0.05, roughness=0.10, emissive_rgb=[0.90, 1.50, 1.80])
    # Translucent amber/gold Kyubi drum glass
    m_trans_gold = builder.add_material("Mat_CyberGoldTranslucent", [0.98, 0.80, 0.18, 0.38], metallic=0.20, roughness=0.12, alpha_mode="BLEND")
    # Frosted cyan energy conduits
    m_trans_cyan = builder.add_material("Mat_CyanTranslucent", [0.25, 0.92, 1.0, 0.45], metallic=0.10, roughness=0.10, emissive_rgb=[0.45, 0.90, 1.20], alpha_mode="BLEND")
    # Folded Tamahagane Katana mirror steel
    m_steel      = builder.add_material("Mat_KatanaSteel", [0.91, 0.93, 0.96, 1.0], metallic=0.92, roughness=0.12)
    # Radiant undulating Hamon tempering wave
    m_hamon      = builder.add_material("Mat_HamonLuminescence", [0.55, 0.96, 1.0, 1.0], metallic=0.15, roughness=0.08, emissive_rgb=[0.75, 1.45, 1.85])
    # Traditional Japanese bronze Seppa spacer
    m_seppa      = builder.add_material("Mat_SeppaBronze", [0.86, 0.58, 0.28, 1.0], metallic=0.82, roughness=0.22)

    # ══════════════════════════════════════════════════════════════
    # 1. CHASSIS MESH (Root Body, Fixed Coordinates)
    # ══════════════════════════════════════════════════════════════
    mesh_chassis = builder.create_mesh("Mesh_Chassis")
    
    # Ergonomic Contoured Grip with Kashira Pommel Cap & Tsuka-Ito Wrap
    v, n, idx = create_chamfered_box(0.0, 0.20, width=0.16, height=0.36, z0=-0.25, z1=-0.06, chamfer=0.04)
    builder.add_mesh_primitive(mesh_chassis, m_dark, v, n, idx)
    
    # Golden Kashira Pommel Cap at base of grip
    v, n, idx = create_chamfered_box(0.0, 0.015, width=0.21, height=0.04, z0=-0.27, z1=-0.04, chamfer=0.015)
    builder.add_mesh_primitive(mesh_chassis, m_gold, v, n, idx)
    # Kashira Lanyard Ring (Fox-fire loop)
    v, n, idx = create_cylinder(0.0, -0.015, z0=-0.17, z1=-0.14, radius=0.028, sides=12)
    builder.add_mesh_primitive(mesh_chassis, m_gold, v, n, idx)
    
    # Diamond Menuki Tsuka-Ito Braided Wrap Accents
    for z_wrap in [-0.21, -0.16, -0.11]:
        v, n, idx = create_chamfered_box(0.0, 0.20, width=0.176, height=0.032, z0=z_wrap - 0.015, z1=z_wrap + 0.015, chamfer=0.007)
        builder.add_mesh_primitive(mesh_chassis, m_red, v, n, idx)
        for side in [-0.089, 0.089]:
            v, n, idx = create_chamfered_box(side, 0.20, width=0.012, height=0.024, z0=z_wrap - 0.010, z1=z_wrap + 0.010, chamfer=0.004)
            builder.add_mesh_primitive(mesh_chassis, m_gold, v, n, idx)
            
    # Trigger Guard & Crimson Beveled Trigger
    v, n, idx = create_chamfered_box(0.0, 0.21, width=0.055, height=0.04, z0=-0.06, z1=0.10, chamfer=0.008)
    builder.add_mesh_primitive(mesh_chassis, m_dark, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.30, width=0.055, height=0.15, z0=0.08, z1=0.12, chamfer=0.008)
    builder.add_mesh_primitive(mesh_chassis, m_dark, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.28, width=0.034, height=0.11, z0=-0.03, z1=0.02, chamfer=0.007)
    builder.add_mesh_primitive(mesh_chassis, m_red, v, n, idx)
    
    # Stock Housing & Twin Hydro-Reservoirs
    v, n, idx = create_chamfered_box(0.0, 0.45, width=0.29, height=0.16, z0=-0.30, z1=0.02, chamfer=0.035)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.49, width=0.27, height=0.19, z0=-0.54, z1=-0.30, chamfer=0.038)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    
    # Twin Hydro-Canisters with High-Pressure Manifold Piping
    for xt in [-0.075, 0.075]:
        v, n, idx = create_cylinder(xt, 0.49, z0=-0.52, z1=-0.32, radius=0.044, sides=16)
        builder.add_mesh_primitive(mesh_chassis, m_cyan, v, n, idx)
        v, n, idx = create_cylinder(xt, 0.49, z0=-0.53, z1=-0.51, radius=0.050, sides=16)
        builder.add_mesh_primitive(mesh_chassis, m_gold, v, n, idx)
        v, n, idx = create_cylinder(xt, 0.49, z0=-0.33, z1=-0.31, radius=0.050, sides=16)
        builder.add_mesh_primitive(mesh_chassis, m_gold, v, n, idx)
        # Gold Fluid Manifold Conduit feeding forward into receiver
        v, n, idx = create_cylinder(xt, 0.55, z0=-0.30, z1=-0.02, radius=0.015, sides=12)
        builder.add_mesh_primitive(mesh_chassis, m_gold, v, n, idx)
        v, n, idx = create_cylinder(xt, 0.55, z0=-0.28, z1=-0.04, radius=0.009, sides=12)
        builder.add_mesh_primitive(mesh_chassis, m_cyan, v, n, idx)
        
    for z_fin in [-0.48, -0.38]:
        v, n, idx = create_chamfered_box(0.0, 0.585, width=0.25, height=0.022, z0=z_fin - 0.014, z1=z_fin + 0.014, chamfer=0.005)
        builder.add_mesh_primitive(mesh_chassis, m_red, v, n, idx)

    # ── SKELETONIZED CYLINDER RECEIVER & SIGHTLINE APERTURE ──
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
    
    # Left & Right Sightline Apertures (Permits full view of Kyubi revolving drum)
    for side_x in [-0.155, 0.155]:
        v, n, idx = create_chamfered_box(side_x, 0.60, width=0.024, height=0.038, z0=0.04, z1=0.32, chamfer=0.007)
        builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
        v, n, idx = create_chamfered_box(side_x, 0.60, width=0.027, height=0.014, z0=0.06, z1=0.30, chamfer=0.004)
        builder.add_mesh_primitive(mesh_chassis, m_red, v, n, idx)
        v, n, idx = create_chamfered_box(side_x, 0.36, width=0.024, height=0.038, z0=0.04, z1=0.32, chamfer=0.007)
        builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
        v, n, idx = create_chamfered_box(side_x, 0.48, width=0.020, height=0.048, z0=0.16, z1=0.20, chamfer=0.005)
        builder.add_mesh_primitive(mesh_chassis, m_gold, v, n, idx)

    # Forward Deck & Collar Base (Z = 0.36 to 0.60)
    v, n, idx = create_chamfered_box(0.0, 0.62, width=0.27, height=0.11, z0=0.36, z1=0.58, chamfer=0.035)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.48, width=0.27, height=0.25, z0=0.36, z1=0.60, chamfer=0.040)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    # Gold collar ring at barrel/blade exit interface
    v, n, idx = create_cylinder(0.0, 0.48, z0=0.575, z1=0.60, radius=0.112, sides=20)
    builder.add_mesh_primitive(mesh_chassis, m_gold, v, n, idx)
    # Recessed dark emitter well with radiant cyan containment ring
    v, n, idx = create_cylinder(0.0, 0.48, z0=0.585, z1=0.602, radius=0.098, sides=18)
    builder.add_mesh_primitive(mesh_chassis, m_dark, v, n, idx)
    v, n, idx = create_cylinder(0.0, 0.48, z0=0.590, z1=0.604, radius=0.082, sides=18)
    builder.add_mesh_primitive(mesh_chassis, m_cyan, v, n, idx)
    
    # 4 Articulated Locking Aperture Clamps around the collar (anchoring deployed blade)
    for clamp_i in range(4):
        c_ang = clamp_i * (math.pi / 2.0)
        cx = math.cos(c_ang) * 0.106
        cy = 0.48 + math.sin(c_ang) * 0.106
        # Clamp bracket
        v, n, idx = create_chamfered_box(cx, cy, width=0.034, height=0.034, z0=0.575, z1=0.608, chamfer=0.006)
        builder.add_mesh_primitive(mesh_chassis, m_dark, v, n, idx)
        # Gold clamp bevel
        v, n, idx = create_cylinder(cx, cy, z0=0.600, z1=0.612, radius=0.010, sides=8)
        builder.add_mesh_primitive(mesh_chassis, m_gold, v, n, idx)
        # Cyan energy rivet
        v, n, idx = create_cylinder(cx, cy, z0=0.608, z1=0.615, radius=0.005, sides=6)
        builder.add_mesh_primitive(mesh_chassis, m_cyan, v, n, idx)
    
    # Tactical Status LEDs on Forward Deck (Cyan / Gold readiness lights)
    for led_i, z_led in enumerate([0.42, 0.48, 0.54]):
        v, n, idx = create_cylinder(-0.115, 0.678, z0=z_led - 0.012, z1=z_led + 0.012, radius=0.008, sides=10)
        builder.add_mesh_primitive(mesh_chassis, m_cyan if led_i < 2 else m_gold, v, n, idx)
        v, n, idx = create_cylinder(0.115, 0.678, z0=z_led - 0.012, z1=z_led + 0.012, radius=0.008, sides=10)
        builder.add_mesh_primitive(mesh_chassis, m_cyan if led_i < 2 else m_gold, v, n, idx)

    # ── KITSUNE FOX-EAR COWL FINS (Upper Receiver Flanks) ──
    for ear_side in [-1, 1]:
        bx = ear_side * 0.102
        tip_x = ear_side * 0.150
        ear_base = [
            [bx - ear_side * 0.02, 0.67, -0.06],
            [bx + ear_side * 0.02, 0.67, -0.06],
            [bx + ear_side * 0.02, 0.67, 0.08],
            [bx - ear_side * 0.02, 0.67, 0.08]
        ]
        ear_mid = [
            [bx * 1.15 - ear_side * 0.015, 0.76, -0.04],
            [bx * 1.15 + ear_side * 0.015, 0.76, -0.04],
            [bx * 1.15 + ear_side * 0.015, 0.76, 0.04],
            [bx * 1.15 - ear_side * 0.015, 0.76, 0.04]
        ]
        ear_tip = [
            [tip_x - ear_side * 0.005, 0.84, -0.02],
            [tip_x + ear_side * 0.005, 0.84, -0.02],
            [tip_x + ear_side * 0.005, 0.84, 0.01],
            [tip_x - ear_side * 0.005, 0.84, 0.01]
        ]
        v, n, idx = create_lofted_poly([ear_base, ear_mid, ear_tip], caps=True)
        builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
        
        # Inner ear crimson bevel accent
        inner_base = [
            [bx, 0.68, -0.04],
            [bx + ear_side * 0.015, 0.68, -0.04],
            [bx + ear_side * 0.015, 0.68, 0.05],
            [bx, 0.68, 0.05]
        ]
        inner_tip = [
            [tip_x - ear_side * 0.005, 0.81, -0.01],
            [tip_x + ear_side * 0.005, 0.81, -0.01],
            [tip_x + ear_side * 0.005, 0.81, 0.01],
            [tip_x - ear_side * 0.005, 0.81, 0.01]
        ]
        v, n, idx = create_lofted_poly([inner_base, inner_tip], caps=True)
        builder.add_mesh_primitive(mesh_chassis, m_red, v, n, idx)
        
        # Outer ear radiant cyan conduit
        v, n, idx = create_chamfered_box(bx * 1.05, 0.75, width=0.008, height=0.08, z0=0.065, z1=0.075, chamfer=0.002)
        builder.add_mesh_primitive(mesh_chassis, m_cyan, v, n, idx)

    # ── HOLOGRAPHIC REFLEX SIGHT ──
    v, n, idx = create_chamfered_box(0.0, 0.685, width=0.11, height=0.018, z0=-0.04, z1=0.08, chamfer=0.005)
    builder.add_mesh_primitive(mesh_chassis, m_dark, v, n, idx)
    v, n, idx = create_chamfered_box(-0.058, 0.738, width=0.015, height=0.088, z0=-0.02, z1=0.06, chamfer=0.004)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    v, n, idx = create_chamfered_box(0.058, 0.738, width=0.015, height=0.088, z0=-0.02, z1=0.06, chamfer=0.004)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.780, width=0.131, height=0.015, z0=-0.02, z1=0.06, chamfer=0.003)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    
    # Holographic Cyan Reticle Emitter Glass
    reticle_pts = [[-0.046, 0.698], [0.046, 0.698], [0.043, 0.770], [-0.043, 0.770]]
    v, n, idx = create_extrusion(reticle_pts, z0=0.015, z1=0.025, caps=True)
    builder.add_mesh_primitive(mesh_chassis, m_trans_cyan, v, n, idx)
    # Central glowing diamond Kitsune pip inside the glass
    v, n, idx = create_chamfered_box(0.0, 0.735, width=0.011, height=0.011, z0=0.018, z1=0.022, chamfer=0.003)
    builder.add_mesh_primitive(mesh_chassis, m_cyan, v, n, idx)
    # Side chevron range brackets on reticle
    for ret_side in [-0.022, 0.022]:
        v, n, idx = create_chamfered_box(ret_side, 0.735, width=0.003, height=0.014, z0=0.018, z1=0.022, chamfer=0.001)
        builder.add_mesh_primitive(mesh_chassis, m_cyan, v, n, idx)

    # ══════════════════════════════════════════════════════════════
    # 2. REVOLVING CYLINDER MESH (Pivot at X=0.0, Y=0.48, Z=0.18)
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
    
    # Central Mechanical Axle with Swirling Fox-Fire Flux Core
    v, n, idx = create_cylinder(0.0, 0.0, z0=-0.165, z1=0.165, radius=0.065, sides=16)
    builder.add_mesh_primitive(mesh_cylinder, m_dark, v, n, idx)
    # Glowing Central Cyan Reactor Spindle
    v, n, idx = create_cylinder(0.0, 0.0, z0=-0.13, z1=0.13, radius=0.035, sides=14)
    builder.add_mesh_primitive(mesh_cylinder, m_cyan, v, n, idx)
    
    # Gold Turbine Spindle Blades
    for tb in range(6):
        tb_ang = (tb / 6.0) * math.pi
        v, n, idx = create_chamfered_box(0.0, 0.0, width=0.12, height=0.014, z0=-0.12, z1=0.12, chamfer=0.003)
        cos_tb, sin_tb = math.cos(tb_ang), math.sin(tb_ang)
        v_rot = [[pt[0] * cos_tb - pt[1] * sin_tb, pt[0] * sin_tb + pt[1] * cos_tb, pt[2]] for pt in v]
        n_rot = [[norm[0] * cos_tb - norm[1] * sin_tb, norm[0] * sin_tb + norm[1] * cos_tb, norm[2]] for norm in n]
        builder.add_mesh_primitive(mesh_cylinder, m_gold, v_rot, n_rot, idx)

    # 9 Fluted Water Bores with Cyan Crystal Vials & Internal Luminous Filaments
    for i in range(9):
        ang = (i / 9.0) * 2 * math.pi
        bore_r = 0.145
        bx = math.cos(ang) * bore_r
        by = math.sin(ang) * bore_r
        # Glowing Cyan Celestial Liquid Vial
        v, n, idx = create_cylinder(bx, by, z0=-0.13, z1=0.13, radius=0.038, sides=14)
        builder.add_mesh_primitive(mesh_cylinder, m_cyan, v, n, idx)
        # Inner High-Intensity Celestial Filament
        v, n, idx = create_cylinder(bx, by, z0=-0.12, z1=0.12, radius=0.015, sides=8)
        builder.add_mesh_primitive(mesh_cylinder, m_hamon, v, n, idx)
        # Brushed Dark Alloy Collars (Front & Back)
        v, n, idx = create_cylinder(bx, by, z0=-0.144, z1=-0.126, radius=0.044, sides=14)
        builder.add_mesh_primitive(mesh_cylinder, m_dark, v, n, idx)
        v, n, idx = create_cylinder(bx, by, z0=0.126, z1=0.144, radius=0.044, sides=14)
        builder.add_mesh_primitive(mesh_cylinder, m_dark, v, n, idx)
        # Gold Retaining Rings on Vials
        v, n, idx = create_cylinder(bx, by, z0=-0.012, z1=0.012, radius=0.042, sides=14)
        builder.add_mesh_primitive(mesh_cylinder, m_gold, v, n, idx)

    # ══════════════════════════════════════════════════════════════
    # 3. BARREL ASSEMBLY MESH (Pivot at X=0.0, Y=0.48, Z=0.55)
    # Extends forward in Cannon mode, commanding high-tech sniper profile
    # ══════════════════════════════════════════════════════════════
    # 3. BARREL ASSEMBLY MESH (Pivot at X=0.0, Y=0.48, Z=0.55)
    # Extends forward in Cannon mode, commanding high-tech sniper profile
    # ══════════════════════════════════════════════════════════════
    mesh_barrel = builder.create_mesh("Mesh_BarrelAssembly")
    
    # Inner Steel Rifled Barrel Housing (local Z=0.04 to 0.52)
    v, n, idx = create_cylinder(0.0, 0.0, z0=0.04, z1=0.52, radius=0.072, sides=18)
    builder.add_mesh_primitive(mesh_barrel, m_dark, v, n, idx)
    
    # 1. Main Octagonal Faceted Shroud Body (local Z=0.04 to 0.36)
    v, n, idx = create_chamfered_box(0.0, 0.0, width=0.21, height=0.19, z0=0.04, z1=0.36, chamfer=0.035)
    builder.add_mesh_primitive(mesh_barrel, m_white, v, n, idx)
    
    # 2. Aerodynamic Tapered Fox-Fang Front Cowl (local Z=0.36 to 0.46)
    cowl_start = [
        [-0.070, -0.095], [0.070, -0.095], [0.105, -0.060], [0.105, 0.060],
        [0.070, 0.095], [-0.070, 0.095], [-0.105, 0.060], [-0.105, -0.060]
    ]
    cowl_end = [
        [-0.058, -0.080], [0.058, -0.080], [0.090, -0.050], [0.090, 0.050],
        [0.058, 0.080], [-0.058, 0.080], [-0.090, 0.050], [-0.090, -0.050]
    ]
    v, n, idx = create_tapered_extrusion(cowl_start, cowl_end, z0=0.36, z1=0.46, caps=True)
    builder.add_mesh_primitive(mesh_barrel, m_white, v, n, idx)

    # Crimson Chamfer Highlights along Shroud Ridges
    for sy in [-0.098, 0.098]:
        v, n, idx = create_chamfered_box(0.0, sy * 0.96, width=0.13, height=0.012, z0=0.06, z1=0.35, chamfer=0.003)
        builder.add_mesh_primitive(mesh_barrel, m_red, v, n, idx)
    # Angled Crimson Cowl Cheeks
    for side_x in [-0.092, 0.092]:
        for side_y in [-0.062, 0.062]:
            v, n, idx = create_chamfered_box(side_x, side_y, width=0.016, height=0.024, z0=0.36, z1=0.45, chamfer=0.004)
            builder.add_mesh_primitive(mesh_barrel, m_red, v, n, idx)
        
    # Longitudinal Vented Heat Gills (Left & Right Flanks)
    for side_x in [-0.107, 0.107]:
        for vent_z in [0.11, 0.19, 0.27]:
            # Recessed glowing cyan plasma vent
            v, n, idx = create_chamfered_box(side_x, 0.0, width=0.008, height=0.062, z0=vent_z - 0.024, z1=vent_z + 0.024, chamfer=0.002)
            builder.add_mesh_primitive(mesh_barrel, m_cyan, v, n, idx)
            # Dark louver grille cover
            v, n, idx = create_chamfered_box(side_x * 0.99, 0.0, width=0.004, height=0.058, z0=vent_z - 0.004, z1=vent_z + 0.004, chamfer=0.001)
            builder.add_mesh_primitive(mesh_barrel, m_dark, v, n, idx)

    # 3. High-Velocity Compensator Muzzle Brake (local Z=0.46 to 0.54)
    comp_start = cowl_end
    comp_end = [
        [-0.048, -0.068], [0.048, -0.068], [0.076, -0.040], [0.076, 0.040],
        [0.048, 0.068], [-0.048, 0.068], [-0.076, 0.040], [-0.076, -0.040]
    ]
    v, n, idx = create_tapered_extrusion(comp_start, comp_end, z0=0.46, z1=0.54, caps=True)
    builder.add_mesh_primitive(mesh_barrel, m_dark, v, n, idx)
    
    # Side Muzzle Baffle Ports & Exhaust Slots
    for side_x in [-0.078, 0.078]:
        # Glowing cyan interior gas chamber
        v, n, idx = create_chamfered_box(side_x * 0.96, 0.0, width=0.008, height=0.048, z0=0.47, z1=0.53, chamfer=0.002)
        builder.add_mesh_primitive(mesh_barrel, m_cyan, v, n, idx)
        # Angled crimson port frame
        v, n, idx = create_chamfered_box(side_x, 0.0, width=0.010, height=0.052, z0=0.48, z1=0.52, chamfer=0.003)
        builder.add_mesh_primitive(mesh_barrel, m_red, v, n, idx)

    # Top & Bottom Vertical Compensator Gas Slots
    for py in [-0.070, 0.070]:
        v, n, idx = create_chamfered_box(0.0, py, width=0.040, height=0.006, z0=0.48, z1=0.525, chamfer=0.002)
        builder.add_mesh_primitive(mesh_barrel, m_cyan, v, n, idx)

    # 4. Stepped Hydro-Vortex Compression Nozzle & Rifled Muzzle Crown (local Z=0.53 to 0.575)
    # Outer dark tactical bezel
    v, n, idx = create_cylinder(0.0, 0.0, z0=0.535, z1=0.552, radius=0.068, sides=18)
    builder.add_mesh_primitive(mesh_barrel, m_dark, v, n, idx)
    # Beveled cyber-gold compression collar ring
    v, n, idx = create_cylinder(0.0, 0.0, z0=0.548, z1=0.565, radius=0.060, sides=18)
    builder.add_mesh_primitive(mesh_barrel, m_gold, v, n, idx)
    # Recessed stepped radiant cyan plasma injector ring
    v, n, idx = create_cylinder(0.0, 0.0, z0=0.542, z1=0.560, radius=0.048, sides=18)
    builder.add_mesh_primitive(mesh_barrel, m_cyan, v, n, idx)
    # Deep dark rifled inner bore core
    v, n, idx = create_cylinder(0.0, 0.0, z0=0.510, z1=0.550, radius=0.036, sides=18)
    builder.add_mesh_primitive(mesh_barrel, m_dark, v, n, idx)
    # Concentric gold focal ring inside bore
    v, n, idx = create_cylinder(0.0, 0.0, z0=0.525, z1=0.545, radius=0.018, sides=14)
    builder.add_mesh_primitive(mesh_barrel, m_gold, v, n, idx)

    # 5. Sculpted Quad Magnetic Fox-Fang Calipers (Particle Accelerator Muzzle Prongs)
    # 4 angled aerodynamic rails situated at 45°, 135°, 225°, 315°
    for fang_i in range(4):
        f_ang = (fang_i / 4.0) * 2 * math.pi + (math.pi / 4.0)
        cos_a = math.cos(f_ang)
        sin_a = math.sin(f_ang)
        
        # Base radial position and tip radial position
        r_base = 0.076
        r_tip = 0.068
        bx, by = cos_a * r_base, sin_a * r_base
        tx, ty = cos_a * r_tip, sin_a * r_tip
        
        # Angular caliper blade wedge
        w_b, h_b = 0.020, 0.016
        w_t, h_t = 0.008, 0.008
        
        p_base = [
            [bx - w_b*0.5, by - h_b*0.5], [bx + w_b*0.5, by - h_b*0.5],
            [bx + w_b*0.5, by + h_b*0.5], [bx - w_b*0.5, by + h_b*0.5]
        ]
        p_tip = [
            [tx - w_t*0.5, ty - h_t*0.5], [tx + w_t*0.5, ty - h_t*0.5],
            [tx + w_t*0.5, ty + h_t*0.5], [tx - w_t*0.5, ty + h_t*0.5]
        ]
        # Main dark magnetic rail body
        v, n, idx = create_tapered_extrusion(p_base, p_tip, z0=0.42, z1=0.62, caps=True)
        builder.add_mesh_primitive(mesh_barrel, m_dark, v, n, idx)
        
        # Inlaid glowing cyan accelerator guide on inner face
        r_in = r_base - 0.008
        r_in_tip = r_tip - 0.006
        ix0, iy0 = cos_a * r_in, sin_a * r_in
        ix1, iy1 = cos_a * r_in_tip, sin_a * r_in_tip
        v, n, idx = create_cylinder((ix0+ix1)*0.5, (iy0+iy1)*0.5, z0=0.46, z1=0.61, radius=0.004, sides=8)
        builder.add_mesh_primitive(mesh_barrel, m_cyan, v, n, idx)
        
        # Cyber-Gold reinforced tip emitter needle
        v, n, idx = create_cylinder(tx, ty, z0=0.605, z1=0.635, radius=0.006, sides=8)
        builder.add_mesh_primitive(mesh_barrel, m_gold, v, n, idx)

    # 6. Streamlined Low-Profile Optic Rail & Front Post Sight (local Z=0.04 to 0.53)
    # Dark tactical top rail base
    v, n, idx = create_chamfered_box(0.0, 0.106, width=0.052, height=0.016, z0=0.04, z1=0.46, chamfer=0.004)
    builder.add_mesh_primitive(mesh_barrel, m_dark, v, n, idx)
    
    # Crimson dorsal spine runner with cooling serrations
    v, n, idx = create_chamfered_box(0.0, 0.115, width=0.028, height=0.008, z0=0.06, z1=0.44, chamfer=0.002)
    builder.add_mesh_primitive(mesh_barrel, m_red, v, n, idx)
    
    # Inlaid glowing cyan sightline trace runner
    v, n, idx = create_chamfered_box(0.0, 0.119, width=0.010, height=0.004, z0=0.10, z1=0.46, chamfer=0.001)
    builder.add_mesh_primitive(mesh_barrel, m_cyan, v, n, idx)
    
    # Aerodynamic Front Post Sight Hood & Tritium Bead (local Z=0.47 to 0.52)
    # Winged sight protector hood
    v, n, idx = create_chamfered_box(0.0, 0.102, width=0.040, height=0.022, z0=0.47, z1=0.515, chamfer=0.006)
    builder.add_mesh_primitive(mesh_barrel, m_dark, v, n, idx)
    # Cyber-Gold front sight post
    v, n, idx = create_cylinder(0.0, 0.108, z0=0.48, z1=0.51, radius=0.005, sides=8)
    builder.add_mesh_primitive(mesh_barrel, m_gold, v, n, idx)
    # Radiant cyan tritium aiming pip
    v, n, idx = create_cylinder(0.0, 0.113, z0=0.485, z1=0.505, radius=0.0035, sides=8)
    builder.add_mesh_primitive(mesh_barrel, m_cyan, v, n, idx)
    
    # 7. Under-Barrel High-Pressure Hydro-Manifold & Stabilizer Keel (local Z=-0.12 to 0.44)
    # Dual parallel high-pressure coolant conduits
    for px in [-0.036, 0.036]:
        v, n, idx = create_cylinder(px, -0.112, z0=0.06, z1=0.38, radius=0.011, sides=12)
        builder.add_mesh_primitive(mesh_barrel, m_cyan, v, n, idx)
        # Gold manifold compression brackets
        for b_z in [0.10, 0.22, 0.34]:
            v, n, idx = create_cylinder(px, -0.112, z0=b_z - 0.010, z1=b_z + 0.010, radius=0.015, sides=12)
            builder.add_mesh_primitive(mesh_barrel, m_gold, v, n, idx)
            
    # Tapered dark tactical keel with angled heat vents
    keel_s = [[0.0, -0.145], [0.038, -0.108], [0.0, -0.092], [-0.038, -0.108]]
    keel_e = [[0.0, -0.115], [0.018, -0.096], [0.0, -0.088], [-0.018, -0.096]]
    v, n, idx = create_tapered_extrusion(keel_s, keel_e, z0=-0.08, z1=0.42, caps=True)
    builder.add_mesh_primitive(mesh_barrel, m_dark, v, n, idx)
    # Crimson keel accent blade runner
    v, n, idx = create_chamfered_box(0.0, -0.132, width=0.012, height=0.016, z0=0.04, z1=0.38, chamfer=0.003)
    builder.add_mesh_primitive(mesh_barrel, m_red, v, n, idx)

    # ══════════════════════════════════════════════════════════════
    # 4. SCULPTED FOX-FLAME TSUBA WINGS (Pivots at X=±0.12, Y=0.52, Z=0.59)
    # 3-Tiered sculpted flame quillons with Sukashi pierced negative space
    # ══════════════════════════════════════════════════════════════
    mesh_tsuba_l = builder.create_mesh("Mesh_TsubaLeft")
    
    # Tier 1: Dark Tactical Alloy Base Plate
    pts_base_l = [
        [0.00,  0.038],
        [-0.06, 0.072],
        [-0.14, 0.082],
        [-0.22, 0.050],
        [-0.25, 0.005],
        [-0.18, -0.028],
        [-0.11, -0.046],
        [0.00,  -0.038]
    ]
    v, n, idx = create_extrusion(pts_base_l, z0=-0.022, z1=0.032, caps=True)
    builder.add_mesh_primitive(mesh_tsuba_l, m_dark, v, n, idx)
    
    # Tier 2: Crimson Flame Feather Wing
    pts_wing_l = [
        [0.00,  0.034],
        [-0.07, 0.082],
        [-0.16, 0.095],
        [-0.25, 0.058],
        [-0.28, 0.008],
        [-0.20, -0.025],
        [-0.12, -0.042],
        [0.00,  -0.032]
    ]
    v, n, idx = create_extrusion(pts_wing_l, z0=-0.016, z1=0.026, caps=True)
    builder.add_mesh_primitive(mesh_tsuba_l, m_red, v, n, idx)
    
    # Tier 3: Polished Cyber-Gold Crest Spine
    pts_crest_l = [
        [-0.02, 0.042],
        [-0.08, 0.090],
        [-0.17, 0.104],
        [-0.26, 0.066],
        [-0.285, 0.018],
        [-0.24, 0.034],
        [-0.15, 0.070],
        [-0.06, 0.052]
    ]
    v, n, idx = create_extrusion(pts_crest_l, z0=-0.010, z1=0.020, caps=True)
    builder.add_mesh_primitive(mesh_tsuba_l, m_gold, v, n, idx)
    
    # Tier 4: Core Radiant Cyan Energy Conduit Channel
    v, n, idx = create_chamfered_box(-0.11, 0.016, width=0.13, height=0.014, z0=-0.024, z1=0.034, chamfer=0.003)
    builder.add_mesh_primitive(mesh_tsuba_l, m_cyan, v, n, idx)
    
    # Right Wing (TsubaRight): Mirrored outward
    mesh_tsuba_r = builder.create_mesh("Mesh_TsubaRight")
    
    pts_base_r = [[-p[0], p[1]] for p in reversed(pts_base_l)]
    v, n, idx = create_extrusion(pts_base_r, z0=-0.022, z1=0.032, caps=True)
    builder.add_mesh_primitive(mesh_tsuba_r, m_dark, v, n, idx)
    
    pts_wing_r = [[-p[0], p[1]] for p in reversed(pts_wing_l)]
    v, n, idx = create_extrusion(pts_wing_r, z0=-0.016, z1=0.026, caps=True)
    builder.add_mesh_primitive(mesh_tsuba_r, m_red, v, n, idx)
    
    pts_crest_r = [[-p[0], p[1]] for p in reversed(pts_crest_l)]
    v, n, idx = create_extrusion(pts_crest_r, z0=-0.010, z1=0.020, caps=True)
    builder.add_mesh_primitive(mesh_tsuba_r, m_gold, v, n, idx)
    
    v, n, idx = create_chamfered_box(0.11, 0.016, width=0.13, height=0.014, z0=-0.024, z1=0.034, chamfer=0.003)
    builder.add_mesh_primitive(mesh_tsuba_r, m_cyan, v, n, idx)

    # ══════════════════════════════════════════════════════════════
    # 5. BLADE ASSEMBLY MESH (Pivot at X=0.0, Y=0.52, Z=0.60)
    # Mastercrafted Japanese Katana:
    # - Stepped Gold Habaki with Seppa Bronze Washers
    # - Elegant Sori Curvature & Razor Shinogi-Zukuri Proportions
    # - Undulating Hamon Tempering Wave Ribbon
    # - Mirror-Polished Folded Tamahagane Katana Steel Body
    # - Radiant Celestial Cyan Plasma Cutting Edge
    # - Swept O-Kissaki Chisel Tip with Yokote Line
    # - Lacquered Crimson Spine Runner & Dual Bo-Hi Fullers
    # ══════════════════════════════════════════════════════════════
    # 5. BLADE ASSEMBLY MESH (Pivot at X=0.0, Y=0.52, Z=0.60)
    # Mastercrafted Japanese Katana:
    # - Multi-Tiered Bronze Seppa & Cyber-Gold Habaki with Illuminated Fox-Flame Crests
    # - Authentic Sori Curvature & Razor Shinogi-Zukuri Proportions
    # - Distinct Japanese Yokote Transverse Ridge Line & Chisel O-Kissaki Point
    # - Swept Boshi Tempering Turn wrapping around Fukura Cutting Edge
    # - Mirror-Polished Folded Tamahagane Katana Steel Body
    # - Radiant Celestial Cyan Plasma Cutting Edge & Dual Bo-Hi Fullers
    # ══════════════════════════════════════════════════════════════
    mesh_blade = builder.create_mesh("Mesh_BladeAssembly")
    
    # ── MULTI-TIERED BRONZE SEPPA & CYBER-GOLD HABAKI WITH FOX CREST ──
    # Primary Seppa Bronze Spacer Washer at blade base (local Z = -0.016 to 0.002)
    v, n, idx = create_chamfered_box(0.0, 0.0, width=0.096, height=0.124, z0=-0.016, z1=0.002, chamfer=0.014)
    builder.add_mesh_primitive(mesh_blade, m_seppa, v, n, idx)
    
    # Secondary Tactical Dark Alloy Spacer Washer
    v, n, idx = create_chamfered_box(0.0, 0.0, width=0.088, height=0.112, z0=-0.008, z1=0.002, chamfer=0.012)
    builder.add_mesh_primitive(mesh_blade, m_dark, v, n, idx)
    
    # Stepped Gold Habaki Collar (local Z = 0.002 to 0.052)
    # Lower primary collar tier
    v, n, idx = create_chamfered_box(0.0, 0.0, width=0.080, height=0.100, z0=0.002, z1=0.032, chamfer=0.012)
    builder.add_mesh_primitive(mesh_blade, m_gold, v, n, idx)
    # Upper tapered collar step
    v, n, idx = create_chamfered_box(0.0, 0.0, width=0.070, height=0.088, z0=0.032, z1=0.052, chamfer=0.010)
    builder.add_mesh_primitive(mesh_blade, m_gold, v, n, idx)
    
    # Yasurime file stroke groove across Habaki
    v, n, idx = create_chamfered_box(0.0, 0.0, width=0.074, height=0.008, z0=0.016, z1=0.024, chamfer=0.002)
    builder.add_mesh_primitive(mesh_blade, m_dark, v, n, idx)
    
    # Illuminated Cyan Kitsune Fox-Flame Micro-Vent Crest on Habaki Flanks
    for side_x in [-0.039, 0.039]:
        # Recessed dark frame
        v, n, idx = create_chamfered_box(side_x, 0.008, width=0.006, height=0.028, z0=0.012, z1=0.040, chamfer=0.002)
        builder.add_mesh_primitive(mesh_blade, m_dark, v, n, idx)
        # Luminous cyan energy conduit
        v, n, idx = create_cylinder(side_x * 1.01, 0.008, z0=0.018, z1=0.034, radius=0.007, sides=8)
        builder.add_mesh_primitive(mesh_blade, m_cyan, v, n, idx)
        # Gold retaining bezel
        v, n, idx = create_cylinder(side_x * 1.02, 0.008, z0=0.024, z1=0.028, radius=0.009, sides=8)
        builder.add_mesh_primitive(mesh_blade, m_gold, v, n, idx)

    # ── AUTHENTIC KATANA BLADE BODY WITH YOKOTE & CHISEL O-KISSAKI ──
    # Length: z_min=0.052 to z_max=1.44 (1.388m Katana reach)
    # Slices: 24 slices with explicit Yokote boundary at t=0.85 (z≈1.23m)
    n_blade_slices = 24
    t_yokote = 0.85
    
    blade_slices_steel = []
    blade_slices_hamon = []
    blade_slices_cyan_edge = []
    blade_slices_crimson_spine = []
    blade_slices_fuller = []
    
    z_min = 0.052
    z_max = 1.44
    
    for s_idx in range(n_blade_slices):
        t = s_idx / (n_blade_slices - 1) # 0.0 at base to 1.0 at tip
        cur_z = z_min + t * (z_max - z_min)
        
        # Sori upward curvature
        y_cur = 0.052 * (t ** 1.65)
        
        # Proportional taper
        w_taper = max(0.20, 1.0 - 0.45 * t)
        h_taper = max(0.25, 1.0 - 0.40 * t)
        
        # Dimensions: Sleek, lethal, authentic Katana cross-section
        hw_shinogi = 0.0105 * w_taper  # Ridge line half-width
        hw_edge    = 0.0010            # Razor-sharp edge
        hw_spine   = 0.0065 * w_taper  # Flat reinforced spine
        
        # Vertical blade positions relative to local Y=0
        blade_h = 0.076 * h_taper
        y_spine_top = y_cur + 0.50 * blade_h
        y_shinogi   = y_cur + 0.12 * blade_h
        y_hamon     = y_cur - 0.20 * blade_h + math.sin(t * 28.0) * 0.004
        y_edge      = y_cur - 0.50 * blade_h
        
        # ── JAPANESE YOKOTE & CHISEL O-KISSAKI GEOMETRY (t >= t_yokote) ──
        if t >= t_yokote:
            tip_u = (t - t_yokote) / (1.0 - t_yokote) # 0.0 at Yokote to 1.0 at apex tip
            # 1. Fukura: Edge sweeps upward in an aggressive chisel Katana arc
            fukura_lift = (tip_u ** 0.82) * (blade_h * 0.94)
            y_edge += fukura_lift
            # 2. Boshi: Tempering wave wraps around the tip following the Fukura
            y_hamon = y_edge + (1.0 - tip_u) * (0.24 * blade_h)
            # 3. Ko-Shinogi: Ridge line descends towards apex chisel point
            y_shinogi = (y_cur + 0.12 * blade_h) * (1.0 - tip_u * 0.70) + y_edge * (tip_u * 0.65)
            # 4. Mune: Spine tapers to apex
            y_spine_top = (y_cur + 0.50 * blade_h) * (1.0 - tip_u * 0.08)
            # 5. Facet narrowing at point
            hw_shinogi *= (1.0 - tip_u * 0.88)
            hw_spine   *= (1.0 - tip_u * 0.85)
            
        # 1. Main Tamahagane Mirror Steel Blade Body (Shinogi-Zukuri diamond cross-section)
        poly_steel = [
            [0.0,         y_spine_top, cur_z],
            [hw_shinogi,  y_shinogi,   cur_z],
            [hw_shinogi * 0.5, y_hamon, cur_z],
            [0.0,         y_hamon,     cur_z],
            [-hw_shinogi * 0.5, y_hamon, cur_z],
            [-hw_shinogi, y_shinogi,   cur_z]
        ]
        blade_slices_steel.append(poly_steel)
        
        # 2. Undulating Luminescent Hamon / Boshi Tempering Wave Ribbon
        poly_hamon = [
            [hw_shinogi * 0.5, y_hamon,         cur_z],
            [hw_shinogi * 0.25, (y_hamon + y_edge) * 0.5, cur_z],
            [-hw_shinogi * 0.25, (y_hamon + y_edge) * 0.5, cur_z],
            [-hw_shinogi * 0.5, y_hamon,         cur_z]
        ]
        blade_slices_hamon.append(poly_hamon)
        
        # 3. Glowing Celestial Cyan Plasma Cutting Edge
        poly_edge = [
            [hw_shinogi * 0.25, (y_hamon + y_edge) * 0.5, cur_z],
            [hw_edge,           y_edge, cur_z],
            [-hw_edge,          y_edge, cur_z],
            [-hw_shinogi * 0.25, (y_hamon + y_edge) * 0.5, cur_z]
        ]
        blade_slices_cyan_edge.append(poly_edge)
        
        # 4. Lacquered Crimson Spine Runner (Mune)
        poly_spine = [
            [0.0,        y_spine_top + 0.006 * h_taper, cur_z],
            [hw_spine,   y_spine_top - 0.005 * h_taper, cur_z],
            [0.0,        y_spine_top - 0.010 * h_taper, cur_z],
            [-hw_spine,  y_spine_top - 0.005 * h_taper, cur_z]
        ]
        blade_slices_crimson_spine.append(poly_spine)
        
        # 5. Dual Inlaid Cyan Bo-Hi Fullers (Runs along shinogi flats, ends at Yokote in Hi-Saki)
        if t <= 0.82:
            fuller_y = y_shinogi + 0.012 * h_taper
            poly_fuller = [
                [hw_shinogi * 0.92,  fuller_y + 0.006, cur_z],
                [hw_shinogi * 1.05,  fuller_y,         cur_z],
                [hw_shinogi * 0.92,  fuller_y - 0.006, cur_z],
                [-hw_shinogi * 0.92, fuller_y - 0.006, cur_z],
                [-hw_shinogi * 1.05, fuller_y,         cur_z],
                [-hw_shinogi * 0.92, fuller_y + 0.006, cur_z]
            ]
            blade_slices_fuller.append(poly_fuller)

    # Loft Blade Meshes
    v, n, idx = create_lofted_poly(blade_slices_steel, caps=True)
    builder.add_mesh_primitive(mesh_blade, m_steel, v, n, idx)
    
    v, n, idx = create_lofted_poly(blade_slices_hamon, caps=True)
    builder.add_mesh_primitive(mesh_blade, m_hamon, v, n, idx)
    
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
