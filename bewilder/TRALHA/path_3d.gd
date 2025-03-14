extends Path3D


var enemy = preload("res://TRALHA/path_follow_3d.tscn") 
# Called when the node enters the scene tree for the first time.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("q"):
		var enemyy = enemy.instantiate()
		add_child(enemyy)


func _on_timer_timeout() -> void:
	#print("timer")
	var enemyy = enemy.instantiate()
	add_child(enemyy)
