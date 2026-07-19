extends Node3D

class_name SeagullLayer

@export var num_birds: int = 4
@export var orbit_radius_min: float = 22.0
@export var orbit_radius_max: float = 38.0
@export var min_y: float = 18.0
@export var max_y: float = 26.0
@export var center_pos := Vector3(0, 0, -32)

var birds: Array[Dictionary] = []
var body_mat: StandardMaterial3D
var beak_mat: StandardMaterial3D
var wingtip_mat: StandardMaterial3D

func _ready() -> void:
	body_mat = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.96, 0.96, 0.98) # White body
	body_mat.roughness = 0.8
	
	beak_mat = StandardMaterial3D.new()
	beak_mat.albedo_color = Color(1.0, 0.7, 0.1) # Amber beak
	beak_mat.emission_enabled = true
	beak_mat.emission = Color(0.9, 0.55, 0.1)
	beak_mat.emission_energy_multiplier = 0.5
	
	wingtip_mat = StandardMaterial3D.new()
	wingtip_mat.albedo_color = Color(0.25, 0.25, 0.3) # Dark grey wingtips
	
	_spawn_seagulls()

func _spawn_seagulls() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for i in range(num_birds):
		var bird_node = _create_seagull_mesh()
		add_child(bird_node)
		
		var radius = rng.randf_range(orbit_radius_min, orbit_radius_max)
		var angle = rng.randf_range(0.0, TAU)
		var height = rng.randf_range(min_y, max_y)
		var speed = rng.randf_range(0.25, 0.45) * (1.0 if rng.randf() > 0.3 else -1.0)
		
		birds.append({
			"node": bird_node,
			"left_wing": bird_node.get_node("LeftWingPivot"),
			"right_wing": bird_node.get_node("RightWingPivot"),
			"radius": radius,
			"angle": angle,
			"height": height,
			"speed": speed,
			"flap_speed": rng.randf_range(6.0, 8.5),
			"time_offset": rng.randf_range(0.0, 100.0)
		})

func _create_seagull_mesh() -> Node3D:
	var bird_root = Node3D.new()
	
	# Main Body (tapered box)
	var body_inst = MeshInstance3D.new()
	var body_mesh = BoxMesh.new()
	body_mesh.size = Vector3(0.28, 0.24, 0.75)
	body_inst.mesh = body_mesh
	body_inst.material_override = body_mat
	bird_root.add_child(body_inst)
	
	# Beak (cone/prism pointing forward)
	var beak_inst = MeshInstance3D.new()
	var beak_mesh = PrismMesh.new()
	beak_mesh.size = Vector3(0.12, 0.3, 0.12)
	beak_inst.mesh = beak_mesh
	beak_inst.material_override = beak_mat
	beak_inst.rotation_degrees = Vector3(-90, 0, 0)
	beak_inst.position = Vector3(0, -0.02, -0.45)
	bird_root.add_child(beak_inst)
	
	# Left Wing Pivot & Mesh
	var left_pivot = Node3D.new()
	left_pivot.name = "LeftWingPivot"
	left_pivot.position = Vector3(-0.14, 0.05, 0.0)
	bird_root.add_child(left_pivot)
	
	var left_wing = MeshInstance3D.new()
	var l_wing_mesh = BoxMesh.new()
	l_wing_mesh.size = Vector3(1.1, 0.04, 0.35)
	left_wing.mesh = l_wing_mesh
	left_wing.material_override = body_mat
	left_wing.position = Vector3(-0.55, 0.0, 0.0)
	left_pivot.add_child(left_wing)
	
	# Left Wingtip
	var left_tip = MeshInstance3D.new()
	var l_tip_mesh = BoxMesh.new()
	l_tip_mesh.size = Vector3(0.35, 0.045, 0.25)
	left_tip.mesh = l_tip_mesh
	left_tip.material_override = wingtip_mat
	left_tip.position = Vector3(-0.95, 0.0, 0.02)
	left_pivot.add_child(left_tip)

	# Right Wing Pivot & Mesh
	var right_pivot = Node3D.new()
	right_pivot.name = "RightWingPivot"
	right_pivot.position = Vector3(0.14, 0.05, 0.0)
	bird_root.add_child(right_pivot)
	
	var right_wing = MeshInstance3D.new()
	var r_wing_mesh = BoxMesh.new()
	r_wing_mesh.size = Vector3(1.1, 0.04, 0.35)
	right_wing.mesh = r_wing_mesh
	right_wing.material_override = body_mat
	right_wing.position = Vector3(0.55, 0.0, 0.0)
	right_pivot.add_child(right_wing)

	# Right Wingtip
	var right_tip = MeshInstance3D.new()
	var r_tip_mesh = BoxMesh.new()
	r_tip_mesh.size = Vector3(0.35, 0.045, 0.25)
	right_tip.mesh = r_tip_mesh
	right_tip.material_override = wingtip_mat
	right_tip.position = Vector3(0.95, 0.0, 0.02)
	right_pivot.add_child(right_tip)

	return bird_root

func _process(delta: float) -> void:
	var time = Time.get_ticks_msec() * 0.001
	for b in birds:
		var node = b["node"] as Node3D
		if not is_instance_valid(node): continue
		
		# Update orbital angle
		b["angle"] += b["speed"] * delta
		var angle = b["angle"] as float
		var rad = b["radius"] as float
		
		# Position along circle centered at center_pos
		var pos_x = center_pos.x + cos(angle) * rad
		var pos_z = center_pos.z + sin(angle) * rad
		node.position = Vector3(pos_x, b["height"], pos_z)
		
		# Orient bird facing along flight tangent direction
		var tangent = Vector3(-sin(angle), 0, cos(angle)) * (1.0 if b["speed"] > 0 else -1.0)
		node.look_at(node.position + tangent, Vector3.UP)
		node.rotate_object_local(Vector3(0, 0, 1), -0.15 * (1.0 if b["speed"] > 0 else -1.0)) # Gentle turn bank angle
		
		# Wing flapping animation with periodic gliding pauses
		var t_offset = b["time_offset"] as float
		var cycle = fmod(time + t_offset, 6.0)
		var flap_rot: float = 0.0
		
		if cycle < 4.0:
			# Active flapping phase
			flap_rot = sin((time + t_offset) * (b["flap_speed"] as float)) * 0.35
		else:
			# Glide phase
			flap_rot = 0.05
			
		var l_wing = b["left_wing"] as Node3D
		var r_wing = b["right_wing"] as Node3D
		if l_wing: l_wing.rotation.z = flap_rot
		if r_wing: r_wing.rotation.z = -flap_rot
