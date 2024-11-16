extends MeshInstance3D

func _ready():
	# Get the material
	var material = get_active_material(0)
	if material == null:
		material = get_active_material(0)
	
	## Set a random offset between 0 and 1
	#if material:
		#print_debug("got one!")
		#var random_offset = randf_range(10,15)
		#material_override.set("shader_parameter/deformation_speed", random_offset)
		#print_debug(material_override.get("shader_parameter/deformation_speed"))
