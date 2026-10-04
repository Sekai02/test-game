extends PlayerState


# Forward roll: while running (run key held), the sprinting roll ("roll_sprint",
# starts and ends running); otherwise the roll from standing ("roll_stand",
# trimmed to the roll itself). Then goes back to Idle or Move.

const STAND_SPEED := 1.3
const SPRINT_SPEED := 0.8
const EXIT_BLEND_TIME := 0.25

var currentAnimation: StringName


func enter(_previousStatePath: String, _data := {}) -> void:
	player.animation_finished.connect(_on_animation_finished)
	var sprinting := is_running()
	currentAnimation = &"roll_sprint" if sprinting else &"roll_stand"
	player.play_animation(currentAnimation, false, -1.0, SPRINT_SPEED if sprinting else STAND_SPEED)


func exit() -> void:
	player.animation_finished.disconnect(_on_animation_finished)


func _on_animation_finished(finishedAnimation: StringName) -> void:
	if finishedAnimation == currentAnimation:
		finished.emit(get_resting_state(), {"blendTime": EXIT_BLEND_TIME})
