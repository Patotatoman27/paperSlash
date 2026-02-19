class_name StateMachine extends Node

@onready var controlledNode: Node2D = $".."

enum STATE {
	IDLE,
	WALK,
	AIR,
}

var currentState : STATE = STATE.IDLE;

func process(input: Dictionary):
	#State Specific
	match currentState:
		STATE.IDLE:
			controlledNode.position += input.get("inputVector", Vector2.ZERO) * controlledNode.speed
			if input.get("jump", false): 
				controlledNode.velocity.y = controlledNode.jumpSpeed;
				currentState = STATE.AIR
		STATE.WALK:
			controlledNode.position += input.get("inputVector", Vector2.ZERO) * controlledNode.speed
			if input.get("jump", false): 
				controlledNode.velocity.y = controlledNode.jumpSpeed;
				currentState = STATE.AIR
		STATE.AIR:
			controlledNode.position += input.get("inputVector", Vector2.ZERO) * controlledNode.speed
			if controlledNode.grounded:
				currentState = STATE.IDLE
	#Physics process
	controlledNode._updatePlayerRect();
	controlledNode.apply_gravity();
	controlledNode._updatePlayerRect();
	controlledNode.resolveCollisions()
	controlledNode.updateGrounded()
