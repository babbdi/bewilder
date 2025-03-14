@icon("res://enemies/AI/editor_icons/_AI_Enemy_Part.svg")
class_name _AI_Enemy_Part extends Area3D



var brain
var what_detects


func is_detectable(body):
	for i in what_detects.size():
		if body.is_in_group(what_detects[i]):
			#print("Detectou o body: ", str(body) + "\n")
			return true

func die(who):
	await on_death()
	who.queue_free()

func on_death():
	return true

func attack(_target, damage, knockback_force):
	var attack = Attack.new()
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
