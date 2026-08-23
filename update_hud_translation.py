import re

with open('scripts/HUD.gd', 'r') as f:
    content = f.read()

# Replace Controller -> Controls for Button
content = content.replace(
    'controller_btn.text = "컨트롤러" if is_kr else "CONTROLLER"',
    'controller_btn.text = "조작법" if is_kr else "CONTROLS"'
)

# Replace Controller -> Controls for Title
content = content.replace(
    'controller_title.text = "컨트롤러" if is_kr else "CONTROLLER"',
    'controller_title.text = "조작법" if is_kr else "CONTROLS"'
)

# Add Legend Translation
legend_translation = """
	var leg_pause = controller_screen.get_node_or_null("CenterContainer/VBoxContainer/LegendRow/LegPause/Label")
	if leg_pause:
		leg_pause.text = "ESC - 일시정지" if is_kr else "ESC - PAUSE"
		if font: leg_pause.add_theme_font_override("font", font)

	var leg_weapons = controller_screen.get_node_or_null("CenterContainer/VBoxContainer/LegendRow/LegWeapons/Label")
	if leg_weapons:
		leg_weapons.text = "TAB - 무기 변경" if is_kr else "TAB - WEAPONS"
		if font: leg_weapons.add_theme_font_override("font", font)

	var leg_ice = controller_screen.get_node_or_null("CenterContainer/VBoxContainer/LegendRow/LegIceBlast/Label")
	if leg_ice:
		leg_ice.text = "R - 얼음 폭발" if is_kr else "R - ICE BLAST"
		if font: leg_ice.add_theme_font_override("font", font)

	var leg_catastrom = controller_screen.get_node_or_null("CenterContainer/VBoxContainer/LegendRow/LegCatastrom/Label")
	if leg_catastrom:
		leg_catastrom.text = "F - 카타스트롬" if is_kr else "F - CATASTROM"
		if font: leg_catastrom.add_theme_font_override("font", font)

	var leg_mouse = controller_screen.get_node_or_null("CenterContainer/VBoxContainer/LegendRow/LegMouse/Label")
	if leg_mouse:
		leg_mouse.text = "MOUSE - 조준/발사" if is_kr else "MOUSE - AIM/SHOOT"
		if font: leg_mouse.add_theme_font_override("font", font)
"""

# Insert right after controller_title translation
insert_point = 'if controller_title:\n\t\tcontroller_title.text = "조작법" if is_kr else "CONTROLS"'
if insert_point in content and "LegPause" not in content:
    parts = content.split(insert_point)
    content = parts[0] + insert_point + legend_translation + parts[1]
elif 'controller_title.text = "조작법" if is_kr else "CONTROLS"' in content and "LegPause" not in content:
    # Fallback insertion
    parts = content.split('controller_title.text = "조작법" if is_kr else "CONTROLS"')
    content = parts[0] + 'controller_title.text = "조작법" if is_kr else "CONTROLS"' + legend_translation + parts[1]

with open('scripts/HUD.gd', 'w') as f:
    f.write(content)
