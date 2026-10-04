extends PlayerState


# Attack sequence with a two handed sword: the Mixamo sword combo (attack_1..3)
# followed by the club combo (attack_4..6), each cut into one piece per hit.
# Every piece starts exactly where the previous one ends (also from the club
# combo back to the sword combo), so they chain without any jump. An attack
# press during a hit plays the next one when the current piece ends, and after
# attack_6 the sequence starts over with attack_1, for as long as attacks keep
# coming. When no press arrives, it goes back to Idle (the combat guard, since
# the sword is drawn) or to Move if a move key is held. Other actions are
# ignored until the sequence stops.

const STEPS := [&"attack_1", &"attack_2", &"attack_3", &"attack_4", &"attack_5", &"attack_6"]
# The sequence starts and ends in a stance far from the guard, so blend slower
# into the first hit and back out of it.
const ENTER_BLEND_TIME := 0.2
const EXIT_BLEND_TIME := 0.3
# The Mixamo combos are animated at a realistic pace, too slow for gameplay.
const ATTACK_SPEED := 1.5

var step := 0
# Attack pressed during a hit: the next hit plays when this one ends.
var queued := false


func enter(_previousStatePath: String, _data := {}) -> void:
	player.animation_finished.connect(_on_animation_finished)
	step = 0
	queued = false
	player.play_animation(STEPS[step], false, ENTER_BLEND_TIME, ATTACK_SPEED)


func exit() -> void:
	player.animation_finished.disconnect(_on_animation_finished)


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		queued = true


func _on_animation_finished(finishedAnimation: StringName) -> void:
	if finishedAnimation != STEPS[step]:
		return
	if queued:
		step = (step + 1) % STEPS.size()
		queued = false
		# Consecutive pieces start where the previous one ends: no blend needed.
		player.play_animation(STEPS[step], false, 0.0, ATTACK_SPEED)
	else:
		finished.emit(get_resting_state(), {"blendTime": EXIT_BLEND_TIME})
