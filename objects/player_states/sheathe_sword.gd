extends PlayerState


# Puts the sword on the back: the draw played backwards. Lifts it over the
# head ("draw_2" backwards), the sword goes from the hand to the back and the
# arm comes down ("draw_1" backwards) while the sword slides from the hand to
# its place on the back. Then goes to Idle or Move.

func enter(_previousStatePath: String, _data := {}) -> void:
	player.animation_finished.connect(_on_animation_finished)
	player.play_animation("draw_2", true)


func exit() -> void:
	player.animation_finished.disconnect(_on_animation_finished)
	player.set_sheath_blend(0.0)


func update(_delta: float) -> void:
	# draw_1 plays backwards: from the hand (end) to the back (start).
	if not player.swordDrawn and player.get_current_animation() == "draw_1":
		player.set_sheath_blend(player.get_animation_position() / player.get_current_animation_length())


func _on_animation_finished(finishedAnimation: StringName) -> void:
	if finishedAnimation == "draw_2":
		player.set_sword_drawn(false)
		# Start the slide back from the hand, not from the sheath.
		player.set_sheath_blend(1.0)
		player.play_animation("draw_1", true)
	elif finishedAnimation == "draw_1":
		finished.emit(get_resting_state())
