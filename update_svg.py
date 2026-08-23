import re

with open('assets/ui/controller/Keyboard_controls.svg', 'r') as f:
    svg = f.read()

# Remove old text tags
svg = re.sub(r'<text.*?</text>', '', svg, flags=re.DOTALL)

# Update viewBox
svg = svg.replace('viewBox="0 0 823 340"', 'viewBox="-120 -60 1063 460"')
svg = svg.replace('width="823" height="340"', 'width="1063" height="460"')

# Add elbow lines before </g>
elbow_lines = """
<!-- Elbow lines -->
<polyline points="52,39 52,-20 -10,-20" fill="none" stroke="#FFD700" stroke-width="3" stroke-linejoin="round"/>
<circle cx="-10" cy="-20" r="4" fill="#FFD700"/>

<polyline points="42,158 -10,158" fill="none" stroke="#FFD700" stroke-width="3" stroke-linejoin="round"/>
<circle cx="-10" cy="158" r="4" fill="#FFD700"/>

<polyline points="239,143 239,-20 280,-20" fill="none" stroke="#4FC3F7" stroke-width="3" stroke-linejoin="round"/>
<circle cx="280" cy="-20" r="4" fill="#4FC3F7"/>

<polyline points="249,213 249,380 290,380" fill="none" stroke="#FF6D00" stroke-width="3" stroke-linejoin="round"/>
<circle cx="290" cy="380" r="4" fill="#FF6D00"/>
"""

svg = svg.replace('</g>', elbow_lines + '\n</g>')

with open('assets/ui/controller/Keyboard_controls.svg', 'w') as f:
    f.write(svg)
