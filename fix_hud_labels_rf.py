with open('scenes/HUD.tscn', 'r') as f:
    content = f.read()

content = content.replace('text = "Q - ICE BLAST"', 'text = "R - ICE BLAST"')
content = content.replace('text = "W - CATASTROM"', 'text = "F - CATASTROM"')

with open('scenes/HUD.tscn', 'w') as f:
    f.write(content)
