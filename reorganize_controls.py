import sys

tscn_path = "scenes/HUD.tscn"
with open(tscn_path, "r") as f:
    content = f.read()

# We need to replace:
# [node name="KeyboardLayout" type="Control" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer"]
# with:
# [node name="ContentRow" type="HBoxContainer" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer"]
# layout_mode = 2
# theme_override_constants/separation = 48
# alignment = 1
#
# [node name="LegendColumn" type="VBoxContainer" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/ContentRow"]
# layout_mode = 2
# theme_override_constants/separation = 16
# alignment = 1
# 
# [node name="KeyboardLayout" type="Control" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/ContentRow"]

# First, replace the KeyboardLayout header
content = content.replace(
    '[node name="KeyboardLayout" type="Control" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer"]',
    '[node name="ContentRow" type="HBoxContainer" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer"]\n'
    'layout_mode = 2\n'
    'theme_override_constants/separation = 48\n'
    'alignment = 1\n\n'
    '[node name="LegendColumn" type="VBoxContainer" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/ContentRow"]\n'
    'layout_mode = 2\n'
    'theme_override_constants/separation = 16\n'
    'alignment = 1\n\n'
    '[node name="KeyboardLayout" type="Control" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/ContentRow"]'
)

# Now, replace the parents of KeyboardLayout children
content = content.replace(
    'parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/KeyboardLayout"',
    'parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/ContentRow/KeyboardLayout"'
)

# Now, we need to remove the LegendRow node definition.
# [node name="LegendRow" type="HBoxContainer" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer"]
# layout_mode = 2
# theme_override_constants/separation = 16
# alignment = 1
content = content.replace(
    '[node name="LegendRow" type="HBoxContainer" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer"]\n'
    'layout_mode = 2\n'
    'theme_override_constants/separation = 16\n'
    'alignment = 1\n\n',
    ''
)

# Now, replace the parents of LegendRow children to be LegendColumn
content = content.replace(
    'parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow"',
    'parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/ContentRow/LegendColumn"'
)
content = content.replace(
    'parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegPause"',
    'parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/ContentRow/LegendColumn/LegPause"'
)
content = content.replace(
    'parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegWeapons"',
    'parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/ContentRow/LegendColumn/LegWeapons"'
)
content = content.replace(
    'parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegIceBlast"',
    'parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/ContentRow/LegendColumn/LegIceBlast"'
)
content = content.replace(
    'parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegCatastrom"',
    'parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/ContentRow/LegendColumn/LegCatastrom"'
)
content = content.replace(
    'parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/LegendRow/LegMouse"',
    'parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/ContentRow/LegendColumn/LegMouse"'
)

with open(tscn_path, "w") as f:
    f.write(content)

print("Done")
