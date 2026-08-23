import re

with open('scenes/HUD.tscn', 'r') as f:
    content = f.read()

replacement = """[node name="KeyboardLayout" type="Control" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer"]
custom_minimum_size = Vector2(559, 231)
layout_mode = 2
script = ExtResource("98_keyboard")

[node name="TextureRect" type="TextureRect" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/KeyboardLayout"]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
texture = ExtResource("92_keyboard_controls")
expand_mode = 1
stretch_mode = 5

[node name="EscLabel" type="Label" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/KeyboardLayout"]
layout_mode = 0
offset_left = -30.0
offset_top = 10.0
theme_override_colors/font_color = Color(1, 0.843, 0, 1)
theme_override_font_sizes/font_size = 24
text = "PAUSE"

[node name="TabLabel" type="Label" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/KeyboardLayout"]
layout_mode = 0
offset_left = -60.0
offset_top = 95.0
theme_override_colors/font_color = Color(1, 0.843, 0, 1)
theme_override_font_sizes/font_size = 24
text = "WEAPONS"

[node name="RLabel" type="Label" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/KeyboardLayout"]
layout_mode = 0
offset_left = 180.0
offset_top = 10.0
theme_override_colors/font_color = Color(0.31, 0.765, 0.969, 1)
theme_override_font_sizes/font_size = 24
text = "ICE BLAST"

[node name="FLabel" type="Label" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/KeyboardLayout"]
layout_mode = 0
offset_left = 180.0
offset_top = 190.0
theme_override_colors/font_color = Color(1, 0.427, 0, 1)
theme_override_font_sizes/font_size = 24
text = "CATASTROM"
"""

pattern = r'\[node name="KeyboardLayout".*?(?=\[node name="Divider2")'
content = re.sub(pattern, replacement + '\n', content, flags=re.DOTALL)

script_res = '[ext_resource type="Script" path="res://scripts/ControllerKeyboard.gd" id="98_keyboard"]\n'
content = content.replace('[ext_resource type="Texture2D"', script_res + '[ext_resource type="Texture2D"', 1)

bg_pattern = r'(\[node name="BG" type="ColorRect" parent="HUD/ControllerScreen"\].*?color = Color\()[0-9., ]+(\))'
content = re.sub(bg_pattern, r'\g<1>0.02, 0.01, 0.05, 1.0\g<2>', content, flags=re.DOTALL)

with open('scenes/HUD.tscn', 'w') as f:
    f.write(content)
