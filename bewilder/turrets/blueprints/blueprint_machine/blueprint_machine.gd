extends Node3D

@onready var left_slot := $Interface/SubViewport/left_slot
@onready var middle_slot := $Interface/SubViewport/middle_slot
@onready var right_slot := $Interface/SubViewport/right_slot

@onready var unlocked_bps : Array
@onready var spawner_blueprint := $spawner_blueprint

@onready var default_blueprint := preload("res://turrets/blueprints/default_blueprint.tscn")

@onready var anim_player := $AnimationPlayer
# Called when the node enters the scene tree for the first time.
var left_number := 0
var middle_number := 1
var right_number := 2

var order_applied : bool = false

func _ready() -> void:
	pass

func check_max() -> void:
	if is_max_left:
		can_go_previous = false
		can_go_next = true
		left_slot.visible = false
		
	elif !is_max_left:
		left_slot.visible = true
		
		
	if is_max_right:
		can_go_next = false
		can_go_previous = true
		right_slot.visible = false
		
	elif !is_max_right:
		right_slot.visible = true
		
		
		
	if deactivade_both:
		can_go_next = false
		can_go_previous = false
		right_slot.visible = false
		left_slot.visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.

func is_in_order() -> bool:
	if left_number == 0 and middle_number == 1 and right_number == 2: return true
	else: return false

func _process(delta: float) -> void:
	unlocked_bps = Events.unlocked_blueprints
	var size := unlocked_bps.size()
	if unlocked_bps != null && !unlocked_bps.is_empty():
		middle_slot.visible = true
		if size == 1:
			deactivade_both = true
			middle_slot.label.text = unlocked_bps.front()
		elif size == 2:
			deactivade_both = false
			if left_number == middle_number: is_max_left = false; is_max_right = true
			else: is_max_left = true ; is_max_right = false
			middle_slot.label.text = unlocked_bps[left_number]
			right_slot.label.text = unlocked_bps[middle_number]
		elif size > 2:
			if order_applied == false: ##Corrigir os números apenas 1 vez
				if is_in_order():
					is_max_left = false
					is_max_right = false
					can_go_next = true
					can_go_previous = true
					order_applied = true
				elif !is_in_order():
					left_number = 0
					middle_number = 1
					right_number = 2
			if left_number < middle_number && middle_number < right_number:
				can_go_next = true
				can_go_previous = true
			middle_slot.label.text = unlocked_bps[middle_number]
			right_slot.label.text = unlocked_bps[right_number]
			left_slot.label.text = unlocked_bps[left_number]
	else:
		deactivade_both = true
		middle_slot.visible = false
	check_max()

var can_go_next : bool = true
var can_go_previous : bool = true

var is_max_right : bool = false
var is_max_left : bool = false
var deactivade_both : bool = false

func _next() -> void:
	if can_go_next:
		if unlocked_bps.size() == 2: ## CASO SO TENHA 2, FICAR NESSA BRINCADEIRA AQ
			if is_max_left and !is_max_right:
				left_number += 1
				#left number == middle number (1)
				#desativar is_max_left pq foi pra direita
		elif !is_max_left and !is_max_right && right_number < unlocked_bps.size() - 1: ## TA NO MEIO
			left_number += 1
			middle_number += 1
			right_number += 1
		elif !is_max_left and !is_max_right && right_number == unlocked_bps.size() - 1: ## TA NO PENULTIMO
			left_number += 1                                                            ## DA DIRETA
			middle_number += 1
			is_max_right = true
		elif is_max_left and !is_max_right && left_number == middle_number: ## TA NO ULTIMO DA ESQUERDA
			middle_number += 1                                    
			right_number += 1
			is_max_left = false
			
func _previous() -> void:
	if can_go_previous:
		if unlocked_bps.size() == 2: ## CASO SO TENHA 2, FICAR NESSA BRINCADEIRA AQ
			if is_max_right and !is_max_left:
				left_number -= 1
		if is_max_right and !is_max_left && middle_number == right_number: ## SE ESTIVER NO ULTIMO
			left_number -= 1                                               ## DA DIREITA  
			middle_number -= 1           
			is_max_right = false              
			
		elif !is_max_left and !is_max_right && left_number > 0: ## TA NO MEIO
			left_number -= 1
			middle_number -= 1
			right_number -= 1
			
		elif !is_max_left and !is_max_right && left_number == 0:## SE ESTIVER NO MEIO E O DA ESQUERDA
			is_max_left = true                                  ## FOR O PRIMEIRO
			middle_number -= 1
			right_number -= 1


func _on_left_area_body_entered(body: Node3D) -> void:
	anim_player.play("button_left_press")
	if body != null and body is Player:
		_previous()


func _on_right_area_body_entered(body: Node3D) -> void:
	anim_player.play("button_right_press")
	if body != null and body is Player:
		_next()


func _on_confirm_area_body_entered(body: Node3D) -> void:
	anim_player.play("button_confirm_press")
	if body != null and body is Player && !unlocked_bps.is_empty():
		var selected_blueprint : String
		if unlocked_bps.size() == 1:
			selected_blueprint = unlocked_bps.front()
		elif unlocked_bps.size() == 2:
			if left_number == middle_number:
				selected_blueprint = unlocked_bps[middle_number]
			else:
				selected_blueprint = unlocked_bps[left_number]
		else:
			selected_blueprint = unlocked_bps[middle_number]
		var inst_blueprint := default_blueprint.instantiate()
		get_parent().add_child(inst_blueprint)
		inst_blueprint.turret_to_spawn = selected_blueprint
		inst_blueprint.global_position = spawner_blueprint.global_position
		print(selected_blueprint)
