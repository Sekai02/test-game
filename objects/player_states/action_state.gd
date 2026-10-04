extends PlayerState
class_name ActionState


# Plays one animation from start to end and then goes back to Idle or Move.
# Used by Consume and Hit.

# With more than one, a random one plays each time (e.g. Hit: chest or head).
@export var animationNames: Array[StringName] = []

var currentAnimation: StringName


func enter(_previousStatePath: String, _data := {}) -> void:
	player.animation_finished.connect(_on_animation_finished)
	currentAnimation = animationNames.pick_random()
	player.play_animation(currentAnimation)


func exit() -> void:
	player.animation_finished.disconnect(_on_animation_finished)


func _on_animation_finished(finishedAnimation: StringName) -> void:
	if finishedAnimation == currentAnimation:
		finished.emit(get_resting_state())
