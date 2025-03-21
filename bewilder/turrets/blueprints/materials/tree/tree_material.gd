class_name tree_material extends Area3D

@export var name_material : String
@export var material : PackedScene 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body != null && body.is_in_group("player"):
		if material != null:
			var inst_material := material.instantiate()
			add_child(inst_material)
