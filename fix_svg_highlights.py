import xml.etree.ElementTree as ET
import re

svg_file = 'assets/ui/controller/Keyboard_controls.svg'
with open(svg_file, 'r') as f:
    content = f.read()

# Remove any existing manual highlights I added previously (the duplicated paths with fills)
# I will just match paths that have fill="#FFD700" or similar and remove them
content = re.sub(r'<path[^>]+fill="#(FFD700|4FC3F7|FF6D00)"[^>]+/>\s*', '', content)

# Now I'll add the new highlights. I need to find the paths for Esc, Tab, Q, W
# Esc: M41 39
# Tab: M41 101 (wait, let's assume M41 101 is Tab, M83 101 is Q, M125 101 is W)
# I will append new paths right before </g>

highlights = """
<path d="M41 39H63C64.6569 39 66 40.3431 66 42V59C66 64.5228 61.5228 69 56 69H48C42.4772 69 38 64.5228 38 59V42C38 40.3431 39.3431 39 41 39Z" fill="#FFD700" fill-opacity="0.25" stroke="#FFD700" stroke-opacity="0.9" stroke-width="2"/>
<path d="M41 101H63C64.6569 101 66 102.343 66 104V121C66 126.523 61.5228 131 56 131H48C42.4772 131 38 126.523 38 121V104C38 102.343 39.3431 101 41 101Z" fill="#FFD700" fill-opacity="0.25" stroke="#FFD700" stroke-opacity="0.9" stroke-width="2"/>
<path d="M83 101H105C106.657 101 108 102.343 108 104V121C108 126.523 103.523 131 98 131H90C84.4772 131 80 126.523 80 121V104C80 102.343 81.3431 101 83 101Z" fill="#4FC3F7" fill-opacity="0.25" stroke="#4FC3F7" stroke-opacity="0.9" stroke-width="2"/>
<path d="M125 101H147C148.657 101 150 102.343 150 104V121C150 126.523 145.523 131 140 131H132C126.477 131 122 126.523 122 121V104C122 102.343 123.343 101 125 101Z" fill="#FF6D00" fill-opacity="0.25" stroke="#FF6D00" stroke-opacity="0.9" stroke-width="2"/>
"""

content = content.replace('</g>', highlights + '\n</g>')

with open(svg_file, 'w') as f:
    f.write(content)
