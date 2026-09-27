#!/usr/bin/env python3
import struct
import json
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
import os

def render_helmet_preview(glb_path, output_png):
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
            'title': 'Kamen Rider Solar Helmet — Front View (Player View)',
            'elev': 12, 'azim': -90, 'pos': 131
        },
        {
            'title': 'Kamen Rider Solar Helmet — 3/4 Perspective Angle',
            'elev': 22, 'azim': -55, 'pos': 132
        },
        {
            'title': 'Kamen Rider Solar Helmet — Top-Down Crown Profile',
            'elev': 65, 'azim': -90, 'pos': 133
        }
    ]
    
    for v in views:
        ax = fig.add_subplot(v['pos'], projection='3d', facecolor='#0b0d14')
        ax.set_title(v['title'], color='#ffcc33', fontsize=14, pad=14, fontweight='bold', fontfamily='sans-serif')
        ax.view_init(elev=v['elev'], azim=v['azim'])
        
        for mesh in gltf.get('meshes', []):
            for prim in mesh.get('primitives', []):
                pos_idx = prim['attributes']['POSITION']
                idx_idx = prim['indices']
                mat_idx = prim.get('material', 0)
                
                verts = get_data(pos_idx)
                indices = get_data(idx_idx).flatten()
                
                tri_verts = verts[indices].reshape(-1, 3, 3)
                color = mat_colors[mat_idx] if mat_idx < len(mat_colors) else [0.7, 0.7, 0.7, 1.0]
                
                edge_col = [c * 0.5 for c in color[:3]] + [0.4]
                poly = Poly3DCollection(tri_verts, facecolors=color, edgecolors=edge_col, linewidths=0.3, alpha=1.0)
                ax.add_collection3d(poly)
                
        ax.set_xlim([-10, 10])
        ax.set_ylim([-5, 15])
        ax.set_zlim([0, 12])
        ax.set_axis_off()
        ax.grid(False)

    plt.tight_layout()
    os.makedirs(os.path.dirname(output_png), exist_ok=True)
    plt.savefig(output_png, dpi=150, facecolor=fig.get_facecolor(), edgecolor='none', bbox_inches='tight')
    plt.close()
    print(f"[OK] Saved preview rendering to: {output_png}")

if __name__ == '__main__':
    render_helmet_preview(
        'assets/models/solar_helmet.glb',
        'assets/models/solar_helmet_preview.png'
    )
