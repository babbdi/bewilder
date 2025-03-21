extends Node3D

@export_enum("Default","Clockwork", "Ballista") var chosen_blueprint : String = "Default"


@onready var mesh := $mesh_text
@onready var collision := $Area3D/CollisionShape3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mesh.mesh.text = chosen_blueprint


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if collision.disabled == true:
		%triangle.scale.x -= 0.1 
		%triangle.scale.y -= 0.1
		%triangle.scale.z -= 0.1
		mesh.scale.x -= 0.1
		mesh.scale.y -= 0.1
		mesh.scale.z -= 0.1
		if %triangle.scale.x <= 0:
			delete()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body != null and body is Player:
		Events.unlocked_blueprints.append(chosen_blueprint)
		collision.disabled = true
		#%AnimationPlayer.play("picked")

func delete() -> void:
	queue_free()
