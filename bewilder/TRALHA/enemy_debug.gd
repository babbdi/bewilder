class_name enemy extends CharacterBody3D

@export var health := 50
var max_health
const SPEED = 2.0
@onready var path = $PathFollow3D
func _ready() -> void:
	max_health = health
	%HealthBar.max_value = max_health

func _process(delta: float) -> void:
	%HealthBar.value = health

func _physics_process(delta: float) -> void:
	get_parent().progress += SPEED * delta

func take_damage(attack: Attack):
	health -= attack.attack_damage
	
	check_death()
	
func check_death():
	if health <= 0:
		get_parent().queue_free()
