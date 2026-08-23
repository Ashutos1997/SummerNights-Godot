import xml.etree.ElementTree as ET
import re

svg_file = 'assets/ui/controller/Keyboard_controls.svg'
with open(svg_file, 'r') as f:
    content = f.read()

content = re.sub(r'<path[^>]+fill="#(FFD700|4FC3F7|FF6D00|80E51A)"[^>]+/>\s*', '', content)

# ESC: Yellow (#FFD700)
# TAB: Lime Green (#80E51A)
# R: Blue (#4FC3F7)
# F: Orange (#FF6D00)
highlights = """
<path d="M41 39H63C64.6569 39 66 40.3431 66 42V59C66 64.5228 61.5228 69 56 69H48C42.4772 69 38 64.5228 38 59V42C38 40.3431 39.3431 39 41 39Z" fill="#FFD700" fill-opacity="0.25" stroke="#FFD700" stroke-opacity="0.9" stroke-width="2"/>
<path d="M41 101H63C64.6569 101 66 102.343 66 104V121C66 126.523 61.5228 131 56 131H48C42.4772 131 38 126.523 38 121V104C38 102.343 39.3431 101 41 101Z" fill="#80E51A" fill-opacity="0.25" stroke="#80E51A" stroke-opacity="0.9" stroke-width="2"/>
<path d="M209 101H231C232.657 101 234 102.343 234 104V121C234 126.523 229.523 131 224 131H216C210.477 131 206 126.523 206 121V104C206 102.343 207.343 101 209 101Z" fill="#4FC3F7" fill-opacity="0.25" stroke="#4FC3F7" stroke-opacity="0.9" stroke-width="2"/>
<path d="M228 143H250C251.657 143 253 144.343 253 146V163C253 168.523 248.523 173 243 173H235C229.477 173 225 168.523 225 163V146C225 144.343 226.343 143 228 143Z" fill="#FF6D00" fill-opacity="0.25" stroke="#FF6D00" stroke-opacity="0.9" stroke-width="2"/>
"""

content = content.replace('</g>', highlights + '\n</g>')

with open(svg_file, 'w') as f:
    f.write(content)
