class_name projectile extends RigidBody3D

@export var _scale : Vector3 = Vector3(1,1,1)
@export_category("STATS")
var damage : float
var speed : float 
var pen : int
var trigger_shoot : bool = false

var _position
var _angle
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("spawnou um tiro")
func _update_info():
	self.global_position = _position
	self.rotation = _angle
	self.scale = _scale
func _process(delta: float) -> void:
	if trigger_shoot:
		apply_impulse(transform.basis.z * speed, -transform.basis.z )
	if pen <= 0:
		projectile_break()

func _on_area_3d_body_entered(body: Node3D) -> void:
	var attack = Attack.new()
	attack.attack_damage = damage
	if body.has_method("take_damage"):
		#print("ui")
		body.take_damage(attack)
		pen -= 1

func projectile_break():
	queue_free()
