import re

with open('scripts/TitleScreen.gd', 'r') as f:
    content = f.read()

# 1. Add LangBtn to onready vars
content = content.replace(
    "@onready var dev_btn = $ColorRect/VBoxContainer/ButtonsBox/DevBtn",
    "@onready var dev_btn = $ColorRect/VBoxContainer/ButtonsBox/DevBtn\n@onready var lang_btn = $LangBtn"
)

# 2. Extract _update_language logic
ready_match = re.search(r'func _ready\(\) -> void:\n\tInput\.set_mouse_mode\(Input\.MOUSE_MODE_VISIBLE\)\n(.*?)(?=\nfunc _process)', content, re.DOTALL)
if ready_match:
    ready_body = ready_match.group(1)
    
    # We want to leave a small _ready() and move the rest
    new_ready = """func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if lang_btn:
		lang_btn.pressed.connect(_on_lang_btn_pressed)
		
	_update_language()
	
	if normal_btn: normal_btn.pressed.connect(_on_normal_pressed)
	if survival_btn: survival_btn.pressed.connect(_on_survival_pressed)
	if dev_btn: dev_btn.pressed.connect(_on_dev_pressed)
	
func _update_language() -> void:"""
    
    # Extract the signal connections out of the original ready_body to avoid duplicating them
    body_lines = ready_body.split("\n")
    update_lines = []
    for line in body_lines:
        if ".pressed.connect" in line and "btn" in line:
            continue # We moved these to new_ready
        update_lines.append(line)
        
    update_body = "\n".join(update_lines)
    
    # We also need to add lang_btn styling inside update_body
    btn_style_target = "for btn in [normal_btn, survival_btn, dev_btn]:"
    btn_style_replace = "for btn in [normal_btn, survival_btn, dev_btn, lang_btn]:"
    update_body = update_body.replace(btn_style_target, btn_style_replace)
    
    # And handle specific pressed color for lang_btn
    pressed_target = "elif btn == dev_btn:\n\t\t\t\t\tstyle_pressed.bg_color = Color(0.8, 0.2, 1.0, 0.4)"
    pressed_replace = pressed_target + "\n\t\t\t\telif btn == lang_btn:\n\t\t\t\t\tstyle_pressed.bg_color = Color(1.0, 1.0, 1.0, 0.4)"
    update_body = update_body.replace(pressed_target, pressed_replace)
    
    content = content[:ready_match.start()] + new_ready + update_body + content[ready_match.end():]

# 3. Add _on_lang_btn_pressed
lang_btn_func = """
func _on_lang_btn_pressed() -> void:
	if is_starting: return
	
	var audio = AudioStreamPlayer.new()
	audio.stream = load("res://assets/sfx/ui_tick.wav")
	audio.bus = "SFX"
	add_child(audio)
	audio.play()
	
	GameState.language = "KR" if GameState.language == "EN" else "EN"
	GameState.save_settings()
	_update_language()
"""
content = content + lang_btn_func

with open('scripts/TitleScreen.gd', 'w') as f:
    f.write(content)
