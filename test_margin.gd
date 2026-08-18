extends SceneTree

func _init():
    var vbox = VBoxContainer.new()
    var lbl1 = Label.new()
    lbl1.text = "Top"
    vbox.add_child(lbl1)
    
    var mc = MarginContainer.new()
    mc.add_theme_constant_override("margin_bottom", -16)
    var sep = HSeparator.new()
    mc.add_child(sep)
    vbox.add_child(mc)
    
    var lbl2 = Label.new()
    lbl2.text = "Bottom"
    vbox.add_child(lbl2)
    
    var root = Window.new()
    root.add_child(vbox)
    vbox.force_update_transform()
    
    print("lbl1 y: ", lbl1.position.y)
    print("mc y: ", mc.position.y, " size: ", mc.size.y)
    print("lbl2 y: ", lbl2.position.y)
    quit()
