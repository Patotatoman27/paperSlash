extends PlayerState

func playerStateProcess(input: Dictionary):
	controlledNode.position.x += input.get("inputVector", Vector2.ZERO).x * controlledNode.speed
	if controlledNode.grounded:
		stateMachine.changeState("Idle")
