extends Health

var can_die = false
func on_death():
	%anim_debug.play("die")
	await get_tree().create_timer(1.68).timeout
