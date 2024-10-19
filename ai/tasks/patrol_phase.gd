@tool
extends BTAction
@export var target_var: StringName = &"target"
# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "Pursue %s" % [LimboUtility.decorate_var(target_var)]
	
func _enter() -> void:
	agent.patrol()
