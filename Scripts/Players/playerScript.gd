extends Node2D

@onready var stage: Node2D = $"../Stage/TestStage"

var velocity : Vector2
var grounded := false
const gravity = 0.1
var speed := 8

# Constantes para el jugador
const PLAYER_SIZE = Vector2(73, 267)
const PLAYER_OFFSET = Vector2(-7.5, 41.5) # offset desde la posición real del nodo

# Collision box
var playerRect: Rect2

#Controllers
var inputPrefix := "P1_"

func _ready():
	_updatePlayerRect()

func _get_local_input() -> Dictionary:
	var inputVector = Input.get_vector(inputPrefix+"Left", inputPrefix+"Right", inputPrefix+"Up", inputPrefix+"Down")
	var input := {}
	if inputVector != Vector2.ZERO:
		input["inputVector"] = inputVector
	return input

func _network_process(input: Dictionary) -> void:
	position += input.get("inputVector", Vector2.ZERO) * speed
	_updatePlayerRect()
	physics_step()

func _save_state() -> Dictionary:
	return {
		position = position,
		velocity = velocity,
		grounded = grounded,
	}

func _load_state(state: Dictionary):
	position = state["position"]
	velocity = state["velocity"]
	grounded = state["grounded"]
	_updatePlayerRect()

func _updatePlayerRect():
	# Player rect centrado en la posición del nodo + offset
	playerRect = Rect2(position + PLAYER_OFFSET - PLAYER_SIZE/2, PLAYER_SIZE)

func physics_step():
	apply_gravity();
	_updatePlayerRect();
	resolveCollisions()
	updateGrounded()

func apply_gravity():
	position.y += 1

func resolveCollisions():
	for f in stage.floorRectangles:
		var floorGlobal = Rect2(f.position + stage.position, f.size)

		if playerRect.intersects(floorGlobal):

			var playerCenter = playerRect.position + playerRect.size / 2
			var floorCenter = floorGlobal.position + floorGlobal.size / 2

			var dx = playerCenter.x - floorCenter.x
			var dy = playerCenter.y - floorCenter.y

			var overlapX = (playerRect.size.x / 2 + floorGlobal.size.x / 2) - abs(dx)
			var overlapY = (playerRect.size.y / 2 + floorGlobal.size.y / 2) - abs(dy)

			# Resolver por el eje de menor penetración
			if overlapX < overlapY:
				# Horizontal
				if dx > 0:
					playerRect.position.x += overlapX
				else:
					playerRect.position.x -= overlapX
			else:
				# Vertical (piso o techo)
				if dy > 0:
					# debajo → empujar hacia abajo (techo)
					playerRect.position.y += overlapY
				else:
					# arriba → empujar hacia arriba (piso)
					playerRect.position.y -= overlapY

	# sincronizar posición del nodo
	position = playerRect.position + PLAYER_SIZE/2 - PLAYER_OFFSET


func updateGrounded():
	grounded = false
	for f in stage.floorRectangles:
		var floorGlobal = Rect2(f.position + stage.position, f.size)
		if playerRect.position.y + playerRect.size.y == floorGlobal.position.y:
			grounded = true
			break

func _draw():
	var local_rect = Rect2(
		playerRect.position - global_position,
		playerRect.size
	)
	draw_rect(local_rect, Color(0, 1, 0, 0.5), false, 2)
