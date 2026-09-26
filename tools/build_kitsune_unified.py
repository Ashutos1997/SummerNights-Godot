#!/usr/bin/env python3
"""
build_kitsune_unified.py - Generates an articulated, transforming Kitsune Buster IX GLB.
Contains distinct hierarchical nodes:
- Chassis (Root Body, Grip, Stock, Reflex Sight, Receiver)
- Cylinder (Revolving 9-Vial Kyubi Chamber with Central Axle)
- BarrelAssembly (Retractable Cannon Barrel, Shroud, Muzzle, Bayonet)
- TsubaLeft (Left Folding Crossguard Wing)
- TsubaRight (Right Folding Crossguard Wing)
- BladeAssembly (Telescoping Katana Blade, Crimson Spine, Glowing Cyan Plasma Edge)
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
            "asset": {"version": "2.0", "generator": "UnifiedKitsuneBuilder"},
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
    m_white = builder.add_material("Mat_PearlWhite", [0.96, 0.96, 0.98, 1.0], metallic=0.06, roughness=0.18)
    m_red   = builder.add_material("Mat_Crimson", [0.88, 0.10, 0.16, 1.0], metallic=0.14, roughness=0.22)
    m_gold  = builder.add_material("Mat_CyberGold", [0.98, 0.76, 0.14, 1.0], metallic=0.50, roughness=0.22)
    m_dark  = builder.add_material("Mat_DarkCharcoal", [0.12, 0.12, 0.16, 1.0], metallic=0.25, roughness=0.50)
    m_cyan  = builder.add_material("Mat_CyanEnergy", [0.25, 0.88, 1.0, 1.0], metallic=0.05, roughness=0.10, emissive_rgb=[0.60, 1.10, 1.30])
    m_trans_gold = builder.add_material("Mat_CyberGoldTranslucent", [0.98, 0.78, 0.16, 0.38], metallic=0.15, roughness=0.15, alpha_mode="BLEND")
    
    # ══════════════════════════════════════════════════════════════
    # 1. CHASSIS MESH (Root Body, Fixed Coordinates)
    # ══════════════════════════════════════════════════════════════
    mesh_chassis = builder.create_mesh("Mesh_Chassis")
    
    # Ergonomic Grip & Heel Plate
    v, n, idx = create_chamfered_box(0.0, 0.22, width=0.18, height=0.40, z0=-0.24, z1=-0.06, chamfer=0.04)
    builder.add_mesh_primitive(mesh_chassis, m_dark, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.025, width=0.24, height=0.05, z0=-0.30, z1=-0.04, chamfer=0.02)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    # Side Grip Crimson Accents
    v, n, idx = create_chamfered_box(-0.092, 0.22, width=0.016, height=0.28, z0=-0.22, z1=-0.08, chamfer=0.005)
    builder.add_mesh_primitive(mesh_chassis, m_red, v, n, idx)
    v, n, idx = create_chamfered_box(0.092, 0.22, width=0.016, height=0.28, z0=-0.22, z1=-0.08, chamfer=0.005)
    builder.add_mesh_primitive(mesh_chassis, m_red, v, n, idx)
    
    # Trigger Guard & Crimson Trigger
    v, n, idx = create_chamfered_box(0.0, 0.23, width=0.06, height=0.05, z0=-0.06, z1=0.10, chamfer=0.010)
    builder.add_mesh_primitive(mesh_chassis, m_dark, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.32, width=0.06, height=0.18, z0=0.08, z1=0.12, chamfer=0.010)
    builder.add_mesh_primitive(mesh_chassis, m_dark, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.30, width=0.04, height=0.12, z0=-0.03, z1=0.02, chamfer=0.008)
    builder.add_mesh_primitive(mesh_chassis, m_red, v, n, idx)
    
    # Stock Housing & Twin Hydro-Vials
    v, n, idx = create_chamfered_box(0.0, 0.46, width=0.30, height=0.16, z0=-0.30, z1=0.02, chamfer=0.04)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.50, width=0.28, height=0.20, z0=-0.52, z1=-0.30, chamfer=0.04)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    for xt in [-0.075, 0.075]:
        v, n, idx = create_cylinder(xt, 0.50, z0=-0.50, z1=-0.32, radius=0.045, sides=16)
        builder.add_mesh_primitive(mesh_chassis, m_cyan, v, n, idx)
        v, n, idx = create_cylinder(xt, 0.50, z0=-0.51, z1=-0.49, radius=0.052, sides=16)
        builder.add_mesh_primitive(mesh_chassis, m_gold, v, n, idx)
        v, n, idx = create_cylinder(xt, 0.50, z0=-0.33, z1=-0.31, radius=0.052, sides=16)
        builder.add_mesh_primitive(mesh_chassis, m_gold, v, n, idx)
    for z_fin in [-0.46, -0.36]:
        v, n, idx = create_chamfered_box(0.0, 0.59, width=0.26, height=0.03, z0=z_fin - 0.02, z1=z_fin + 0.02, chamfer=0.008)
        builder.add_mesh_primitive(mesh_chassis, m_red, v, n, idx)
        
    # Cylinder Cradles / Bridges
    v, n, idx = create_chamfered_box(0.0, 0.48, width=0.32, height=0.30, z0=0.00, z1=0.04, chamfer=0.04)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.48, width=0.32, height=0.30, z0=0.32, z1=0.36, chamfer=0.04)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    
    # Lower Keel & Decks
    v, n, idx = create_chamfered_box(0.0, 0.28, width=0.16, height=0.06, z0=0.00, z1=0.36, chamfer=0.02)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.63, width=0.28, height=0.12, z0=-0.32, z1=0.00, chamfer=0.04)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    v, n, idx = create_chamfered_box(-0.141, 0.63, width=0.016, height=0.06, z0=-0.24, z1=-0.02, chamfer=0.005)
    builder.add_mesh_primitive(mesh_chassis, m_dark, v, n, idx)
    v, n, idx = create_chamfered_box(0.141, 0.63, width=0.016, height=0.06, z0=-0.24, z1=-0.02, chamfer=0.005)
    builder.add_mesh_primitive(mesh_chassis, m_dark, v, n, idx)
    
    # Forward Deck & Collar Base (Z = 0.36 to 0.60)
    v, n, idx = create_chamfered_box(0.0, 0.63, width=0.28, height=0.12, z0=0.36, z1=0.58, chamfer=0.04)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    v, n, idx = create_chamfered_box(0.0, 0.48, width=0.28, height=0.26, z0=0.36, z1=0.60, chamfer=0.045)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    
    # Reflex Sight Riser & Holographic Frame
    v, n, idx = create_chamfered_box(0.0, 0.695, width=0.11, height=0.018, z0=-0.04, z1=0.08, chamfer=0.005)
    builder.add_mesh_primitive(mesh_chassis, m_dark, v, n, idx)
    v, n, idx = create_chamfered_box(-0.060, 0.745, width=0.016, height=0.085, z0=-0.02, z1=0.06, chamfer=0.004)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    v, n, idx = create_chamfered_box(0.060, 0.745, width=0.016, height=0.085, z0=-0.02, z1=0.06, chamfer=0.004)
    builder.add_mesh_primitive(mesh_chassis, m_white, v, n, idx)
    reticle_pts = [[-0.050, 0.705], [0.050, 0.705], [0.045, 0.785], [-0.045, 0.785]]
    v, n, idx = create_extrusion(reticle_pts, z0=0.015, z1=0.025, caps=True)
    builder.add_mesh_primitive(mesh_chassis, m_cyan, v, n, idx)
    
    # Sightline Channel & Inlaid Ribs
    v, n, idx = create_chamfered_box(0.0, 0.692, width=0.07, height=0.012, z0=-0.28, z1=-0.04, chamfer=0.003)
    builder.add_mesh_primitive(mesh_chassis, m_dark, v, n, idx)
    v, n, idx = create_chamfered_box(-0.046, 0.692, width=0.010, height=0.010, z0=-0.26, z1=-0.05, chamfer=0.002)
    builder.add_mesh_primitive(mesh_chassis, m_red, v, n, idx)
    v, n, idx = create_chamfered_box(0.046, 0.692, width=0.010, height=0.010, z0=-0.26, z1=-0.05, chamfer=0.002)
    builder.add_mesh_primitive(mesh_chassis, m_red, v, n, idx)
    
    # ══════════════════════════════════════════════════════════════
    # 2. REVOLVING CYLINDER MESH (Pivot at X=0.0, Y=0.48, Z=0.18)
    # Coordinates centered locally around (0, 0, 0)
    # ══════════════════════════════════════════════════════════════
    mesh_cylinder = builder.create_mesh("Mesh_Cylinder")
    
    # Translucent Drum Shell (Local Z from -0.14 to +0.14)
    v, n, idx = create_cylinder(0.0, 0.0, z0=-0.14, z1=0.14, radius=0.205, sides=24)
    builder.add_mesh_primitive(mesh_cylinder, m_trans_gold, v, n, idx)
    # Gold Rim Bands
    v, n, idx = create_cylinder(0.0, 0.0, z0=-0.145, z1=-0.115, radius=0.218, sides=24)
    builder.add_mesh_primitive(mesh_cylinder, m_gold, v, n, idx)
    v, n, idx = create_cylinder(0.0, 0.0, z0=0.115, z1=0.145, radius=0.218, sides=24)
    builder.add_mesh_primitive(mesh_cylinder, m_gold, v, n, idx)
    # Central Axle
    v, n, idx = create_cylinder(0.0, 0.0, z0=-0.165, z1=0.165, radius=0.065, sides=16)
    builder.add_mesh_primitive(mesh_cylinder, m_dark, v, n, idx)
    # 9 Water Bores with Cyan Vials
    for i in range(9):
        ang = (i / 9.0) * 2 * math.pi
        bore_r = 0.145
        bx = math.cos(ang) * bore_r
        by = math.sin(ang) * bore_r
        v, n, idx = create_cylinder(bx, by, z0=-0.13, z1=0.13, radius=0.038, sides=12)
        builder.add_mesh_primitive(mesh_cylinder, m_cyan, v, n, idx)
        v, n, idx = create_cylinder(bx, by, z0=-0.142, z1=-0.128, radius=0.044, sides=12)
        builder.add_mesh_primitive(mesh_cylinder, m_dark, v, n, idx)
        v, n, idx = create_cylinder(bx, by, z0=0.128, z1=0.142, radius=0.044, sides=12)
        builder.add_mesh_primitive(mesh_cylinder, m_dark, v, n, idx)

    # ══════════════════════════════════════════════════════════════
    # 3. BARREL ASSEMBLY MESH (Pivot at X=0.0, Y=0.48, Z=0.55)
    # Coordinates relative to Z=0.55 (Cannon configuration)
    # ══════════════════════════════════════════════════════════════
    mesh_barrel = builder.create_mesh("Mesh_BarrelAssembly")
    
    # Inner Steel Barrel (Z=0.60 to 0.96 -> local Z=0.05 to 0.41)
    v, n, idx = create_cylinder(0.0, 0.0, z0=0.05, z1=0.41, radius=0.075, sides=16)
    builder.add_mesh_primitive(mesh_barrel, m_dark, v, n, idx)
    # Outer Octagonal Shroud (local Z=0.05 to 0.33)
    v, n, idx = create_chamfered_box(0.0, 0.0, width=0.22, height=0.20, z0=0.05, z1=0.33, chamfer=0.035)
    builder.add_mesh_primitive(mesh_barrel, m_white, v, n, idx)
    # Dual-Port Muzzle Brake (local Z=0.33 to 0.42)
    v, n, idx = create_chamfered_box(0.0, 0.0, width=0.20, height=0.18, z0=0.33, z1=0.42, chamfer=0.030)
    builder.add_mesh_primitive(mesh_barrel, m_dark, v, n, idx)
    # Side Cutouts
    v, n, idx = create_chamfered_box(-0.102, 0.0, width=0.012, height=0.07, z0=0.35, z1=0.40, chamfer=0.003)
    builder.add_mesh_primitive(mesh_barrel, m_red, v, n, idx)
    v, n, idx = create_chamfered_box(0.102, 0.0, width=0.012, height=0.07, z0=0.35, z1=0.40, chamfer=0.003)
    builder.add_mesh_primitive(mesh_barrel, m_red, v, n, idx)
    # Luminous Muzzle Ring & Crown
    v, n, idx = create_cylinder(0.0, 0.0, z0=0.41, z1=0.44, radius=0.068, sides=16)
    builder.add_mesh_primitive(mesh_barrel, m_cyan, v, n, idx)
    v, n, idx = create_cylinder(0.0, 0.0, z0=0.435, z1=0.455, radius=0.062, sides=16)
    builder.add_mesh_primitive(mesh_barrel, m_red, v, n, idx)
    
    # Top Bayonet Blade (Z=0.55 to 1.06 -> local Z=0.0 to 0.51)
    bayonet_s = [[0.0, 0.725 - 0.48], [0.042, 0.685 - 0.48], [0.0, 0.580 - 0.48], [-0.042, 0.685 - 0.48]]
    bayonet_e = [[0.0, 0.640 - 0.48], [0.003, 0.615 - 0.48], [0.0, 0.590 - 0.48], [-0.003, 0.615 - 0.48]]
    v, n, idx = create_tapered_extrusion(bayonet_s, bayonet_e, z0=0.0, z1=0.51, caps=True)
    builder.add_mesh_primitive(mesh_barrel, m_red, v, n, idx)
    
    # Under-Barrel Stabilizer Keel (Z=0.36 to 0.90 -> local Z=-0.19 to 0.35)
    under_s = [[0.0, 0.400 - 0.48], [0.036, 0.355 - 0.48], [0.0, 0.280 - 0.48], [-0.036, 0.355 - 0.48]]
    under_e = [[0.0, 0.425 - 0.48], [0.003, 0.400 - 0.48], [0.0, 0.375 - 0.48], [-0.003, 0.400 - 0.48]]
    v, n, idx = create_tapered_extrusion(under_s, under_e, z0=-0.19, z1=0.35, caps=True)
    builder.add_mesh_primitive(mesh_barrel, m_red, v, n, idx)

    # ══════════════════════════════════════════════════════════════
    # 4. TSUBA CROSSGUARD WINGS (Pivots at X=±0.12, Y=0.52, Z=0.59)
    # Left and Right aerodynamic wings that unfold when drawing the Katana
    # ══════════════════════════════════════════════════════════════
    mesh_tsuba_l = builder.create_mesh("Mesh_TsubaLeft")
    # Left wing geometry relative to pivot (-0.12, 0.52, 0.59)
    v, n, idx = create_chamfered_box(-0.08, 0.0, width=0.16, height=0.05, z0=-0.02, z1=0.04, chamfer=0.010)
    builder.add_mesh_primitive(mesh_tsuba_l, m_red, v, n, idx)
    v, n, idx = create_chamfered_box(-0.16, 0.0, width=0.03, height=0.035, z0=-0.01, z1=0.03, chamfer=0.006)
    builder.add_mesh_primitive(mesh_tsuba_l, m_gold, v, n, idx)
    
    mesh_tsuba_r = builder.create_mesh("Mesh_TsubaRight")
    # Right wing geometry relative to pivot (+0.12, 0.52, 0.59)
    v, n, idx = create_chamfered_box(0.08, 0.0, width=0.16, height=0.05, z0=-0.02, z1=0.04, chamfer=0.010)
    builder.add_mesh_primitive(mesh_tsuba_r, m_red, v, n, idx)
    v, n, idx = create_chamfered_box(0.16, 0.0, width=0.03, height=0.035, z0=-0.01, z1=0.03, chamfer=0.006)
    builder.add_mesh_primitive(mesh_tsuba_r, m_gold, v, n, idx)

    # ══════════════════════════════════════════════════════════════
    # 5. BLADE ASSEMBLY MESH (Pivot at X=0.0, Y=0.52, Z=0.60)
    # Telescoping Katana Blade, Crimson Spine, Radiant Cyan Plasma Edge
    # ══════════════════════════════════════════════════════════════
    mesh_blade = builder.create_mesh("Mesh_BladeAssembly")
    
    # Collar / Habaki (Local Z = 0.0 to 0.04)
    v, n, idx = create_chamfered_box(0.0, 0.0, width=0.10, height=0.16, z0=0.0, z1=0.04, chamfer=0.015)
    builder.add_mesh_primitive(mesh_blade, m_gold, v, n, idx)
    
    # Blade Base to Mid-Section (Local Z = 0.04 to 0.76)
    blade_start = [[0.0, 0.68 - 0.52], [0.025, 0.53 - 0.52], [0.0, 0.38 - 0.52], [-0.025, 0.53 - 0.52]]
    blade_mid   = [[0.0, 0.65 - 0.52], [0.020, 0.53 - 0.52], [0.0, 0.39 - 0.52], [-0.020, 0.53 - 0.52]]
    v, n, idx = create_tapered_extrusion(blade_start, blade_mid, z0=0.04, z1=0.76, caps=True)
    builder.add_mesh_primitive(mesh_blade, m_white, v, n, idx)
    
    # Blade Mid to Pointed Swept Tip (Local Z = 0.76 to 1.25, Total blade length = 1.25m!)
    blade_tip = [[0.0, 0.56 - 0.52], [0.003, 0.53 - 0.52], [0.0, 0.52 - 0.52], [-0.003, 0.53 - 0.52]]
    v, n, idx = create_tapered_extrusion(blade_mid, blade_tip, z0=0.76, z1=1.25, caps=True)
    builder.add_mesh_primitive(mesh_blade, m_white, v, n, idx)
    
    # Radiant Cyan Plasma Edge (Local Z = 0.04 to 1.20)
    edge_start = [[0.0, 0.39 - 0.52], [0.008, 0.43 - 0.52], [0.0, 0.36 - 0.52], [-0.008, 0.43 - 0.52]]
    edge_end   = [[0.0, 0.52 - 0.52], [0.002, 0.53 - 0.52], [0.0, 0.51 - 0.52], [-0.002, 0.53 - 0.52]]
    v, n, idx = create_tapered_extrusion(edge_start, edge_end, z0=0.04, z1=1.20, caps=True)
    builder.add_mesh_primitive(mesh_blade, m_cyan, v, n, idx)
    
    # Crimson Spine Runner (Local Z = 0.04 to 0.86)
    spine_s = [[0.0, 0.69 - 0.52], [0.010, 0.65 - 0.52], [0.0, 0.63 - 0.52], [-0.010, 0.65 - 0.52]]
    spine_e = [[0.0, 0.65 - 0.52], [0.004, 0.63 - 0.52], [0.0, 0.62 - 0.52], [-0.004, 0.63 - 0.52]]
    v, n, idx = create_tapered_extrusion(spine_s, spine_e, z0=0.04, z1=0.86, caps=True)
    builder.add_mesh_primitive(mesh_blade, m_red, v, n, idx)

    # ══════════════════════════════════════════════════════════════
    # HIERARCHY NODES
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
