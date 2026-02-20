class_name Player extends Node2D 

#Referencias
@onready var stateMachine: StateMachine = $StateMachine
@onready var AnimPlayer: NetworkAnimationPlayer = $NetworkAnimationPlayer
@onready var stage: Node2D = $"../Stage/TestStage"
#Controllers
var inputPrefix := "P1_"

#Atributos //Se guardan
var velocity : Vector2
var grounded : bool = false
var turnRight : bool = true;
#Stats
var speed : int
var jumpSpeed : int
var gravity : int
# Collision box
var playerRect: Rect2
@export var PLAYER_OFFSET : Vector2
@export var PLAYER_SIZE : Vector2

#region INPUT
func _get_local_input() -> Dictionary:
	var inputVector = Input.get_vector(inputPrefix+"Left", inputPrefix+"Right", inputPrefix+"Up", inputPrefix+"Down")
	var input := {}
	if inputVector != Vector2.ZERO:
		input["inputVector"] = inputVector
	if Input.is_action_just_pressed(inputPrefix+"Jump"):
		input["jump"] = true
	return input

#region PROCESS
func _network_process(input: Dictionary) -> void:
	stateMachine.process(input)

#region STATE SAVE/LOAD
func _save_state() -> Dictionary:
	return {
		position = position,
		velocity = velocity,
		grounded = grounded,
		turnRight = turnRight,
		SMstate = stateMachine.currentState
	}

func _load_state(state: Dictionary):
	position = state["position"]
	velocity = state["velocity"]
	grounded = state["grounded"]
	turnRight = state["turnRight"]
	stateMachine.currentState = state["SMstate"]
	_updatePlayerRect()

#region HITBOX
func _draw():
	var local_rect = Rect2(
		playerRect.position - global_position,
		playerRect.size
	)
	draw_rect(local_rect, Color(0, 1, 0, 0.5), false, 2)

func _updatePlayerRect():
	playerRect = Rect2(position + PLAYER_OFFSET - PLAYER_SIZE/2, PLAYER_SIZE)

func apply_gravity():
	velocity.y += gravity
	position.y += velocity.y

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
					velocity.y = 0;
	# sincronizar posición del nodo
	position = playerRect.position + PLAYER_SIZE/2 - PLAYER_OFFSET


#func updateGrounded():
	#grounded = false
	#for f in stage.floorRectangles:
		#var floorGlobal = Rect2(f.position + stage.position, f.size)
		#if playerRect.position.y + playerRect.size.y == floorGlobal.position.y:
			#grounded = true
			#break
func updateGrounded():
	grounded = false

	for f in stage.floorRectangles:
		var floorGlobal = Rect2(f.position + stage.position, f.size)

		var playerBottom = playerRect.position.y + playerRect.size.y
		var floorTop = floorGlobal.position.y

		# Coincidencia exacta vertical
		if playerBottom == floorTop:

			var playerLeft = playerRect.position.x
			var playerRight = playerRect.position.x + playerRect.size.x
			var floorLeft = floorGlobal.position.x
			var floorRight = floorGlobal.position.x + floorGlobal.size.x

			# Overlap horizontal real (sin contar bordes exactos)
			if playerRight > floorLeft and playerLeft < floorRight:
				grounded = true
				break

func updateFacing():
	if turnRight:
		self.scale = Vector2(1.0, 1.0)
	else:
		self.scale = Vector2(-1.0, 1.0)
