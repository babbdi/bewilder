extends Node3D

var max_health := 1.0:
	set = set_max_health
var current_health := 1.0:
	set = set_current_health
	
var resource

func _ready() -> void:
	resource = get_parent().resource
	max_health = resource.max_health
	current_health = resource.max_health
	debug()
func take_damage(attack: Attack):
	print("torreta levou dano")
	current_health -= attack.attack_damage
	if current_health <= 0:
		get_parent().queue_free()
	
func set_current_health(new_current_health):
	if new_current_health < current_health:
		%debug.play("hurt")
	else:
		%debug.play("heal")
	var tween := create_tween().set_parallel()
	tween.tween_property(%HealthBar, "value", new_current_health, 0.6)
	current_health = new_current_health
	print(current_health)
	
func set_max_health(new_max_health):
	max_health = new_max_health
	
func debug():
	%HealthBar.max_value = max_health
	%HealthBar.value = current_health
