class_name resource_material extends Node3D

@export_enum("Wood","Stone","Crystal") var selected_material : String = "Wood"

@export var wood_collision_shape : CollisionShape3D

#@onready var mesh = Node3D
@onready var mesh_node := %mesh_node

@onready var debug_status := %debug_status

var is_being_held : bool = false
var is_being_used : bool = false

@onready var anim_player := %anim_player
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	#spawn_mesh()
	var find_child_collision := mesh_node.find_child("CollisionShape3D") ## pega a colisão da mesh 
	match selected_material:
		"Wood":
			find_child_collision.reparent(self) ## parasita a mesh de colisão do filho 
#func spawn_mesh():
	#var inst_mesh = mesh.instantiate()
	#self.add_child(inst_mesh)
	#inst_mesh.global_position = %spawn_mesh.global_position
	#collision_shape = inst_mesh.collision_shape
	#pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_being_used:
		debug_status.mesh.text = "STATUS: BEING USED: " + selected_material 
	else:
		debug_status.mesh.text = "STATUS: NOT USED: " + selected_material




func is_used() -> void:
	is_being_held = false
	queue_free()
