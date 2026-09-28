#!/usr/bin/env python3
import struct
import json
import math
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection

def render_unified_preview(glb_path, output_png, mode="cannon"):
    with open(glb_path, 'rb') as f:
        magic, version, length = struct.unpack('<III', f.read(12))
        chunk_len, chunk_type = struct.unpack('<II', f.read(8))
        gltf = json.loads(f.read(chunk_len).decode('utf-8'))
        bin_len, bin_type = struct.unpack('<II', f.read(8))
        bin_data = f.read(bin_len)
        
    def get_data(acc_idx):
        acc = gltf['accessors'][acc_idx]
        bv = gltf['bufferViews'][acc['bufferView']]
        offset = bv.get('byteOffset', 0) + acc.get('byteOffset', 0)
        count = acc['count']
        ctype = acc['componentType']
        atype = acc['type']
        
        components = {'SCALAR': 1, 'VEC2': 2, 'VEC3': 3, 'VEC4': 4}[atype]
        dtype = {5126: np.float32, 5125: np.uint32, 5123: np.uint16}.get(ctype, np.float32)
        return np.frombuffer(bin_data[offset:offset + count * components * np.dtype(dtype).itemsize], dtype=dtype).reshape(count, components)

    mat_colors = []
    for mat in gltf.get('materials', []):
        pbr = mat.get('pbrMetallicRoughness', {})
        col = pbr.get('baseColorFactor', [0.8, 0.8, 0.8, 1.0])
        emissive = mat.get('emissiveFactor', [0.0, 0.0, 0.0])
        # If emissive, boost the visual vibrance
        if any(e > 0.05 for e in emissive):
            col = [min(1.0, c * 0.7 + e * 0.45) for c, e in zip(col[:3], emissive)] + [col[3] if len(col) > 3 else 1.0]
        mat_colors.append(col)

    fig = plt.figure(figsize=(24, 8), facecolor='#0e1017')
    
    title_prefix = "Kitsune Buster IX - Cannon Mode" if mode == "cannon" else "Kitsune Buster IX - Katana Blade Mode"
    y_lim = (-0.65, 1.10) if mode == "cannon" else (-0.65, 1.95)
    
    views = [
        {
            'title': f'{title_prefix} (First-Person Sightline)',
            'elev': 10, 'azim': -90, 'pos': 131,
            'aspect': (1.1, 1.8, 1.1)
        },
        {
            'title': f'{title_prefix} (Hero 3/4 Perspective)',
            'elev': 18, 'azim': 42, 'pos': 132,
            'aspect': (1.1, 1.8, 1.1)
        },
        {
            'title': f'{title_prefix} (Profile Elevation)',
            'elev': 0, 'azim': 0, 'pos': 133,
            'aspect': (0.8, 1.8, 1.1)
        }
    ]
    
    light_dir = np.array([0.5, -0.4, 0.75])
    light_dir = light_dir / np.linalg.norm(light_dir)

    # Node configuration per mode
    nodes = gltf.get('nodes', [])
    node_transforms = {}
    for i, node in enumerate(nodes):
        name = node.get('name', '')
        pos = np.array(node.get('translation', [0.0, 0.0, 0.0]), dtype=np.float32)
        scale = np.array(node.get('scale', [1.0, 1.0, 1.0]), dtype=np.float32)
        rot_deg_z = 0.0
        
        if mode == "cannon":
            if name == "BladeAssembly":
                scale = np.array([0.0, 0.0, 0.0], dtype=np.float32) # Hidden
            elif name == "TsubaLeft":
                rot_deg_z = -35.0
                scale = np.array([0.7, 0.7, 0.7], dtype=np.float32)
            elif name == "TsubaRight":
                rot_deg_z = 35.0
                scale = np.array([0.7, 0.7, 0.7], dtype=np.float32)
        else: # blade mode
            if name == "BarrelAssembly":
                scale = np.array([0.0, 0.0, 0.0], dtype=np.float32) # Retracted/Hidden
            elif name == "BladeAssembly":
                pos = np.array([0.0, 0.48, 0.55], dtype=np.float32)
                scale = np.array([1.0, 1.0, 1.0], dtype=np.float32)
            elif name in ["TsubaLeft", "TsubaRight"]:
                rot_deg_z = 0.0
                scale = np.array([1.0, 1.0, 1.0], dtype=np.float32)

        rad_z = math.radians(rot_deg_z)
        cz, sz = math.cos(rad_z), math.sin(rad_z)
        R_z = np.array([[cz, -sz, 0], [sz, cz, 0], [0, 0, 1]], dtype=np.float32)
        
        node_transforms[i] = (pos, scale, R_z, node.get('mesh', None))

    for v_cfg in views:
        ax = fig.add_subplot(v_cfg['pos'], projection='3d', facecolor='#0e1017')
        ax.set_title(v_cfg['title'], color='#F4E8D0', fontsize=12, fontweight='bold', pad=12)
        
        ax.set_xlim(-0.55, 0.55)
        ax.set_ylim(y_lim[0], y_lim[1])
        ax.set_zlim(-0.20, 1.15)
        ax.view_init(elev=v_cfg['elev'], azim=v_cfg['azim'])
        ax.set_box_aspect(v_cfg['aspect'])
        fig.canvas.draw()
        
        cam_pos = ax._get_camera_loc()
        
        all_triangles = []
        all_colors = []
        all_centroids = []
        
        for n_idx, (t_pos, t_scale, t_rot, mesh_idx) in node_transforms.items():
            if mesh_idx is None or np.all(t_scale < 1e-4):
                continue
            mesh = gltf['meshes'][mesh_idx]
            for prim in mesh['primitives']:
                verts = get_data(prim['attributes']['POSITION'])
                indices = get_data(prim['indices']).flatten()
                base_col = np.array(mat_colors[prim['material']][:3])
                
                # Apply local node transform: scale -> rotate -> translate
                scaled_v = verts * t_scale
                rotated_v = np.dot(scaled_v, t_rot.T)
                transformed_v = rotated_v + t_pos
                
                # Map Godot coords:
                # X (width) -> X
                # Z (length) -> Y
                # Y (height) -> Z
                m_verts = np.zeros_like(transformed_v)
                m_verts[:, 0] = transformed_v[:, 0] # X
                m_verts[:, 1] = transformed_v[:, 2] # Z -> Y
                m_verts[:, 2] = transformed_v[:, 1] # Y -> Z
                
                triangles = m_verts[indices].reshape(-1, 3, 3)
                v0 = triangles[:, 0, :]
                v1 = triangles[:, 1, :]
                v2 = triangles[:, 2, :]
                normals = np.cross(v1 - v0, v2 - v0)
                norm_len = np.linalg.norm(normals, axis=1, keepdims=True)
                norm_len[norm_len < 1e-6] = 1.0
                normals = normals / norm_len
                
                centroids = np.mean(triangles, axis=1)
                to_cam = cam_pos - centroids
                
                # Back-face culling
                dot_cam = np.sum(normals * to_cam, axis=1)
                front_mask = dot_cam > 0.0
                
                vis_triangles = triangles[front_mask]
                vis_normals = normals[front_mask]
                vis_centroids = centroids[front_mask]
                
                diff = np.maximum(0.18, np.dot(vis_normals, light_dir)) * 0.72 + 0.28
                lit_rgb = np.clip(diff[:, None] * base_col[:3], 0, 1)
                alpha_val = float(base_col[3]) if len(base_col) > 3 else 1.0
                face_colors = np.column_stack([lit_rgb, np.full(len(lit_rgb), alpha_val)])
                
                for tri, col, c in zip(vis_triangles, face_colors, vis_centroids):
                    all_triangles.append(tri)
                    all_colors.append(col)
                    all_centroids.append(c)
                    
        if all_centroids:
            all_c = np.array(all_centroids)
            dists = np.linalg.norm(all_c - cam_pos, axis=1)
            # Painter sort: furthest first
            sort_order = np.argsort(-dists)
            sorted_triangles = [all_triangles[i] for i in sort_order]
            sorted_colors = [all_colors[i] for i in sort_order]
            
            poly = Poly3DCollection(sorted_triangles, facecolors=sorted_colors, edgecolors='none', linewidths=0.0)
            ax.add_collection3d(poly)
            
        ax.axis('off')
        
    plt.tight_layout()
    plt.savefig(output_png, dpi=180, facecolor=fig.get_facecolor(), edgecolor='none')
    plt.close()
    print(f"Rendered preview to {output_png}")

if __name__ == '__main__':
    render_unified_preview('assets/blaster_kitsune_unified.glb', '/Users/ashj/.gemini/antigravity-ide/brain/e2b8cc3e-1b57-4579-91d4-5008b80a2449/kitsune_unified_cannon.png', mode="cannon")
    render_unified_preview('assets/blaster_kitsune_unified.glb', '/Users/ashj/.gemini/antigravity-ide/brain/e2b8cc3e-1b57-4579-91d4-5008b80a2449/kitsune_unified_blade.png', mode="blade")


