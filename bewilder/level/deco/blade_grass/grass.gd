extends MultiMeshInstance3D

@export var character_path : Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	material_override.set_shader_parameter("character_position", character_path.global_transform.origin)
