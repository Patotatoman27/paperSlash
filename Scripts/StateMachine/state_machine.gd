class_name StateMachine extends Node

@onready var controlledNode : Node = self.owner
@export var firstState : BaseState
var currentState : BaseState = null;
var desiredNextState : BaseState = null;

var framesInState : int = 0;

enum STATE {
	IDLE,
	WALK,
	JUMP,
	AIR,
}

func _ready() -> void:
	#print("Starting State Machine for ", str(controlledNode.name))
	call_deferred("firstState_start")

func firstState_start():
	currentState = firstState
	state_start();

func state_start():
	currentState.controlledNode = controlledNode
	currentState.stateMachine = self
	framesInState = 0;
	#print(str(controlledNode.name), " | cambia a state: ", str(currentState.name), " | en el frame: ", framesInState)
	currentState.start()

func applyChangeState(newState : BaseState):
	framesInState = 0;
	#Si el estado actual no es nulo y hay un end, llamalo.
	if currentState and currentState.has_method("end"): currentState.end();
	#Cambia el Estado y comienzalo
	currentState = newState
	state_start()

func changeState(newState : String):
	if newState != currentState.name:
		desiredNextState = get_node(newState)


func process(input: Dictionary):
	#print("PROCESS CALLED by ", controlledNode.name)
	
	#if controlledNode.name == "Player1":
		#print(controlledNode.name, " in state ", str(currentState.name), " in frame ", str(framesInState) )
	#Physics process
	controlledNode._updatePlayerRect();
	controlledNode.apply_gravity();
	controlledNode._updatePlayerRect();
	controlledNode.resolveCollisions()
	controlledNode.updateGrounded()
	#State Logic
	if currentState and currentState.has_method("playerStateProcess"): currentState.playerStateProcess(input);
	#Design??
	controlledNode.updateFacing();
	#Frame Data
	framesInState += 1;
	if desiredNextState != null:
		applyChangeState(desiredNextState)
		desiredNextState = null;
