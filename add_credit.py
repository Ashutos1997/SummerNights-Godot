import re

with open('scenes/HUD.tscn', 'r') as f:
    content = f.read()

credit_node = """[node name="ItmUI1c" type="Label" parent="HUD/CreditsScreen/CenterContainer/VBoxContainer/ScrollArea/CreditsList"]
layout_mode = 2
mouse_filter = 2
theme_override_colors/font_color = Color(1, 1, 1, 0.85)
theme_override_font_sizes/font_size = 12
text = "Keyboard SVG  ·  Oscar Nilsson  ·  CC0"
horizontal_alignment = 1

"""

# Insert it right after ItmUI1b
pattern = r'(\[node name="ItmUI1b".*?horizontal_alignment = 1\n)'
content = re.sub(pattern, r'\1\n' + credit_node, content, flags=re.DOTALL)

with open('scenes/HUD.tscn', 'w') as f:
    f.write(content)
