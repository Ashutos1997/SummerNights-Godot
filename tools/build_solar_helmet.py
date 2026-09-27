#!/usr/bin/env python3
"""
build_solar_helmet.py
Generates the complete Kamen Rider Apex Helmet (assets/models/solar_helmet.glb).
Fully encapsulates the Sun (R ≈ 7.80m) with:
  1. Full Cranial Shell (Skullcap, Temporal Dome, and Occipital Back Armor)
  2. Iconic Kamen Rider Compound Eye Visors (Luminous faceted ruby/amber insectoid eyes)
  3. Kamen Rider Crusher Mouth Plate (Stepped horizontal ventilation slats & angular chin keel)
  4. Dual High-Rising Sun-Gold V-Crest Horns + Central Forehead O-Signal Ruby Gem
  5. Lateral Ear Receptors & Dual Steam Exhaust Cowls
  6. Sub-assemblies organized into Helmet_Crest, Helmet_Faceplate, Helmet_Cheeks for henshin slam assembly!
"""

import math
import struct
import json
import os
import numpy as np

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
            "asset": {"version": "2.0", "generator": "KamenRiderSolarHelmetBuilder"},
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
            f.write(struct.pack("<I", len(json_bytes)))
            f.write(b"JSON")
            f.write(json_bytes)
            f.write(struct.pack("<I", len(self.bin_data)))
            f.write(b"BIN\x00")
            f.write(self.bin_data)

# ═════════════════════════════════════════════════════════════════════════════
# Geometry Helpers
# ═════════════════════════════════════════════════════════════════════════════

def calc_normal(p0, p1, p2):
    v01 = [p1[0]-p0[0], p1[1]-p0[1], p1[2]-p0[2]]
    v02 = [p2[0]-p0[0], p2[1]-p0[1], p2[2]-p0[2]]
    nx = v01[1]*v02[2] - v01[2]*v02[1]
    ny = v01[2]*v02[0] - v01[0]*v02[2]
    nz = v01[0]*v02[1] - v01[1]*v02[0]
    l = math.sqrt(nx*nx + ny*ny + nz*nz)
    if l > 1e-6:
        return [nx/l, ny/l, nz/l]
    return [0.0, 1.0, 0.0]

def create_chamfered_box_3d(cx, cy, cz, width, height, depth, chamfer=0.15):
    hw = width * 0.5
    hh = height * 0.5
    hd = depth * 0.5
    c = min(chamfer, hw*0.4, hh*0.4, hd*0.4)

    verts = []
    norms = []
    indices = []

    def add_quad(p0, p1, p2, p3):
        n = calc_normal(p0, p1, p2)
        b = len(verts)
        verts.extend([p0, p1, p2, p3])
        norms.extend([n] * 4)
        indices.extend([b, b+1, b+2, b, b+2, b+3])

    # 6 primary faces
    add_quad([cx - hw + c, cy - hh + c, cz + hd],
             [cx + hw - c, cy - hh + c, cz + hd],
             [cx + hw - c, cy + hh - c, cz + hd],
             [cx - hw + c, cy + hh - c, cz + hd])
    add_quad([cx + hw - c, cy - hh + c, cz - hd],
             [cx - hw + c, cy - hh + c, cz - hd],
             [cx - hw + c, cy + hh - c, cz - hd],
             [cx + hw - c, cy + hh - c, cz - hd])
    add_quad([cx - hw + c, cy + hh, cz + hd - c],
             [cx + hw - c, cy + hh, cz + hd - c],
             [cx + hw - c, cy + hh, cz - hd + c],
             [cx - hw + c, cy + hh, cz - hd + c])
    add_quad([cx - hw + c, cy - hh, cz - hd + c],
             [cx + hw - c, cy - hh, cz - hd + c],
             [cx + hw - c, cy - hh, cz + hd - c],
             [cx - hw + c, cy - hh, cz + hd - c])
    add_quad([cx + hw, cy - hh + c, cz + hd - c],
             [cx + hw, cy - hh + c, cz - hd + c],
             [cx + hw, cy + hh - c, cz - hd + c],
             [cx + hw, cy + hh - c, cz + hd - c])
    add_quad([cx - hw, cy - hh + c, cz - hd + c],
             [cx - hw, cy - hh + c, cz + hd - c],
             [cx - hw, cy + hh - c, cz + hd - c],
             [cx - hw, cy + hh - c, cz - hd + c])

    # Chamfer edges
    add_quad([cx - hw + c, cy + hh - c, cz + hd], [cx + hw - c, cy + hh - c, cz + hd],
             [cx + hw - c, cy + hh, cz + hd - c], [cx - hw + c, cy + hh, cz + hd - c])
    add_quad([cx - hw + c, cy - hh, cz + hd - c], [cx + hw - c, cy - hh, cz + hd - c],
             [cx + hw - c, cy - hh + c, cz + hd], [cx - hw + c, cy - hh + c, cz + hd])
    add_quad([cx + hw - c, cy + hh - c, cz - hd], [cx - hw + c, cy + hh - c, cz - hd],
             [cx - hw + c, cy + hh, cz - hd + c], [cx + hw - c, cy + hh, cz - hd + c])
    add_quad([cx + hw - c, cy - hh, cz - hd + c], [cx - hw + c, cy - hh, cz - hd + c],
             [cx - hw + c, cy - hh + c, cz - hd], [cx + hw - c, cy - hh + c, cz - hd])
    add_quad([cx + hw - c, cy - hh + c, cz + hd], [cx + hw, cy - hh + c, cz + hd - c],
             [cx + hw, cy + hh - c, cz + hd - c], [cx + hw - c, cy + hh - c, cz + hd])
    add_quad([cx - hw, cy - hh + c, cz + hd - c], [cx - hw + c, cy - hh + c, cz + hd],
             [cx - hw + c, cy + hh - c, cz + hd], [cx - hw, cy + hh - c, cz + hd - c])
    add_quad([cx + hw, cy - hh + c, cz - hd + c], [cx + hw - c, cy - hh + c, cz - hd],
             [cx + hw - c, cy + hh - c, cz - hd], [cx + hw, cy + hh - c, cz - hd + c])
    add_quad([cx - hw - c + c, cy - hh + c, cz - hd], [cx - hw, cy - hh + c, cz - hd + c],
             [cx - hw, cy + hh - c, cz - hd + c], [cx - hw - c + c, cy + hh - c, cz - hd])

    return verts, norms, indices

def create_extrusion(pts2d, z0, z1, caps=True):
    n_pts = len(pts2d)
    verts = []
    norms = []
    indices = []

    for i in range(n_pts):
        next_i = (i + 1) % n_pts
        p0 = pts2d[i]
        p1 = pts2d[next_i]
        dx = p1[0] - p0[0]
        dy = p1[1] - p0[1]
        nx = dy
        ny = -dx
        l = math.hypot(nx, ny)
        if l > 1e-6: nx, ny = nx/l, ny/l
        else: nx, ny = 0, 1

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
        b_front = len(verts)
        for p in pts2d:
            verts.append([p[0], p[1], z1])
            norms.append([0.0, 0.0, 1.0])
        for i in range(1, n_pts - 1):
            indices.extend([b_front, b_front + i, b_front + i + 1])

        b_back = len(verts)
        for p in pts2d:
            verts.append([p[0], p[1], z0])
            norms.append([0.0, 0.0, -1.0])
        for i in range(1, n_pts - 1):
            indices.extend([b_back, b_back + i + 1, b_back + i])

    return verts, norms, indices

def create_spherical_shell_sector(phi_min, phi_max, theta_min, theta_max, r_inner, r_outer, n_phi=8, n_theta=12):
    # Generates a thick curved spherical armor shell sector
    verts = []
    norms = []
    indices = []

    def sphere_pt(r, phi, theta):
        cp = math.cos(phi)
        sp = math.sin(phi)
        ct = math.cos(theta)
        st = math.sin(theta)
        return [r * cp * st, r * sp, r * cp * ct]

    def add_quad(p0, p1, p2, p3):
        n = calc_normal(p0, p1, p2)
        b = len(verts)
        verts.extend([p0, p1, p2, p3])
        norms.extend([n] * 4)
        indices.extend([b, b+1, b+2, b, b+2, b+3])

    phi_steps = np.linspace(phi_min, phi_max, n_phi)
    theta_steps = np.linspace(theta_min, theta_max, n_theta)

    for i in range(n_phi - 1):
        for j in range(n_theta - 1):
            p_a, p_b = phi_steps[i], phi_steps[i+1]
            t_a, t_b = theta_steps[j], theta_steps[j+1]

            # Outer surface
            p0 = sphere_pt(r_outer, p_a, t_a)
            p1 = sphere_pt(r_outer, p_a, t_b)
            p2 = sphere_pt(r_outer, p_b, t_b)
            p3 = sphere_pt(r_outer, p_b, t_a)
            add_quad(p0, p1, p2, p3)

            # Inner surface
            q0 = sphere_pt(r_inner, p_a, t_a)
            q1 = sphere_pt(r_inner, p_a, t_b)
            q2 = sphere_pt(r_inner, p_b, t_b)
            q3 = sphere_pt(r_inner, p_b, t_a)
            add_quad(q1, q0, q3, q2)

    # Edge caps
    # Bottom rim (phi_min)
    p_bot = phi_steps[0]
    for j in range(n_theta - 1):
        t_a, t_b = theta_steps[j], theta_steps[j+1]
        p_in_a = sphere_pt(r_inner, p_bot, t_a)
        p_in_b = sphere_pt(r_inner, p_bot, t_b)
        p_out_a = sphere_pt(r_outer, p_bot, t_a)
        p_out_b = sphere_pt(r_outer, p_bot, t_b)
        add_quad(p_out_a, p_out_b, p_in_b, p_in_a)

    # Top rim (phi_max)
    p_top = phi_steps[-1]
    for j in range(n_theta - 1):
        t_a, t_b = theta_steps[j], theta_steps[j+1]
        p_in_a = sphere_pt(r_inner, p_top, t_a)
        p_in_b = sphere_pt(r_inner, p_top, t_b)
        p_out_a = sphere_pt(r_outer, p_top, t_a)
        p_out_b = sphere_pt(r_outer, p_top, t_b)
        add_quad(p_in_a, p_in_b, p_out_b, p_out_a)

    # Left & Right edges
    for i in range(n_phi - 1):
        p_a, p_b = phi_steps[i], phi_steps[i+1]
        # left (theta_min)
        t_l = theta_steps[0]
        add_quad(sphere_pt(r_inner, p_a, t_l), sphere_pt(r_inner, p_b, t_l),
                 sphere_pt(r_outer, p_b, t_l), sphere_pt(r_outer, p_a, t_l))
        # right (theta_max)
        t_r = theta_steps[-1]
        add_quad(sphere_pt(r_outer, p_a, t_r), sphere_pt(r_outer, p_b, t_r),
                 sphere_pt(r_inner, p_b, t_r), sphere_pt(r_inner, p_a, t_r))

    return verts, norms, indices

def create_faceted_compound_eye(pts_outer, center_z_bulge, z_base):
    # Generates authentic faceted Kamen Rider compound eye polygons
    # Slanted geodesic prism with faceted jewel facets
    verts = []
    norms = []
    indices = []

    # Calculate center 2d
    cx = sum(p[0] for p in pts_outer) / len(pts_outer)
    cy = sum(p[1] for p in pts_outer) / len(pts_outer)
    cz = z_base + center_z_bulge

    p_center = [cx, cy, cz]
    n_pts = len(pts_outer)

    # Base rim vertices
    rim_verts = [[p[0], p[1], z_base] for p in pts_outer]

    # Faceted triangles connecting center apex to rim
    for i in range(n_pts):
        nxt = (i + 1) % n_pts
        p0 = p_center
        p1 = rim_verts[i]
        p2 = rim_verts[nxt]
        n = calc_normal(p0, p1, p2)
        b = len(verts)
        verts.extend([p0, p1, p2])
        norms.extend([n] * 3)
        indices.extend([b, b+1, b+2])

    return verts, norms, indices

# ═════════════════════════════════════════════════════════════════════════════
# Main Model Construction
# ═════════════════════════════════════════════════════════════════════════════

def build_solar_helmet(out_path):
    builder = GLTFBuilder()

    # Materials Palette (Strict Design System & Toon Shader Harmony)
    m_gold = builder.add_material("Mat_Helmet_Gold", [0.96, 0.74, 0.20], roughness=0.28, metallic=0.85)
    m_chassis = builder.add_material("Mat_Helmet_Chassis", [0.12, 0.11, 0.16], roughness=0.45, metallic=0.25)
    m_titanium = builder.add_material("Mat_Helmet_Titanium", [0.35, 0.36, 0.42], roughness=0.32, metallic=0.75)
    # Luminous Kamen Rider Compound Eye Ruby / Crimson
    m_ruby_eye = builder.add_material("Mat_Helmet_RubyEye", [0.96, 0.15, 0.15], roughness=0.15, metallic=0.10, emission_rgb=[0.96, 0.15, 0.15], emission_strength=4.5)
    # Shinto Vermilion Trim / Forehead Gem
    m_crimson = builder.add_material("Mat_Helmet_Crimson", [0.88, 0.12, 0.12], roughness=0.25, metallic=0.30, emission_rgb=[0.88, 0.12, 0.12], emission_strength=3.0)
    # Cyan LED Diode / HUD Rails
    m_cyan = builder.add_material("Mat_Helmet_Cyan", [0.20, 0.92, 1.00], roughness=0.20, metallic=0.10, emission_rgb=[0.20, 0.92, 1.00], emission_strength=4.0)
    # Amber Internal Heat Core
    m_amber = builder.add_material("Mat_Helmet_Amber", [1.00, 0.70, 0.18], roughness=0.22, metallic=0.10, emission_rgb=[1.00, 0.70, 0.18], emission_strength=3.5)

    # ═════════════════════════════════════════════════════════════════════════
    # 1. HELMET CRANIAL SHELL & V-CREST CROWN (Sub-assembly: Helmet_Crest)
    # Encapsulates upper hemisphere (R ≈ 7.85m to 8.25m) and occipital dome
    # ═════════════════════════════════════════════════════════════════════════
    mesh_crown = builder.create_mesh("Mesh_Helmet_Crown")

    # A. Spherical Cranial Dome (Full upper skull shell encapsulating top and back)
    # theta from +45° through 180° to 315° (wrapping sides and back of skull)
    # phi from +15° (temples/occiput) to +82° (crown apex)
    v, n, idx = create_spherical_shell_sector(
        phi_min=math.radians(12.0),
        phi_max=math.radians(82.0),
        theta_min=math.radians(45.0),
        theta_max=math.radians(315.0),
        r_inner=7.82,
        r_outer=8.22,
        n_phi=10,
        n_theta=20
    )
    builder.add_mesh_primitive(mesh_crown, m_chassis, v, n, idx)

    # B. Central Dorsal Spine (Golden keel along crown apex from forehead to back)
    v, n, idx = create_chamfered_box_3d(0.0, 8.05, 0.0, width=1.40, height=1.50, depth=14.50, chamfer=0.20)
    builder.add_mesh_primitive(mesh_crown, m_gold, v, n, idx)

    # C. High-Rising Majestic Kamen Rider V-Crest Horns (Sun-Gold)
    # Left V-Crest Horn (Slanted dramatically up and back)
    horn_pts_left = [
        [-0.45,  6.20],
        [-1.20,  6.00],
        [-5.20, 12.20],
        [-3.80, 12.60],
        [-1.90,  9.50],
        [-0.45,  8.20]
    ]
    v, n, idx = create_extrusion(horn_pts_left, z0=5.20, z1=6.20, caps=True)
    builder.add_mesh_primitive(mesh_crown, m_gold, v, n, idx)

    # Right V-Crest Horn (Mirrored)
    horn_pts_right = [
        [ 0.45,  6.20],
        [ 0.45,  8.20],
        [ 1.90,  9.50],
        [ 3.80, 12.60],
        [ 5.20, 12.20],
        [ 1.20,  6.00]
    ]
    v, n, idx = create_extrusion(horn_pts_right, z0=5.20, z1=6.20, caps=True)
    builder.add_mesh_primitive(mesh_crown, m_gold, v, n, idx)

    # Inner Secondary V-Horns (Sharper front tines with obsidian inlay)
    horn_inner_left = [
        [-0.30,  6.50],
        [-0.85,  6.40],
        [-2.80, 10.40],
        [-1.90, 10.70],
        [-0.30,  7.80]
    ]
    v, n, idx = create_extrusion(horn_inner_left, z0=6.15, z1=6.80, caps=True)
    builder.add_mesh_primitive(mesh_crown, m_chassis, v, n, idx)

    horn_inner_right = [
        [ 0.30,  6.50],
        [ 0.30,  7.80],
        [ 1.90, 10.70],
        [ 2.80, 10.40],
        [ 0.85,  6.40]
    ]
    v, n, idx = create_extrusion(horn_inner_right, z0=6.15, z1=6.80, caps=True)
    builder.add_mesh_primitive(mesh_crown, m_chassis, v, n, idx)

    # D. Central Forehead O-Signal Ruby Diamond Gem
    gem_pts = [
        [ 0.00,  7.60],
        [-0.90,  6.50],
        [ 0.00,  5.40],
        [ 0.90,  6.50]
    ]
    v, n, idx = create_extrusion(gem_pts, z0=5.80, z1=6.90, caps=True)
    builder.add_mesh_primitive(mesh_crown, m_crimson, v, n, idx)

    # Gold Bezel around Forehead Gem
    v, n, idx = create_chamfered_box_3d(0.0, 6.50, 5.75, width=2.40, height=2.60, depth=0.55, chamfer=0.18)
    builder.add_mesh_primitive(mesh_crown, m_gold, v, n, idx)

    # ═════════════════════════════════════════════════════════════════════════
    # 2. THE FACEPLATE: COMPOUND EYE VISORS & CRUSHER MOUTH PLATE
    # (Sub-assembly: Helmet_Faceplate)
    # Completely encapsulates the front eyes and mouth of the Sun!
    # ═════════════════════════════════════════════════════════════════════════
    mesh_face = builder.create_mesh("Mesh_Helmet_Faceplate")

    # A. Forehead Brow Crossbar (Heavy obsidian & gold brow shielding the eyes)
    z_face = 7.35
    v, n, idx = create_chamfered_box_3d(0.0, 3.80, z_face, width=7.80, height=1.30, depth=1.40, chamfer=0.22)
    builder.add_mesh_primitive(mesh_face, m_chassis, v, n, idx)
    v, n, idx = create_chamfered_box_3d(0.0, 4.15, z_face + 0.35, width=8.20, height=0.45, depth=0.90, chamfer=0.10)
    builder.add_mesh_primitive(mesh_face, m_gold, v, n, idx)

    # B. Iconic Kamen Rider Compound Eye Visors ("Ocular Lenses")
    # Faceted jewel compound eyes placed directly over the eyes!
    # Left Compound Eye Visor (X = -0.6 to -4.4, Y = +0.7 to +3.4)
    eye_pts_left = [
        [-0.70,  3.20],
        [-3.60,  3.40],
        [-4.50,  2.20],
        [-4.40,  0.80],
        [-3.20,  0.50],
        [-1.10,  1.70]
    ]
    v, n, idx = create_faceted_compound_eye(eye_pts_left, center_z_bulge=0.85, z_base=z_face - 0.10)
    builder.add_mesh_primitive(mesh_face, m_ruby_eye, v, n, idx)

    # Right Compound Eye Visor (X = +0.7 to +4.4)
    eye_pts_right = [
        [ 0.70,  3.20],
        [ 1.10,  1.70],
        [ 3.20,  0.50],
        [ 4.40,  0.80],
        [ 4.50,  2.20],
        [ 3.60,  3.40]
    ]
    v, n, idx = create_faceted_compound_eye(eye_pts_right, center_z_bulge=0.85, z_base=z_face - 0.10)
    builder.add_mesh_primitive(mesh_face, m_ruby_eye, v, n, idx)

    # Eye Visor Outer Bezel Rims (Sun-Gold framing around each compound eye)
    for sign_x in [-1.0, 1.0]:
        bezel_pts = [
            [sign_x * 0.50, 3.40],
            [sign_x * 3.75, 3.60],
            [sign_x * 4.80, 2.25],
            [sign_x * 4.70, 0.65],
            [sign_x * 3.10, 0.35],
            [sign_x * 0.90, 1.60]
        ]
        if sign_x < 0: bezel_pts = bezel_pts[::-1]
        v, n, idx = create_extrusion(bezel_pts, z0=z_face - 0.25, z1=z_face + 0.30, caps=True)
        builder.add_mesh_primitive(mesh_face, m_gold, v, n, idx)

    # Central Nose Bridge & Keel between eyes
    v, n, idx = create_chamfered_box_3d(0.0, 2.20, z_face + 0.45, width=1.10, height=2.40, depth=0.80, chamfer=0.15)
    builder.add_mesh_primitive(mesh_face, m_chassis, v, n, idx)
    # Glowing Cyan Collimator Pin on Nose Bridge
    v, n, idx = create_chamfered_box_3d(0.0, 2.20, z_face + 0.88, width=0.35, height=1.60, depth=0.25, chamfer=0.06)
    builder.add_mesh_primitive(mesh_face, m_cyan, v, n, idx)

    # C. Kamen Rider Crusher Mouth Plate ("Faceplate & Mandible")
    # Stepped horizontal ventilation grille slats covering mouth!
    crusher_z = z_face + 0.15

    # 4 Horizontal Grille Louver Slats (tiered forward in Z)
    slat_data = [
        # (y_pos, width, height, z_offset)
        ( 0.20, 5.20, 0.42, 0.35),
        (-0.45, 4.60, 0.42, 0.45),
        (-1.10, 4.00, 0.42, 0.52),
        (-1.75, 3.40, 0.42, 0.48),
    ]
    for y_s, w_s, h_s, z_off in slat_data:
        # Titanium Grille Slat
        v, n, idx = create_chamfered_box_3d(0.0, y_s, crusher_z + z_off, width=w_s, height=h_s, depth=0.65, chamfer=0.08)
        builder.add_mesh_primitive(mesh_face, m_titanium, v, n, idx)
        # Dark Obsidian Intake Slot beneath slat
        v, n, idx = create_chamfered_box_3d(0.0, y_s - 0.18, crusher_z + z_off - 0.15, width=w_s - 0.40, height=0.16, depth=0.45, chamfer=0.04)
        builder.add_mesh_primitive(mesh_face, m_chassis, v, n, idx)

    # Angular Chin Keel (Triangular chin guard pointing down toward Driver belt)
    chin_pts = [
        [ 0.00, -3.20],
        [-1.60, -2.10],
        [-1.80, -1.60],
        [ 1.80, -1.60],
        [ 1.60, -2.10]
    ]
    v, n, idx = create_extrusion(chin_pts, z0=crusher_z - 0.10, z1=crusher_z + 0.70, caps=True)
    builder.add_mesh_primitive(mesh_face, m_gold, v, n, idx)

    # Central Chin Spine Accent (Obsidian Shinto Vane)
    v, n, idx = create_chamfered_box_3d(0.0, -2.30, crusher_z + 0.72, width=0.55, height=1.60, depth=0.35, chamfer=0.08)
    builder.add_mesh_primitive(mesh_face, m_chassis, v, n, idx)

    # ═════════════════════════════════════════════════════════════════════════
    # 3. HELMET LATERAL CHEEKS & EAR COWLS (Sub-assembly: Helmet_Cheeks)
    # Aerodynamic lateral guards with circular ear turbines & steam cowls
    # ═════════════════════════════════════════════════════════════════════════
    mesh_cheeks = builder.create_mesh("Mesh_Helmet_Cheeks")

    for sign_x in [-1.0, 1.0]:
        cx = sign_x * 7.10
        # Aerodynamic curved cheek plate
        v, n, idx = create_chamfered_box_3d(cx, 0.80, 4.80, width=1.60, height=5.20, depth=4.50, chamfer=0.32)
        builder.add_mesh_primitive(mesh_cheeks, m_chassis, v, n, idx)

        # Sun-Gold Cheek Frame Chevron
        v, n, idx = create_chamfered_box_3d(sign_x * 7.60, 0.80, 5.10, width=0.60, height=5.40, depth=3.80, chamfer=0.18)
        builder.add_mesh_primitive(mesh_cheeks, m_gold, v, n, idx)

        # Circular Ear Receptor Disc (Classic Tokusatsu audio turbine)
        v, n, idx = create_chamfered_box_3d(sign_x * 7.75, 1.20, 2.60, width=0.45, height=2.40, depth=2.40, chamfer=0.45)
        builder.add_mesh_primitive(mesh_cheeks, m_titanium, v, n, idx)
        # Inner Glowing Amber Turbine Core
        v, n, idx = create_chamfered_box_3d(sign_x * 7.82, 1.20, 2.60, width=0.35, height=1.50, depth=1.50, chamfer=0.30)
        builder.add_mesh_primitive(mesh_cheeks, m_amber, v, n, idx)

        # Dual Steam Exhaust Cowls (Top and bottom cylinders)
        for c_y in [-0.20, 2.40]:
            v, n, idx = create_chamfered_box_3d(sign_x * 7.20, c_y, 2.20, width=1.20, height=0.90, depth=1.60, chamfer=0.18)
            builder.add_mesh_primitive(mesh_cheeks, m_titanium, v, n, idx)
            # Glowing heat aperture
            v, n, idx = create_chamfered_box_3d(sign_x * 7.20, c_y, 1.35, width=0.80, height=0.60, depth=0.40, chamfer=0.10)
            builder.add_mesh_primitive(mesh_cheeks, m_amber, v, n, idx)

        # Lower Jaw Clamping Mandibles (Connecting cheek down toward Driver belt)
        v, n, idx = create_chamfered_box_3d(sign_x * 5.80, -2.40, 5.40, width=1.10, height=2.60, depth=1.50, chamfer=0.22)
        builder.add_mesh_primitive(mesh_cheeks, m_gold, v, n, idx)

    # ═════════════════════════════════════════════════════════════════════════
    # Build Node Hierarchy
    # ═════════════════════════════════════════════════════════════════════════
    n_crest = builder.add_node("Helmet_Crest", mesh_idx=mesh_crown)
    n_face = builder.add_node("Helmet_Faceplate", mesh_idx=mesh_face)
    n_cheeks = builder.add_node("Helmet_Cheeks", mesh_idx=mesh_cheeks)

    builder.add_node("SolarHelmetRoot", children=[n_crest, n_face, n_cheeks])

    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    builder.build_glb(out_path)
    print(f"[OK] Successfully built Kamen Rider Apex Helmet: {out_path} ({os.path.getsize(out_path)} bytes)")

if __name__ == "__main__":
    out_file = os.path.abspath("assets/models/solar_helmet.glb")
    build_solar_helmet(out_file)
