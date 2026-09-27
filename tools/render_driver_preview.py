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
            'title': 'Solar Driver & Belt — Front View (Player View)',
            'elev': 10, 'azim': -90, 'pos': 131
        },
        {
            'title': 'Solar Driver & Belt — 3/4 Perspective Angle',
            'elev': 25, 'azim': -55, 'pos': 132
        },
        {
            'title': 'Solar Driver & Belt — Top-Down Planetary Ring Profile',
            'elev': 70, 'azim': -90, 'pos': 133
        }
    ]
    
    for v in views:
        ax = fig.add_subplot(v['pos'], projection='3d', facecolor='#0b0d14')
        ax.set_title(v['title'], color='#ffcc33', fontsize=14, pad=14, fontweight='bold', fontfamily='sans-serif')
        ax.view_init(elev=v['elev'], azim=v['azim'])
        
        ax.set_axis_off()
        ax.set_box_aspect([1, 1, 0.35])
        
        for mesh in gltf.get('meshes', []):
            for prim in mesh.get('primitives', []):
                pos_idx = prim['attributes']['POSITION']
                idx_idx = prim.get('indices')
                mat_idx = prim.get('material', 0)
                
                pos = get_data(pos_idx)
                indices = get_data(idx_idx).flatten().astype(int)
                
                tri_verts = pos[indices].reshape(-1, 3, 3)
                
                color = mat_colors[mat_idx] if mat_idx < len(mat_colors) else [0.8, 0.8, 0.8, 1.0]
                
                poly = Poly3DCollection(tri_verts, alpha=1.0)
                poly.set_facecolor(color)
                poly.set_edgecolor([c * 0.45 for c in color[:3]] + [0.4])
                poly.set_linewidth(0.2)
                ax.add_collection3d(poly)
                
        ax.set_xlim(-9.0, 9.0)
        ax.set_ylim(-9.0, 9.0)
        ax.set_zlim(-3.0, 3.0)

    plt.tight_layout()
    os.makedirs(os.path.dirname(output_png), exist_ok=True)
    plt.savefig(output_png, dpi=160, facecolor='#0b0d14', edgecolor='none')
    plt.close()
    print(f"[OK] Saved preview rendering to: {output_png}")

if __name__ == "__main__":
    glb = os.path.abspath("assets/models/solar_driver.glb")
    png = os.path.abspath("assets/models/solar_driver_preview.png")
    render_driver_preview(glb, png)
