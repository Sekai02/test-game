extends PlayerState


# Knocked down: flies back and falls ("knockdown"), then gets up (GetUp).

func enter(_previousStatePath: String, _data := {}) -> void:
	player.animation_finished.connect(_on_animation_finished)
	player.play_animation("knockdown")


func exit() -> void:
	player.animation_finished.disconnect(_on_animation_finished)


func _on_animation_finished(finishedAnimation: StringName) -> void:
	if finishedAnimation == "knockdown":
		finished.emit(GET_UP)
