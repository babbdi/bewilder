class_name Attack_Range extends _AI_Enemy_Part



func _on_attack_range_body_entered(body: Node3D) -> void:
	if is_detectable(body):
		attack(body, brain.parent.damage, brain.parent.knockback_force)


		#brain.is_in_attack_range = true
		
#func _on_attack_range_body_exited(body: Node3D) -> void:
	#if is_detectable(body):
		#brain.is_in_attack_range = false
		
