extends CharacterBody3D


@onready var _look_at_bone := $MelbourneSkin/mel/blacksmith/Skeleton3D/_look_at_bone
@onready var _look_at_target := $_look_at_target
@onready var anim_tree := $MelbourneSkin/AnimationTree
var is_talking := false
@export var where_head_is : Marker3D
func _process(delta: float) -> void:

	if is_talking:
			anim_tree.set("parameters/blend talking/blend_amount", 1.0)
	else:
			anim_tree.set("parameters/blend talking/blend_amount", 0.0)
