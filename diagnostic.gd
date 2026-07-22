extends SceneTree
func _init():
    var main_scene = load("res://scenes/Main.tscn")
    if main_scene:
        var main = main_scene.instantiate()
        # build scene manually if it's in _ready
        main._ready()
        
        var gun = main.gun
        print("Gun node: ", gun.get_class())
        print("Gun parent: ", gun.get_parent().name)
        print("Gun local pos: ", gun.position)
        print("Gun local rot: ", gun.rotation_degrees)
        
        # gun_model is a child of gun
        var gun_model = gun.get_child(0)
        var aabb = AABB()
        if gun_model is Node3D:
            for child in gun_model.get_children():
                if child is MeshInstance3D:
                    aabb = aabb.merge(child.get_aabb())
        print("Gun AABB: ", aabb)
        
        print("Camera: ", main.camera.get_path())
    quit()
