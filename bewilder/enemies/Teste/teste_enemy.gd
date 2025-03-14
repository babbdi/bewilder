extends CharacterBody3D



@onready var nav: NavigationAgent3D = $NavigationAgent3D
@export var max_health = 10
@export var target : Node3D 
@export var speed = 5.0
@export var accel = 2.5
@export var damage := 10.0
@export var knockback_force := 5.0
@export var mesh: MeshInstance3D 
@export var brain: Node3D 

var direction = Vector3(1.0,1.0,1.0)
var delta = 1.0


func _physics_process(delta: float) -> void:
	if target != null:
		delta = delta
		nav.target_position = target.global_position
		
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
		
	var last_direction = Vector3.FORWARD
	last_direction = direction
	mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(last_direction.x, last_direction.z), delta * 2)
	nav.velocity = direction
	#velocity = velocity.lerp(direction * speed, accel * delta)
	#velocity = velocity.move_toward(direction * accel, speed * delta)

func take_damage(attack: Attack): ## estou passando a função de tomar dano para o node "Health" do cérebro, para poder lidar com 
	if brain.has_health:          ## on_death() e etc.
		var brain_health = brain.get_node_or_null("Health")
		if brain_health == null:
			print("ENEMY ", str(self), " DOENST HAVE A HEALTHY BRAIN")
			return
		brain_health.take_damage(attack)
		
func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity * accel, speed * delta)
	if target != null:
		move_and_slide()
