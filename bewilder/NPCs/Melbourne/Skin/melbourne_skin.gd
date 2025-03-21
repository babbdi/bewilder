class_name npc_skin extends Node3D

@export var _look_at_bone : LookAtModifier3D 
@export var _look_at_target : Marker3D

var body : Node3D
var is_looking := false

func _on_look_at_area_3d_entered(_body: CharacterBody3D) -> void:
	if _body.is_in_group("player"):
		body = _body
		is_looking = true
		_look_at_bone.active = true
		#print("BODY NPC")

func _on_look_at_area_3d_exited(_body: CharacterBody3D) -> void:
	if _body.is_in_group("player"):
		is_looking = false
		
	
func _process(delta: float) -> void:
	if is_looking:
		_look_at_target.global_position = lerp(_look_at_target.global_position,body.where_head_is.global_position, 
		1 * delta)
		_look_at_bone.influence = lerp(_look_at_bone.influence,1.0, 1 * delta)
	else:
		_look_at_bone.influence = lerp(_look_at_bone.influence,0.0, 1 * delta)
