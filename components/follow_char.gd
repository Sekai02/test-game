extends Node3D


# Third person camera that stays behind and above the player and follows it
# smoothly (Lord of the Rings: The Two Towers style). The player doesn't
# control it.

@export var player: Player
@export var distance := 2.0
@export var height := 1.8
@export var lookHeight := 1.4
@export var followSpeed := 5.0

@onready var camera: Camera3D = $Camera3D


func _ready() -> void:
	if player == null:
		return
	global_position = player.global_position
	rotation.y = player.global_rotation.y
	# The character model faces +Z, so "behind" is -Z.
	camera.position = Vector3(0, height, -distance)
	camera.look_at(global_position + Vector3.UP * lookHeight)


# Physics process because the player is a RigidBody3D and moves on physics ticks.
func _physics_process(delta: float) -> void:
	if player == null:
		return
	var weight := 1.0 - exp(-followSpeed * delta)
	global_position = global_position.lerp(player.global_position, weight)
	rotation.y = lerp_angle(rotation.y, player.global_rotation.y, weight)
