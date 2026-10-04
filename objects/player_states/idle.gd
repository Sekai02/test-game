extends PlayerState


# Standing still: the two handed combat guard ("idle_combat") with the sword
# drawn, or the model's relaxed idle with it sheathed.


# data.blendTime: blend into the idle (the previous state can ask for a slower one).
func enter(_previousStatePath: String, data := {}) -> void:
	player.play_animation(get_idle_animation(), false, data.get("blendTime", -1.0))


func handle_input(event: InputEvent) -> void:
	handle_action_input(event)


func update(_delta: float) -> void:
	if get_resting_state() == MOVE:
		finished.emit(MOVE)


func get_idle_animation() -> StringName:
	return &"idle_combat" if player.swordDrawn else &"idle"
