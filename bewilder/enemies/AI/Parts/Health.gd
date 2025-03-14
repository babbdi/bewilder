class_name Health extends _AI_Enemy_Part



func take_damage(attack: Attack): 
	brain.current_health -= attack.attack_damage
	if brain.current_health <= 0: 
		die(brain.parent)
