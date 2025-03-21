extends Node3D
@export var _turret : turret
@export var _player : Player
@onready var turret_name: Label = %turret_name
@onready var turret_damage: Label = %turret_damage
@onready var turret_fire_speed: Label = %turret_fire_speed

var is_showing := false

func _ready() -> void:
	if _turret != null:
		turret_name.text = _turret.resource.name
		turret_damage.text = str(_turret.resource.projectile_damage)
		turret_fire_speed.text = str(_turret.resource.max_fire_rate_ms / 1000)
	

func _process(delta: float) -> void:
	if is_showing:
		self.global_rotation = _player._camera.global_rotation
	

func show_interface(player : Player, decision : bool) -> void:
	if decision == true:
		player = _player
		is_showing = true
	else:
		is_showing = false
	
