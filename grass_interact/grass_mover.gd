tool
extends Spatial


# Called when the node enters the scene tree for the first time.
func _process(delta: float) -> void:
	get_parent().get_parent().get_node("Grass").material_override.set_shader_param("player_pos", global_transform.origin)
