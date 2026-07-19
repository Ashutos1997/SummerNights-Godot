extends Node3D

class_name CloudLayer

@export var num_clouds: int = 18
@export var min_speed: float = 1.2
@export var max_speed: float = 3.2
@export var bounds_x: float = 85.0
@export var min_y: float = 14.0
@export var max_y: float = 28.0
@export var min_z: float = -75.0
@export var max_z: float = -20.0

var clouds: Array[Dictionary] = []
var cloud_mat: StandardMaterial3D

func _ready() -> void:
	# Shared sunset cloud material with toon diffuse & warm sunset emission
	cloud_mat = StandardMaterial3D.new()
	cloud_mat.albedo_color = Color(1.0, 0.84, 0.58, 0.95)
	cloud_mat.roughness = 0.85
	cloud_mat.emission_enabled = true
	cloud_mat.emission = Color(0.9, 0.48, 0.15)
	cloud_mat.emission_energy_multiplier = 0.45
	
	_spawn_clouds()

func _spawn_clouds() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for i in range(num_clouds):
		var cloud_node = _create_stylized_cloud_mesh(rng)
		add_child(cloud_node)
		
		var start_x = rng.randf_range(-bounds_x, bounds_x)
		var start_y = rng.randf_range(min_y, max_y)
		var start_z = rng.randf_range(min_z, max_z)
		var speed = rng.randf_range(min_speed, max_speed)
		
		# Varied scale range from small wispy clouds to large billowy clouds (0.8x to 4.2x)
		var scale_factor = rng.randf_range(0.8, 4.2)
		var sx = scale_factor * rng.randf_range(0.85, 1.35)
		var sy = scale_factor * rng.randf_range(0.45, 0.85)
		var sz = scale_factor * rng.randf_range(0.75, 1.25)
		
		cloud_node.position = Vector3(start_x, start_y, start_z)
		cloud_node.scale = Vector3(sx, sy, sz)
		
		clouds.append({
			"node": cloud_node,
			"speed": speed,
			"base_y": start_y,
			"bob_speed": rng.randf_range(0.4, 1.0),
			"time_offset": rng.randf_range(0.0, 100.0)
		})

func _create_stylized_cloud_mesh(rng: RandomNumberGenerator) -> Node3D:
	var cloud_root = Node3D.new()
	
	# Randomized puff cluster count and offsets for organic, varied cloud shapes
	var puff_count = rng.randi_range(4, 9)
	for p in range(puff_count):
		var mesh_inst = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = rng.randf_range(0.7, 2.2)
		sphere.height = sphere.radius * 2.0
		sphere.radial_segments = 8
		sphere.rings = 6
		mesh_inst.mesh = sphere
		mesh_inst.material_override = cloud_mat
		
		var offset = Vector3(
			rng.randf_range(-2.2, 2.2) if p > 0 else 0.0,
			rng.randf_range(-0.4, 0.6) if p > 0 else 0.0,
			rng.randf_range(-0.5, 0.5) if p > 0 else 0.0
		)
		mesh_inst.position = offset
		cloud_root.add_child(mesh_inst)
		
	return cloud_root

func _process(delta: float) -> void:
	var time = Time.get_ticks_msec() * 0.001
	for c in clouds:
		var node = c["node"] as Node3D
		if not is_instance_valid(node): continue
		
		# Move left to right
		node.position.x += c["speed"] * delta
		
		# Gentle vertical bobbing
		var bob = sin(time * c["bob_speed"] + c["time_offset"]) * 0.25
		node.position.y = c["base_y"] + bob
		
		# Seamless wrap from right boundary (+85m) to left boundary (-85m)
		if node.position.x > bounds_x:
			node.position.x = -bounds_x
			node.position.y = randf_range(min_y, max_y)
			c["base_y"] = node.position.y
			
			# Re-randomize size & aspect ratio on wrap for endless variety
			var sf = randf_range(0.8, 4.2)
			node.scale = Vector3(
				sf * randf_range(0.85, 1.35),
				sf * randf_range(0.45, 0.85),
				sf * randf_range(0.75, 1.25)
			)
