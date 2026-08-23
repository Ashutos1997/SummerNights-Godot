import re

with open('scenes/HUD.tscn', 'r') as f:
    content = f.read()

# First, extract the KeyboardLayout block to replace the labels in it.
# We will just write a python script to replace the entire KeyboardLayout block.
replacement = """[node name="KeyboardLayout" type="Control" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer"]
custom_minimum_size = Vector2(534, 231)
layout_mode = 2

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
offset_left = -20.0
offset_top = 8.0
offset_right = 45.0
offset_bottom = 31.0
theme_override_colors/font_color = Color(1, 0.843, 0, 1)
theme_override_font_sizes/font_size = 24
text = "PAUSE"
horizontal_alignment = 2

[node name="TabLabel" type="Label" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/KeyboardLayout"]
layout_mode = 0
offset_left = -20.0
offset_top = 98.0
offset_right = 45.0
offset_bottom = 121.0
theme_override_colors/font_color = Color(1, 0.843, 0, 1)
theme_override_font_sizes/font_size = 24
text = "WEAPONS"
horizontal_alignment = 2

[node name="RLabel" type="Label" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/KeyboardLayout"]
layout_mode = 0
offset_left = 208.0
offset_top = 8.0
offset_right = 320.0
offset_bottom = 31.0
theme_override_colors/font_color = Color(0.31, 0.765, 0.969, 1)
theme_override_font_sizes/font_size = 24
text = "ICE BLAST"

[node name="FLabel" type="Label" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/KeyboardLayout"]
layout_mode = 0
offset_left = 213.0
offset_top = 211.0
offset_right = 320.0
offset_bottom = 234.0
theme_override_colors/font_color = Color(1, 0.427, 0, 1)
theme_override_font_sizes/font_size = 24
text = "CATASTROM"

[node name="MouseGroup" type="Control" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/KeyboardLayout"]
layout_mode = 1
anchors_preset = 11
anchor_left = 1.0
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = -5.0
offset_top = 85.0
offset_right = 145.0
grow_horizontal = 0
grow_vertical = 2

[node name="MouseTitle" type="Label" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/KeyboardLayout/MouseGroup"]
layout_mode = 0
offset_left = 0.0
offset_top = 0.0
offset_right = 150.0
offset_bottom = 23.0
theme_override_font_sizes/font_size = 24
text = "MOUSE"
horizontal_alignment = 1

[node name="MouseMoves" type="Label" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/KeyboardLayout/MouseGroup"]
layout_mode = 0
offset_left = 0.0
offset_top = 20.0
offset_right = 150.0
offset_bottom = 43.0
theme_override_colors/font_color = Color(1, 0.843, 0, 1)
theme_override_font_sizes/font_size = 24
text = "AIM / MOVE"
horizontal_alignment = 1

[node name="MouseL" type="Label" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/KeyboardLayout/MouseGroup"]
layout_mode = 0
offset_left = 0.0
offset_top = 40.0
offset_right = 150.0
offset_bottom = 63.0
theme_override_colors/font_color = Color(1, 0.843, 0, 1)
theme_override_font_sizes/font_size = 24
text = "L: SHOOT"
horizontal_alignment = 1

[node name="MouseR" type="Label" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/KeyboardLayout/MouseGroup"]
layout_mode = 0
offset_left = 0.0
offset_top = 60.0
offset_right = 150.0
offset_bottom = 83.0
theme_override_colors/font_color = Color(0.31, 0.765, 0.969, 1)
theme_override_font_sizes/font_size = 24
text = "R: ICE BLAST"
horizontal_alignment = 1"""

pattern = r'\[node name="KeyboardLayout" type="Control" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer"\].*?horizontal_alignment = 1'
content = re.sub(pattern, replacement, content, flags=re.DOTALL)

with open('scenes/HUD.tscn', 'w') as f:
    f.write(content)
