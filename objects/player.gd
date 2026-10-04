extends RigidBody3D
class_name Player


# Emitted when a non looping animation reaches its end.
signal animation_finished(animationName: StringName)

# Library with a model's own versions of shared animations.
const MODEL_LIBRARY := &"model/"

@onready var charMaleModel: Node3D = $CharMaleModel
@onready var charFemaleModel: Node3D = $CharFemaleModel
@onready var stateMachine: StateMachine = $StateMachine
# Both models always play the same animation, so switching models keeps the pose.
@onready var animationPlayers: Array[AnimationPlayer] = [
	$CharMaleModel/AnimationPlayer,
	$CharFemaleModel/AnimationPlayer,
]

# Sword in the hand (true) or sheathed on the back (false). The player starts
# with it sheathed.
var swordDrawn := false
# Resting transform of the sheathed sword of each model (see set_sheath_blend).
var sheathRest := {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Each model can have its own versions (different lengths), so only the
	# visible model reports finished animations.
	for animationPlayer in animationPlayers:
		animationPlayer.animation_finished.connect(
			func(finishedAnimation: StringName) -> void:
				if animationPlayer == get_visible_animation_player():
					animation_finished.emit(get_base_name(finishedAnimation)))
	for model in [charMaleModel, charFemaleModel]:
		sheathRest[model] = model.get_node("Armature/Skeleton3D/Back/SwordOnBack").transform
	set_sword_drawn(swordDrawn)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Testing: F1 switches between the male and female models, F2 gets hit,
# F3 dies (or revives when already dead) and F4 gets knocked down.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_switch_model"):
		charMaleModel.visible = not charMaleModel.visible
		charFemaleModel.visible = not charMaleModel.visible
	elif event.is_action_pressed("debug_hit"):
		take_hit()
	elif event.is_action_pressed("debug_death"):
		if is_dead():
			revive()
		else:
			die()
	elif event.is_action_pressed("debug_knockdown"):
		knock_down()


# Regular hit. Ignored on the ground (dead, knocked down or getting up).
func take_hit() -> void:
	if not is_dead() and not is_on_ground():
		stateMachine.transition_to(PlayerState.HIT)


func knock_down() -> void:
	if not is_dead() and not is_on_ground():
		stateMachine.transition_to(PlayerState.KNOCKDOWN)


# Knocked down or getting up.
func is_on_ground() -> bool:
	return stateMachine.state.name in [PlayerState.KNOCKDOWN, PlayerState.GET_UP]


func die() -> void:
	if not is_dead():
		stateMachine.transition_to(PlayerState.DEATH)


func revive() -> void:
	if is_dead():
		stateMachine.transition_to(PlayerState.GET_UP)


func is_dead() -> bool:
	return stateMachine.state.name == PlayerState.DEATH


# Plays an animation on both models, blending from the current one.
# blendTime -1 uses the AnimationPlayer's default blend time.
# A model can have its own version of an animation in its "model" library
# (e.g. the male strafes); it's used instead of the shared one. A model that
# doesn't have the animation at all (e.g. the female only idle variations)
# keeps playing what it was playing.
# speed: playback speed multiplier (e.g. faster attacks).
func play_animation(animationName: StringName, backwards := false, blendTime := -1.0, speed := 1.0) -> void:
	for animationPlayer in animationPlayers:
		var fullName := animationName
		if animationPlayer.has_animation(MODEL_LIBRARY + animationName):
			fullName = MODEL_LIBRARY + animationName
		elif not animationPlayer.has_animation(animationName):
			continue
		# play() on the animation already playing keeps going, so restart it.
		if animationPlayer.assigned_animation == fullName:
			animationPlayer.stop()
		# Backwards: negative speed, starting from the end.
		animationPlayer.play(fullName, blendTime, -speed if backwards else speed, backwards)


# Animation name without the "model/" library prefix.
func get_base_name(animationName: StringName) -> StringName:
	return StringName(String(animationName).trim_prefix(MODEL_LIBRARY))


# Shows the sword in the hand or on the back, on both models. The left hand IK
# only makes sense with the sword in the hand.
func set_sword_drawn(drawn: bool) -> void:
	swordDrawn = drawn
	for model in [charMaleModel, charFemaleModel]:
		model.get_node("Armature/Skeleton3D/RightHand/SwordBronzeModel").visible = drawn
		model.get_node("Armature/Skeleton3D/Back/SwordOnBack").visible = not drawn
		model.get_node("Armature/Skeleton3D/LeftHandIK").active = drawn


# Moves the sheathed sword between its place on the back (0) and the hand (1),
# so while drawing it slides out of the sheath into the hand, and while
# sheathing back into place, instead of jumping when it changes hands.
# `progress` is how far the hand is on its way to the back (0 to 1); the sword
# only moves in the second half, when the hand is already behind the head (the
# sheath and hand orientations are ~180 degrees apart earlier, and blending
# there makes the sword flip).
func set_sheath_blend(progress: float) -> void:
	var weight := smoothstep(0.5, 1.0, progress)
	for model in [charMaleModel, charFemaleModel]:
		var back: Node3D = model.get_node("Armature/Skeleton3D/Back/SwordOnBack")
		var hand: Node3D = model.get_node("Armature/Skeleton3D/RightHand/SwordBronzeModel")
		var rest: Transform3D = back.get_parent().global_transform * sheathRest[model]
		back.global_transform = rest.interpolate_with(hand.global_transform, weight)


# Idle variations the visible model has in its own library: the ones named
# "<prefix>_N" (e.g. "idle_variation" with the sword drawn and
# "idle_sheathed_variation" with it sheathed).
func get_idle_variations(prefix: String) -> Array[StringName]:
	var variations: Array[StringName] = []
	var animationPlayer := get_visible_animation_player()
	var library := MODEL_LIBRARY.trim_suffix("/")
	if animationPlayer.has_animation_library(library):
		for animationName in animationPlayer.get_animation_library(library).get_animation_list():
			if String(animationName).begins_with(prefix + "_"):
				variations.append(animationName)
	return variations


func get_visible_animation_player() -> AnimationPlayer:
	return animationPlayers[0] if charMaleModel.visible else animationPlayers[1]


func get_current_animation() -> StringName:
	return get_base_name(get_visible_animation_player().current_animation)


func get_current_animation_length() -> float:
	return get_visible_animation_player().current_animation_length


func get_animation_position() -> float:
	return get_visible_animation_player().current_animation_position
