extends SceneTree
func _init():
    var node = load("res://assets/models/sun_lowpoly.glb").instantiate()
    var mesh = node.get_child(0).mesh
    var mat = mesh.surface_get_material(0)
    if mat:
        print("Albedo tex: ", mat.albedo_texture)
    quit()
