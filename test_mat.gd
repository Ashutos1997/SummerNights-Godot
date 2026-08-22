extends SceneTree
func _init():
    var m = StandardMaterial3D.new()
    print("specular in m? ", "specular" in m)
    print("metallic_specular in m? ", "metallic_specular" in m)
    quit()
