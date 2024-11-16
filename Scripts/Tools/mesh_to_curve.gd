@tool
extends Path3D

@export var distance_between_planks = 1.0:
	set(value):
		if distance_between_planks != value:  # Prevent recursion
			distance_between_planks = value
			is_dirty = true

var is_dirty = false
@export var object_to_instantiate: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	if not has_node("instances"):
		var multi = MultiMeshInstance3D.new()
		multi.name = "instances"
		add_child(multi)
		multi.owner = get_tree().edited_scene_root
		
		var mm = MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		multi.multimesh = mm
	
	update_multimesh()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if is_dirty:
		update_multimesh()
		is_dirty = false

func update_multimesh():
	if not object_to_instantiate:
		return
		
	# Create a temporary instance to get the mesh
	var temp_instance = object_to_instantiate.instantiate()
	if not temp_instance is Node3D:
		temp_instance.free()
		return
		
	var mm = $instances.multimesh
	mm.mesh = temp_instance.get_mesh()
	temp_instance.free()
	
	var path_length: float = curve.get_baked_length()
	var count = int(floor(path_length / distance_between_planks))
	mm.instance_count = count
	
	var offset = distance_between_planks/2.0
	for i in range(count):
		var curve_distance = offset + distance_between_planks * i
		var position = curve.sample_baked(curve_distance, true)
		var basis = Basis()
		
		var up = curve.sample_baked_up_vector(curve_distance, true)
		var forward = position.direction_to(curve.sample_baked(curve_distance + 0.1, true))
		basis.y = up
		basis.x = forward.cross(up).normalized()
		basis.z = -forward
		
		var transform = Transform3D(basis, position)
		mm.set_instance_transform(i, transform)

func _on_curve_changed():
	is_dirty = true
