#extends RigidBody3D
#
#@export var collision_shape : CollisionShape3D
#var is_being_held = false
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
### Called every frame. 'delta' is the elapsed time since the previous frame.
##func _process(delta: float) -> void:
	##if is_being_held:
		##get_parent().is_being_held = true
		##
		##self.freeze = true
	##else:
		##get_parent().is_being_held = false
		##self.freeze = false
