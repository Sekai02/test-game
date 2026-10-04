extends PlayerState


# Takes the sword from the back: reaches over the right shoulder ("draw_1"),
# the sword goes from the back to the hand and is pulled to the guard
# ("draw_2"). While the hand reaches back the sheathed sword slides into it,
# so it doesn't jump when it changes hands. Then goes back to Idle or Move.


func enter(_previousStatePath: String, _data := {}) -> void:
	player.animation_finished.connect(_on_animation_finished)
	player.play_animation("draw_1")


func exit() -> void:
	player.animation_finished.disconnect(_on_animation_finished)
	player.set_sheath_blend(0.0)


func update(_delta: float) -> void:
	if player.get_current_animation() == "draw_1":
		player.set_sheath_blend(player.get_animation_position() / player.get_current_animation_length())


func _on_animation_finished(finishedAnimation: StringName) -> void:
	if finishedAnimation == "draw_1":
		player.set_sword_drawn(true)
		player.play_animation("draw_2")
	elif finishedAnimation == "draw_2":
		finished.emit(get_resting_state())
