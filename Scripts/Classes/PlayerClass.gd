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
	position += input.get("inputVector", Vector2.ZERO) * speed
	if input.get("jump", false): 
		velocity.y = jumpSpeed;
	stateMachine._updatePlayerRect()
	stateMachine.physics_step()

#region STATE SAVE/LOAD
func _save_state() -> Dictionary:
	return {
		position = position,
		velocity = velocity,
		grounded = grounded,
		SMstate = stateMachine.currentState
	}

func _load_state(state: Dictionary):
	position = state["position"]
	velocity = state["velocity"]
	grounded = state["grounded"]
	stateMachine.currentState = state["SMstate"]
	stateMachine._updatePlayerRect()

#region HITBOX
func _draw():
	var local_rect = Rect2(
		playerRect.position - global_position,
		playerRect.size
	)
	draw_rect(local_rect, Color(0, 1, 0, 0.5), false, 2)
