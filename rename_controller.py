import re

with open('scenes/HUD.tscn', 'r') as f:
    content = f.read()

# Replace ControllerBtn text
pattern1 = r'(\[node name="ControllerBtn" type="Button" parent="HUD/pause_screen/ColorRect/CenterContainer/VBoxContainer"\].*?text = ")CONTROLLER(")'
content = re.sub(pattern1, r'\g<1>CONTROLS\g<2>', content, flags=re.DOTALL)

# Replace Title text
pattern2 = r'(\[node name="Title" type="Label" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer/TitleRow"\].*?text = ")CONTROLLER(")'
content = re.sub(pattern2, r'\g<1>CONTROLS\g<2>', content, flags=re.DOTALL)

with open('scenes/HUD.tscn', 'w') as f:
    f.write(content)
