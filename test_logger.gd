extends SceneTree

func _init():
    var gs = load("res://scripts/GameState.gd").new()
    gs.level = 3
    gs.score = 1500
    gs.is_survival_mode = false
    
    print("Testing PlaytestLogger...")
    gs.log_playtest_round("Win", 45.2, "heavy")
    
    var f = FileAccess.open("user://playtest_logs.json", FileAccess.READ)
    if f:
        print("Log contents:")
        print(f.get_as_text())
    else:
        print("Failed to read file.")
        
    quit()
