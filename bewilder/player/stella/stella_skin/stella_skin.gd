class_name StellaSkin extends Node3D

@onready var animation_tree = %AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")
@onready var move_tilt_path : String = "parameters/StateMachine/Move/tilt/add_amount"

var run_tilt = 0.0 : set = _set_run_tilt


@onready var hair_front_bang: BoneAttachment3D = $stella_imported/Stella/Skeleton3D/hairFrontBang
@onready var anteneas: MeshInstance3D = $stella_imported/Stella/Skeleton3D/anteneas
@onready var ears: MeshInstance3D = $stella_imported/Stella/Skeleton3D/ears
@onready var eyes: MeshInstance3D = $stella_imported/Stella/Skeleton3D/eyes
@onready var hair: MeshInstance3D = $stella_imported/Stella/Skeleton3D/hair
@onready var hair_lateral_bangs: MeshInstance3D = $stella_imported/Stella/Skeleton3D/hairLateralBangs
@onready var head: MeshInstance3D = $stella_imported/Stella/Skeleton3D/head

#@export var blink = true : set = set_blink
#@onready var blink_timer = %BlinkTimer
#@onready var closed_eyes_timer = %ClosedEyesTimer
#@onready var eye_mat = %stella_skin/stella_imported/Stella/Skeleton3D/eyes.get("surface_material_override/2")

#func set_blink(state : bool):
	#if blink == state: return
	#blink = state
	#if blink:
		#blink_timer.start(0.2)
	#else:
		#blink_timer.stop()
		#closed_eyes_timer.stop()
var value_blend_running : float = 0.0
var value_blend_griddy : float = 0.0
var value_blend_holding : float = 0.0
func update_blend():
	animation_tree.set("parameters/StateMachine/Fall/Fall & Hold/blend_amount", value_blend_holding)
	animation_tree.set("parameters/StateMachine/Idle/Idle & Hold/blend_amount", value_blend_holding)
	animation_tree.set("parameters/StateMachine/Jump/Jump & Hold/blend_amount", value_blend_holding)
	animation_tree.set("parameters/StateMachine/Run/Run & Hold/blend_amount", value_blend_holding)
	animation_tree.set("parameters/StateMachine/Idle/Idle & Griddy/blend_amount", value_blend_griddy)
	animation_tree.set("parameters/StateMachine/Run/Run & Running/blend_amount", value_blend_running)
	animation_tree.set("parameters/StateMachine/Run/Filter Bangs Run/blend_amount", 0.7)

func blend_minus(anim):
	match anim:
		"running":
			value_blend_running = lerpf(value_blend_running, 1.0, 0.09)
		"holding":
			value_blend_holding = lerpf(value_blend_holding, 1.0, 0.09)
		"griddy":
			value_blend_griddy = lerpf(value_blend_griddy, 1.0, 0.05)
	update_blend()
func blend_plus(anim):
	match anim:
		"running":
			value_blend_running = lerpf(value_blend_running, 0.0, 0.09)
		"holding":
			value_blend_holding = lerpf(value_blend_holding, 0.0, 0.09)
		"griddy":
			value_blend_griddy = lerpf(value_blend_griddy, 0.0, 0.09)
	update_blend()
	
func _set_run_tilt(value : float):
	run_tilt = clamp(value, -1.0, 1.0)
	animation_tree.set(move_tilt_path, run_tilt)

func idle():
	state_machine.travel("Idle")

func run():
	state_machine.travel("Run")

func fall():
	state_machine.travel("Fall")

func jump():
	state_machine.travel("Jump")

func edge_grab():
	state_machine.travel("EdgeGrab")

func wall_slide():
	state_machine.travel("WallSlide")

func hide_head(is_visible):
	if !is_visible:
		hair_front_bang.visible = false
		anteneas.visible = false
		ears.visible = false
		eyes.visible = false
		hair.visible = false
		hair_lateral_bangs.visible = false
		head.visible = false
	else:
		hair_front_bang.visible = true
		anteneas.visible = true
		ears.visible = true
		eyes.visible = true
		hair.visible = true
		hair_lateral_bangs.visible = true
		head.visible = true
