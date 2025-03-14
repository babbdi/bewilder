class_name turret extends Node3D
### previewing_fade_in, previewing_fade_out, shoot, reload, fade_in
# My code is loosely based on code from here:
# https://github.com/IndieQuest/ModularTurret/tree/master/src
# https://www.youtube.com/watch?v=4IS9zIVCDKc&ab_channel=IndieQuest
# but modified by me, Neal Holtschulte in 2024 because
# 1. That code didn't work for me and 
# 2. it was designed to only work when the turret
# was parallel to the ground.
# This was a life saver:
# https://math.stackexchange.com/questions/728481/3d-projection-onto-a-plane

# movement rates in degrees
@onready var elevation_speed_deg: float 
@onready var rotation_speed_deg: float
# elevation constraints in degrees
@onready var min_elevation_deg: float 
@onready var max_elevation_deg: float
# Turret components:
# Body only rotates around y axisF
# Head only rotates (elevates) around x axis

# Turret should rotate to look at this object
var target: Node3D
var targets : Array
@export var resource : turret_resource
@export_category("Essentials")
@export var projectile_scene : PackedScene
@export var _turret_base : turret_base
@export_category("Math")
#@export var raycast : RayCast3D
@export var projectile_spawn_location : Node3D

# Rates and constraints converted to radians
@onready var elevation_speed: float 
@onready var rotation_speed: float 
@onready var min_elevation: float 
@onready var max_elevation: float 
# This is for disabling the turret if a vital component is null
var just_spawned: bool = false # animar fade in
var active: bool = false

var previewing: bool = false # animar preview
@export_category("Rotation")

#@export var outline : MeshInstance3D
@onready var anim : AnimationPlayer

@export var body: Node3D # Component to be rotated
@export var head: Node3D# Component to be elevated

@export_category("Collisions")
@export var detection : StaticBody3D
var last_fire_time = -999999

func _ready() -> void:
	detection.set_process_mode(PROCESS_MODE_DISABLED)
	elevation_speed_deg = resource.elevation_speed_deg
	rotation_speed_deg = resource.rotation_speed_deg
	min_elevation_deg = resource.min_elevation_deg
	max_elevation_deg = resource.max_elevation_deg
	elevation_speed = deg_to_rad(elevation_speed_deg)
	rotation_speed = deg_to_rad(rotation_speed_deg)
	min_elevation = deg_to_rad(min_elevation_deg)
	max_elevation = deg_to_rad(max_elevation_deg) 
	#if shape_collision1 != null:
		#shape_collision1.disabled = false
	#if shape_collision2 != null:
		#shape_collision2.disabled = false
	#if shape_collision3 != null:
		#shape_collision3.disabled = false
func play_previewing_anim_fade_in():
	_turret_base.anim_player.play("previewing_fade_in")
	#print("AAAAAAAAAAAAAAA")
func play_previewing_anim_fade_out():
	_turret_base.anim_player.play("previewing_fade_in", -1, -1, true)
func _physics_process(delta: float) -> void:
	if just_spawned:
		_turret_base.play_anim("fade_in")
		just_spawned = false
		#
	if !targets.is_empty() && !previewing:
		target = targets.front()
		rotate_and_elevate(delta, target.global_position)
		if can_shoot():
			shoot()
	%MeshInstance3D.mesh.text = str(%AnimationPlayer.current_animation)
func rotate_and_elevate(delta: float, current_target:Vector3) -> void:
	# Project the target onto the XZ plane of the turret
	# but first adjust by the global position because
	# the global basis is purely orientation, not position.
	var rotation_targ:Vector3 = get_projected(current_target - body.global_position, body.global_basis.y)
	# But! You also need to account for changes in position,
	# so add back in the global position adjustment.
	rotation_targ = rotation_targ + body.global_position

	# Get the angle from the body's facing direction (z)
	# to the projected point. Since the point is projected
	# onto the plane, this should be the angle the body
	# should rotate to face along only one axis.
	var y_angle:float = get_angle_to_target(body.global_position, rotation_targ, body.global_basis.z)
	
	# Rotate toward target
	# Calculate sign to rotate left or right.
	var rotation_sign:float = sign(body.to_local(current_target).x)
	# Calculate step size and direction. Use min to avoid
	# over-rotating. Just snap to the desired angle if it's
	# less than what we would rotate this frame.
	var final_y:float = rotation_sign * min(rotation_speed * delta, y_angle)
	body.rotate_y(final_y)
	
	# Rotation is complete, now we elevate.
	# Project the target onto the ZY plane of the head
	# but first adjust by the global position because
	# the global basis is purely orientation, not position.
	var elevation_targ:Vector3 = get_projected(current_target - head.global_position, head.global_basis.x)
	# But! You also need to account for changes in position,
	# so add back in the global position adjustment.
	elevation_targ = elevation_targ + head.global_position
	
	# Get the angle from the head's facing direction (z)
	# to the projected point. Since the point is projected
	# onto the plane, this should be the angle the head
	# should rotate to face along only one axis.
	var x_angle:float = get_angle_to_target(head.global_position, elevation_targ, head.global_basis.z)
	
	# Elevate toward target.
	# Calculate sign to elevate up or down.
	# There's an extra negative sign because pitching up is negative.
	var elevation_sign:float = -sign(head.to_local(current_target).y)
	# Calculate step size and direction. Use min to avoid
	# over-rotating. Just snap to the desired angle if it's
	# less than what we would rotate this frame.
	var final_x:float = elevation_sign * min(elevation_speed * delta, x_angle)
	head.rotate_x(final_x)
	# Clamp elevation within limits.
	# Reverse and negate max and min because up is negative and
	# down is positive.
	head.rotation.x = clamp(
		head.rotation.x,
		-max_elevation, min_elevation
	)
func get_angle_to_target(seeker_pos:Vector3, target_pos:Vector3, facing_dir:Vector3) -> float:
	# Pre: target_pos is a Vector3 representing x,y,z
	# coordinates in space.
	# seeker_pos is a Vector3 representing x,y,z
	# coordinates in space.
	# facing_dir is a Vector3 representing the direction
	# we want to find the angle with respect to.
	# Post: Uses Law of Cosines to calculate and
	# return the difference between heading angle
	# (facing_dir) and global angle to target
	# (dir_to) in radians.
	# Typically, facing_dir will be -seeker.global_transform.basis.z
	# but it can be useful to ask about 
	# seeker.global_transform.basis.y to see if target
	# is above or below, or use seeker.global_transform.basis.x
	# to see if target is to the left or right.
	# Return value guaranteed to be between 0 and pi
	var dir_to = seeker_pos.direction_to(target_pos)
	# Normalizing IS necessary under certain circumstances.
	facing_dir = facing_dir.normalized()
	dir_to = dir_to.normalized()
	return acos(facing_dir.dot(dir_to))
func get_projected(pos:Vector3, normal:Vector3) -> Vector3:
	# Project position "pos" onto the plane with the given normal vector.
	# https://math.stackexchange.com/questions/728481/3d-projection-onto-a-plane
	# "projected" is the vector indicating how far above/below
	# the target is from the plane of rotation.
	normal = normal.normalized()
	var projection:Vector3 = (pos.dot(normal) / normal.dot(normal)) * normal
	# By subtracting projection from position, we get the
	# projected point.
	return pos - projection

var enemy_in_raycast = false
func body_entered_rc_enemy(body: Node3D) -> void:
	if body.has_method("take_damage") && body == target:
		enemy_in_raycast = true
		#print("oi")
			
func body_exited_rc_enemy(body: Node3D) -> void:
	if body.has_method("take_damage") && body == target:
		enemy_in_raycast = false
			
func can_shoot():
	if enemy_in_raycast && resource.current_ammo > 0:
		if !_turret_base.is_animation_playing("reload"):
			#print("PODE ATIRAR")
			return true
	elif resource.current_ammo <= 0:
		#print("PRECISA RECARREGAR")
		reload()
		
		

func shoot():
	_turret_base.play_anim("shoot")
	resource.current_ammo -= 1
	last_fire_time = Time.get_ticks_msec()
	if resource.one_shot == true:
		#print("OI")
		reload()
	#target.take_damage(attack)
func spawn_projectile():
	var projectile_instantiate = projectile_scene.instantiate()
	add_child(projectile_instantiate)
	projectile_instantiate.scale = Vector3(0.25,0.25,0.25)
	projectile_instantiate._position = projectile_spawn_location.global_position
	projectile_instantiate._angle = projectile_spawn_location.global_rotation
	projectile_instantiate._update_info()
	projectile_instantiate.speed = resource.projectile_speed
	projectile_instantiate.damage = resource.projectile_damage
	projectile_instantiate.pen = resource.projectile_pen
	projectile_instantiate.trigger_shoot = true
	#await get_tree().create_timer(resource.projectile_life_time * 100).timeout
	#projectile_instantiate.queue_free()
	#print("PROJECTILE SPAWNED")
	
func reload():
	#projectile_instantiate.trigger_shoot = true
	var can_reload = get_amount_can_reload()
	if can_reload < 0:
		return
		#print("NAO PODE CARREGAR")
	elif resource.magazine_capacity == INF or resource.current_ammo == INF:
		resource.current_ammo = resource.magazine_capacity
	else:
		resource.current_ammo += can_reload
		resource.reserve_ammo -= can_reload
		#if resource.one_shot == true:
			#_turret_base.play_anim_next("reload")
		#else:
		_turret_base.play_anim("reload")
		#print("CARREGANDO")
func get_amount_can_reload() -> int:
	var wish_reload = resource.magazine_capacity - resource.current_ammo
	var can_reload = min(wish_reload, resource.reserve_ammo)
	return can_reload
	

func activate_detection():
	detection.set_process_mode(PROCESS_MODE_INHERIT)
	_turret_base.play_anim("reload")
		

#func update_turret_info():
	#%turret_name.text = str(turret_name)
	#%turret_damage.text = %turret_damage.text + str(damage)




			
