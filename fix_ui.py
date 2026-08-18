import re

with open('scenes/HUD.tscn', 'r') as f:
    content = f.read()

# Remove SpacerCore from CreditsScreen
content = re.sub(r'\[node name="SpacerCore" type="Control" parent="HUD/CreditsScreen/CenterContainer/VBoxContainer/ScrollArea/CreditsList"\]\nlayout_mode = 2\nmouse_filter = 2\ncustom_minimum_size = Vector2\(0, 16\)\n\n', '', content)

with open('scenes/HUD.tscn', 'w') as f:
    f.write(content)
