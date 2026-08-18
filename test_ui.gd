extends SceneTree

func _init():
    var packed = load("res://scenes/HUD.tscn")
    var hud = packed.instantiate()
    var vbox = hud.get_node("HUD/SettingsScreen/CenterContainer/VBoxContainer")
    vbox.force_update_transform()
    print("SettingsScreen VBox children positions:")
    for c in vbox.get_children():
        print(c.name, ": pos.y = ", c.position.y, ", size.y = ", c.size.y)
        
    var pause_vbox = hud.get_node("HUD/pause_screen/ColorRect/VBoxContainer")
    pause_vbox.force_update_transform()
    print("\nPauseScreen VBox children positions:")
    for c in pause_vbox.get_children():
        print(c.name, ": pos.y = ", c.position.y, ", size.y = ", c.size.y)
    
    quit()
