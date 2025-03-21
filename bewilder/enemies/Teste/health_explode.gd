extends Health


func on_death() -> bool:
	%anim_debug.play("die")
	await get_tree().create_timer(1.68).timeout
	return true
