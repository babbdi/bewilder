class_name turret_base extends Node3D

@export var anim_player : AnimationPlayer


var targets

#func _physics_process(delta: float) -> void:
	##print(anim_player.get_queue())
	#print("CURRENT ANIMATION: " + anim_player.current_animation)
func play_anim(anim : String):
	if !anim_player.is_playing():
		anim_player.play(anim)
	elif anim_player.is_playing() && anim_player.current_animation != anim:
		if anim_player.animation_get_next(anim) != anim:
			anim_player.queue(anim)

func is_animation_playing(anim):
	if anim_player.is_playing() and anim_player.current_animation == anim:
		return true
func queue_anim(name : String):
	var anim_player : AnimationPlayer = anim_player
	if not anim_player: return
	anim_player.queue(name)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	targets = get_parent().targets

func _on_check_enemy_body_entered(body: Node3D) -> void:
	if body != null:
			if body.has_method("take_damage") && body.is_in_group("enemy"):
				targets.append(body)


func _on_check_enemy_body_exited(body: Node3D) -> void:
	if body != null:
			if targets.has(body) && body.is_in_group("enemy"):
				targets.erase(body)
