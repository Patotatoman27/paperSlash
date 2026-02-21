class_name StateMachine extends Node

@onready var controlledNode : Node = self.owner
@export var firstState : BaseState
var currentState : BaseState = null;

enum STATE {
	IDLE,
	WALK,
	JUMP,
	AIR,
}

func _ready() -> void:
	call_deferred("firstState_start")

func firstState_start():
	currentState = firstState
	state_start();

func state_start():
	currentState.controlledNode = controlledNode
	currentState.stateMachine = self
	currentState.start()

func changeState(newState : String):
	#Si el estado actual no es nulo y hay un end, llamalo.
	if currentState and currentState.has_method("end"): currentState.end();
	#Cambia el Estado y comienzalo
	currentState = get_node(newState)
	state_start()


func process(input: Dictionary):
	if currentState and currentState.has_method("playerStateProcess"): currentState.playerStateProcess(input);
	#Physics process
	controlledNode._updatePlayerRect();
	controlledNode.apply_gravity();
	controlledNode._updatePlayerRect();
	controlledNode.resolveCollisions()
	controlledNode.updateGrounded()
	#Design??
	controlledNode.updateFacing();
