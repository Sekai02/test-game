extends Node
class_name StateMachine


# Runs the active State (one of its children) and switches states when the
# active one emits `finished`.

@export var initialState: State = null

@onready var state: State = initialState if initialState != null else get_child(0)


func _ready() -> void:
	for child in get_children():
		if child is State:
			child.finished.connect(transition_to)
	await owner.ready
	state.enter("")


func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)


func _process(delta: float) -> void:
	state.update(delta)


func _physics_process(delta: float) -> void:
	state.physics_update(delta)


# Public so the owner can force a state too (e.g. getting hit from outside).
func transition_to(targetStatePath: String, data: Dictionary = {}) -> void:
	if not has_node(targetStatePath):
		printerr(owner.name + ": trying to transition to state " + targetStatePath + " but it doesn't exist.")
		return
	var previousStatePath := state.name
	state.exit()
	state = get_node(targetStatePath)
	state.enter(previousStatePath, data)
