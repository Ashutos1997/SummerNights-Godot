import sys

with open('scenes/HUD.tscn', 'r') as f:
    lines = f.read().splitlines()

# Find last ext_resource
last_ext_idx = -1
for i, line in enumerate(lines):
    if line.startswith('[ext_resource'):
        last_ext_idx = i

if last_ext_idx != -1:
    lines.insert(last_ext_idx + 1, '[ext_resource type="Texture2D" path="res://assets/ui/controller/Keyboard.svg" id="92_keyboard"]')

# Find the Divider inside ControllerScreen
divider_idx = -1
for i, line in enumerate(lines):
    if line.startswith('[node name="Divider" type="HSeparator" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer"]'):
        divider_idx = i
        break

if divider_idx != -1:
    # find the end of the Divider node block (next node)
    insert_idx = divider_idx
    while insert_idx < len(lines) and not lines[insert_idx].startswith('[node name="Divider2"'):
        insert_idx += 1
    
    node_str = """
[node name="KeyboardLayout" type="TextureRect" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer"]
custom_minimum_size = Vector2(500, 250)
layout_mode = 2
texture = ExtResource("92_keyboard")
expand_mode = 1
stretch_mode = 5
"""
    lines = lines[:insert_idx] + node_str.strip('\n').split('\n') + [''] + lines[insert_idx:]

with open('scenes/HUD.tscn', 'w') as f:
    f.write('\n'.join(lines) + '\n')
