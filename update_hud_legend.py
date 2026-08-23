import re

with open('scenes/HUD.tscn', 'r') as f:
    content = f.read()

replacement = """[node name="KeyboardLayout" type="Control" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer"]
custom_minimum_size = Vector2(559, 231)
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

[node name="LegendRow" type="HBoxContainer" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer"]
layout_mode = 2
theme_override_constants/separation = 24
alignment = 1

[node name="LegPause" type="HBoxContainer" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow"]
layout_mode = 2
theme_override_constants/separation = 8
alignment = 1

[node name="Swatch" type="ColorRect" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegPause"]
custom_minimum_size = Vector2(16, 16)
layout_mode = 2
size_flags_vertical = 4
color = Color(1, 0.843, 0, 1)

[node name="Label" type="Label" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegPause"]
layout_mode = 2
theme_override_font_sizes/font_size = 24
text = "ESC - PAUSE"

[node name="LegWeapons" type="HBoxContainer" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow"]
layout_mode = 2
theme_override_constants/separation = 8
alignment = 1

[node name="Swatch" type="ColorRect" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegWeapons"]
custom_minimum_size = Vector2(16, 16)
layout_mode = 2
size_flags_vertical = 4
color = Color(1, 0.843, 0, 1)

[node name="Label" type="Label" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegWeapons"]
layout_mode = 2
theme_override_font_sizes/font_size = 24
text = "TAB - WEAPONS"

[node name="LegIceBlast" type="HBoxContainer" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow"]
layout_mode = 2
theme_override_constants/separation = 8
alignment = 1

[node name="Swatch" type="ColorRect" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegIceBlast"]
custom_minimum_size = Vector2(16, 16)
layout_mode = 2
size_flags_vertical = 4
color = Color(0.31, 0.765, 0.969, 1)

[node name="Label" type="Label" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegIceBlast"]
layout_mode = 2
theme_override_font_sizes/font_size = 24
text = "Q - ICE BLAST"

[node name="LegCatastrom" type="HBoxContainer" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow"]
layout_mode = 2
theme_override_constants/separation = 8
alignment = 1

[node name="Swatch" type="ColorRect" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegCatastrom"]
custom_minimum_size = Vector2(16, 16)
layout_mode = 2
size_flags_vertical = 4
color = Color(1, 0.427, 0, 1)

[node name="Label" type="Label" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegCatastrom"]
layout_mode = 2
theme_override_font_sizes/font_size = 24
text = "W - CATASTROM"

[node name="LegMouse" type="HBoxContainer" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow"]
layout_mode = 2
theme_override_constants/separation = 8
alignment = 1

[node name="Swatch" type="ColorRect" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegMouse"]
custom_minimum_size = Vector2(16, 16)
layout_mode = 2
size_flags_vertical = 4
color = Color(0.6, 0.6, 0.6, 1)

[node name="Label" type="Label" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegMouse"]
layout_mode = 2
theme_override_font_sizes/font_size = 24
text = "MOUSE - AIM/SHOOT"
"""

pattern = r'\[node name="KeyboardLayout".*?(?=\[node name="Divider2")'
content = re.sub(pattern, replacement + '\n', content, flags=re.DOTALL)

with open('scenes/HUD.tscn', 'w') as f:
    f.write(content)
