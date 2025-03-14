class_name Detects_New_Target extends _AI_Enemy_Part


func _on_body_entered(body: Node3D) -> void:
	if is_detectable(body):
		if brain.targets.has(body):
			return
		brain.targets.insert(0,body)
		brain.parent.target = body


#func _on_body_exited(body: Node3D) -> void:
	#if is_detectable(body):
		#brain.targets.erase(body)
