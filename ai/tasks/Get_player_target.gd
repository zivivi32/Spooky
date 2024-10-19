@tool
extends BTAction
## Stores the first node in the [member group] on the blackboard, returning [code]SUCCESS[/code]. [br]
## Returns [code]FAILURE[/code] if the group contains 0 nodes.

## Name of the SceneTree group.
@export var group: StringName

## Blackboard variable in which the task will store the acquired node.
@export var output_var: StringName = &"target"
func _generate_name() -> String:
	return "GetFirstNodeInGroup \"%s\"  ➜%s" % [
		group,
		LimboUtility.decorate_var(output_var)
		]
func _tick(delta: float) -> Status:
	var player = agent.get_tree().get_first_node_in_group(group)
	if !player:
		return FAILURE
	
	blackboard.set_var(output_var, player)
	agent.player = player
	return SUCCESS
