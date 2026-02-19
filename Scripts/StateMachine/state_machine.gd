class_name StateMachine extends Node

@onready var controlledNode: Node2D = $".."

enum STATE {
	IDLE,
	WALK,
	AIR,
}

var currentState : STATE = STATE.IDLE;

func process(input: Dictionary):
	controlledNode.position += input.get("inputVector", Vector2.ZERO) * controlledNode.speed
	if input.get("jump", false): 
		controlledNode.velocity.y = controlledNode.jumpSpeed;
	match currentState:
		STATE.IDLE:
			controlledNode.velocity.y = 0;
		STATE.WALK:
			pass;
		STATE.AIR:
			pass;
