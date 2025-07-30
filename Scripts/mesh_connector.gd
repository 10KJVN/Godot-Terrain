@tool
extends MeshInstance3D

@export var sky_3d_node: NodePath
@onready var sky_3d: Sky3D = get_node(sky_3d_node)

func _process(delta):
	if !sky_3d or !sky_3d.tod:
		return
		
	var material = get_active_material(0)
	if material is ShaderMaterial:
		# Get normalized time (0-1 range for full day cycle)
		var tod = sky_3d.tod
		var time_normalized = tod.total_hours / 24.0
		
		# Sync all properties
		material.set_shader_parameter("sun_direction", -sky_3d.sun.global_transform.basis.z)
		material.set_shader_parameter("sun_color", sky_3d.sun.light_color)
		material.set_shader_parameter("sun_energy", sky_3d.sun.light_energy)
		material.set_shader_parameter("time_of_day", time_normalized)
		material.set_shader_parameter("ambient_light", 
			sky_3d.environment.ambient_light_color * sky_3d.environment.ambient_light_energy)
		
		# Optional: Sync moon properties if needed
		if sky_3d.moon:
			material.set_shader_parameter("moon_direction", -sky_3d.moon.global_transform.basis.z)
			material.set_shader_parameter("moon_color", sky_3d.moon.light_color)
