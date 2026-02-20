class_name StateMachine extends Node

@onready var controlledNode: Node2D = $".."

enum STATE {
	IDLE,
	WALK,
	JUMP,
	AIR,
}

var currentState : STATE = STATE.IDLE;

func process(input: Dictionary):
	#State Specific
	match currentState:
		STATE.IDLE:
			var daInput = input.get("inputVector", Vector2.ZERO)
			if daInput.x != 0:
				currentState = STATE.WALK
			if input.get("jump", false): 
				currentState = STATE.JUMP
			if not controlledNode.grounded:
				currentState = STATE.AIR
		STATE.WALK:
			var daInput = input.get("inputVector", Vector2.ZERO)
			controlledNode.position.x += daInput.x * controlledNode.speed
			if daInput.x > 0:
				controlledNode.turnRight = true;
			elif daInput.x < 0:
				controlledNode.turnRight = false;
			if input.get("jump", false): 
				currentState = STATE.JUMP
			if not controlledNode.grounded:
				currentState = STATE.AIR
		STATE.JUMP:
			controlledNode.position += input.get("inputVector", Vector2.ZERO) * controlledNode.speed
			controlledNode.velocity.y = controlledNode.jumpSpeed;
			currentState = STATE.AIR
		STATE.AIR:
			controlledNode.position.x += input.get("inputVector", Vector2.ZERO).x * controlledNode.speed
			if controlledNode.grounded:
				currentState = STATE.IDLE
	#Physics process
	controlledNode._updatePlayerRect();
	controlledNode.apply_gravity();
	controlledNode._updatePlayerRect();
	controlledNode.resolveCollisions()
	controlledNode.updateGrounded()
	#Design??
	controlledNode.updateFacing();
