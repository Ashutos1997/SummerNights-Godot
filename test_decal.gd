extends SceneTree

func _init():
    var d = Decal.new()
    d.size = Vector3(1, 2, 3)
    print("AABB: ", d.get_aabb())
    quit()
