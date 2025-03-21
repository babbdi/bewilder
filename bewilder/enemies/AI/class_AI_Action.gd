@icon("res://enemies/AI/editor_icons/_AI_Enemy_Part.svg")
class_name _AI_Enemy_Part extends Area3D



var brain : Node3D
var what_detects : Array[String]


func is_detectable(body : Node3D) -> bool:
	for i : int in what_detects.size():
		if body.is_in_group(what_detects[i]):
			#print("Detectou o body: ", str(body) + "\n")
			return true
		else: return false
	return false


func die(who : Node3D) -> void:
	#brain.parent.remove_from_group("enemy")
	await on_death()
	who.queue_free()

func on_death() -> bool:
	return true

func attack(_target : Node3D, damage : float, knockback_force : float) -> void:
	var attack := Attack.new()
	attack.knockback_force = knockback_force
	attack.attack_position = self.global_position
	attack.attack_damage = damage
	%anim_debug.play("attack")
	#print("BRAIN atacou: ", _target)
	if _target != null:
		#print(_target.health)
		_target.take_damage(attack)
	else:
		print("target from attack BRAIN = NULL")
