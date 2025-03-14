extends Node3D


@export var has_health := false

var max_health := 0.0:
	set = set_max_health
var current_health := 0.0:
	set = set_current_health


@export_enum("enemy","interactable","material","npc","player","turret") var what_detects_help : String = "player"
@export var what_detects : Array[String]
@export var parent: CharacterBody3D 

var target_group
var target
var targets : Array
#var is_in_attack_range = false

func _ready() -> void:
	
	max_health = parent.max_health
	current_health = max_health
	
	targets.append(parent.target) ## pega o target inicial e adiciona ele na lista
	for i in get_children():
		i.brain = self
		i.what_detects = what_detects
	
	debug()
func _process(delta: float) -> void:
	target = parent.target ## se certifica de que estamos falando do mesmo alvo (todas mudança de target alteram o parent.target, não esse.
	
	#if target == null: ## caso não tenha nenhum alvo, pegue o próximo da lista de targets
		#for i in targets.size(): ## se certifica de que não tem nenhum node null em targets
			#if targets[i] == null:
				#print("irei apagar o: ", str(targets[i]))
				#targets.remove_at(i)
			#else:
				#parent.target = targets[i]
				#print("novo target: ", str(targets[i]))
	if targets[0] == null: 
		#print("irei apagar o: ", str(targets[0]))
		targets.remove_at(0)
	else:
		#print("novo target: ", str(targets[0]))
		parent.target = targets[0]
	%MeshInstance3D5.mesh.text ="TARGETS: " + str(targets)

func set_max_health(new_max_health):
	max_health = new_max_health

func set_current_health(new_current_health):
	if new_current_health < current_health:
		%anim_debug.play("hurt")
	else:
		%anim_debug.play("heal")
	var tween := create_tween().set_parallel()
	tween.tween_property(%HealthBar, "value", new_current_health, 0.6)
	current_health = new_current_health
	#print(current_health)
	

	
func debug():
	%HealthBar.max_value = max_health
	%HealthBar.value = current_health
