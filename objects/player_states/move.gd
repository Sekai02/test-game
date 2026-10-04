extends PlayerState


# Walks while a move key is held, and runs while the run key is held too, in
# four directions (forward, back, left and right strafes; diagonals use the
# forward/back animation).
# Sword drawn: Mixamo two handed combat animations.
# Sword sheathed: Mixamo unarmed locomotion; the male and female models each
# have their own walk, run and strafes (see Player.play_animation). There's no
# unarmed walk back, so walking back plays the walk reversed.

# direction -> [sheathed walk, sheathed run, drawn walk, drawn run]
const ANIMATIONS := {
	"forward": [&"walk", &"run", &"walk_combat", &"run_combat"],
	"back": [&"walk", &"run_back_relaxed", &"walk_back", &"run_back"],
	"left": [&"walk_left", &"run_left", &"walk_left_combat", &"run_left_combat"],
	"right": [&"walk_right", &"run_right", &"walk_right_combat", &"run_right_combat"],
}

var currentAnimation: StringName = &""
var currentBackwards := false


# data.blendTime: blend into the first animation (the previous state can ask
# for a slower one).
func enter(_previousStatePath: String, data := {}) -> void:
	currentAnimation = &""
	update_animation(data.get("blendTime", -1.0))


func handle_input(event: InputEvent) -> void:
	handle_action_input(event)


func update(_delta: float) -> void:
	if get_resting_state() == IDLE:
		finished.emit(IDLE)
		return
	update_animation()


func update_animation(blendTime := -1.0) -> void:
	var direction := get_move_direction()
	var index := (2 if player.swordDrawn else 0) + (1 if is_running() else 0)
	var animationName: StringName = ANIMATIONS[direction][index]
	var backwards := direction == "back" and animationName == &"walk"
	if animationName != currentAnimation or backwards != currentBackwards:
		currentAnimation = animationName
		currentBackwards = backwards
		player.play_animation(animationName, backwards, blendTime)
