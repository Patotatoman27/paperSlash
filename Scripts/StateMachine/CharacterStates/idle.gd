extends PlayerState

func start():
	controlledNode.AnimPlayer.play("Idle") 

func playerStateProcess(input: Dictionary):
	var daInput = input.get("inputVector", Vector2.ZERO)
	if daInput.x != 0:
		stateMachine.changeState("Walk")
		return
	if input.get("jump", false): 
		stateMachine.changeState("Jump")
		return
	if not controlledNode.grounded:
		stateMachine.changeState("Air")
		return
