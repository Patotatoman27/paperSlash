extends Player

func _ready():
	stateMachine._updatePlayerRect()
	speed = 8
	jumpSpeed = -30
	gravity = 1.5
	AnimPlayer.play("Idle")
