import xml.etree.ElementTree as ET
tree = ET.parse('assets/ui/controller/Keyboard_controls.svg')
root = tree.getroot()
ns = {'svg': 'http://www.w3.org/2000/svg'}
paths = root.findall('.//svg:path', ns)
for p in paths:
    d = p.get('d')
    if d.startswith('M41 101') or d.startswith('M83 101') or d.startswith('M125 101'):
        print(d[:30])
