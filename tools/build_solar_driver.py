#!/usr/bin/env python3
"""
build_solar_driver.py - Generates an authentic, high-detail, low-poly
Equatorial Solar Driver & Planetary Belt 3D model in GLB format.

Design Specs:
- Fitted for the Sun's core sphere (R ≈ 7.80m).
- Planetary Belt: Dual continuous Sun-Gold segmented armor rings (R ≈ 8.05m - 8.35m)
  with glowing incandescent amber conduits and 6 obsidian lock brackets.
- Driver Buckle (Rider / Regad Omega inspired):
  - Heavy obsidian chassis with beveled cyber-gold frame bars and Shinto crimson inlays.
  - Lateral Drone Docking Bays (X = ±2.35m) with cyan LED alignment runners for eye drones.
  - Multi-tier central ocular iris: titanium ring, gold notched bezel, convex amber lens dome,
    and glowing incandescent pupil core with reticle collimator pins.
  - Separate named nodes for Buckle, BeltLeft, and BeltRight for smooth animation.
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

def create_box_3d(min_pt, max_pt):
    x0, y0, z0 = min_pt
    x1, y1, z1 = max_pt
    pts_2d = [[x0, y0], [x1, y0], [x1, y1], [x0, y1]]
    return create_extrusion(pts_2d, z0, z1, caps=True)

def create_chamfered_box_3d(cx, cy, cz, width, height, depth, chamfer=0.08):
    w2 = width * 0.5
    h2 = height * 0.5
    c = min(chamfer, w2 * 0.35, h2 * 0.35)
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
    return create_extrusion(pts, cz - depth * 0.5, cz + depth * 0.5, caps=True)

def create_cylinder_z(cx, cy, z0, z1, radius, sides=16, caps=True):
    pts = []
    for i in range(sides):
        ang = (i / float(sides)) * math.tau
        pts.append([cx + math.cos(ang) * radius, cy + math.sin(ang) * radius])
    return create_extrusion(pts, z0, z1, caps=caps)

def create_torus_z(cx, cy, cz, r_major, r_minor, sides_major=32, sides_minor=8):
    verts = []
    normals = []
    indices = []
    
    for i in range(sides_major):
        theta = (i / float(sides_major)) * math.tau
        cos_t = math.cos(theta)
        sin_t = math.sin(theta)
        
        for j in range(sides_minor):
            phi = (j / float(sides_minor)) * math.tau
            cos_p = math.cos(phi)
            sin_p = math.sin(phi)
            
            x = cx + (r_major + r_minor * cos_p) * cos_t
            y = cy + (r_major + r_minor * cos_p) * sin_t
            z = cz + r_minor * sin_p
            
            nx = cos_p * cos_t
            ny = cos_p * sin_t
            nz = sin_p
            
            verts.append([x, y, z])
            normals.append([nx, ny, nz])
            
    for i in range(sides_major):
        next_i = (i + 1) % sides_major
        for j in range(sides_minor):
            next_j = (j + 1) % sides_minor
            p0 = i * sides_minor + j
            p1 = next_i * sides_minor + j
            p2 = next_i * sides_minor + next_j
            p3 = i * sides_minor + next_j
            indices.extend([p0, p1, p2, p0, p2, p3])
            
    return verts, normals, indices

def create_convex_lens_dome_z(cx, cy, z_base, z_tip, radius, rings=6, sides=16):
    verts = []
    normals = []
    indices = []
    
    verts.append([cx, cy, z_tip])
    normals.append([0.0, 0.0, 1.0 if z_tip > z_base else -1.0])
    
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
            nz = math.cos(theta) if z_tip > z_base else -math.cos(theta)
            
            verts.append([vx, vy, z])
            normals.append([nx, ny, nz])
            
    for s in range(sides):
        next_s = (s + 1) % sides
        indices.extend([0, 1 + s, 1 + next_s])
        
    for r in range(rings - 1):
        r0 = 1 + r * sides
        r1 = 1 + (r + 1) * sides
        for s in range(sides):
            next_s = (s + 1) % sides
            indices.extend([
                r0 + s, r1 + s, r1 + next_s,
                r0 + s, r1 + next_s, r0 + next_s
            ])
            
    return verts, normals, indices

def create_solar_flare_ray_3d(cx, cy, angle, r_inner, r_mid, r_tip, w_base, w_mid, z0, z1):
    """Creates a faceted 3D aerodynamic solar flare ray / prominence wedge radiating from (cx, cy)."""
    ca = math.cos(angle)
    sa = math.sin(angle)
    ux, uy = ca, sa
    vx, vy = -sa, ca
    
    p0 = [cx + ux * r_inner - vx * (w_base * 0.5), cy + uy * r_inner - vy * (w_base * 0.5)]
    p1 = [cx + ux * r_mid   - vx * (w_mid * 0.5),   cy + uy * r_mid   - vy * (w_mid * 0.5)]
    p2 = [cx + ux * r_tip,                          cy + uy * r_tip]
    p3 = [cx + ux * r_mid   + vx * (w_mid * 0.5),   cy + uy * r_mid   + vy * (w_mid * 0.5)]
    p4 = [cx + ux * r_inner + vx * (w_base * 0.5), cy + uy * r_inner + vy * (w_base * 0.5)]
    
    pts = [p0, p1, p2, p3, p4]
    return create_extrusion(pts, z0, z1, caps=True)

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
        if mesh_idx is not None:
            node["mesh"] = mesh_idx
        if children is not None:
            node["children"] = children
        if translation is not None:
            node["translation"] = translation
        if rotation is not None:
            node["rotation"] = rotation
        if scale is not None:
            node["scale"] = scale
        self.nodes.append(node)
        return node_idx

    def export(self, file_path):
        # Default scene contains all root nodes (nodes not listed as children of any other node)
        all_children = set()
        for n in self.nodes:
            if "children" in n:
                all_children.update(n["children"])
        root_nodes = [i for i in range(len(self.nodes)) if i not in all_children]
        
        gltf = {
            "asset": {"version": "2.0", "generator": "SummerNights Solar Driver Exporter"},
            "scenes": [{"name": "SolarDriverScene", "nodes": root_nodes}],
            "scene": 0,
            "nodes": self.nodes,
            "meshes": self.meshes,
            "materials": self.materials,
            "accessors": self.accessors,
            "bufferViews": self.buffer_views,
            "buffers": [{"byteLength": len(self.bin_data)}]
        }
        
        json_str = json.dumps(gltf, separators=(',', ':'))
        json_bytes = json_str.encode('utf-8')
        json_pad = (4 - (len(json_bytes) % 4)) % 4
        json_bytes += b' ' * json_pad
        
        bin_pad = (4 - (len(self.bin_data) % 4)) % 4
        bin_bytes = self.bin_data + (b'\x00' * bin_pad)
        
        total_len = 12 + 8 + len(json_bytes) + 8 + len(bin_bytes)
        
        with open(file_path, "wb") as f:
            f.write(struct.pack("<4sII", b"glTF", 2, total_len))
            f.write(struct.pack("<II", len(json_bytes), 0x4E4F534A))
            f.write(json_bytes)
            f.write(struct.pack("<II", len(bin_bytes), 0x004E4942))
            f.write(bin_bytes)
        print(f"[OK] Successfully exported: {file_path} ({total_len} bytes)")

# ─────────────────────────────────────────────────────────────────────────────
# Procedural 3D Model Generation
# ─────────────────────────────────────────────────────────────────────────────

def build_curved_belt_ribbon(r_inner, r_outer, height, angle_start, angle_end, segments=32):
    """Generates an arched 3D belt ribbon conforming to the Sun's sphere radius."""
    verts = []
    normals = []
    indices = []
    
    h2 = height * 0.5
    
    for s in range(segments + 1):
        frac = s / float(segments)
        ang = angle_start + (angle_end - angle_start) * frac
        ca = math.cos(ang)
        sa = math.sin(ang)
        
        # 4 vertices per slice (front-top, front-bot, back-top, back-bot)
        # Here 'front' is r_outer, 'back' is r_inner
        # Coordinates in XZ plane: x = r * sin(ang), z = r * cos(ang)
        v_ot = [sa * r_outer,  h2, ca * r_outer]
        v_ob = [sa * r_outer, -h2, ca * r_outer]
        v_it = [sa * r_inner,  h2, ca * r_inner]
        v_ib = [sa * r_inner, -h2, ca * r_inner]
        
        # Normals
        n_out = [sa, 0.0, ca]
        n_in  = [-sa, 0.0, -ca]
        n_top = [0.0, 1.0, 0.0]
        n_bot = [0.0, -1.0, 0.0]
        
        # To have crisp flat shading normals, we append individual quad faces below
    
    # Re-build quad by quad for clean per-face or cylindrical normals
    for s in range(segments):
        f0 = s / float(segments)
        f1 = (s + 1) / float(segments)
        a0 = angle_start + (angle_end - angle_start) * f0
        a1 = angle_start + (angle_end - angle_start) * f1
        
        c0, s0 = math.cos(a0), math.sin(a0)
        c1, s1 = math.cos(a1), math.sin(a1)
        
        # Outer Face (+radial)
        base = len(verts)
        verts.extend([
            [s0 * r_outer,  h2, c0 * r_outer],
            [s1 * r_outer,  h2, c1 * r_outer],
            [s1 * r_outer, -h2, c1 * r_outer],
            [s0 * r_outer, -h2, c0 * r_outer]
        ])
        normals.extend([
            [s0, 0.0, c0], [s1, 0.0, c1], [s1, 0.0, c1], [s0, 0.0, c0]
        ])
        indices.extend([base, base + 1, base + 2, base, base + 2, base + 3])
        
        # Top Face (+Y)
        base = len(verts)
        verts.extend([
            [s0 * r_inner,  h2, c0 * r_inner],
            [s1 * r_inner,  h2, c1 * r_inner],
            [s1 * r_outer,  h2, c1 * r_outer],
            [s0 * r_outer,  h2, c0 * r_outer]
        ])
        normals.extend([[0.0, 1.0, 0.0]] * 4)
        indices.extend([base, base + 1, base + 2, base, base + 2, base + 3])
        
        # Bottom Face (-Y)
        base = len(verts)
        verts.extend([
            [s0 * r_outer, -h2, c0 * r_outer],
            [s1 * r_outer, -h2, c1 * r_outer],
            [s1 * r_inner, -h2, c1 * r_inner],
            [s0 * r_inner, -h2, c0 * r_inner]
        ])
        normals.extend([[0.0, -1.0, 0.0]] * 4)
        indices.extend([base, base + 1, base + 2, base, base + 2, base + 3])
        
    return verts, normals, indices

def build_solar_driver_glb(output_path):
    builder = GLBBuilder()
    
    # ── PBR Materials ────────────────────────────────────────────────────────
    # 1. Radiant Sun-Gold Plating (Tokusatsu Champion Gold)
    m_gold = builder.add_material(
        "M_SunGold",
        base_color=[0.96, 0.72, 0.20, 1.0],
        metallic=0.68,
        roughness=0.20
    )
    # 2. Dark Obsidian Chassis (Zillion Driver deep cybernetic frame)
    m_chassis = builder.add_material(
        "M_ObsidianChassis",
        base_color=[0.11, 0.10, 0.14, 1.0],
        metallic=0.82,
        roughness=0.24
    )
    # 3. Shinto Vermilion Crimson (Tokusatsu Inlay Red)
    m_crimson = builder.add_material(
        "M_ShintoCrimson",
        base_color=[0.88, 0.16, 0.16, 1.0],
        metallic=0.35,
        roughness=0.30
    )
    # 4. Brushed Titanium / Steel (Lock Teeth, Brackets)
    m_titanium = builder.add_material(
        "M_BrushedTitanium",
        base_color=[0.32, 0.33, 0.36, 1.0],
        metallic=0.75,
        roughness=0.28
    )
    # 5. Incandescent Solar Amber Conduit (Emissive Power Rails)
    m_conduit = builder.add_material(
        "M_AmberConduit",
        base_color=[1.0, 0.74, 0.24, 1.0],
        metallic=0.0,
        roughness=0.15,
        emissive_rgb=[1.0, 0.70, 0.20]
    )
    # 6. Blazing Solar Core Pupil (Ultra-Emissive Bloom Eye)
    m_core = builder.add_material(
        "M_SolarCorePupil",
        base_color=[1.0, 0.65, 0.15, 1.0],
        metallic=0.0,
        roughness=0.10,
        emissive_rgb=[1.0, 0.65, 0.15]
    )
    # 7. Cyan Alignment Guide LEDs (Drone Docking Guides)
    m_cyan = builder.add_material(
        "M_CyanLED",
        base_color=[0.18, 0.90, 1.0, 1.0],
        metallic=0.0,
        roughness=0.15,
        emissive_rgb=[0.18, 0.90, 1.0]
    )

    # ═════════════════════════════════════════════════════════════════════════
    # PART 1: DRIVER BUCKLE (Center Tokusatsu Henshin Belt Buckle)
    # Mounted at the Sun's lower waist/equator facing the beach (Z ≈ 7.28m)
    # Features an iconic Sun Crest in the middle and aerodynamic wing designs on left and right.
    # ═════════════════════════════════════════════════════════════════════════
    mesh_buckle = builder.create_mesh("Mesh_DriverBuckle")
    z_b = 7.28
    
    # 1. Main Obsidian Chassis (5.8m wide x 2.7m high x 0.64m deep)
    v, n, idx = create_chamfered_box_3d(0.0, 0.0, z_b - 0.20, width=5.80, height=2.70, depth=0.64, chamfer=0.26)
    builder.add_mesh_primitive(mesh_buckle, m_chassis, v, n, idx)
    
    # 2. Beveled Sun-Gold Frame Horizon Bars (Top: Y=+1.22m, Bottom: Y=-1.22m)
    v, n, idx = create_chamfered_box_3d(0.0,  1.22, z_b + 0.05, width=6.12, height=0.42, depth=0.60, chamfer=0.12)
    builder.add_mesh_primitive(mesh_buckle, m_gold, v, n, idx)
    v, n, idx = create_chamfered_box_3d(0.0, -1.22, z_b + 0.05, width=6.12, height=0.42, depth=0.60, chamfer=0.12)
    builder.add_mesh_primitive(mesh_buckle, m_gold, v, n, idx)

    # 3. Outer Chevron Side Wing Endcaps & Latch Jaws (X = ±2.98m)
    for sign_x in [-1.0, 1.0]:
        v, n, idx = create_chamfered_box_3d(sign_x * 2.98, 0.0, z_b + 0.05, width=0.48, height=2.88, depth=0.64, chamfer=0.14)
        builder.add_mesh_primitive(mesh_buckle, m_gold, v, n, idx)
        
        # Titanium latch jaw connecting to belt strap
        v, n, idx = create_box_3d(
            [sign_x * 2.98 - 0.30, -0.98, z_b - 0.48],
            [sign_x * 2.98 + 0.30,  0.98, z_b + 0.24]
        )
        builder.add_mesh_primitive(mesh_buckle, m_titanium, v, n, idx)
        
        # Glowing vertical amber indicator slit
        v, n, idx = create_box_3d(
            [sign_x * 2.98 - 0.04, -0.75, z_b + 0.35],
            [sign_x * 2.98 + 0.04,  0.75, z_b + 0.39]
        )
        builder.add_mesh_primitive(mesh_buckle, m_conduit, v, n, idx)

    # ═════════════════════════════════════════════════════════════════════════
    # A. THE SUN IN THE MIDDLE (Central Solar Crest & 16-Ray Sunburst Corona)
    # ═════════════════════════════════════════════════════════════════════════
    # Outer Coronal Titanium Base Disc
    v, n, idx = create_cylinder_z(0.0, 0.0, z0=z_b + 0.44, z1=z_b + 0.66, radius=1.28, sides=32, caps=True)
    builder.add_mesh_primitive(mesh_buckle, m_titanium, v, n, idx)

    # 16-Ray 3D Sunburst Corona (Rays raised to front face: Z = z_b + 0.66 to z_b + 0.84)
    # Primary 8 Major Solar Rays (Cyber-Gold with glowing incandescent amber spine needle)
    for r_i in range(8):
        ray_ang = (r_i / 8.0) * math.tau
        is_vertical = (r_i == 2 or r_i == 6)
        is_horiz = (r_i == 0 or r_i == 4)
        
        # North and South crown the belt boldly; East and West point to flank conduits
        if is_vertical:
            r_tip, r_mid, w_b, w_m = 1.88, 1.48, 0.32, 0.18
        elif is_horiz:
            r_tip, r_mid, w_b, w_m = 1.55, 1.35, 0.28, 0.16
        else:
            r_tip, r_mid, w_b, w_m = 1.65, 1.38, 0.28, 0.16
        
        # Outer Gold Ray Body
        v, n, idx = create_solar_flare_ray_3d(0.0, 0.0, ray_ang, r_inner=1.04, r_mid=r_mid, r_tip=r_tip,
                                              w_base=w_b, w_mid=w_m, z0=z_b + 0.66, z1=z_b + 0.82)
        builder.add_mesh_primitive(mesh_buckle, m_gold, v, n, idx)
        
        # Glowing Amber Spine Needle
        v, n, idx = create_solar_flare_ray_3d(0.0, 0.0, ray_ang, r_inner=1.12, r_mid=r_mid * 0.96, r_tip=r_tip - 0.16,
                                              w_base=w_b * 0.45, w_mid=w_m * 0.40, z0=z_b + 0.80, z1=z_b + 0.88)
        builder.add_mesh_primitive(mesh_buckle, m_conduit, v, n, idx)

    # Secondary 8 Intercardinal Solar Rays (Shinto Crimson with Gold Bead Tip)
    for r_i in range(8):
        ray_ang = (r_i / 8.0) * math.tau + (math.pi / 8.0)
        ca, sa = math.cos(ray_ang), math.sin(ray_ang)
        r_tip = 1.40
        r_mid = 1.25
        
        # Crimson Flare Ray
        v, n, idx = create_solar_flare_ray_3d(0.0, 0.0, ray_ang, r_inner=1.08, r_mid=r_mid, r_tip=r_tip,
                                              w_base=0.20, w_mid=0.11, z0=z_b + 0.64, z1=z_b + 0.78)
        builder.add_mesh_primitive(mesh_buckle, m_crimson, v, n, idx)
        
        # Gold Tip Jewel
        v, n, idx = create_cylinder_z(ca * (r_tip - 0.04), sa * (r_tip - 0.04), z0=z_b + 0.74, z1=z_b + 0.82, radius=0.042, sides=8)
        builder.add_mesh_primitive(mesh_buckle, m_gold, v, n, idx)

    # Stepped Cyber-Gold Corona Bezel Ring (Torus)
    v, n, idx = create_torus_z(0.0, 0.0, cz=z_b + 0.70, r_major=1.12, r_minor=0.13, sides_major=32, sides_minor=8)
    builder.add_mesh_primitive(mesh_buckle, m_gold, v, n, idx)

    # 12 Radial Golden Corona Flutes
    for i in range(12):
        ang = (i / 12.0) * math.tau
        ca, sa = math.cos(ang), math.sin(ang)
        v, n, idx = create_chamfered_box_3d(ca * 1.15, sa * 1.15, z_b + 0.74, width=0.16, height=0.16, depth=0.12, chamfer=0.03)
        builder.add_mesh_primitive(mesh_buckle, m_gold, v, n, idx)

    # Radiant Convex Solar Disc Lens (Glowing Amber-Gold Core Dome)
    v, n, idx = create_convex_lens_dome_z(0.0, 0.0, z_base=z_b + 0.68, z_tip=z_b + 0.90, radius=0.94, rings=6, sides=24)
    builder.add_mesh_primitive(mesh_buckle, m_conduit, v, n, idx)

    # Incandescent Concentric Solar Pupil Core (Blazing Focal Center)
    v, n, idx = create_convex_lens_dome_z(0.0, 0.0, z_base=z_b + 0.78, z_tip=z_b + 0.98, radius=0.52, rings=5, sides=20)
    builder.add_mesh_primitive(mesh_buckle, m_core, v, n, idx)

    # Inner Heart-of-the-Sun Medallion (Central Golden Solar Star Crest)
    v, n, idx = create_cylinder_z(0.0, 0.0, z0=z_b + 0.92, z1=z_b + 0.99, radius=0.24, sides=16)
    builder.add_mesh_primitive(mesh_buckle, m_gold, v, n, idx)
    v, n, idx = create_cylinder_z(0.0, 0.0, z0=z_b + 0.97, z1=z_b + 1.02, radius=0.12, sides=12)
    builder.add_mesh_primitive(mesh_buckle, m_core, v, n, idx)
    
    # 8 Collimator Needles radiating from inner sun heart
    for c_i in range(8):
        c_ang = (c_i / 8.0) * math.tau
        ca, sa = math.cos(c_ang), math.sin(c_ang)
        pin_pts = [
            [ca * 0.50 - sa * 0.025, sa * 0.50 + ca * 0.025],
            [ca * 0.50 + sa * 0.025, sa * 0.50 - ca * 0.025],
            [ca * 0.24 + sa * 0.015, sa * 0.24 - ca * 0.015],
            [ca * 0.24 - sa * 0.015, sa * 0.24 + ca * 0.015]
        ]
        v, n, idx = create_extrusion(pin_pts, z0=z_b + 0.92, z1=z_b + 0.98, caps=True)
        builder.add_mesh_primitive(mesh_buckle, m_titanium, v, n, idx)
        
        # Glowing cyan tip emitter
        v, n, idx = create_cylinder_z(ca * 0.48, sa * 0.48, z0=z_b + 0.94, z1=z_b + 1.01, radius=0.028, sides=6)
        builder.add_mesh_primitive(mesh_buckle, m_cyan, v, n, idx)

    # ═════════════════════════════════════════════════════════════════════════
    # B. DYNAMIC DESIGN ON THE LEFT & RIGHT (Swept Wing Cowls, Conduits, Louvers, Docks)
    # ═════════════════════════════════════════════════════════════════════════
    for sign_x in [-1.0, 1.0]:
        bx = sign_x * 1.95
        
        # 1. Swept Solar Wing Armor Cowls (Top Wing Armor: Y = +0.76m to +1.18m)
        pts_wing_top = [
            [sign_x * 1.25,  0.80],
            [sign_x * 2.85,  1.15],
            [sign_x * 2.88,  0.78],
            [sign_x * 1.35,  0.58]
        ]
        v, n, idx = create_extrusion(pts_wing_top, z0=z_b + 0.20, z1=z_b + 0.52, caps=True)
        builder.add_mesh_primitive(mesh_buckle, m_chassis, v, n, idx)
        
        # Beveled Gold Upper Wing Rim
        pts_rim_top = [
            [sign_x * 1.25,  0.80],
            [sign_x * 2.85,  1.15],
            [sign_x * 2.85,  1.22],
            [sign_x * 1.25,  0.88]
        ]
        v, n, idx = create_extrusion(pts_rim_top, z0=z_b + 0.38, z1=z_b + 0.60, caps=True)
        builder.add_mesh_primitive(mesh_buckle, m_gold, v, n, idx)
        
        # Shinto Crimson Accent Wing Stripe
        pts_crim_top = [
            [sign_x * 1.38,  0.72],
            [sign_x * 2.76,  1.04],
            [sign_x * 2.76,  0.94],
            [sign_x * 1.38,  0.64]
        ]
        v, n, idx = create_extrusion(pts_crim_top, z0=z_b + 0.46, z1=z_b + 0.58, caps=True)
        builder.add_mesh_primitive(mesh_buckle, m_crimson, v, n, idx)

        # 2. Swept Solar Wing Armor Cowls (Bottom Wing Armor: Y = -0.76m to -1.18m)
        pts_wing_bot = [
            [sign_x * 1.25, -0.80],
            [sign_x * 1.35, -0.58],
            [sign_x * 2.88, -0.78],
            [sign_x * 2.85, -1.15]
        ]
        v, n, idx = create_extrusion(pts_wing_bot, z0=z_b + 0.20, z1=z_b + 0.52, caps=True)
        builder.add_mesh_primitive(mesh_buckle, m_chassis, v, n, idx)
        
        # Beveled Gold Lower Wing Rim
        pts_rim_bot = [
            [sign_x * 1.25, -0.88],
            [sign_x * 2.85, -1.22],
            [sign_x * 2.85, -1.15],
            [sign_x * 1.25, -0.80]
        ]
        v, n, idx = create_extrusion(pts_rim_bot, z0=z_b + 0.38, z1=z_b + 0.60, caps=True)
        builder.add_mesh_primitive(mesh_buckle, m_gold, v, n, idx)
        
        # Shinto Crimson Accent Wing Stripe
        pts_crim_bot = [
            [sign_x * 1.38, -0.64],
            [sign_x * 2.76, -0.94],
            [sign_x * 2.76, -1.04],
            [sign_x * 1.38, -0.72]
        ]
        v, n, idx = create_extrusion(pts_crim_bot, z0=z_b + 0.46, z1=z_b + 0.58, caps=True)
        builder.add_mesh_primitive(mesh_buckle, m_crimson, v, n, idx)

        # 3. Dual High-Pressure Plasma Conduits (Upper Y=+0.68m, Lower Y=-0.68m)
        # Running visibly above and below the docking bay across the entire flank
        for cy in [-0.68, 0.68]:
            x_min = min(sign_x * 1.25, sign_x * 2.80)
            x_max = max(sign_x * 1.25, sign_x * 2.80)
            # Glowing Amber Conduit Rail
            v, n, idx = create_chamfered_box_3d((x_min + x_max) * 0.5, cy, z_b + 0.54,
                                                width=abs(x_max - x_min), height=0.11, depth=0.14, chamfer=0.02)
            builder.add_mesh_primitive(mesh_buckle, m_conduit, v, n, idx)
            
            # Gold Manifold Brackets clamping conduits
            for kx in [sign_x * 1.42, sign_x * 1.95, sign_x * 2.58]:
                v, n, idx = create_chamfered_box_3d(kx, cy, z_b + 0.56, width=0.16, height=0.18, depth=0.16, chamfer=0.03)
                builder.add_mesh_primitive(mesh_buckle, m_gold, v, n, idx)
                # Titanium Fastener Rivet
                v, n, idx = create_cylinder_z(kx, cy, z0=z_b + 0.62, z1=z_b + 0.66, radius=0.035, sides=6)
                builder.add_mesh_primitive(mesh_buckle, m_titanium, v, n, idx)

        # 4. Inner Power Coupling Relief (Between Sun & Docking Bay: X = ±1.25m to ±1.55m)
        cx_mid = sign_x * 1.38
        # Shinto Crimson Power Cell Base
        v, n, idx = create_chamfered_box_3d(cx_mid, 0.0, z_b + 0.45, width=0.26, height=0.90, depth=0.22, chamfer=0.04)
        builder.add_mesh_primitive(mesh_buckle, m_crimson, v, n, idx)
        # Glowing vertical Cyan indicator rail
        v, n, idx = create_box_3d([cx_mid - 0.03, -0.38, z_b + 0.55], [cx_mid + 0.03, 0.38, z_b + 0.60])
        builder.add_mesh_primitive(mesh_buckle, m_cyan, v, n, idx)

        # 5. Flank Cooling Heat Louvers (Between Docking Bay & Endcap: X = ±2.58m, Y in [-0.40, 0.40])
        for l_idx in [-1.5, -0.5, 0.5, 1.5]:
            ly = l_idx * 0.18
            lx = sign_x * 2.58
            # Recessed glowing cyan intake slot
            v, n, idx = create_box_3d([lx - 0.14, ly - 0.04, z_b + 0.46], [lx + 0.14, ly + 0.04, z_b + 0.52])
            builder.add_mesh_primitive(mesh_buckle, m_cyan, v, n, idx)
            # Angled titanium louver fin
            v, n, idx = create_chamfered_box_3d(lx, ly, z_b + 0.54, width=0.30, height=0.07, depth=0.12, chamfer=0.015)
            builder.add_mesh_primitive(mesh_buckle, m_titanium, v, n, idx)

        # 6. Sculpted Drone Docking Bay Receptor (Centered precisely at X = ±1.95m, Y = 0.0m)
        # Compact, sleek faceted titanium housing (width 0.80m x height 1.15m x depth 0.60m)
        v, n, idx = create_chamfered_box_3d(bx, 0.0, z_b + 0.40, width=0.82, height=1.16, depth=0.55, chamfer=0.12)
        builder.add_mesh_primitive(mesh_buckle, m_titanium, v, n, idx)

        # Deep Recessed Docking Port Well (Obsidian)
        v, n, idx = create_box_3d([bx - 0.32, -0.46, z_b + 0.36], [bx + 0.32, 0.46, z_b + 0.68])
        builder.add_mesh_primitive(mesh_buckle, m_chassis, v, n, idx)

        # Dual Vertical Cyan Alignment LED Rails
        for led_x in [-0.14, 0.14]:
            v, n, idx = create_box_3d([bx + led_x - 0.03, -0.44, z_b + 0.66], [bx + led_x + 0.03, 0.44, z_b + 0.72])
            builder.add_mesh_primitive(mesh_buckle, m_cyan, v, n, idx)

        # Central Power Receptor Hub (Circular gold docking port with radiant cyan core)
        v, n, idx = create_cylinder_z(bx, 0.0, z0=z_b + 0.54, z1=z_b + 0.70, radius=0.16, sides=16)
        builder.add_mesh_primitive(mesh_buckle, m_gold, v, n, idx)
        v, n, idx = create_cylinder_z(bx, 0.0, z0=z_b + 0.66, z1=z_b + 0.74, radius=0.08, sides=12)
        builder.add_mesh_primitive(mesh_buckle, m_cyan, v, n, idx)

        # Top and Bottom Cyber-Gold Magnetic Clamp Teeth
        v, n, idx = create_chamfered_box_3d(bx,  0.52, z_b + 0.48, width=0.56, height=0.14, depth=0.42, chamfer=0.03)
        builder.add_mesh_primitive(mesh_buckle, m_gold, v, n, idx)
        v, n, idx = create_chamfered_box_3d(bx, -0.52, z_b + 0.48, width=0.56, height=0.14, depth=0.42, chamfer=0.03)
        builder.add_mesh_primitive(mesh_buckle, m_gold, v, n, idx)

    # ═════════════════════════════════════════════════════════════════════════
    # PART 2: PLANETARY BELT STRAPS (Left & Right Equatorial Ribbons)
    # Radii: Lower waist R_inner = 6.95m, R_outer = 7.35m
    # Belt Height: 1.10m, Conduit Height: 0.32m
    # Wraps around from front buckle (ang ≈ ±0.40 rad ≈ 23°) to back (ang ≈ ±3.08 rad ≈ 176°)
    # ═════════════════════════════════════════════════════════════════════════
    
    r_in = 6.95
    r_out = 7.35
    h_belt = 1.10
    ang_buckle = 0.34 # Extends inside buckle chassis (X ≈ ±2.45m) for seamless overlap
    ang_back = math.pi - 0.06

    # ── Left Strap ──
    mesh_left = builder.create_mesh("Mesh_BeltStrap_Left")
    # Outer Gold Armor Band
    v, n, idx = build_curved_belt_ribbon(r_in, r_out, h_belt, ang_buckle, ang_back, segments=32)
    builder.add_mesh_primitive(mesh_left, m_gold, v, n, idx)
    # Glowing Amber Conduit Rail (protruding slightly outward)
    v, n, idx = build_curved_belt_ribbon(r_out - 0.02, r_out + 0.08, 0.32, ang_buckle, ang_back, segments=32)
    builder.add_mesh_primitive(mesh_left, m_conduit, v, n, idx)
    
    # 3 Obsidian Lock Bracket Clasps along Left Strap
    left_bracket_angles = [0.90, 1.70, 2.50]
    for b_ang in left_bracket_angles:
        cb, sb = math.cos(b_ang), math.sin(b_ang)
        bx = sb * (r_out + 0.10)
        bz = cb * (r_out + 0.10)
        # Bracket mesh
        v, n, idx = create_chamfered_box_3d(0.0, 0.0, 0.0, width=0.55, height=1.38, depth=0.32, chamfer=0.08)
        # Rotate bracket to align with belt tangent
        rot_y = b_ang
        v_rot = []
        n_rot = []
        for p in v:
            rx = p[0] * math.cos(rot_y) + p[2] * math.sin(rot_y) + bx
            ry = p[1]
            rz = -p[0] * math.sin(rot_y) + p[2] * math.cos(rot_y) + bz
            v_rot.append([rx, ry, rz])
        for p in n:
            nx = p[0] * math.cos(rot_y) + p[2] * math.sin(rot_y)
            ny = p[1]
            nz = -p[0] * math.sin(rot_y) + p[2] * math.cos(rot_y)
            n_rot.append([nx, ny, nz])
        builder.add_mesh_primitive(mesh_left, m_chassis, v_rot, n_rot, idx)
        
        # Cyan status diode in center of bracket
        v_d, n_d, idx_d = create_box_3d([-0.06, -0.18, 0.15], [0.06, 0.18, 0.20])
        v_d_rot = []
        n_d_rot = []
        for p in v_d:
            rx = p[0] * math.cos(rot_y) + p[2] * math.sin(rot_y) + bx
            ry = p[1]
            rz = -p[0] * math.sin(rot_y) + p[2] * math.cos(rot_y) + bz
            v_d_rot.append([rx, ry, rz])
        for p in n_d:
            nx = p[0] * math.cos(rot_y) + p[2] * math.sin(rot_y)
            ny = p[1]
            nz = -p[0] * math.sin(rot_y) + p[2] * math.cos(rot_y)
            n_d_rot.append([nx, ny, nz])
        builder.add_mesh_primitive(mesh_left, m_cyan, v_d_rot, n_d_rot, idx_d)

    # ── Right Strap ──
    mesh_right = builder.create_mesh("Mesh_BeltStrap_Right")
    # Outer Gold Armor Band
    v, n, idx = build_curved_belt_ribbon(r_in, r_out, h_belt, -ang_buckle, -ang_back, segments=32)
    builder.add_mesh_primitive(mesh_right, m_gold, v, n, idx)
    # Glowing Amber Conduit Rail
    v, n, idx = build_curved_belt_ribbon(r_out - 0.02, r_out + 0.08, 0.32, -ang_buckle, -ang_back, segments=32)
    builder.add_mesh_primitive(mesh_right, m_conduit, v, n, idx)
    
    # 3 Obsidian Lock Bracket Clasps along Right Strap
    for b_ang in left_bracket_angles:
        r_ang = -b_ang
        cb, sb = math.cos(r_ang), math.sin(r_ang)
        bx = sb * (r_out + 0.10)
        bz = cb * (r_out + 0.10)
        # Bracket mesh
        v, n, idx = create_chamfered_box_3d(0.0, 0.0, 0.0, width=0.55, height=1.38, depth=0.32, chamfer=0.08)
        rot_y = r_ang
        v_rot = []
        n_rot = []
        for p in v:
            rx = p[0] * math.cos(rot_y) + p[2] * math.sin(rot_y) + bx
            ry = p[1]
            rz = -p[0] * math.sin(rot_y) + p[2] * math.cos(rot_y) + bz
            v_rot.append([rx, ry, rz])
        for p in n:
            nx = p[0] * math.cos(rot_y) + p[2] * math.sin(rot_y)
            ny = p[1]
            nz = -p[0] * math.sin(rot_y) + p[2] * math.cos(rot_y)
            n_rot.append([nx, ny, nz])
        builder.add_mesh_primitive(mesh_right, m_chassis, v_rot, n_rot, idx)
        
        # Cyan status diode
        v_d, n_d, idx_d = create_box_3d([-0.06, -0.18, 0.15], [0.06, 0.18, 0.20])
        v_d_rot = []
        n_d_rot = []
        for p in v_d:
            rx = p[0] * math.cos(rot_y) + p[2] * math.sin(rot_y) + bx
            ry = p[1]
            rz = -p[0] * math.sin(rot_y) + p[2] * math.cos(rot_y) + bz
            v_d_rot.append([rx, ry, rz])
        for p in n_d:
            nx = p[0] * math.cos(rot_y) + p[2] * math.sin(rot_y)
            ny = p[1]
            nz = -p[0] * math.sin(rot_y) + p[2] * math.cos(rot_y)
            n_d_rot.append([nx, ny, nz])
        builder.add_mesh_primitive(mesh_right, m_cyan, v_d_rot, n_d_rot, idx_d)

    # ═════════════════════════════════════════════════════════════════════════
    # Scene Hierarchy Assembly
    # ═════════════════════════════════════════════════════════════════════════
    node_buckle = builder.add_node("DriverBuckle", mesh_idx=mesh_buckle)
    node_strap_l = builder.add_node("BeltStrap_Left", mesh_idx=mesh_left)
    node_strap_r = builder.add_node("BeltStrap_Right", mesh_idx=mesh_right)
    
    # Root Parent Node
    builder.add_node("SolarDriverRoot", children=[node_buckle, node_strap_l, node_strap_r])

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    builder.export(output_path)

if __name__ == "__main__":
    out_file = os.path.abspath("assets/models/solar_driver.glb")
    build_solar_driver_glb(out_file)
