extends CutsceneStep
class_name AnimationTreeStep

@export var animation_tree_name: String
@export var animation_state_name: String
@export var return_to_animation: bool = false
@export var return_animation_name: String

var animation_tree: AnimationTree
var is_playing: bool = false
var is_returning: bool = false

func execute() -> void:
	# Find the AnimationTree node in the scene
	var animation_trees = scene_tree.get_nodes_in_group("animation_tree")
	for tree in animation_trees:
		if tree.name == animation_tree_name:
			animation_tree = tree
			break
	
	if animation_tree:
		animation_tree.active = true
		var state_machine = animation_tree.get("parameters/playback")
		if state_machine is AnimationNodeStateMachinePlayback:
			state_machine.travel(animation_state_name)  # Use travel instead of direct set
			is_playing = true
			is_returning = false

func is_complete() -> bool:
	if not wait_for_completion:
		return true
	
	if not animation_tree:
		push_warning("AnimationTree not found!")
		return true
	
	var state_machine = animation_tree.get("parameters/playback")
	if not state_machine is AnimationNodeStateMachinePlayback:
		push_warning("Invalid state machine playback!")
		return true
	
	# Check if the primary animation has finished
	if is_playing:
		if state_machine.get_current_node() != animation_state_name or state_machine.is_playing() == false:
			is_playing = false
			
			# Handle return animation
			if return_to_animation and not is_returning:
				state_machine.travel(return_animation_name)
				is_returning = true
			else:
				return true
	
	# Check return animation completion
	elif is_returning:
		if state_machine.get_current_node() != return_animation_name or state_machine.is_playing() == false:
			is_returning = false
			return true
	
	return false
