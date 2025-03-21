class_name Player extends CharacterBody3D



@export_group("Stats")
@export var health := 100.0
@export var regeneration := 0.5

@export_group("Movement")
## Character maximum run speed on the ground in meters per second.
@export var move_speed := 8.0
var max_move_speed : float
## Ground movement acceleration in meters per second squared.
@export var acceleration := 20.0
var max_accelaration : float
## When the player is on the ground and presses the jump button, the vertical
## velocity is set to this value.
@export var jump_impulse := 12.0
## Player model rotation speed in arbitrary units. Controls how fast the
## character skin orients to the movement or camera direction.
@export var rotation_speed := 12.0
## Minimum horizontal speed on the ground. This controls when the character skin's
## animation tree changes between the idle and running states.
@export var stopping_speed := 1.0

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export var _look_at : Marker3D
var where_to := "none"
var tilt_upper_limit := PI / 3.0
var tilt_lower_limit := -PI / 8.0
@export var tp_tilt_upper_limit := PI / 3.0
@export var tp_tilt_lower_limit := -PI / 8.0
@export var fp_tilt_upper_limit := 1.047
@export var fp_tilt_lower_limit := -1.4

@export var tp_camera_fov := 50
@export var tp_camera_v_offset := 0.250
@export var fp_camera_fov := 60
@export var fp_camera_v_offset := 0.0

@export var fp_spring_length := 0.0 

var _gravity := -30.0
var _was_on_floor_last_frame := true
var _camera_input_direction := Vector2.ZERO
## Each frame, we find the height of the ground below the player and store it here.
## The camera uses this to keep a fixed height while the player jumps, for example.
var ground_height := 0.0
var is_in_interaction := false
@onready var spring_arm_3d: SpringArm3D = $CameraPivot/SpringArm3D



## The last movement or aim direction input by the player. We use this to orient
## the character model.
@onready var _last_input_direction := global_basis.z
# We store the initial position of the player to reset to it when the player falls off the map.
@onready var _start_position := global_position

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _skin: StellaSkin = %stella_skin
@onready var _landing_sound: AudioStreamPlayer3D = %LandingSound
@onready var _jump_sound: AudioStreamPlayer3D = %JumpSound
@onready var _dust_particles: GPUParticles3D = %DustParticles
@export var where_head_is : Marker3D
var is_holding : bool = false
var is_running_fast : bool = false

signal first_person(look_at : Node3D)

func _ready() -> void:
	max_move_speed = move_speed
	max_accelaration = acceleration
	Events.kill_plane_touched.connect(func on_kill_plane_touched() -> void:
		global_position = _start_position
		velocity = Vector3.ZERO
		_skin.idle()
		set_physics_process(true)
	)


func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	elif event.is_action_pressed("left_click") && !is_in_interaction:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#first_person(null)
	
	var max_spring := 12.0
	var min_spring := 3.0
	var cur_spring : float = spring_arm_3d.spring_length 
	if cur_spring != fp_spring_length:
		if event.is_action_pressed("scroll_up"):
			if cur_spring < max_spring:
				spring_arm_3d.spring_length += 1
		elif event.is_action_pressed("scroll_down"):
			if cur_spring > min_spring:
				spring_arm_3d.spring_length -= 1

@export_group("Grab")
@export var grab_location : Node3D
var held_object : Node3D
func interact() -> void:
	var obj : Node3D
	if %raycast_grab.is_colliding() && !is_holding && held_object == null:
		obj = %raycast_grab.get_collider()
	if Input.is_action_just_pressed("interact"):
		if is_holding && held_object != null:
			held_object.set_collision_layer_value(2,true)
			held_object.set_collision_layer_value(1,true)
			is_holding = false
			held_object.is_being_held = false
			held_object = null
		if obj != null:
			if obj.is_in_group("material"):
				held_object = obj
				held_object.set_collision_layer_value(1,false)
				held_object.set_collision_layer_value(2,false)
				#held_object.mesh
				is_holding = true
				obj.is_being_held = true
			elif obj.get_parent().is_in_group("interactable"):
				obj.get_parent().interact()
				#first_person(obj.get_parent().get_parent().head)

func _unhandled_input(event: InputEvent) -> void:
	var is_object_being_held := held_object == null
	var player_is_using_mouse := (
		event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if player_is_using_mouse:
		if spring_arm_3d.spring_length == fp_spring_length:
			_camera_input_direction.y = event.relative.y * mouse_sensitivity
		else:
			_camera_input_direction.y = -event.relative.y * mouse_sensitivity
		_camera_input_direction.x = -event.relative.x * mouse_sensitivity



func _physics_process(delta: float) -> void:
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, tilt_lower_limit, tilt_upper_limit)
	_camera_pivot.rotation.y += _camera_input_direction.x * delta

	_camera_input_direction = Vector2.ZERO
	

	if Input.is_action_pressed("run"): is_running_fast = true
	else: is_running_fast = false
	# Calculate movement input and align it to the camera's direction.
	var raw_input := Input.get_vector("a", "d", "w", "s", 0.4)
	# Should be projected onto the ground plane.
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()

	# To not orient the character too abruptly, we filter movement inputs we
	# consider when turning the skin. This also ensures we have a normalized
	# direction for the rotation basis.
	if !is_in_interaction:
		if move_direction.length() > 0.2:
			_last_input_direction = move_direction.normalized()
		var target_angle := Vector3.BACK.signed_angle_to(_last_input_direction, Vector3.UP)
		_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)

	# We separate out the y velocity to only interpolate the velocity in the
	# ground plane, and not affect the gravity.
	var y_velocity := velocity.y
	velocity.y = 0.0
	if !is_in_interaction:
		velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
		if is_equal_approx(move_direction.length_squared(), 0.0) and velocity.length_squared() < stopping_speed:
			velocity = Vector3.ZERO
	velocity.y = y_velocity + _gravity * delta

	# Character animations and visual effects.
	var ground_speed := Vector2(velocity.x, velocity.z).length()
	var is_just_jumping := Input.is_action_just_pressed("jump") and is_on_floor()
		

	if Input.is_action_pressed("r"):
		_skin.blend_minus("griddy")
	else:
		_skin.blend_plus("griddy")
	if Input.is_action_just_pressed("first_person"):
		emit_signal("first_person", null)
		
	match is_holding && held_object != null:
		true:

			_skin.blend_minus("holding")
			_skin.update_blend()
			held_object.global_position = grab_location.global_position;
			held_object.global_rotation = grab_location.global_rotation
			%raycast_grab.collide_with_bodies = false
		false:
			_skin.blend_plus("holding")
			_skin.update_blend()
			%raycast_grab.collide_with_bodies = true
	if held_object == null:
		is_holding = false

	if is_just_jumping:
		if !is_in_interaction:
			velocity.y += jump_impulse
			_skin.jump()
			_jump_sound.play()
	elif not is_on_floor() and velocity.y < 0:
		_skin.fall()
	elif is_on_floor():
		if ground_speed > 0.0:
			_skin.run()
		else: _skin.idle(); 
		
	if is_running_fast && !is_holding:
		_skin.blend_minus("running")
		_skin.update_blend()
		acceleration = max_accelaration * 0.5
		move_speed = max_move_speed / 0.5
	else:
		_skin.blend_plus("running")
		_skin.update_blend()
		move_speed = max_move_speed
		acceleration = max_accelaration
	_dust_particles.emitting = is_on_floor() && ground_speed > 0.0
	if is_on_floor() and not _was_on_floor_last_frame:
		_landing_sound.play()
	
	_was_on_floor_last_frame = is_on_floor()
	
	change_spring_arm(where_to, delta)
	interact()
	move_and_slide()
	
var saved_length : float

func _on_first_person(look_at: Variant) -> void:
	#print("\n")
	#print("spr ", spring_arm_3d.spring_length)
	#print("fp ", fp_spring_length)
	#print("saved ", saved_length)
	#print("where" , where_to)
	if floorf(spring_arm_3d.spring_length) == floorf(fp_spring_length) && where_to == "none": ## tira o zoom
		where_to = "zoom_out"
		tilt_lower_limit = tp_tilt_lower_limit
		tilt_upper_limit = tp_tilt_upper_limit
		%Camera3D.fov = tp_camera_fov
		%Camera3D.v_offset = tp_camera_v_offset
		
		
		%stella_skin.hide_head(true)
	elif floorf(spring_arm_3d.spring_length) != floorf(fp_spring_length) && where_to == "none":
		saved_length = spring_arm_3d.spring_length 
		where_to = "zoom_in"
		tilt_lower_limit = fp_tilt_lower_limit
		tilt_upper_limit = fp_tilt_upper_limit
		%Camera3D.fov = fp_camera_fov
		%Camera3D.v_offset = fp_camera_v_offset
		if look_at != null:
			%CameraPivot.look_at(look_at.global_position,Vector3.UP,true)


		
func change_spring_arm(where_to_ : String, delta : float) -> void:
	#print("spr ", spring_arm_3d.spring_length)
	match where_to_:
		"zoom_in":
			spring_arm_3d.spring_length = lerpf(spring_arm_3d.spring_length,fp_spring_length, 8 * delta)
			if spring_arm_3d.spring_length <= 1.0:
				%stella_skin.hide_head(false)
				if spring_arm_3d.spring_length <= 0.01:
					spring_arm_3d.spring_length = floorf(spring_arm_3d.spring_length * delta)
					where_to = "none"
		"zoom_out":
			spring_arm_3d.spring_length = lerpf(spring_arm_3d.spring_length, saved_length, 8 * delta)
			if spring_arm_3d.spring_length >= saved_length - 0.01:
				spring_arm_3d.spring_length = floorf(spring_arm_3d.spring_length)
				where_to = "none"
			elif spring_arm_3d.spring_length >= 1.0:
				%stella_skin.hide_head(true)
			#if spring_arm_3d.spring_length <= 0.01:
				#spring_arm_3d.spring_length = floorf(spring_arm_3d.spring_length)
			
			#if spring_arm_3d.spring_length == saved_length:
			#	where_to = "none"

func take_damage(attack: Attack) -> void:
	health -= attack.attack_damage
	velocity.x = (global_transform.origin.x - attack.attack_position.x) * attack.knockback_force
	#velocity.y = (global_transform.origin.y - attack.attack_position.y) * attack.knockback_force / 2
	#if health <= 0:
		#print("Stella morreu")
	
