import re

with open('scenes/HUD.tscn', 'r') as f:
    content = f.read()

# The SpacerBottom node looks like this:
# [node name="SpacerBottom" type="Control" parent="HUD/ControllerScreen/CenterContainer/VBoxContainer"]
# custom_minimum_size = Vector2(0, 8)
# layout_mode = 2

# I will just match it and replace it with an empty string
pattern = r'\[node name="SpacerBottom".*?layout_mode = 2\n\n'
content = re.sub(pattern, '', content, flags=re.DOTALL)

with open('scenes/HUD.tscn', 'w') as f:
    f.write(content)
