extends PlayerState


# Raises the sword ("block_start") and holds the guard while the block key is
# held: standing ("block_hold") or walking in any direction ("block_walk",
# "block_walk_back", "block_walk_left", "block_walk_right"). Running isn't
# possible while blocking, so the run key is ignored here. On
# release: when standing, lowers the sword ("block_end") and goes back to Idle;
# when moving, goes straight to Move.

# direction -> guard animation ("" = standing still)
const GUARD_ANIMATIONS := {
	"": &"block_hold",
	"forward": &"block_walk",
	"back": &"block_walk_back",
	"left": &"block_walk_left",
	"right": &"block_walk_right",
}

var guardUp := false
var lowering := false


func enter(_previousStatePath: String, _data := {}) -> void:
	guardUp = false
	lowering = false
	player.animation_finished.connect(_on_animation_finished)
	player.play_animation("block_start")


func exit() -> void:
	player.animation_finished.disconnect(_on_animation_finished)


func update(_delta: float) -> void:
	if not guardUp or lowering:
		return
	if Input.is_action_pressed("block"):
		play_guard_animation()
	else:
		release_guard()


func play_guard_animation() -> void:
	var animationName: StringName = GUARD_ANIMATIONS[get_move_direction()]
	if player.get_current_animation() != animationName:
		player.play_animation(animationName)


func release_guard() -> void:
	if is_moving():
		finished.emit(MOVE)
	else:
		lowering = true
		player.play_animation("block_end")


func _on_animation_finished(finishedAnimation: StringName) -> void:
	if finishedAnimation == "block_start":
		guardUp = true
		if Input.is_action_pressed("block"):
			play_guard_animation()
		else:
			release_guard()
	elif finishedAnimation == "block_end":
		finished.emit(get_resting_state())
