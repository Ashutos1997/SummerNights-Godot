#!/usr/bin/env python3
"""
build_solar_helmet.py
Generates the Kamen Rider Apex Helmet (assets/models/solar_helmet.glb) for the Sun.
Designed to encapsulate the Sun's upper hemisphere and cheeks (R ≈ 7.80m).

Components:
  1. Helmet_Crown: High-rising dual V-Crest horns + skullcap armor + vermilion crest gem
  2. Helmet_Brow: Heavy beveled brow arch with cyan diodes and visor mounting
  3. Helmet_LeftCheek: Aerodynamic cheek plate + exhaust steam cowl + lower jaw lock
  4. Helmet_RightCheek: Mirrored right cheek plate + exhaust steam cowl + lower jaw lock
  5. Helmet_VisorFrame: Angular compound visor rim framing the furious eyes
"""

import math
import struct
import json
import os

class GLTFBuilder:
    def __init__(self):
        self.materials = []
        self.meshes = []
        self.nodes = []
        self.bin_data = bytearray()
        self.buffer_views = []
        self.accessors = []

    def add_material(self, name, albedo_rgb, roughness=0.35, metallic=0.75, emission_rgb=None, emission_strength=1.0):
        mat = {
            "name": name,
            "pbrMetallicRoughness": {
                "baseColorFactor": [albedo_rgb[0], albedo_rgb[1], albedo_rgb[2], 1.0],
                "roughnessFactor": roughness,
                "metallicFactor": metallic
            }
        }
        if emission_rgb:
            mat["emissiveFactor"] = [
                emission_rgb[0] * emission_strength,
                emission_rgb[1] * emission_strength,
                emission_rgb[2] * emission_strength
            ]
        self.materials.append(mat)
        return len(self.materials) - 1

    def add_buffer_data(self, data: bytes, target=None):
        offset = len(self.bin_data)
        # 4-byte align
        pad = (4 - (offset % 4)) % 4
        if pad > 0:
            self.bin_data.extend(b'\x00' * pad)
            offset += pad
        self.bin_data.extend(data)
        
        bv_idx = len(self.buffer_views)
        bv = {
            "buffer": 0,
            "byteOffset": offset,
            "byteLength": len(data)
        }
        if target:
            bv["target"] = target
        self.buffer_views.append(bv)
        return bv_idx

    def add_accessor(self, bv_idx, comp_type, count, acc_type, min_val=None, max_val=None):
        acc = {
            "bufferView": bv_idx,
            "byteOffset": 0,
            "componentType": comp_type,
            "count": count,
            "type": acc_type
        }
        if min_val is not None:
            acc["min"] = min_val
        if max_val is not None:
            acc["max"] = max_val
        self.accessors.append(acc)
        return len(self.accessors) - 1

    def create_mesh(self, name):
        m = {"name": name, "primitives": []}
        self.meshes.append(m)
        return len(self.meshes) - 1

    def add_mesh_primitive(self, mesh_idx, mat_idx, vertices, normals, indices):
        v_bytes = bytearray()
        min_v = [float('inf')]*3
        max_v = [float('-inf')]*3
        for v in vertices:
            for c in range(3):
                if v[c] < min_v[c]: min_v[c] = v[c]
                if v[c] > max_v[c]: max_v[c] = v[c]
            v_bytes.extend(struct.pack("<fff", v[0], v[1], v[2]))
        
        n_bytes = bytearray()
        for n in normals:
            n_bytes.extend(struct.pack("<fff", n[0], n[1], n[2]))

        idx_bytes = bytearray()
        for idx in indices:
            idx_bytes.extend(struct.pack("<H", idx))

        bv_v = self.add_buffer_data(v_bytes, target=34962)
        acc_v = self.add_accessor(bv_v, 5126, len(vertices), "VEC3", min_val=min_v, max_val=max_v)

        bv_n = self.add_buffer_data(n_bytes, target=34962)
        acc_n = self.add_accessor(bv_n, 5126, len(normals), "VEC3")

        bv_idx = self.add_buffer_data(idx_bytes, target=34963)
        acc_idx = self.add_accessor(bv_idx, 5123, len(indices), "SCALAR")

        self.meshes[mesh_idx]["primitives"].append({
            "attributes": {
                "POSITION": acc_v,
                "NORMAL": acc_n
            },
            "indices": acc_idx,
            "material": mat_idx,
            "mode": 4
        })

    def add_node(self, name, mesh_idx=None, translation=None, rotation=None, scale=None, children=None):
        node = {"name": name}
        if mesh_idx is not None:
            node["mesh"] = mesh_idx
        if translation:
            node["translation"] = translation
        if rotation:
            node["rotation"] = rotation
        if scale:
            node["scale"] = scale
        if children:
            node["children"] = children
        self.nodes.append(node)
        return len(self.nodes) - 1

    def build_glb(self, out_path):
        pad = (4 - (len(self.bin_data) % 4)) % 4
        if pad > 0:
            self.bin_data.extend(b'\x00' * pad)

        gltf = {
            "asset": {"version": "2.0", "generator": "SolarHelmetBuilder"},
            "scene": 0,
            "scenes": [{"name": "DefaultScene", "nodes": [len(self.nodes) - 1]}],
            "nodes": self.nodes,
            "meshes": self.meshes,
            "materials": self.materials,
            "accessors": self.accessors,
            "bufferViews": self.buffer_views,
            "buffers": [{"byteLength": len(self.bin_data)}]
        }

        json_bytes = json.dumps(gltf, separators=(',', ':')).encode('utf-8')
        json_pad = (4 - (len(json_bytes) % 4)) % 4
        if json_pad > 0:
            json_bytes += b' ' * json_pad

        total_size = 12 + 8 + len(json_bytes) + 8 + len(self.bin_data)

        with open(out_path, "wb") as f:
            f.write(b"glTF")
            f.write(struct.pack("<I", 2))
            f.write(struct.pack("<I", total_size))
            # JSON Chunk
            f.write(struct.pack("<I", len(json_bytes)))
            f.write(b"JSON")
            f.write(json_bytes)
            # BIN Chunk
            f.write(struct.pack("<I", len(self.bin_data)))
            f.write(b"BIN\x00")
            f.write(self.bin_data)

# ═════════════════════════════════════════════════════════════════════════════
# Geometry Helpers
# ═════════════════════════════════════════════════════════════════════════════

def create_box_3d(min_pt, max_pt):
    x0, y0, z0 = min_pt
    x1, y1, z1 = max_pt
    verts = [
        # Front
        [x0, y0, z1], [x1, y0, z1], [x1, y1, z1], [x0, y1, z1],
        # Back
        [x1, y0, z0], [x0, y0, z0], [x0, y1, z0], [x1, y1, z0],
        # Top
        [x0, y1, z1], [x1, y1, z1], [x1, y1, z0], [x0, y1, z0],
        # Bottom
        [x0, y0, z0], [x1, y0, z0], [x1, y0, z1], [x0, y0, z1],
        # Right
        [x1, y0, z1], [x1, y0, z0], [x1, y1, z0], [x1, y1, z1],
        # Left
        [x0, y0, z0], [x0, y0, z1], [x0, y1, z1], [x0, y1, z0],
    ]
    norms = [
        [ 0,  0,  1], [ 0,  0,  1], [ 0,  0,  1], [ 0,  0,  1],
        [ 0,  0, -1], [ 0,  0, -1], [ 0,  0, -1], [ 0,  0, -1],
        [ 0,  1,  0], [ 0,  1,  0], [ 0,  1,  0], [ 0,  1,  0],
        [ 0, -1,  0], [ 0, -1,  0], [ 0, -1,  0], [ 0, -1,  0],
        [ 1,  0,  0], [ 1,  0,  0], [ 1,  0,  0], [ 1,  0,  0],
        [-1,  0,  0], [-1,  0,  0], [-1,  0,  0], [-1,  0,  0],
    ]
    indices = []
    for face in range(6):
        b = face * 4
        indices.extend([b, b+1, b+2, b, b+2, b+3])
    return verts, norms, indices

def create_chamfered_box_3d(cx, cy, cz, width, height, depth, chamfer=0.15):
    # Generates a box with beveled 45° chamfered edges
    hw = width * 0.5
    hh = height * 0.5
    hd = depth * 0.5
    c = min(chamfer, hw*0.4, hh*0.4, hd*0.4)

    # 8 corners truncated to 24 face-aligned vertices
    verts = []
    norms = []
    indices = []

    def add_quad(p0, p1, p2, p3):
        # calculate normal
        v01 = [p1[0]-p0[0], p1[1]-p0[1], p1[2]-p0[2]]
        v02 = [p2[0]-p0[0], p2[1]-p0[1], p2[2]-p0[2]]
        nx = v01[1]*v02[2] - v01[2]*v02[1]
        ny = v01[2]*v02[0] - v01[0]*v02[2]
        nz = v01[0]*v02[1] - v01[1]*v02[0]
        l = math.sqrt(nx*nx + ny*ny + nz*nz)
        if l > 1e-6:
            nx, ny, nz = nx/l, ny/l, nz/l
        else:
            nx, ny, nz = 0, 1, 0

        b = len(verts)
        verts.extend([p0, p1, p2, p3])
        norms.extend([[nx, ny, nz]] * 4)
        indices.extend([b, b+1, b+2, b, b+2, b+3])

    # Front face
    add_quad([cx - hw + c, cy - hh + c, cz + hd],
             [cx + hw - c, cy - hh + c, cz + hd],
             [cx + hw - c, cy + hh - c, cz + hd],
             [cx - hw + c, cy + hh - c, cz + hd])
    # Back face
    add_quad([cx + hw - c, cy - hh + c, cz - hd],
             [cx - hw + c, cy - hh + c, cz - hd],
             [cx - hw + c, cy + hh - c, cz - hd],
             [cx + hw - c, cy + hh - c, cz - hd])
    # Top face
    add_quad([cx - hw + c, cy + hh, cz + hd - c],
             [cx + hw - c, cy + hh, cz + hd - c],
             [cx + hw - c, cy + hh, cz - hd + c],
             [cx - hw + c, cy + hh, cz - hd + c])
    # Bottom face
    add_quad([cx - hw + c, cy - hh, cz - hd + c],
             [cx + hw - c, cy - hh, cz - hd + c],
             [cx + hw - c, cy - hh, cz + hd - c],
             [cx - hw + c, cy - hh, cz + hd - c])
    # Right face
    add_quad([cx + hw, cy - hh + c, cz + hd - c],
             [cx + hw, cy - hh + c, cz - hd + c],
             [cx + hw, cy + hh - c, cz - hd + c],
             [cx + hw, cy + hh - c, cz + hd - c])
    # Left face
    add_quad([cx - hw, cy - hh + c, cz - hd + c],
             [cx - hw, cy - hh + c, cz + hd - c],
             [cx - hw, cy + hh - c, cz + hd - c],
             [cx - hw, cy + hh - c, cz - hd + c])

    # Chamfer bevels (12 edge strips)
    # Top-Front
    add_quad([cx - hw + c, cy + hh - c, cz + hd],
             [cx + hw - c, cy + hh - c, cz + hd],
             [cx + hw - c, cy + hh, cz + hd - c],
             [cx - hw + c, cy + hh, cz + hd - c])
    # Bottom-Front
    add_quad([cx - hw + c, cy - hh, cz + hd - c],
             [cx + hw - c, cy - hh, cz + hd - c],
             [cx + hw - c, cy - hh + c, cz + hd],
             [cx - hw + c, cy - hh + c, cz + hd])
    # Top-Back
    add_quad([cx + hw - c, cy + hh - c, cz - hd],
             [cx - hw + c, cy + hh - c, cz - hd],
             [cx - hw + c, cy + hh, cz - hd + c],
             [cx + hw - c, cy + hh, cz - hd + c])
    # Bottom-Back
    add_quad([cx + hw - c, cy - hh, cz - hd + c],
             [cx - hw + c, cy - hh, cz - hd + c],
             [cx - hw + c, cy - hh + c, cz - hd],
             [cx + hw - c, cy - hh + c, cz - hd])

    # Right-Front
    add_quad([cx + hw - c, cy - hh + c, cz + hd],
             [cx + hw, cy - hh + c, cz + hd - c],
             [cx + hw, cy + hh - c, cz + hd - c],
             [cx + hw - c, cy + hh - c, cz + hd])
    # Left-Front
    add_quad([cx - hw, cy - hh + c, cz + hd - c],
             [cx - hw + c, cy - hh + c, cz + hd],
             [cx - hw + c, cy + hh - c, cz + hd],
             [cx - hw, cy + hh - c, cz + hd - c])
    # Right-Back
    add_quad([cx + hw, cy - hh + c, cz - hd + c],
             [cx + hw - c, cy - hh + c, cz - hd],
             [cx + hw - c, cy + hh - c, cz - hd],
             [cx + hw, cy + hh - c, cz - hd + c])
    # Left-Back
    add_quad([cx - hw - c + c, cy - hh + c, cz - hd],
             [cx - hw, cy - hh + c, cz - hd + c],
             [cx - hw, cy + hh - c, cz - hd + c],
             [cx - hw - c + c, cy + hh - c, cz - hd])

    return verts, norms, indices

def create_extrusion(pts2d, z0, z1, caps=True):
    n_pts = len(pts2d)
    verts = []
    norms = []
    indices = []

    # Side walls
    for i in range(n_pts):
        next_i = (i + 1) % n_pts
        p0 = pts2d[i]
        p1 = pts2d[next_i]
        dx = p1[0] - p0[0]
        dy = p1[1] - p0[1]
        nx = dy
        ny = -dx
        l = math.sqrt(nx*nx + ny*ny)
        if l > 1e-6:
            nx, ny = nx/l, ny/l
        else:
            nx, ny = 0, 1

        b = len(verts)
        verts.extend([
            [p0[0], p0[1], z0],
            [p1[0], p1[1], z0],
            [p1[0], p1[1], z1],
            [p0[0], p0[1], z1]
        ])
        norms.extend([[nx, ny, 0.0]] * 4)
        indices.extend([b, b+1, b+2, b, b+2, b+3])

    if caps:
        # Front cap (z1)
        b_front = len(verts)
        for p in pts2d:
            verts.append([p[0], p[1], z1])
            norms.append([0.0, 0.0, 1.0])
        # Simple fan triangulation
        for i in range(1, n_pts - 1):
            indices.extend([b_front, b_front + i, b_front + i + 1])

        # Back cap (z0)
        b_back = len(verts)
        for p in pts2d:
            verts.append([p[0], p[1], z0])
            norms.append([0.0, 0.0, -1.0])
        for i in range(1, n_pts - 1):
            indices.extend([b_back, b_back + i + 1, b_back + i])

    return verts, norms, indices

def create_cylinder_z(cx, cy, z0, z1, radius, sides=16, caps=True):
    verts = []
    norms = []
    indices = []
    dz = z1 - z0

    for i in range(sides):
        a0 = (i / float(sides)) * math.tau
        a1 = ((i + 1) / float(sides)) * math.tau
        c0, s0 = math.cos(a0), math.sin(a0)
        c1, s1 = math.cos(a1), math.sin(a1)

        b = len(verts)
        verts.extend([
            [cx + c0 * radius, cy + s0 * radius, z0],
            [cx + c1 * radius, cy + s1 * radius, z0],
            [cx + c1 * radius, cy + s1 * radius, z1],
            [cx + c0 * radius, cy + s0 * radius, z1],
        ])
        norms.extend([
            [c0, s0, 0], [c1, s1, 0], [c1, s1, 0], [c0, s0, 0]
        ])
        indices.extend([b, b+1, b+2, b, b+2, b+3])

    if caps:
        # front cap z1
        b_front = len(verts)
        verts.append([cx, cy, z1])
        norms.append([0, 0, 1])
        for i in range(sides):
            a = (i / float(sides)) * math.tau
            verts.append([cx + math.cos(a)*radius, cy + math.sin(a)*radius, z1])
            norms.append([0, 0, 1])
        for i in range(sides):
            nxt = (i + 1) % sides
            indices.extend([b_front, b_front + 1 + i, b_front + 1 + nxt])

        # back cap z0
        b_back = len(verts)
        verts.append([cx, cy, z0])
        norms.append([0, 0, -1])
        for i in range(sides):
            a = (i / float(sides)) * math.tau
            verts.append([cx + math.cos(a)*radius, cy + math.sin(a)*radius, z0])
            norms.append([0, 0, -1])
        for i in range(sides):
            nxt = (i + 1) % sides
            indices.extend([b_back, b_back + 1 + nxt, b_back + 1 + i])

    return verts, norms, indices

# ═════════════════════════════════════════════════════════════════════════════
# Main Model Construction
# ═════════════════════════════════════════════════════════════════════════════

def build_solar_helmet(out_path):
    builder = GLTFBuilder()

    # Materials Palette (Strict Design System & Toon Shader Harmony)
    m_gold = builder.add_material("Mat_Helmet_Gold", [0.96, 0.74, 0.20], roughness=0.28, metallic=0.85)
    m_chassis = builder.add_material("Mat_Helmet_Chassis", [0.12, 0.11, 0.16], roughness=0.45, metallic=0.20)
    m_titanium = builder.add_material("Mat_Helmet_Titanium", [0.35, 0.36, 0.42], roughness=0.32, metallic=0.75)
    m_crimson = builder.add_material("Mat_Helmet_Crimson", [0.88, 0.12, 0.12], roughness=0.25, metallic=0.30, emission_rgb=[0.88, 0.12, 0.12], emission_strength=2.5)
    m_cyan = builder.add_material("Mat_Helmet_Cyan", [0.20, 0.92, 1.00], roughness=0.20, metallic=0.10, emission_rgb=[0.20, 0.92, 1.00], emission_strength=4.0)
    m_amber = builder.add_material("Mat_Helmet_Amber", [1.00, 0.70, 0.18], roughness=0.22, metallic=0.10, emission_rgb=[1.00, 0.70, 0.18], emission_strength=3.5)

    # ═════════════════════════════════════════════════════════════════════════
    # 1. HELMET CROWN (Top Apex V-Crest, Skullcap & Vermilion Diamond Gem)
    # Mounted at the top crown of the Sun sphere (Y ≈ +5.8m to +11.8m)
    # ═════════════════════════════════════════════════════════════════════════
    mesh_crown = builder.create_mesh("Mesh_Helmet_Crown")

    # A. Skullcap Hugging Arc (Upper Hemisphere Dome Band)
    # R ≈ 7.85m to 8.25m, Y ≈ +5.6m to +7.2m
    z_cap = 4.2
    v, n, idx = create_chamfered_box_3d(0.0, 6.40, z_cap, width=7.20, height=1.60, depth=2.40, chamfer=0.25)
    builder.add_mesh_primitive(mesh_crown, m_chassis, v, n, idx)

    # B. Central Spine Armor (Obsidian dorsal ridge along center)
    v, n, idx = create_chamfered_box_3d(0.0, 7.80, z_cap + 0.40, width=1.40, height=3.60, depth=1.60, chamfer=0.20)
    builder.add_mesh_primitive(mesh_crown, m_chassis, v, n, idx)

    # C. Majestic Kamen Rider Dual V-Crest Horns (Sun-Gold Angular Horns)
    # Left V-Crest Horn (Slanted up and out: X = 0 to -4.8m, Y = 6.2m to 11.6m)
    horn_pts_left = [
        [-0.40,  6.20],
        [-1.10,  6.00],
        [-4.80, 11.20],
        [-3.60, 11.60],
        [-1.80,  9.20],
        [-0.40,  8.00]
    ]
    v, n, idx = create_extrusion(horn_pts_left, z0=z_cap + 0.35, z1=z_cap + 1.25, caps=True)
    builder.add_mesh_primitive(mesh_crown, m_gold, v, n, idx)

    # Right V-Crest Horn (Mirrored: X = 0 to +4.8m)
    horn_pts_right = [
        [ 0.40,  6.20],
        [ 0.40,  8.00],
        [ 1.80,  9.20],
        [ 3.60, 11.60],
        [ 4.80, 11.20],
        [ 1.10,  6.00]
    ]
    v, n, idx = create_extrusion(horn_pts_right, z0=z_cap + 0.35, z1=z_cap + 1.25, caps=True)
    builder.add_mesh_primitive(mesh_crown, m_gold, v, n, idx)

    # Inner Secondary V-Horns (Sharper front tines)
    horn_inner_left = [
        [-0.30,  6.50],
        [-0.80,  6.40],
        [-2.40,  9.80],
        [-1.60, 10.10],
        [-0.30,  7.60]
    ]
    v, n, idx = create_extrusion(horn_inner_left, z0=z_cap + 1.20, z1=z_cap + 1.65, caps=True)
    builder.add_mesh_primitive(mesh_crown, m_gold, v, n, idx)

    horn_inner_right = [
        [ 0.30,  6.50],
        [ 0.30,  7.60],
        [ 1.60, 10.10],
        [ 2.40,  9.80],
        [ 0.80,  6.40]
    ]
    v, n, idx = create_extrusion(horn_inner_right, z0=z_cap + 1.20, z1=z_cap + 1.65, caps=True)
    builder.add_mesh_primitive(mesh_crown, m_gold, v, n, idx)

    # D. Central Shinto Vermilion Jewel (Forehead Apex Gem Diamond)
    gem_pts = [
        [ 0.00,  7.40],
        [-0.75,  6.50],
        [ 0.00,  5.60],
        [ 0.75,  6.50]
    ]
    v, n, idx = create_extrusion(gem_pts, z0=z_cap + 0.85, z1=z_cap + 1.55, caps=True)
    builder.add_mesh_primitive(mesh_crown, m_crimson, v, n, idx)

    # Gold Bezel framing the Forehead Gem
    v, n, idx = create_chamfered_box_3d(0.0, 6.50, z_cap + 0.70, width=2.00, height=2.20, depth=0.45, chamfer=0.15)
    builder.add_mesh_primitive(mesh_crown, m_gold, v, n, idx)

    # ═════════════════════════════════════════════════════════════════════════
    # 2. HELMET BROW (Forehead Brow Arch & Visor Mount)
    # Sitting right above the Sun's angry eyes (Y ≈ +2.6m to +4.5m, Z ≈ 6.8m)
    # ═════════════════════════════════════════════════════════════════════════
    mesh_brow = builder.create_mesh("Mesh_Helmet_Brow")

    z_brow = 6.85
    # Heavy beveled brow arch (Crossbar shielding eyes)
    v, n, idx = create_chamfered_box_3d(0.0, 3.60, z_brow, width=7.40, height=1.10, depth=1.20, chamfer=0.20)
    builder.add_mesh_primitive(mesh_brow, m_chassis, v, n, idx)

    # Sun-Gold Brow Trim Plate
    v, n, idx = create_chamfered_box_3d(0.0, 3.85, z_brow + 0.35, width=7.80, height=0.42, depth=0.80, chamfer=0.08)
    builder.add_mesh_primitive(mesh_brow, m_gold, v, n, idx)

    # Central Crosshair Collimator Notch
    v, n, idx = create_chamfered_box_3d(0.0, 3.25, z_brow + 0.50, width=0.80, height=0.60, depth=0.60, chamfer=0.08)
    builder.add_mesh_primitive(mesh_brow, m_titanium, v, n, idx)
    # Glowing Cyan Aim Diode
    v, n, idx = create_cylinder_z(0.0, 3.25, z0=z_brow + 0.65, z1=z_brow + 0.85, radius=0.18, sides=12)
    builder.add_mesh_primitive(mesh_brow, m_cyan, v, n, idx)

    # Lateral Cyan Telemetry Diodes (3 per side)
    for sign_x in [-1.0, 1.0]:
        for d_i in range(3):
            dx = sign_x * (1.60 + d_i * 0.95)
            v, n, idx = create_box_3d([dx - 0.12, 3.65, z_brow + 0.55], [dx + 0.12, 3.80, z_brow + 0.65])
            builder.add_mesh_primitive(mesh_brow, m_cyan, v, n, idx)

    # ═════════════════════════════════════════════════════════════════════════
    # 3. HELMET LEFT CHEEK (Cheek Armor, Steam Exhaust Cowl, Jaw Clamps)
    # Wraps around the left lateral flank (X ≈ -6.6m to -7.8m, Y ≈ -0.8m to +3.6m)
    # ═════════════════════════════════════════════════════════════════════════
    mesh_left_cheek = builder.create_mesh("Mesh_Helmet_LeftCheek")

    # Main Obsidian Cheek Plate (curved aerodynamic guard)
    v, n, idx = create_chamfered_box_3d(-6.60, 1.20, 4.80, width=1.50, height=4.20, depth=3.80, chamfer=0.28)
    builder.add_mesh_primitive(mesh_left_cheek, m_chassis, v, n, idx)

    # Sun-Gold Outer Cheek Ribs (Angular armor chevron)
    v, n, idx = create_chamfered_box_3d(-7.20, 1.20, 5.10, width=0.55, height=4.40, depth=3.20, chamfer=0.16)
    builder.add_mesh_primitive(mesh_left_cheek, m_gold, v, n, idx)

    # Dual High-Pressure Steam Exhaust Cowls (Cylinders pointing backward-outward)
    for c_y in [0.20, 2.20]:
        v, n, idx = create_cylinder_z(-7.10, c_y, z0=3.20, z1=5.20, radius=0.62, sides=16)
        builder.add_mesh_primitive(mesh_left_cheek, m_titanium, v, n, idx)
        # Inner Exhaust Vent Core (Glowing Amber heat aperture)
        v, n, idx = create_cylinder_z(-7.10, c_y, z0=3.00, z1=3.40, radius=0.48, sides=12)
        builder.add_mesh_primitive(mesh_left_cheek, m_amber, v, n, idx)

    # Lower Jaw Clamping Tines (Pointing downward toward Driver belt)
    v, n, idx = create_chamfered_box_3d(-5.80, -1.20, 5.60, width=0.90, height=2.20, depth=1.20, chamfer=0.18)
    builder.add_mesh_primitive(mesh_left_cheek, m_gold, v, n, idx)
    v, n, idx = create_chamfered_box_3d(-5.20, -1.80, 5.80, width=0.65, height=1.40, depth=0.85, chamfer=0.12)
    builder.add_mesh_primitive(mesh_left_cheek, m_titanium, v, n, idx)

    # ═════════════════════════════════════════════════════════════════════════
    # 4. HELMET RIGHT CHEEK (Mirrored Right Flank)
    # ═════════════════════════════════════════════════════════════════════════
    mesh_right_cheek = builder.create_mesh("Mesh_Helmet_RightCheek")

    # Main Obsidian Cheek Plate
    v, n, idx = create_chamfered_box_3d(6.60, 1.20, 4.80, width=1.50, height=4.20, depth=3.80, chamfer=0.28)
    builder.add_mesh_primitive(mesh_right_cheek, m_chassis, v, n, idx)

    # Sun-Gold Outer Cheek Ribs
    v, n, idx = create_chamfered_box_3d(7.20, 1.20, 5.10, width=0.55, height=4.40, depth=3.20, chamfer=0.16)
    builder.add_mesh_primitive(mesh_right_cheek, m_gold, v, n, idx)

    # Dual Steam Exhaust Cowls
    for c_y in [0.20, 2.20]:
        v, n, idx = create_cylinder_z(7.10, c_y, z0=3.20, z1=5.20, radius=0.62, sides=16)
        builder.add_mesh_primitive(mesh_right_cheek, m_titanium, v, n, idx)
        v, n, idx = create_cylinder_z(7.10, c_y, z0=3.00, z1=3.40, radius=0.48, sides=12)
        builder.add_mesh_primitive(mesh_right_cheek, m_amber, v, n, idx)

    # Lower Jaw Clamping Tines
    v, n, idx = create_chamfered_box_3d(5.80, -1.20, 5.60, width=0.90, height=2.20, depth=1.20, chamfer=0.18)
    builder.add_mesh_primitive(mesh_right_cheek, m_gold, v, n, idx)
    v, n, idx = create_chamfered_box_3d(5.20, -1.80, 5.80, width=0.65, height=1.40, depth=0.85, chamfer=0.12)
    builder.add_mesh_primitive(mesh_right_cheek, m_titanium, v, n, idx)

    # ═════════════════════════════════════════════════════════════════════════
    # 5. HELMET VISOR FRAME (Compound Eye Framing Ribs)
    # Frames the angry eyes without occluding the face (X ≈ ±3.5m, Y ≈ 0.5m to 2.4m)
    # ═════════════════════════════════════════════════════════════════════════
    mesh_visor = builder.create_mesh("Mesh_Helmet_VisorFrame")

    z_vis = 7.15
    for sign_x in [-1.0, 1.0]:
        # Slanted Eye Caliper Outer Bezel
        caliper_pts = [
            [sign_x * 1.40, 2.50],
            [sign_x * 4.40, 2.30],
            [sign_x * 4.60, 0.60],
            [sign_x * 3.80, 0.40],
            [sign_x * 1.60, 1.60]
        ]
        if sign_x < 0:
            caliper_pts = caliper_pts[::-1]

        v, n, idx = create_extrusion(caliper_pts, z0=z_vis - 0.15, z1=z_vis + 0.35, caps=True)
        builder.add_mesh_primitive(mesh_visor, m_gold, v, n, idx)

        # Glowing Cyan Inner LED Rail inside Visor Rim
        rail_pts = [
            [sign_x * 1.70, 2.35],
            [sign_x * 4.15, 2.15],
            [sign_x * 4.30, 0.85],
            [sign_x * 3.75, 0.70],
            [sign_x * 1.85, 1.70]
        ]
        if sign_x < 0:
            rail_pts = rail_pts[::-1]

        v, n, idx = create_extrusion(rail_pts, z0=z_vis + 0.28, z1=z_vis + 0.45, caps=True)
        builder.add_mesh_primitive(mesh_visor, m_cyan, v, n, idx)

        # Shinto Vermilion Teardrop / Fang Accent beneath eyes
        fang_pts = [
            [sign_x * 3.60,  0.50],
            [sign_x * 4.30,  0.60],
            [sign_x * 3.80, -0.60]
        ]
        if sign_x < 0:
            fang_pts = fang_pts[::-1]
        v, n, idx = create_extrusion(fang_pts, z0=z_vis - 0.10, z1=z_vis + 0.25, caps=True)
        builder.add_mesh_primitive(mesh_visor, m_crimson, v, n, idx)

    # ═════════════════════════════════════════════════════════════════════════
    # Build Node Hierarchy
    # ═════════════════════════════════════════════════════════════════════════
    # Separate animating nodes so Godot Tweens can assemble them dynamically!
    n_crown = builder.add_node("Helmet_Crown", mesh_idx=mesh_crown)
    n_brow = builder.add_node("Helmet_Brow", mesh_idx=mesh_brow)
    n_left_cheek = builder.add_node("Helmet_LeftCheek", mesh_idx=mesh_left_cheek)
    n_right_cheek = builder.add_node("Helmet_RightCheek", mesh_idx=mesh_right_cheek)
    n_visor = builder.add_node("Helmet_VisorFrame", mesh_idx=mesh_visor)

    # Master Root Node
    builder.add_node("SolarHelmetRoot", children=[n_crown, n_brow, n_left_cheek, n_right_cheek, n_visor])

    # Export GLB file
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    builder.build_glb(out_path)
    print(f"[OK] Successfully exported: {out_path} ({os.path.getsize(out_path)} bytes)")

if __name__ == "__main__":
    out_file = os.path.abspath("assets/models/solar_helmet.glb")
    build_solar_helmet(out_file)
