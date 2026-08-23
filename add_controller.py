import re

with open('scenes/HUD.tscn', 'r') as f:
    lines = f.read().splitlines()

# 1. Find MainMenuBtn and insert ControllerBtn before it
main_menu_idx = -1
for i, line in enumerate(lines):
    if line.startswith('[node name="MainMenuBtn" type="Button" parent="HUD/pause_screen/ColorRect/VBoxContainer"]'):
        main_menu_idx = i
        break

if main_menu_idx != -1:
    btn_code = [
        '[node name="ControllerBtn" type="Button" parent="HUD/pause_screen/ColorRect/VBoxContainer"]',
        'custom_minimum_size = Vector2(280, 52)',
        'layout_mode = 2',
        'mouse_filter = 0',
        'text = "CONTROLLER"',
        ''
    ]
    lines = lines[:main_menu_idx] + btn_code + lines[main_menu_idx:]

# 2. Extract SettingsScreen
settings_start = -1
settings_end = -1
for i, line in enumerate(lines):
    if line.startswith('[node name="SettingsScreen" type="Control" parent="HUD"]'):
        settings_start = i
    if settings_start != -1 and line.startswith('[node name="WinScreen" type="Control" parent="HUD"]'):
        settings_end = i
        break

settings_lines = lines[settings_start:settings_end]

# 3. Create ControllerScreen
controller_lines = []
skip = False
for line in settings_lines:
    if line.startswith('[node name="RowSFX"'):
        skip = True
    elif line.startswith('[node name="Divider2"'):
        skip = False
        
    if not skip:
        # Rename paths
        line = line.replace('HUD/SettingsScreen', 'HUD/ControllerScreen')
        line = line.replace('name="SettingsScreen"', 'name="ControllerScreen"')
        line = line.replace('text = "SETTINGS"', 'text = "CONTROLLER"')
        controller_lines.append(line)

# Append ControllerScreen right before WinScreen
lines = lines[:settings_end] + controller_lines + [''] + lines[settings_end:]

with open('scenes/HUD.tscn', 'w') as f:
    f.write('\n'.join(lines) + '\n')
