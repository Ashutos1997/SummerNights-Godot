#!/usr/bin/env python3
import struct
import json
import math
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection

def render_preview(glb_path, output_png):
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
        mat_colors.append(col)

    fig = plt.figure(figsize=(22, 7.5), facecolor='#13151b')
    
    views = [
        {
            'title': '1. First-Person Player View (True ADS Holographic Sightline)',
            'elev': 12, 'azim': -90, 'pos': 131,
            'aspect': (1.1, 1.7, 1.1)
        },
        {
            'title': '2. Hero 3/4 Perspective View (Kitsune Buster IX)',
            'elev': 18, 'azim': 38, 'pos': 132,
            'aspect': (1.1, 1.7, 1.1)
        },
        {
            'title': '3. Profile Elevation (Integrated Bayonet & Kyubi Drum)',
            'elev': 0, 'azim': 0, 'pos': 133,
            'aspect': (0.9, 1.7, 1.1)
        }
    ]
    
    light_dir = np.array([0.5, -0.3, 0.8])
    light_dir = light_dir / np.linalg.norm(light_dir)

    for v_cfg in views:
        ax = fig.add_subplot(v_cfg['pos'], projection='3d', facecolor='#13151b')
        ax.set_title(v_cfg['title'], color='#F0E6D2', fontsize=13, fontweight='bold', pad=14)
        
        ax.set_xlim(-0.45, 0.45)
        ax.set_ylim(-0.60, 1.20)
        ax.set_zlim(-0.15, 1.05)
        ax.view_init(elev=v_cfg['elev'], azim=v_cfg['azim'])
        ax.set_box_aspect(v_cfg['aspect'])
        fig.canvas.draw()
        
        cam_pos = ax._get_camera_loc()
        
        all_triangles = []
        all_colors = []
        all_centroids = []
        
        for prim in gltf['meshes'][0]['primitives']:
            verts = get_data(prim['attributes']['POSITION'])
            indices = get_data(prim['indices']).flatten()
            base_col = np.array(mat_colors[prim['material']][:3])
            
            # Map Godot coords:
            # X (width) -> X
            # Z (barrel length) -> Y
            # Y (height) -> Z
            m_verts = np.zeros_like(verts)
            m_verts[:, 0] = verts[:, 0] # X
            m_verts[:, 1] = verts[:, 2] # Z -> Y
            m_verts[:, 2] = verts[:, 1] # Y -> Z
            
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
            
            diff = np.maximum(0.20, np.dot(vis_normals, light_dir)) * 0.70 + 0.30
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
            # Painter sort: furthest first (descending distance)
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
    render_preview('assets/blaster_kitsune.glb', '/Users/ashj/.gemini/antigravity-ide/brain/e2b8cc3e-1b57-4579-91d4-5008b80a2449/kitsune_buster_preview.png')

