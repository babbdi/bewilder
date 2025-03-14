extends Node3D

@export var target : Node3D

@export_range(0.1,5,0.1) var intensity : float = 1.0
@export_range(0.1,5,1.0) var wait_time : float = 3.0
@onready var path_3d: Path3D = $Path3D

@onready var in_between_waves: Timer = $InBetweenWaves

@export var enemy_test : PackedScene = preload("res://enemies/Teste/teste_enemy.tscn")
var array_enemies


var rng = RandomNumberGenerator.new()
var spawn_range : Array[Marker3D]

func _ready() -> void:
	in_between_waves.wait_time = wait_time / intensity
	print(in_between_waves.wait_time)
	for i in self.get_children():
		spawn_range.append(i)

func _process(delta: float) -> void:
	pass
	
	
func spawn_enemy():
	var e = enemy_test.instantiate()
	e.target = target
	add_child(e)
	e.scale = Vector3(1.0,1.0,1.0)
	var random_position = rng.randi_range(0, spawn_range.size() - 1)
	e.global_position = spawn_range[random_position].global_position
	


func _on_in_between_waves_timeout() -> void:
	spawn_enemy()
