@icon("res://turrets/hud/Icons/base.svg")
class_name turret_base extends CharacterBody3D

var targets : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	targets = get_parent().targets
	resource = get_parent().resource
	max_health = resource.max_health
	current_health = resource.max_health
	debug()
func _on_check_enemy_body_entered(body: Node3D) -> void:
	if body != null:
			if body.has_method("take_damage") && body.is_in_group("enemy"):
				targets.append(body)


func _on_check_enemy_body_exited(body: Node3D) -> void:
	if body != null:
			if targets.has(body) && body.is_in_group("enemy"):
				targets.erase(body)

var max_health := 1.0:
	set = set_max_health
var current_health := 1.0:
	set = set_current_health
	
var resource : Resource

func take_damage(attack: Attack) -> void:
	print("torreta levou dano")
	current_health -= attack.attack_damage
	if current_health <= 0:
		get_parent().queue_free()
	
func set_current_health(new_current_health : float) -> void:
	if new_current_health < current_health:
		%debug.play("hurt")
	else:
		%debug.play("heal")
	var tween := create_tween().set_parallel()
	tween.tween_property(%HealthBar, "value", new_current_health, 0.6)
	current_health = new_current_health
	print(current_health)
	
func set_max_health(new_max_health : float) -> void:
	max_health = new_max_health
	
func debug() -> void:
	%HealthBar.max_value = max_health
	%HealthBar.value = current_health
