extends State
class_name PlayerState


# Base for the player's states: the name of every state and access to the player.

const IDLE = "Idle"
const MOVE = "Move"
const ROLL = "Roll"
const ATTACK = "Attack"
const BLOCK = "Block"
const CONSUME = "Consume"
const HIT = "Hit"
const KNOCKDOWN = "Knockdown"
const GET_UP = "GetUp"
const DEATH = "Death"
const DRAW_SWORD = "DrawSword"
const SHEATHE_SWORD = "SheatheSword"

var player: Player


func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null, "PlayerState nodes must be inside the Player scene.")


# State to go back to when an action ends: Move if a move key is held, else Idle.
func get_resting_state() -> String:
	return MOVE if is_moving() else IDLE


func is_moving() -> bool:
	return get_move_direction() != ""


# "forward", "back", "left", "right" or "" (not moving). Forward and back win
# over the sides (diagonals use the forward/back animation); forward wins over
# back and opposite sides cancel each other.
func get_move_direction() -> String:
	if Input.is_action_pressed("move_forward"):
		return "forward"
	if Input.is_action_pressed("move_backward"):
		return "back"
	var left := Input.is_action_pressed("move_left")
	var right := Input.is_action_pressed("move_right")
	if left and not right:
		return "left"
	if right and not left:
		return "right"
	return ""


# Run key held while moving.
func is_running() -> bool:
	return is_moving() and Input.is_action_pressed("run")


# Actions that can start from Idle and Move. Returns true if one started.
# Q sheathes or draws the sword; attacking or blocking with the sword sheathed
# only draws it (attacking or blocking needs another press afterwards).
func handle_action_input(event: InputEvent) -> bool:
	if event.is_action_pressed("toggle_sword"):
		finished.emit(SHEATHE_SWORD if player.swordDrawn else DRAW_SWORD)
		return true
	for action in [["roll", ROLL], ["attack", ATTACK], ["block", BLOCK], ["consume", CONSUME]]:
		if event.is_action_pressed(action[0]):
			if action[1] in [ATTACK, BLOCK] and not player.swordDrawn:
				finished.emit(DRAW_SWORD)
			else:
				finished.emit(action[1])
			return true
	return false
