extends PlayerState


# Final state: plays the fall and stays on the ground. Only the player can
# take it out of here (see Player.revive()).

func enter(_previousStatePath: String, _data := {}) -> void:
	player.play_animation("death")
