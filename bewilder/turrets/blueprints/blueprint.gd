class_name blueprints extends RigidBody3D

@export_enum("Default", "Clockwork") var turret_to_spawn : String = "Default"

@export var ballista : PackedScene = preload("res://turrets/ballista/turret_ballista.tscn")
@export var spawn_location : Node3D 
var selected_turret : PackedScene



var is_player_near : bool = false
var is_being_held : bool = false
var is_progress_bar_full : bool = false
var is_all_required_material_near: bool = false
var is_previwed : bool = false

@onready var debug_mesh := %MeshInstance3D2
@export var necessary_materials : Array[String]
@export var near_materials : Array[resource_material]


func disable_collision() -> void:
	%CollisionShape3D.disabled = true
	self.freeze = true
func enable_collision() -> void:
	%CollisionShape3D.disabled = false
	self.freeze = false
func _process(delta: float) -> void:
	
	match turret_to_spawn:
		"Ballista":
			selected_turret = ballista
	if !is_previwed:
		tower_preview()
		is_previwed = true
	if instanciate_tower != null: 
		instanciate_tower.global_position = spawn_location.global_position
		instanciate_tower.global_rotation = spawn_location.global_rotation
	if necessary_materials.size() == near_materials.size():
		is_all_required_material_near = true
	else:
		is_all_required_material_near = false
	if is_player_near && !is_being_held:
		progress_show()
		if is_progress_bar_full and is_all_required_material_near:
			tower_place()

		progress_show()
		if Input.is_action_pressed("interact_secundary"):
			interactHold()
		else:
			%ProgressBar.value -= 1                                                                                                                     
	else:
		%ProgressBar.value -= 1
		progress_hide()
		
	check_progress_bar()
	debug_mesh.mesh.text = "NECESSARY MATERIALS: " + str(necessary_materials) 

var should_show := false
func progress_show() -> void:
	if should_show:
		%anim_player_fade.play("fade_in")
		should_show = false
	#last_anim_played = %AnimationPlayer.current_animation
func progress_hide() -> void:
	if !should_show:
		%anim_player_fade.play("fade_in",-1,-1,true)
		should_show = true
func hide_sprite() -> void:
	%Sprite3D.visible = false
func show_sprite() -> void:
	%Sprite3D.visible = true
func check_progress_bar() -> void: 
	if %ProgressBar.value == %ProgressBar.max_value:
		is_progress_bar_full = true
	else:
		is_progress_bar_full = false
func interactHold() -> void:
	if is_all_required_material_near:
		%ProgressBar.value += 1
	else:
		%anim_player_flash.play("flash_red")
		
func tower_place() -> void:
	for i in near_materials.size():
		near_materials[i].anim_player.play("is_used")
	instanciate_tower.just_spawned = true
	instanciate_tower.previewing = false
	#instanciate_tower.active = true
	%anim_player_fade.play("is_used")

var instanciate_tower : Node3D

func tower_preview() -> void:
	if selected_turret != null:
		var place_selected_turret := selected_turret.instantiate()
		get_parent().add_child(place_selected_turret)
		instanciate_tower = place_selected_turret
		place_selected_turret.play_previewing_anim_fade_out()
		place_selected_turret.previewing = true
		
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body != null:
		if body.is_in_group("player"):
			if %Sprite3D != null:
				is_player_near = true
				if instanciate_tower != null: instanciate_tower.play_previewing_anim_fade_in(); #print("oiyyyy")
		if body is resource_material:
			if necessary_materials.has(body.selected_material) && !body.is_being_used && !is_all_required_material_near:
				body.is_being_used = true
				near_materials.append(body)
				%anim_player_flash.play("flash_green")
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body != null:
		if body.is_in_group("player"):
			if %Sprite3D != null:
				is_player_near = false
				if instanciate_tower != null: instanciate_tower.play_previewing_anim_fade_out()
		if body is resource_material:
			if near_materials.has(body):
				body.is_being_used = false
				near_materials.erase(body)
			

func is_used() -> void:
	queue_free()
