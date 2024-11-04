extends Node3D

@export var area_pcam: PhantomCamera3D
@export var interaction_area: InteractionArea
@export var hub_shop: CanvasLayer
var initial_camera_position: Vector3
var initial_camera_rotation: Vector3

@export_subgroup("Dialogue properties")
#const balloon_scene = preload("res://Dialogues/balloon.tscn")
@export var dialogue_resource: DialogueResource
@export var dialogue_to_start: String
@export var bought_dialogue: String
@export var leaving_without_purchase_dialogue: String


var tween: Tween
var tween_duration: float = 0.9

@export var cutscene_res: Cutscene
func _ready() -> void:
	interaction_area.interact = Callable(self, "start_dialogue")
	
	Events.connect("shop_done", shop_end)
	#Events.connect("shop_open", shop_open)
	DialogueManager.connect("dialogue_ended", shop_open)
	
func shop_open(resource) -> void:
	if GlobalVariables.open_shop:
		hub_shop.show()
		GlobalVariables.open_shop = false
	else:
		area_pcam.set_priority(0)
		Events.out_interaction.emit()

func start_dialogue(): 
	CutsceneManager.play_cutscene(cutscene_res)

func dialogue_shop(_dialogue_to_start):
	var balloon_scene = load("res://Dialogues/balloon.tscn")
	var balloon: Node = balloon_scene.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, _dialogue_to_start)

func shop_end():
	if GlobalVariables.bought_something:
		dialogue_shop(bought_dialogue)
	else: 
		dialogue_shop(leaving_without_purchase_dialogue)
		
	GlobalVariables.bought_something = false
	await DialogueManager.dialogue_ended
	
	area_pcam.set_priority(0)
	Events.out_interaction.emit()
