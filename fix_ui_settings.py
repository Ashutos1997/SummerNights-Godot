import re

with open('scenes/HUD.tscn', 'r') as f:
    content = f.read()

# Change separation of SettingsScreen VBoxContainer from 24 to 16
content = re.sub(
    r'\[node name="VBoxContainer" type="VBoxContainer" parent="HUD/SettingsScreen/CenterContainer"\]\ncustom_minimum_size = Vector2\(560, 0\)\nlayout_mode = 2\nmouse_filter = 2\nalignment = 1\ntheme_override_constants/separation = 24',
    r'[node name="VBoxContainer" type="VBoxContainer" parent="HUD/SettingsScreen/CenterContainer"]\ncustom_minimum_size = Vector2(560, 0)\nlayout_mode = 2\nmouse_filter = 2\nalignment = 1\ntheme_override_constants/separation = 16',
    content
)

with open('scenes/HUD.tscn', 'w') as f:
    f.write(content)
