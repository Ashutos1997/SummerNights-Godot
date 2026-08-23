import re

with open('assets/ui/controller/Keyboard_controls.svg', 'r') as f:
    svg = f.read()

# Remove the elbow lines and circles
svg = re.sub(r'<!-- Elbow lines -->.*?</g>', '</g>', svg, flags=re.DOTALL)

# Restore viewBox
svg = svg.replace('viewBox="-120 -60 1063 460"', 'viewBox="0 0 823 340"')
svg = svg.replace('width="1063" height="460"', 'width="823" height="340"')

with open('assets/ui/controller/Keyboard_controls.svg', 'w') as f:
    f.write(svg)
