#!/usr/bin/env python3
"""
build_solar_eye_drone.py - Generates an authentic, high-detail, low-poly
Solar Eye Drone ("Helios Drone / Audience Glare") 3D model in GLB format.

Design Language:
- Retro PS1/Arcade Tokusatsu aesthetic matching Summer Nights and Kitsune Buster IX.
- Octagonal cyber-gold armored chassis with beveled panel lines and cardinal verniers.
- Sweeping audience-glare eyebrow wing crests with Shinto crimson inlays.
- Multi-tier internal gimbal spherical core with dark obsidian gunmetal plating.
- Stepped focusing aperture with interlocking steel iris blades.
- Deep, radiant convex solar pupil lens with incandescent amber-crimson bloom.
- Rear coronal heatsink radiator fins and micro-thruster nozzle.
- Forward sightline aligned to -Z (standard Godot forward direction).
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
    start_ccw = ensure_ccw(pts_start_2d)
    end_ccw = ensure_ccw(pts_end_2d)
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
        if length > 1e-6:
            n /= length
        else:
            n = np.array([0.0, 0.0, 1.0], dtype=np.float32)
            
        base = len(verts)
        verts.extend([p0_start.tolist(), p1_start.tolist(), p1_end.tolist(), p0_end.tolist()])
        normals.extend([n.tolist()] * 4)
        indices.extend([base, base + 1, base + 2, base, base + 2, base + 3])
        
    if caps and n_pts >= 3:
        pts_end_arr = np.array(end_ccw, dtype=np.float32)
        c_front = len(verts)
        center_front = [float(np.mean(pts_end_arr[:, 0])), float(np.mean(pts_end_arr[:, 1])), z1]
        verts.append(center_front)
        normals.append([0.0, 0.0, 1.0])
        for p in end_ccw:
            verts.append([p[0], p[1], z1])
            normals.append([0.0, 0.0, 1.0])
        for i in range(n_pts):
            indices.extend([c_front, c_front + 1 + i, c_front + 1 + ((i + 1) % n_pts)])
            
        pts_start_arr = np.array(start_ccw, dtype=np.float32)
        c_back = len(verts)
        center_back = [float(np.mean(pts_start_arr[:, 0])), float(np.mean(pts_start_arr[:, 1])), z0]
        verts.append(center_back)
        normals.append([0.0, 0.0, -1.0])
        for p in start_ccw:
            verts.append([p[0], p[1], z0])
            normals.append([0.0, 0.0, -1.0])
        for i in range(n_pts):
            indices.extend([c_back, c_back + 1 + ((i + 1) % n_pts), c_back + 1 + i])
            
    return verts, normals, indices

def create_chamfered_box(cx, cy, width, height, z0, z1, chamfer=0.03):
    w2 = width * 0.5
    h2 = height * 0.5
    c = min(chamfer, w2 * 0.4, h2 * 0.4)
    pts = [
        [cx - w2 + c, cy - h2],
        [cx + w2 - c, cy - h2],
        [cx + w2, cy - h2 + c],
        [cx + w2, cy + h2 - c],
        [cx + w2 - c, cy + h2],
        [cx - w2 + c, cy + h2],
        [cx - w2, cy + h2 - c],
        [cx - w2, cy - h2 + c]
    ]
    return create_extrusion(pts, z0, z1, caps=True)

def create_cylinder(cx, cy, z0, z1, radius, sides=16, caps=True):
    pts = []
    for i in range(sides):
        ang = (i / float(sides)) * math.tau
        pts.append([cx + math.cos(ang) * radius, cy + math.sin(ang) * radius])
    return create_extrusion(pts, z0, z1, caps=caps)

def create_tapered_cylinder(cx, cy, z0, z1, r0, r1, sides=16, caps=True):
    pts0 = []
    pts1 = []
    for i in range(sides):
        ang = (i / float(sides)) * math.tau
        pts0.append([cx + math.cos(ang) * r0, cy + math.sin(ang) * r0])
        pts1.append([cx + math.cos(ang) * r1, cy + math.sin(ang) * r1])
    return create_tapered_extrusion(pts0, pts1, z0, z1, caps=caps)

def create_ring_octagonal(cx, cy, z0, z1, r_in, r_out, sides=16):
    """Creates a hollow octagonal/polygonal armor ring."""
    verts = []
    normals = []
    indices = []
    
    angles = [(i / float(sides)) * math.tau for i in range(sides)]
    
    # Outer cylinder wall
    v_out, n_out, i_out = create_cylinder(cx, cy, z0, z1, r_out, sides=sides, caps=False)
    verts.extend(v_out)
    normals.extend(n_out)
    indices.extend(i_out)
    
    # Inner cylinder wall (reversed normals for interior)
    base_in = len(verts)
    for i in range(sides):
        next_i = (i + 1) % sides
        a0 = angles[i]
        a1 = angles[next_i]
        p0 = [cx + math.cos(a0) * r_in, cy + math.sin(a0) * r_in]
        p1 = [cx + math.cos(a1) * r_in, cy + math.sin(a1) * r_in]
        
        # Inward facing normals
        nx0 = -math.cos(a0)
        ny0 = -math.sin(a0)
        nx1 = -math.cos(a1)
        ny1 = -math.sin(a1)
        
        idx = len(verts)
        verts.extend([
            [p0[0], p0[1], z0],
            [p1[0], p1[1], z0],
            [p1[0], p1[1], z1],
            [p0[0], p0[1], z1]
        ])
        normals.extend([[nx0, ny0, 0.0], [nx1, ny1, 0.0], [nx1, ny1, 0.0], [nx0, ny0, 0.0]])
        indices.extend([idx, idx + 2, idx + 1, idx, idx + 3, idx + 2])
        
    # Front and back end caps (connecting r_in to r_out)
    for z_pos, norm_z in [(z1, 1.0), (z0, -1.0)]:
        base_cap = len(verts)
        for i in range(sides):
            a = angles[i]
            ca = math.cos(a)
            sa = math.sin(a)
            verts.append([cx + ca * r_out, cy + sa * r_out, z_pos])
            normals.append([0.0, 0.0, norm_z])
            verts.append([cx + ca * r_in, cy + sa * r_in, z_pos])
            normals.append([0.0, 0.0, norm_z])
            
        for i in range(sides):
            next_i = (i + 1) % sides
            o0 = base_cap + i * 2
            i0 = base_cap + i * 2 + 1
            o1 = base_cap + next_i * 2
            i1 = base_cap + next_i * 2 + 1
            if norm_z > 0:
                indices.extend([o0, o1, i1, o0, i1, i0])
            else:
                indices.extend([o0, i1, o1, o0, i0, i1])
                
    return verts, normals, indices

def create_convex_lens_dome(cx, cy, z_base, z_tip, radius, rings=6, sides=16):
    """Creates a high-precision convex ocular lens dome."""
    verts = []
    normals = []
    indices = []
    
    # Vertex at tip
    verts.append([cx, cy, z_tip])
    normals.append([0.0, 0.0, -1.0 if z_tip < z_base else 1.0])
    
    for r in range(1, rings + 1):
        frac = r / float(rings)
        # Spherical dome profile
        theta = frac * (math.pi * 0.5)
        rad = radius * math.sin(theta)
        z = z_tip + (z_base - z_tip) * (1.0 - math.cos(theta))
        
        for s in range(sides):
            ang = (s / float(sides)) * math.tau
            ca = math.cos(ang)
            sa = math.sin(ang)
            vx = cx + ca * rad
            vy = cy + sa * rad
            
            # Normal calculation for spherical surface
            nx = ca * math.sin(theta)
            ny = sa * math.sin(theta)
            nz = -math.cos(theta) if z_tip < z_base else math.cos(theta)
            
            verts.append([vx, vy, z])
            normals.append([nx, ny, nz])
            
    # Triangles from tip to first ring
    for s in range(sides):
        next_s = (s + 1) % sides
        indices.extend([0, 1 + next_s, 1 + s])
        
    # Quad strips between rings
    for r in range(rings - 1):
        r0 = 1 + r * sides
        r1 = 1 + (r + 1) * sides
        for s in range(sides):
            next_s = (s + 1) % sides
            indices.extend([
                r0 + s, r0 + next_s, r1 + next_s,
                r0 + s, r1 + next_s, r1 + s
            ])
            
    return verts, normals, indices

# ─────────────────────────────────────────────────────────────────────────────
# GLB Binary Builder
# ─────────────────────────────────────────────────────────────────────────────
class GLBBuilder:
    def __init__(self):
        self.bin_data = bytearray()
        self.buffer_views = []
        self.accessors = []
        self.materials = []
        self.meshes = []
        self.nodes = []

    def add_material(self, name, base_color, metallic=0.5, roughness=0.5, emissive_rgb=None, alpha_mode="OPAQUE"):
        mat_idx = len(self.materials)
        mat = {
            "name": name,
            "pbrMetallicRoughness": {
                "baseColorFactor": base_color,
                "metallicFactor": metallic,
                "roughnessFactor": roughness
            },
            "alphaMode": alpha_mode,
            "doubleSided": True
        }
        if emissive_rgb is not None:
            mat["emissiveFactor"] = emissive_rgb
            mat["extensions"] = {
                "KHR_materials_emissive_strength": {
                    "emissiveStrength": 2.5
                }
            }
        self.materials.append(mat)
        return mat_idx

    def _add_buffer_view(self, data, target=None):
        offset = len(self.bin_data)
        self.bin_data.extend(data)
        pad = (4 - (len(self.bin_data) % 4)) % 4
        self.bin_data.extend(b'\x00' * pad)
        
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

    def _add_accessor(self, bv_idx, count, component_type, acc_type, min_val=None, max_val=None):
        acc_idx = len(self.accessors)
        acc = {
            "bufferView": bv_idx,
            "byteOffset": 0,
            "componentType": component_type,
            "count": count,
            "type": acc_type
        }
        if min_val is not None: acc["min"] = min_val
        if max_val is not None: acc["max"] = max_val
        self.accessors.append(acc)
        return acc_idx

    def create_mesh(self, name):
        mesh_idx = len(self.meshes)
        self.meshes.append({
            "name": name,
            "primitives": []
        })
        return mesh_idx

    def add_mesh_primitive(self, mesh_idx, material_idx, verts, normals, indices):
        if len(verts) == 0 or len(indices) == 0:
            return
            
        v_np = np.array(verts, dtype=np.float32)
        n_np = np.array(normals, dtype=np.float32)
        i_np = np.array(indices, dtype=np.uint16)
        
        bv_v = self._add_buffer_view(v_np.tobytes(), target=34962)
        bv_n = self._add_buffer_view(n_np.tobytes(), target=34962)
        bv_i = self._add_buffer_view(i_np.tobytes(), target=34963)
        
        acc_v = self._add_accessor(bv_v, len(verts), 5126, "VEC3", min_val=v_np.min(axis=0).tolist(), max_val=v_np.max(axis=0).tolist())
        acc_n = self._add_accessor(bv_n, len(normals), 5126, "VEC3")
        acc_i = self._add_accessor(bv_i, len(indices), 5123, "SCALAR")
        
        self.meshes[mesh_idx]["primitives"].append({
            "attributes": {
                "POSITION": acc_v,
                "NORMAL": acc_n
            },
            "indices": acc_i,
            "material": material_idx
        })

    def add_node(self, name, mesh_idx=None, children=None, translation=None, rotation=None, scale=None):
        node_idx = len(self.nodes)
        node = {"name": name}
        if mesh_idx is not None: node["mesh"] = mesh_idx
        if children is not None: node["children"] = children
        if translation is not None: node["translation"] = translation
        if rotation is not None: node["rotation"] = rotation
        if scale is not None: node["scale"] = scale
        self.nodes.append(node)
        return node_idx

    def export(self, filepath):
        gltf = {
            "asset": {"version": "2.0", "generator": "SummerNights Solar Drone Synthesizer"},
            "scene": 0,
            "scenes": [{"name": "DefaultScene", "nodes": [len(self.nodes) - 1]}],
            "nodes": self.nodes,
            "meshes": self.meshes,
            "materials": self.materials,
            "accessors": self.accessors,
            "bufferViews": self.buffer_views,
            "buffers": [{"byteLength": len(self.bin_data)}],
            "extensionsUsed": ["KHR_materials_emissive_strength"]
        }
        
        json_str = json.dumps(gltf, separators=(',', ':'))
        json_bytes = json_str.encode('utf-8')
        pad_json = (4 - (len(json_bytes) % 4)) % 4
        json_bytes += b' ' * pad_json
        
        total_len = 12 + 8 + len(json_bytes) + 8 + len(self.bin_data)
        
        with open(filepath, 'wb') as f:
            f.write(b'glTF')
            f.write(struct.pack('<I', 2))
            f.write(struct.pack('<I', total_len))
            
            f.write(struct.pack('<I', len(json_bytes)))
            f.write(b'JSON')
            f.write(json_bytes)
            
            f.write(struct.pack('<I', len(self.bin_data)))
            f.write(b'BIN\x00')
            f.write(self.bin_data)
            
        print(f"Exported clean GLB: {filepath} ({total_len} bytes)")

# ─────────────────────────────────────────────────────────────────────────────
# Procedural Model Assembly
# ─────────────────────────────────────────────────────────────────────────────
def build_solar_eye_drone_model(output_path):
    builder = GLBBuilder()

    # Materials
    m_gold    = builder.add_material("Mat_CyberGold", [0.98, 0.78, 0.16, 1.0], metallic=0.85, roughness=0.18)
    m_dark    = builder.add_material("Mat_DarkCharcoal", [0.10, 0.11, 0.14, 1.0], metallic=0.75, roughness=0.25)
    m_crimson = builder.add_material("Mat_Crimson", [0.88, 0.10, 0.16, 1.0], metallic=0.25, roughness=0.20)
    m_steel   = builder.add_material("Mat_KatanaSteel", [0.86, 0.88, 0.92, 1.0], metallic=0.92, roughness=0.15)
    m_solar   = builder.add_material("Mat_SolarCore", [1.0, 0.42, 0.08, 1.0], metallic=0.10, roughness=0.08, emissive_rgb=[1.0, 0.45, 0.10])
    m_cyan    = builder.add_material("Mat_CyanEnergy", [0.22, 0.92, 1.0, 1.0], metallic=0.15, roughness=0.10, emissive_rgb=[0.8, 1.5, 1.8])
    m_glass   = builder.add_material("Mat_LensGlass", [0.95, 0.80, 0.25, 0.35], metallic=0.10, roughness=0.05, alpha_mode="BLEND")

    mesh_body = builder.create_mesh("Mesh_SolarEyeDrone")

    # 1. Outer Faceted Octagonal Armor Ring (Cyber-Gold)
    # Forward face is at -Z, rear at +Z
    v, n, idx = create_ring_octagonal(0.0, 0.0, z0=-0.14, z1=0.14, r_in=0.48, r_out=0.68, sides=16)
    builder.add_mesh_primitive(mesh_body, m_gold, v, n, idx)

    # Chamfered Front Bezel Lip on Outer Ring
    v, n, idx = create_tapered_cylinder(0.0, 0.0, z0=-0.14, z1=-0.19, r0=0.68, r1=0.63, sides=16, caps=False)
    builder.add_mesh_primitive(mesh_body, m_gold, v, n, idx)

    # 2. Four Cardinal Vernier Thruster Blocks (Top, Bottom, Left, Right)
    vernier_positions = [
        (0.0, 0.72, 0.0),   # Top
        (0.0, -0.72, 0.0),  # Bottom
        (-0.72, 0.0, 0.0),  # Left
        (0.72, 0.0, 0.0)    # Right
    ]
    for vx, vy, vz in vernier_positions:
        # Mounting block
        v, n, idx = create_chamfered_box(vx, vy, width=0.18, height=0.14, z0=-0.12, z1=0.12, chamfer=0.03)
        builder.add_mesh_primitive(mesh_body, m_dark, v, n, idx)
        # Micro exhaust nozzle
        v, n, idx = create_cylinder(vx, vy, z0=0.12, z1=0.17, radius=0.05, sides=12)
        builder.add_mesh_primitive(mesh_body, m_steel, v, n, idx)
        # Emissive cyan sensor slit on front
        v, n, idx = create_chamfered_box(vx, vy, width=0.12, height=0.04, z0=-0.13, z1=-0.11, chamfer=0.01)
        builder.add_mesh_primitive(mesh_body, m_cyan, v, n, idx)

    # 3. Audience Glare Eyebrow Wings (Sweeping Falcon Horns)
    # Sweeping back and outward from top corners
    for sign_x in [-1.0, 1.0]:
        wing_base_x = sign_x * 0.45
        wing_tip_x  = sign_x * 0.88
        
        # Outer Gold Fin Blade
        fin_pts = [
            [wing_base_x, 0.35],
            [wing_base_x + sign_x * 0.12, 0.65],
            [wing_tip_x, 0.88],
            [wing_tip_x - sign_x * 0.15, 0.60],
            [wing_base_x - sign_x * 0.05, 0.28]
        ]
        v, n, idx = create_extrusion(fin_pts, z0=-0.08, z1=0.08, caps=True)
        builder.add_mesh_primitive(mesh_body, m_gold, v, n, idx)

        # Shinto Crimson Accent Inlay Ridge
        inlay_pts = [
            [wing_base_x + sign_x * 0.04, 0.40],
            [wing_base_x + sign_x * 0.10, 0.62],
            [wing_tip_x - sign_x * 0.06, 0.82],
            [wing_tip_x - sign_x * 0.16, 0.64],
            [wing_base_x - sign_x * 0.01, 0.35]
        ]
        v, n, idx = create_extrusion(inlay_pts, z0=-0.09, z1=-0.06, caps=True)
        builder.add_mesh_primitive(mesh_body, m_crimson, v, n, idx)

        # Lower Aerodynamic Stabilizer Quill (Cheek Armor)
        lower_pts = [
            [sign_x * 0.52, -0.22],
            [sign_x * 0.74, -0.48],
            [sign_x * 0.62, -0.56],
            [sign_x * 0.44, -0.34]
        ]
        v, n, idx = create_extrusion(lower_pts, z0=-0.06, z1=0.06, caps=True)
        builder.add_mesh_primitive(mesh_body, m_gold, v, n, idx)

    # 4. Internal Gimbal Eyeball Housing (Dark Obsidian Gunmetal)
    # A faceted spherical sphere nestled in the center
    v, n, idx = create_convex_lens_dome(0.0, 0.0, z_base=0.16, z_tip=-0.22, radius=0.45, rings=6, sides=16)
    builder.add_mesh_primitive(mesh_body, m_dark, v, n, idx)
    v, n, idx = create_convex_lens_dome(0.0, 0.0, z_base=0.16, z_tip=0.28, radius=0.45, rings=6, sides=16)
    builder.add_mesh_primitive(mesh_body, m_dark, v, n, idx)

    # Side Gimbal Pivot Bolts
    for sign_x in [-1.0, 1.0]:
        v, n, idx = create_cylinder(sign_x * 0.44, 0.0, z0=-0.04, z1=0.04, radius=0.08, sides=12)
        builder.add_mesh_primitive(mesh_body, m_steel, v, n, idx)

    # 5. Stepped Concentric Ocular Aperture Rings (Front -Z)
    v, n, idx = create_tapered_cylinder(0.0, 0.0, z0=-0.20, z1=-0.28, r0=0.38, r1=0.32, sides=16, caps=False)
    builder.add_mesh_primitive(mesh_body, m_gold, v, n, idx)

    # Mechanical Steel Iris Shutter Blades (8 interlocking blades)
    for i in range(8):
        ang = (i / 8.0) * math.tau
        blade_pts = [
            [math.cos(ang) * 0.31, math.sin(ang) * 0.31],
            [math.cos(ang + 0.35) * 0.31, math.sin(ang + 0.35) * 0.31],
            [math.cos(ang + 0.65) * 0.22, math.sin(ang + 0.65) * 0.22],
            [math.cos(ang + 0.15) * 0.18, math.sin(ang + 0.15) * 0.18]
        ]
        v, n, idx = create_extrusion(blade_pts, z0=-0.27, z1=-0.29, caps=True)
        builder.add_mesh_primitive(mesh_body, m_steel, v, n, idx)

    # 6. Radiant Central Solar Pupil Lens (Emissive Amber-Crimson Core)
    # Convex lens protruding through the aperture
    v, n, idx = create_convex_lens_dome(0.0, 0.0, z_base=-0.26, z_tip=-0.36, radius=0.20, rings=6, sides=16)
    builder.add_mesh_primitive(mesh_body, m_solar, v, n, idx)

    # Central Pinhole Reticle Core (Dark charcoal target)
    v, n, idx = create_cylinder(0.0, 0.0, z0=-0.37, z1=-0.35, radius=0.045, sides=12)
    builder.add_mesh_primitive(mesh_body, m_dark, v, n, idx)

    # Protective Translucent Optical Dome Cap
    v, n, idx = create_convex_lens_dome(0.0, 0.0, z_base=-0.24, z_tip=-0.39, radius=0.23, rings=6, sides=16)
    builder.add_mesh_primitive(mesh_body, m_glass, v, n, idx)

    # 7. Rear Propulsion Core & Radiator Fins (+Z rear face)
    # Rear exhaust bell
    v, n, idx = create_tapered_cylinder(0.0, 0.0, z0=0.18, z1=0.34, r0=0.30, r1=0.18, sides=16, caps=False)
    builder.add_mesh_primitive(mesh_body, m_dark, v, n, idx)

    # Central Plasma Exhaust Core
    v, n, idx = create_cylinder(0.0, 0.0, z0=0.32, z1=0.35, radius=0.14, sides=16)
    builder.add_mesh_primitive(mesh_body, m_solar, v, n, idx)

    # 6 Radial Heat Radiator Grilles
    for i in range(6):
        ang = (i / 6.0) * math.tau
        fin_pts = [
            [math.cos(ang) * 0.16, math.sin(ang) * 0.16],
            [math.cos(ang) * 0.36, math.sin(ang) * 0.36],
            [math.cos(ang) * 0.32, math.sin(ang) * 0.32],
            [math.cos(ang) * 0.14, math.sin(ang) * 0.14]
        ]
        v, n, idx = create_extrusion(fin_pts, z0=0.18, z1=0.32, caps=True)
        builder.add_mesh_primitive(mesh_body, m_steel, v, n, idx)

    # Build Scene Node
    node_body = builder.add_node("SolarEyeDrone", mesh_idx=mesh_body)
    builder.add_node("RootNode", children=[node_body])

    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
    builder.export(output_path)

if __name__ == "__main__":
    out_file = os.path.join(os.path.dirname(os.path.dirname(__file__)), "assets", "models", "solar_eye_drone.glb")
    build_solar_eye_drone_model(out_file)
