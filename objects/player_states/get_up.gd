extends PlayerState


# Gets up from the ground ("get_up") and goes back to Idle or Move. Used after
# a knockdown ("get_up" starts where "knockdown" ends) and when reviving.

# Death ends lying further back and with the arms open, so blend slower.
const FROM_DEATH_BLEND_TIME := 0.4


func enter(previousStatePath: String, _data := {}) -> void:
	player.animation_finished.connect(_on_animation_finished)
	player.play_animation("get_up", false, FROM_DEATH_BLEND_TIME if previousStatePath == DEATH else -1.0)


func exit() -> void:
	player.animation_finished.disconnect(_on_animation_finished)


func _on_animation_finished(finishedAnimation: StringName) -> void:
	if finishedAnimation == "get_up":
		finished.emit(get_resting_state())
