extends PlayerState

func playerStateProcess(input: Dictionary):
	controlledNode.position += input.get("inputVector", Vector2.ZERO) * controlledNode.speed
	controlledNode.velocity.y = controlledNode.jumpSpeed;
	stateMachine.changeState("Air")
