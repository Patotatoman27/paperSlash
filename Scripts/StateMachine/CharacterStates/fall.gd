extends PlayerState

func playerStateProcess(input: Dictionary):
	print(stateMachine.framesInState)
	controlledNode.position.x += input.get("inputVector", Vector2.ZERO).x * controlledNode.speed
	if controlledNode.grounded:
		print("Outtastate")
		stateMachine.changeState("Idle")
		return 
