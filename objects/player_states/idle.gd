extends PlayerState


# Standing still: the two handed combat guard ("idle_combat") with the sword
# drawn, or the model's relaxed idle with it sheathed. Every VARIATION_DELAY_MIN
# to VARIATION_DELAY_MAX seconds it plays a random idle variation of the
# visible model ("idle_variation_N" drawn, "idle_sheathed_variation_N"
# sheathed, in each model's "model" library); a model without variations for
# the current sword state just keeps idling.

const VARIATION_DELAY_MIN := 8.0
const VARIATION_DELAY_MAX := 12.0
# Variations can start in a pose far from the idle (e.g. relaxed vs guard), so
# blend slower into and out of them.
const VARIATION_BLEND_TIME := 0.4

var timeLeft := 0.0
var playingVariation: StringName = &""


# data.blendTime: blend into the idle (the previous state can ask for a slower one).
func enter(_previousStatePath: String, data := {}) -> void:
	player.animation_finished.connect(_on_animation_finished)
	playingVariation = &""
	timeLeft = randf_range(VARIATION_DELAY_MIN, VARIATION_DELAY_MAX)
	player.play_animation(get_idle_animation(), false, data.get("blendTime", -1.0))


func exit() -> void:
	player.animation_finished.disconnect(_on_animation_finished)


func handle_input(event: InputEvent) -> void:
	handle_action_input(event)


func update(delta: float) -> void:
	if get_resting_state() == MOVE:
		finished.emit(MOVE)
		return
	if playingVariation != &"":
		# The model was switched (F1) during the variation: back to the guard.
		if player.get_current_animation() != playingVariation:
			end_variation()
		return
	timeLeft -= delta
	if timeLeft <= 0.0:
		var variations := player.get_idle_variations("idle_variation" if player.swordDrawn else "idle_sheathed_variation")
		if variations.is_empty():
			timeLeft = randf_range(VARIATION_DELAY_MIN, VARIATION_DELAY_MAX)
			return
		playingVariation = variations.pick_random()
		player.play_animation(playingVariation, false, VARIATION_BLEND_TIME)


func get_idle_animation() -> StringName:
	return &"idle_combat" if player.swordDrawn else &"idle"


func end_variation() -> void:
	playingVariation = &""
	timeLeft = randf_range(VARIATION_DELAY_MIN, VARIATION_DELAY_MAX)
	player.play_animation(get_idle_animation(), false, VARIATION_BLEND_TIME)


func _on_animation_finished(finishedAnimation: StringName) -> void:
	if finishedAnimation == playingVariation:
		end_variation()
