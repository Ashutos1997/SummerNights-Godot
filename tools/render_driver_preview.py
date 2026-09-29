#!/usr/bin/env python3
import struct
import json
import math
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
import os

def render_driver_preview(glb_path, output_png):
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
        if any(e > 0.05 for e in emissive):
            col = [min(1.0, c * 0.6 + e * 0.6) for c, e in zip(col[:3], emissive)] + [1.0]
        mat_colors.append(col[:4])

    fig = plt.figure(figsize=(24, 8), facecolor='#0b0d14')
    
    views = [
        {
            'title': 'Solar Driver Buckle — Front View (Central Sun & Flanks)',
            'elev': 2, 'azim': 90, 'pos': 131,
            'xlim': (-3.6, 3.6), 'ylim': (-2.5, 2.5), 'zlim': (-1.8, 1.8),
            'aspect': [2.0, 1.2, 1.0], 'center_buckle': True
        },
        {
            'title': 'Solar Driver Buckle — 3/4 Perspective Angle',
            'elev': 20, 'azim': 65, 'pos': 132,
            'xlim': (-3.6, 3.6), 'ylim': (-2.5, 2.5), 'zlim': (-1.8, 1.8),
            'aspect': [2.0, 1.2, 1.0], 'center_buckle': True
        },
        {
            'title': 'Equatorial Planetary Belt & Driver — Full Overview',
            'elev': 28, 'azim': 80, 'pos': 133,
            'xlim': (-9.5, 9.5), 'ylim': (-9.5, 9.5), 'zlim': (-3.0, 3.0),
            'aspect': [1.0, 1.0, 0.35], 'center_buckle': False
        }
    ]
    
    for v in views:
        ax = fig.add_subplot(v['pos'], projection='3d', facecolor='#0b0d14')
        ax.set_title(v['title'], color='#ffcc33', fontsize=13, pad=12, fontweight='bold', fontfamily='sans-serif')
        ax.view_init(elev=v['elev'], azim=v['azim'])
        
        ax.set_axis_off()
        ax.set_box_aspect(v['aspect'])
        
        all_tris = []
        all_colors = []
        
        for mesh in gltf.get('meshes', []):
            for prim in mesh.get('primitives', []):
                pos_idx = prim['attributes']['POSITION']
                idx_idx = prim.get('indices')
                mat_idx = prim.get('material', 0)
                
                pos = get_data(pos_idx)
                indices = get_data(idx_idx).flatten().astype(int)
                
                # Map Godot coords (X, Y_up, Z_depth) -> Matplotlib 3D (X, Y_depth, Z_up)
                pts_transformed = np.stack([pos[:, 0], pos[:, 2], pos[:, 1]], axis=-1).copy()
                if v.get('center_buckle', False):
                    pts_transformed[:, 1] -= 7.28 # Center buckle at depth origin
                tri_verts = pts_transformed[indices].reshape(-1, 3, 3)
                
                color = mat_colors[mat_idx] if mat_idx < len(mat_colors) else [0.8, 0.8, 0.8, 1.0]
                n_tris = len(tri_verts)
                all_tris.extend(tri_verts)
                all_colors.extend([color] * n_tris)
                
        poly = Poly3DCollection(all_tris, alpha=1.0)
        poly.set_facecolor(all_colors)
        poly.set_edgecolor([[c * 0.45 for c in col[:3]] + [0.35] for col in all_colors])
        poly.set_linewidth(0.15)
        ax.add_collection3d(poly)
                
        ax.set_xlim(v['xlim'])
        ax.set_ylim(v['ylim'])
        ax.set_zlim(v['zlim'])

    plt.tight_layout()
    os.makedirs(os.path.dirname(output_png), exist_ok=True)
    plt.savefig(output_png, dpi=160, facecolor='#0b0d14', edgecolor='none')
    plt.close()
    print(f"[OK] Saved preview rendering to: {output_png}")

if __name__ == "__main__":
    glb = os.path.abspath("assets/models/solar_driver.glb")
    png = os.path.abspath("assets/models/solar_driver_preview.png")
    render_driver_preview(glb, png)
