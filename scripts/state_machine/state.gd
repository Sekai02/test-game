extends Node
class_name State


# Base state for a finite state machine (GDQuest pattern). The StateMachine
# only calls these methods on the active state.

# Emitted to ask the state machine to switch to another state.
signal finished(nextStatePath: String, data: Dictionary)


# Called by the state machine on unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass


# Called by the state machine every frame.
func update(_delta: float) -> void:
	pass


# Called by the state machine every physics tick.
func physics_update(_delta: float) -> void:
	pass


# Called when the state machine switches to this state.
func enter(_previousStatePath: String, _data := {}) -> void:
	pass


# Called before the state machine leaves this state.
func exit() -> void:
	pass
