extends SceneTree
func _init():
    var scn = load("res://assets/models/sun_lowpoly.glb").instantiate()
    print("Children: ", scn.get_children())
    var mesh_node = scn.get_child(0)
    print("Mesh node type: ", mesh_node.get_class())
    if mesh_node is MeshInstance3D:
        var mesh = mesh_node.mesh
        print("Mesh surfaces: ", mesh.get_surface_count())
        var mat = mesh.surface_get_material(0)
        print("Material: ", mat)
        if mat and mat is StandardMaterial3D:
            print("Albedo tex: ", mat.albedo_texture)
    quit()
