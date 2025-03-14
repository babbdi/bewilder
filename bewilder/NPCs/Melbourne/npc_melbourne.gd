extends CharacterBody3D



@onready var anim_tree = $MelbourneSkin/AnimationTree

var is_talking
@export var head : Marker3D
func _process(delta: float) -> void:

	if is_talking:
			anim_tree.set("parameters/blend talking/blend_amount", 1.0)
	else:
			anim_tree.set("parameters/blend talking/blend_amount", 0.0)
