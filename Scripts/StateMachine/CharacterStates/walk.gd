extends PlayerState

func start():
	controlledNode.AnimPlayer.play("Walk") 

func end():
	controlledNode.AnimPlayer.play("Idle") 

func playerStateProcess(input: Dictionary):
	var daInput = input.get("inputVector", Vector2.ZERO)
	controlledNode.position.x += daInput.x * controlledNode.speed
	if daInput.x > 0:
		controlledNode.turnRight = true;
	elif daInput.x < 0:
		controlledNode.turnRight = false;
	if daInput.x == 0:
		stateMachine.changeState("Idle")
	if input.get("jump", false): 
		stateMachine.changeState("Jump")
	if not controlledNode.grounded:
		stateMachine.changeState("Air")
