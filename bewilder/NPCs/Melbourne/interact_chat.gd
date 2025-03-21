extends Node3D

@export_group("Diálogo", "dialogue_")
@export var dialogue_resource : DialogueResource
@export var dialogue_start : String = "start"
@export var dialogue_area : Area3D
var is_talking := false
var player : Player
func _process(delta: float) -> void:
	get_parent().is_talking = is_talking
func interact() -> void:
	#player.emit_signal("first_person", get_parent().head)
	DialogueManager.get_current_scene = func() -> Node3D:
		return self
	DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start)

func chatting(decision : bool) -> void:
	if decision:
		player.emit_signal("first_person", get_parent().where_head_is)
		player.is_in_interaction = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		player.emit_signal("first_person", null)
		player.is_in_interaction = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_near_area_body_entered(body: Player) -> void:
	#is_player_near = true
	player = body
	%ui_interaction.play("!_show_up")
func _on_near_area_body_exited(body: Player) -> void:
		#is_player_near = false
	%ui_interaction.play_backwards("!_show_up")
