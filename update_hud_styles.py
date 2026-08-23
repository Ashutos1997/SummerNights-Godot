import re

with open('scenes/HUD.tscn', 'r') as f:
    content = f.read()

subresources = """
[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_leg_esc"]
bg_color = Color(1, 0.843, 0, 0.25)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(1, 0.843, 0, 0.9)
corner_radius_top_left = 2
corner_radius_top_right = 2
corner_radius_bottom_right = 2
corner_radius_bottom_left = 2

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_leg_tab"]
bg_color = Color(0.5, 0.9, 0.1, 0.25)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(0.5, 0.9, 0.1, 0.9)
corner_radius_top_left = 2
corner_radius_top_right = 2
corner_radius_bottom_right = 2
corner_radius_bottom_left = 2

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_leg_r"]
bg_color = Color(0.31, 0.765, 0.969, 0.25)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(0.31, 0.765, 0.969, 0.9)
corner_radius_top_left = 2
corner_radius_top_right = 2
corner_radius_bottom_right = 2
corner_radius_bottom_left = 2

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_leg_f"]
bg_color = Color(1, 0.427, 0, 0.25)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(1, 0.427, 0, 0.9)
corner_radius_top_left = 2
corner_radius_top_right = 2
corner_radius_bottom_right = 2
corner_radius_bottom_left = 2

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_leg_mouse"]
bg_color = Color(0.6, 0.6, 0.6, 0.25)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(0.6, 0.6, 0.6, 0.9)
corner_radius_top_left = 2
corner_radius_top_right = 2
corner_radius_bottom_right = 2
corner_radius_bottom_left = 2
"""

if "StyleBoxFlat_leg_esc" not in content:
    content = content.replace('[node name="CanvasLayer"', subresources + '\n[node name="CanvasLayer"')

replacement = """[node name="LegendRow" type="HBoxContainer" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer"]
layout_mode = 2
theme_override_constants/separation = 16
alignment = 1

[node name="LegPause" type="HBoxContainer" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow"]
layout_mode = 2
theme_override_constants/separation = 8
alignment = 1

[node name="Swatch" type="Panel" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegPause"]
custom_minimum_size = Vector2(16, 16)
layout_mode = 2
size_flags_vertical = 4
theme_override_styles/panel = SubResource("StyleBoxFlat_leg_esc")

[node name="Label" type="Label" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegPause"]
layout_mode = 2
theme_override_font_sizes/font_size = 20
text = "ESC - PAUSE"

[node name="LegWeapons" type="HBoxContainer" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow"]
layout_mode = 2
theme_override_constants/separation = 8
alignment = 1

[node name="Swatch" type="Panel" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegWeapons"]
custom_minimum_size = Vector2(16, 16)
layout_mode = 2
size_flags_vertical = 4
theme_override_styles/panel = SubResource("StyleBoxFlat_leg_tab")

[node name="Label" type="Label" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegWeapons"]
layout_mode = 2
theme_override_font_sizes/font_size = 20
text = "TAB - WEAPONS"

[node name="LegIceBlast" type="HBoxContainer" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow"]
layout_mode = 2
theme_override_constants/separation = 8
alignment = 1

[node name="Swatch" type="Panel" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegIceBlast"]
custom_minimum_size = Vector2(16, 16)
layout_mode = 2
size_flags_vertical = 4
theme_override_styles/panel = SubResource("StyleBoxFlat_leg_r")

[node name="Label" type="Label" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegIceBlast"]
layout_mode = 2
theme_override_font_sizes/font_size = 20
text = "R - ICE BLAST"

[node name="LegCatastrom" type="HBoxContainer" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow"]
layout_mode = 2
theme_override_constants/separation = 8
alignment = 1

[node name="Swatch" type="Panel" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegCatastrom"]
custom_minimum_size = Vector2(16, 16)
layout_mode = 2
size_flags_vertical = 4
theme_override_styles/panel = SubResource("StyleBoxFlat_leg_f")

[node name="Label" type="Label" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegCatastrom"]
layout_mode = 2
theme_override_font_sizes/font_size = 20
text = "F - CATASTROM"

[node name="LegMouse" type="HBoxContainer" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow"]
layout_mode = 2
theme_override_constants/separation = 8
alignment = 1

[node name="Swatch" type="Panel" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegMouse"]
custom_minimum_size = Vector2(16, 16)
layout_mode = 2
size_flags_vertical = 4
theme_override_styles/panel = SubResource("StyleBoxFlat_leg_mouse")

[node name="Label" type="Label" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegMouse"]
layout_mode = 2
theme_override_font_sizes/font_size = 20
text = "MOUSE - AIM/SHOOT"

[node name="SpacerBottom" type="Control" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer"]
custom_minimum_size = Vector2(0, 8)
layout_mode = 2
"""

pattern = r'\[node name="LegendRow".*?(?=\[node name="Divider2")'
content = re.sub(pattern, replacement + '\n', content, flags=re.DOTALL)

with open('scenes/HUD.tscn', 'w') as f:
    f.write(content)
