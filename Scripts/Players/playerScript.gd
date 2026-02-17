extends Node2D

var speed := 8;

func _get_local_input() -> Dictionary:
	var inputVector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var input := {}
	if inputVector != Vector2.ZERO:
		input["inputVector"] = inputVector
	return input

func _network_process(input: Dictionary) -> void:
	position += input.get("inputVector", Vector2.ZERO) * speed

func _save_state() -> Dictionary:
	return {
		position = position,
	}

func _load_state(state: Dictionary):
	position = state["position"]
