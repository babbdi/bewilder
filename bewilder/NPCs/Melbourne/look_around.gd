extends Node3D

@onready var anim_tree = $"../MelbourneSkin/AnimationTree"

var blend_amount = 0.0
var turn_around_amount = 0.6

var where_is_player

func _process(delta: float) -> void:
	match where_is_player:
		-90:
			blend_amount = lerpf(blend_amount, -2, turn_around_amount * delta)
		-60:
			blend_amount = lerpf(blend_amount, -1.250, turn_around_amount * delta)
		-45:
			blend_amount = lerpf(blend_amount, -0.5, turn_around_amount * delta)
		0:
			blend_amount = lerpf(blend_amount, 0, turn_around_amount * delta)
		45:
			blend_amount = lerpf(blend_amount, 0.5, turn_around_amount * delta)
		60:
			blend_amount = lerpf(blend_amount, 1.250, turn_around_amount * delta)
		90:
			blend_amount = lerpf(blend_amount, 2, turn_around_amount * delta)
			
	anim_tree.set("parameters/blend look/add_amount", blend_amount)
	#print(blend_amount)

func degree_m90(body: Player):
	where_is_player = -90
func degree_m60(body: Player):
	where_is_player = -60
func degree_m45(body: Player):
	where_is_player = -45
func degree_0(body: Player):
	where_is_player = 0
func degree_45(body: Player):
	where_is_player = 45
func degree_60(body: Player):
	where_is_player = 60
func degree_90(body: Player):
	where_is_player = 90
