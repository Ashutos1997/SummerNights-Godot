import re

with open('scripts/HUD.gd', 'r') as f:
    code = f.read()

# 1. Add vars
vars_inject = """@onready var controller_btn     = $HUD/pause_screen/ColorRect/VBoxContainer/ControllerBtn
@onready var controller_screen  = $HUD/ControllerScreen
@onready var controller_back_btn = $HUD/ControllerScreen/CenterContainer/VBoxContainer/BackBtn
@onready var controller_title    = $HUD/ControllerScreen/CenterContainer/VBoxContainer/TitleRow/Title
@onready var controller_prompt   = $HUD/ControllerScreen/CenterContainer/VBoxContainer/ClosePrompt
"""
code = code.replace('@onready var settings_btn       = $HUD/pause_screen/ColorRect/VBoxContainer/SettingsBtn',
                    '@onready var settings_btn       = $HUD/pause_screen/ColorRect/VBoxContainer/SettingsBtn\n@onready var controller_btn     = $HUD/pause_screen/ColorRect/VBoxContainer/ControllerBtn')
code = code.replace('@onready var settings_back_btn = $HUD/SettingsScreen/CenterContainer/VBoxContainer/BackBtn',
                    '@onready var settings_back_btn = $HUD/SettingsScreen/CenterContainer/VBoxContainer/BackBtn\n' + vars_inject.split('\n', 1)[1])

# 2. _ready visibility
code = code.replace('settings_screen.visible = false', 'settings_screen.visible = false\n\tif controller_screen: controller_screen.visible = false')

# 3. _setup_pause_screen array and connections
code = code.replace('credits_btn, achievements_btn, buffs_btn, pause_menu_btn, settings_back_btn, credits_back_btn]:',
                    'credits_btn, controller_btn, achievements_btn, buffs_btn, pause_menu_btn, settings_back_btn, credits_back_btn, controller_back_btn]:')

conn_inject = """	if controller_btn:
		controller_btn.pressed.connect(_on_controller_pressed)
	if controller_back_btn:
		controller_back_btn.pressed.connect(_close_controller)
"""
code = code.replace('if credits_back_btn:\n\t\tcredits_back_btn.pressed.connect(_close_credits)',
                    'if credits_back_btn:\n\t\tcredits_back_btn.pressed.connect(_close_credits)\n' + conn_inject)

# 4. _process escape handling
code = code.replace('elif credits_screen and credits_screen.visible:\n\t\t\t_close_credits()',
                    'elif credits_screen and credits_screen.visible:\n\t\t\t_close_credits()\n\t\telif controller_screen and controller_screen.visible:\n\t\t\t_close_controller()')

# 5. Focus Neighbors
code = code.replace('if pause_resume_btn and settings_btn and credits_btn and pause_menu_btn:',
                    'if pause_resume_btn and settings_btn and credits_btn and controller_btn and pause_menu_btn:')
code = code.replace('credits_btn.focus_neighbor_bottom = credits_btn.get_path_to(pause_menu_btn)',
                    'credits_btn.focus_neighbor_bottom = credits_btn.get_path_to(controller_btn)\n\t\tcontroller_btn.focus_neighbor_top = controller_btn.get_path_to(credits_btn)\n\t\tcontroller_btn.focus_neighbor_bottom = controller_btn.get_path_to(pause_menu_btn)')
code = code.replace('pause_menu_btn.focus_neighbor_top = pause_menu_btn.get_path_to(credits_btn)',
                    'pause_menu_btn.focus_neighbor_top = pause_menu_btn.get_path_to(controller_btn)')

# 6. Localization
loc_inject = """	if controller_btn:
		controller_btn.text = "컨트롤러" if is_kr else "CONTROLLER"
		if font: controller_btn.add_theme_font_override("font", font)
	if controller_title:
		controller_title.text = "컨트롤러" if is_kr else "CONTROLLER"
		if font: controller_title.add_theme_font_override("font", font)
	if controller_prompt:
		controller_prompt.text = "닫으려면 ESC를 누르세요" if is_kr else "PRESS ESC TO CLOSE"
		if font: controller_prompt.add_theme_font_override("font", font)
	if controller_back_btn:
		controller_back_btn.text = "뒤로" if is_kr else "BACK"
		if font: controller_back_btn.add_theme_font_override("font", font)
"""
code = code.replace('if settings_btn:', loc_inject + '\n\tif settings_btn:')

# 7. Functions
funcs_inject = """
func _on_controller_pressed() -> void:
	if ui_tick_player: ui_tick_player.play()
	pause_screen.visible = false
	controller_screen.visible = true
	controller_screen.modulate.a = 0.0
	var tw = create_tween()
	tw.tween_property(controller_screen, "modulate:a", 1.0, 0.3)

func _close_controller() -> void:
	if ui_tick_player: ui_tick_player.play()
	var tw = create_tween()
	tw.tween_property(controller_screen, "modulate:a", 0.0, 0.2)
	tw.tween_callback(func():
		controller_screen.visible = false
		pause_screen.visible = true
		if controller_btn: controller_btn.grab_focus()
	)
"""
code = code.replace('func _on_credits_pressed() -> void:', funcs_inject + '\nfunc _on_credits_pressed() -> void:')

with open('scripts/HUD.gd', 'w') as f:
    f.write(code)
