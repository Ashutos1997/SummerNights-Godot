#!/usr/bin/env python3
"""
build_solar_eye_drone.py - Generates an authentic, high-detail, low-poly
Solar Eye Drone ("Helios Drone / Audience Glare") 3D model in GLB format.

Upgraded Enhancements:
- 8 Segmented Armor Plates with recessed expansion joints and glowing cyan conduits.
- Tiered Falcon Wing Plumes (Triple Swept Feathers) with Shinto crimson inlays and cyan plasma vents.
- Aggressive Lower Cybernetic Predator Mandibles ("Sun-Fangs") framing the lower eye.
- 8-Point Omni-Directional Vernier Thruster System (4 Cardinal + 4 Diagonal Pods).
- 4 Inward-Facing Laser Collimator Needle Pins at 45° diagonal corners.
- Multi-tier Concentric Iris Reticle with Core Focal Lens and Protective Optical Glass.
- Rear High-Output Propulsion Vectoring Bell with 8 Radial Radiator Cooling Fins.
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

def create_convex_lens_dome(cx, cy, z_base, z_tip, radius, rings=6, sides=16):
    verts = []
    normals = []
    indices = []
    
    verts.append([cx, cy, z_tip])
    normals.append([0.0, 0.0, -1.0 if z_tip < z_base else 1.0])
    
    for r in range(1, rings + 1):
        frac = r / float(rings)
        theta = frac * (math.pi * 0.5)
        rad = radius * math.sin(theta)
        z = z_tip + (z_base - z_tip) * (1.0 - math.cos(theta))
        
        for s in range(sides):
            ang = (s / float(sides)) * math.tau
            ca = math.cos(ang)
            sa = math.sin(ang)
            vx = cx + ca * rad
            vy = cy + sa * rad
            
            nx = ca * math.sin(theta)
            ny = sa * math.sin(theta)
            nz = -math.cos(theta) if z_tip < z_base else math.cos(theta)
            
            verts.append([vx, vy, z])
            normals.append([nx, ny, nz])
            
    for s in range(sides):
        next_s = (s + 1) % sides
        indices.extend([0, 1 + next_s, 1 + s])
        
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
            mat["emissiveFactor"] = emissive_rgb[:3]
        self.materials.append(mat)
        return mat_idx

    def _add_buffer_view(self, data, target=None):
        bv_idx = len(self.buffer_views)
        offset = len(self.bin_data)
        self.bin_data.extend(data)
        pad = (4 - (len(self.bin_data) % 4)) % 4
        self.bin_data.extend(b'\x00' * pad)
        
        bv = {
            "buffer": 0,
            "byteOffset": offset,
            "byteLength": len(data)
        }
        if target is not None:
            bv["target"] = target
        self.buffer_views.append(bv)
        return bv_idx

    def _add_accessor(self, buffer_view_idx, count, component_type, acc_type, min_val=None, max_val=None):
        acc_idx = len(self.accessors)
        acc = {
            "bufferView": buffer_view_idx,
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
            "asset": {"version": "2.0", "generator": "SummerNights Enhanced Solar Drone Synthesizer"},
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

    # Materials — Stylized Summer Nights Anime/Arcade Palette
    # Radiant Sunflower Cyber-Gold (Low metallic preserves vibrant diffuse albedo in backlighting)
    m_gold    = builder.add_material("Mat_CyberGold", [1.0, 0.86, 0.22, 1.0], metallic=0.12, roughness=0.28)
    # Solar Pearl Ivory (Crisp hero contrast matching the Kitsune Buster and cartoon clouds)
    m_pearl   = builder.add_material("Mat_SolarPearl", [0.97, 0.96, 0.93, 1.0], metallic=0.06, roughness=0.32)
    # Warm Terracotta Bronze / Slate (Warm mechanical depth without turning into pitch black void)
    m_chassis = builder.add_material("Mat_DarkChassis", [0.38, 0.30, 0.28, 1.0], metallic=0.20, roughness=0.38)
    # Vibrant Shinto Torii / Solar Flare Vermilion (Bright saturated red/orange)
    m_crimson = builder.add_material("Mat_Crimson", [0.98, 0.20, 0.12, 1.0], metallic=0.08, roughness=0.22)
    # Polished Silver-White Katana Steel
    m_steel   = builder.add_material("Mat_KatanaSteel", [0.92, 0.94, 0.98, 1.0], metallic=0.25, roughness=0.20)
    # Incandescent Solar Eye Iris (Supercharged warm bloom core)
    m_solar   = builder.add_material("Mat_SolarCore", [1.0, 0.88, 0.35, 1.0], metallic=0.08, roughness=0.06, emissive_rgb=[3.5, 2.2, 0.5])
    # Menacing Concentric Solar Pupil (Blazing focal point)
    m_pupil   = builder.add_material("Mat_SolarPupil", [1.0, 0.18, 0.05, 1.0], metallic=0.05, roughness=0.05, emissive_rgb=[4.5, 1.0, 0.2])
    # Hyper-Luminous Cyan Plasma (Vernier thrusters, wing exhaust & conduits)
    m_cyan    = builder.add_material("Mat_CyanEnergy", [0.18, 0.92, 1.0, 1.0], metallic=0.10, roughness=0.10, emissive_rgb=[1.5, 3.8, 5.0])

    mesh_body = builder.create_mesh("Mesh_SolarEyeDrone")

    # 1. Inner Obsidian Chassis Ring
    v, n, idx = create_tapered_cylinder(0.0, 0.0, z0=-0.14, z1=0.14, r0=0.48, r1=0.52, sides=16, caps=False)
    builder.add_mesh_primitive(mesh_body, m_chassis, v, n, idx)

    # 2. Eight Segmented Beveled Cyber-Gold & Pearl Armor Plates (with recessed expansion joints)
    # Alternating Cardinal (Gold) and Diagonal (Pearl Ivory) for distinct anime/arcade mecha styling
    gap_rad = 0.065
    for i in range(8):
        ang_mid = (i / 8.0) * math.tau
        a0 = ang_mid - (math.pi / 8.0) + gap_rad
        a1 = ang_mid + (math.pi / 8.0) - gap_rad
        
        # Plate 2D polygon with beveled outer corners
        r_in = 0.49
        r_out = 0.70
        pts_plate = [
            [math.cos(a0) * r_in, math.sin(a0) * r_in],
            [math.cos(a0) * r_out, math.sin(a0) * r_out],
            [math.cos(ang_mid) * (r_out + 0.03), math.sin(ang_mid) * (r_out + 0.03)],
            [math.cos(a1) * r_out, math.sin(a1) * r_out],
            [math.cos(a1) * r_in, math.sin(a1) * r_in]
        ]
        v, n, idx = create_extrusion(pts_plate, z0=-0.14, z1=0.14, caps=True)
        plate_mat = m_gold if (i % 2 == 0) else m_pearl
        builder.add_mesh_primitive(mesh_body, plate_mat, v, n, idx)

        # Recessed thermal expansion joint with glowing cyan conduit pill
        joint_ang = ang_mid + (math.pi / 8.0)
        jx = math.cos(joint_ang) * 0.61
        jy = math.sin(joint_ang) * 0.61
        v, n, idx = create_cylinder(jx, jy, z0=-0.145, z1=-0.11, radius=0.024, sides=8)
        builder.add_mesh_primitive(mesh_body, m_cyan, v, n, idx)

    # Chamfered Front Bezel Lip on Armor Ring
    v, n, idx = create_tapered_cylinder(0.0, 0.0, z0=-0.14, z1=-0.21, r0=0.69, r1=0.63, sides=16, caps=False)
    builder.add_mesh_primitive(mesh_body, m_gold, v, n, idx)

    # 3. Eight-Point Omni-Directional Vernier System (4 Cardinal + 4 Diagonal)
    # Cardinal Verniers (Heavy Duty)
    cardinal_pos = [(0.0, 0.76, 0.0), (0.0, -0.76, 0.0), (-0.76, 0.0, 0.0), (0.76, 0.0, 0.0)]
    for vx, vy, vz in cardinal_pos:
        v, n, idx = create_chamfered_box(vx, vy, width=0.19, height=0.15, z0=-0.12, z1=0.12, chamfer=0.03)
        builder.add_mesh_primitive(mesh_body, m_chassis, v, n, idx)
        v, n, idx = create_cylinder(vx, vy, z0=0.12, z1=0.18, radius=0.055, sides=12)
        builder.add_mesh_primitive(mesh_body, m_steel, v, n, idx)
        v, n, idx = create_chamfered_box(vx, vy, width=0.13, height=0.045, z0=-0.13, z1=-0.11, chamfer=0.01)
        builder.add_mesh_primitive(mesh_body, m_cyan, v, n, idx)

    # Diagonal Auxiliary Micro-Verniers (Agility Roll Pods)
    diag_dist = 0.71
    diag_pos = [
        (-diag_dist * 0.707, diag_dist * 0.707),
        (diag_dist * 0.707, diag_dist * 0.707),
        (-diag_dist * 0.707, -diag_dist * 0.707),
        (diag_dist * 0.707, -diag_dist * 0.707)
    ]
    for dx, dy in diag_pos:
        v, n, idx = create_cylinder(dx, dy, z0=-0.10, z1=0.10, radius=0.05, sides=8)
        builder.add_mesh_primitive(mesh_body, m_chassis, v, n, idx)
        v, n, idx = create_cylinder(dx, dy, z0=0.10, z1=0.15, radius=0.035, sides=8)
        builder.add_mesh_primitive(mesh_body, m_cyan, v, n, idx)

    # 4. Tiered Falcon Wing Plumes (Triple Swept Feathers per side)
    for sign_x in [-1.0, 1.0]:
        # --- Feather 1: Upper Primary Glare Blade (Longest, most aggressive) ---
        f1_base_x = sign_x * 0.44
        f1_tip_x  = sign_x * 0.98
        f1_pts = [
            [f1_base_x, 0.36],
            [f1_base_x + sign_x * 0.14, 0.70],
            [f1_tip_x, 0.96],
            [f1_tip_x - sign_x * 0.16, 0.68],
            [f1_base_x - sign_x * 0.04, 0.30]
        ]
        v, n, idx = create_extrusion(f1_pts, z0=-0.08, z1=0.08, caps=True)
        builder.add_mesh_primitive(mesh_body, m_gold, v, n, idx)

        # Crimson Inlay Ridge on Primary Blade
        f1_inlay = [
            [f1_base_x + sign_x * 0.05, 0.42],
            [f1_base_x + sign_x * 0.12, 0.67],
            [f1_tip_x - sign_x * 0.07, 0.90],
            [f1_tip_x - sign_x * 0.18, 0.70],
            [f1_base_x + sign_x * 0.01, 0.36]
        ]
        v, n, idx = create_extrusion(f1_inlay, z0=-0.09, z1=-0.05, caps=True)
        builder.add_mesh_primitive(mesh_body, m_crimson, v, n, idx)

        # Cyan Plasma Vent Line on Trailing Edge
        f1_vent = [
            [f1_tip_x - sign_x * 0.09, 0.88],
            [f1_tip_x - sign_x * 0.05, 0.92],
            [f1_tip_x - sign_x * 0.14, 0.72],
            [f1_tip_x - sign_x * 0.18, 0.71]
        ]
        v, n, idx = create_extrusion(f1_vent, z0=-0.085, z1=-0.065, caps=True)
        builder.add_mesh_primitive(mesh_body, m_cyan, v, n, idx)

        # --- Feather 2: Mid Secondary Feather (Solar Pearl White contrast plumage) ---
        f2_base_x = sign_x * 0.48
        f2_tip_x  = sign_x * 0.88
        f2_pts = [
            [f2_base_x, 0.22],
            [f2_base_x + sign_x * 0.16, 0.50],
            [f2_tip_x, 0.66],
            [f2_tip_x - sign_x * 0.14, 0.45],
            [f2_base_x - sign_x * 0.02, 0.16]
        ]
        v, n, idx = create_extrusion(f2_pts, z0=-0.06, z1=0.06, caps=True)
        builder.add_mesh_primitive(mesh_body, m_pearl, v, n, idx)

        # --- Feather 3: Lower Tertiary Feather ---
        f3_base_x = sign_x * 0.52
        f3_tip_x  = sign_x * 0.76
        f3_pts = [
            [f3_base_x, 0.08],
            [f3_base_x + sign_x * 0.12, 0.32],
            [f3_tip_x, 0.42],
            [f3_tip_x - sign_x * 0.12, 0.24],
            [f3_base_x, 0.04]
        ]
        v, n, idx = create_extrusion(f3_pts, z0=-0.05, z1=0.05, caps=True)
        builder.add_mesh_primitive(mesh_body, m_gold, v, n, idx)

    # 5. Aggressive Lower Cybernetic Predator Mandibles ("Sun-Fangs")
    for sign_x in [-1.0, 1.0]:
        # Pincer mandible curving downward and inward
        fang_pts = [
            [sign_x * 0.48, -0.25],
            [sign_x * 0.72, -0.52],
            [sign_x * 0.60, -0.78],
            [sign_x * 0.32, -0.84],
            [sign_x * 0.18, -0.74],
            [sign_x * 0.38, -0.62],
            [sign_x * 0.46, -0.42],
            [sign_x * 0.38, -0.28]
        ]
        v, n, idx = create_extrusion(fang_pts, z0=-0.09, z1=0.09, caps=True)
        builder.add_mesh_primitive(mesh_body, m_gold, v, n, idx)

        # Crimson Fang Center Groove
        fang_groove = [
            [sign_x * 0.56, -0.50],
            [sign_x * 0.52, -0.70],
            [sign_x * 0.32, -0.75],
            [sign_x * 0.38, -0.64],
            [sign_x * 0.48, -0.45]
        ]
        v, n, idx = create_extrusion(fang_groove, z0=-0.10, z1=-0.07, caps=True)
        builder.add_mesh_primitive(mesh_body, m_crimson, v, n, idx)

        # Hydraulic Pivot Joint (Warm Bronze Slate)
        v, n, idx = create_cylinder(sign_x * 0.44, -0.28, z0=-0.10, z1=0.10, radius=0.065, sides=12)
        builder.add_mesh_primitive(mesh_body, m_chassis, v, n, idx)

    # 6. Internal Multi-Tier Gimbal Eyeball Housing (Warm Bronze Slate)
    v, n, idx = create_convex_lens_dome(0.0, 0.0, z_base=0.16, z_tip=-0.22, radius=0.46, rings=6, sides=16)
    builder.add_mesh_primitive(mesh_body, m_chassis, v, n, idx)
    v, n, idx = create_convex_lens_dome(0.0, 0.0, z_base=0.16, z_tip=0.28, radius=0.46, rings=6, sides=16)
    builder.add_mesh_primitive(mesh_body, m_chassis, v, n, idx)

    # Side Gimbal Heavy Trunnion Pivot Bolts
    for sign_x in [-1.0, 1.0]:
        v, n, idx = create_cylinder(sign_x * 0.44, 0.0, z0=-0.06, z1=0.06, radius=0.09, sides=12)
        builder.add_mesh_primitive(mesh_body, m_steel, v, n, idx)
        v, n, idx = create_cylinder(sign_x * 0.44, 0.0, z0=-0.07, z1=-0.06, radius=0.05, sides=8)
        builder.add_mesh_primitive(mesh_body, m_cyan, v, n, idx)

    # 7. Stepped Concentric Ocular Aperture Rings (Front -Z)
    v, n, idx = create_tapered_cylinder(0.0, 0.0, z0=-0.20, z1=-0.28, r0=0.38, r1=0.32, sides=16, caps=False)
    builder.add_mesh_primitive(mesh_body, m_gold, v, n, idx)

    # 8 Interlocking Polished Steel Iris Shutter Blades
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

    # 8. Four Inward Laser Collimator Needle Pins (at 45° diagonal corners)
    for c_idx in range(4):
        c_ang = (c_idx / 4.0) * math.tau + (math.pi / 4.0)
        c_cos = math.cos(c_ang)
        c_sin = math.sin(c_ang)
        
        # Needle body extending from r=0.34 to r=0.22
        n_pts = [
            [c_cos * 0.34 - c_sin * 0.022, c_sin * 0.34 + c_cos * 0.022],
            [c_cos * 0.34 + c_sin * 0.022, c_sin * 0.34 - c_cos * 0.022],
            [c_cos * 0.22 + c_sin * 0.008, c_sin * 0.22 - c_cos * 0.008],
            [c_cos * 0.22 - c_sin * 0.008, c_sin * 0.22 + c_cos * 0.008]
        ]
        v, n, idx = create_extrusion(n_pts, z0=-0.29, z1=-0.32, caps=True)
        builder.add_mesh_primitive(mesh_body, m_steel, v, n, idx)

        # Glowing cyan focus tip
        tip_x = c_cos * 0.21
        tip_y = c_sin * 0.21
        v, n, idx = create_cylinder(tip_x, tip_y, z0=-0.325, z1=-0.305, radius=0.016, sides=8)
        builder.add_mesh_primitive(mesh_body, m_cyan, v, n, idx)

    # 9. Concentric Multi-Ring Target Reticle & Solar Pupil Lens
    # Inner gold target ring
    v, n, idx = create_tapered_cylinder(0.0, 0.0, z0=-0.28, z1=-0.33, r0=0.23, r1=0.21, sides=16, caps=False)
    builder.add_mesh_primitive(mesh_body, m_gold, v, n, idx)

    # Radiant Convex Solar Iris Lens (Emissive Amber-Gold Bloom Core)
    v, n, idx = create_convex_lens_dome(0.0, 0.0, z_base=-0.26, z_tip=-0.36, radius=0.20, rings=6, sides=16)
    builder.add_mesh_primitive(mesh_body, m_solar, v, n, idx)

    # Incandescent Concentric Solar Pupil (Blazing Ember Focal Lens)
    v, n, idx = create_convex_lens_dome(0.0, 0.0, z_base=-0.34, z_tip=-0.385, radius=0.10, rings=5, sides=12)
    builder.add_mesh_primitive(mesh_body, m_pupil, v, n, idx)

    # Central Cyan Optical Focal Pin
    v, n, idx = create_cylinder(0.0, 0.0, z0=-0.395, z1=-0.375, radius=0.035, sides=12)
    builder.add_mesh_primitive(mesh_body, m_cyan, v, n, idx)

    # 10. Rear High-Output Propulsion Vectoring Bell & Radiator Fins (+Z)
    # Outer exhaust bell
    v, n, idx = create_tapered_cylinder(0.0, 0.0, z0=0.18, z1=0.36, r0=0.32, r1=0.20, sides=16, caps=False)
    builder.add_mesh_primitive(mesh_body, m_chassis, v, n, idx)

    # Stepped Gold Gimbal Vector Ring
    v, n, idx = create_cylinder(0.0, 0.0, z0=0.30, z1=0.34, radius=0.22, sides=16, caps=False)
    builder.add_mesh_primitive(mesh_body, m_gold, v, n, idx)

    # Central Plasma Discharge Core
    v, n, idx = create_cylinder(0.0, 0.0, z0=0.34, z1=0.38, radius=0.15, sides=16)
    builder.add_mesh_primitive(mesh_body, m_solar, v, n, idx)

    # Inner Cyan Plasma Emitter
    v, n, idx = create_cylinder(0.0, 0.0, z0=0.37, z1=0.39, radius=0.07, sides=12)
    builder.add_mesh_primitive(mesh_body, m_cyan, v, n, idx)

    # 8 Radial Radiator Cooling Fins
    for i in range(8):
        ang = (i / 8.0) * math.tau
        fin_pts = [
            [math.cos(ang) * 0.16, math.sin(ang) * 0.16],
            [math.cos(ang) * 0.38, math.sin(ang) * 0.38],
            [math.cos(ang) * 0.34, math.sin(ang) * 0.34],
            [math.cos(ang) * 0.14, math.sin(ang) * 0.14]
        ]
        v, n, idx = create_extrusion(fin_pts, z0=0.18, z1=0.34, caps=True)
        builder.add_mesh_primitive(mesh_body, m_steel, v, n, idx)

    # Build Scene Node
    node_body = builder.add_node("SolarEyeDrone", mesh_idx=mesh_body)

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    builder.export(output_path)

if __name__ == "__main__":
    out_file = os.path.abspath("assets/models/solar_eye_drone.glb")
    build_solar_eye_drone_model(out_file)
