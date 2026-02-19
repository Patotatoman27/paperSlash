extends Player

func _ready():
	_updatePlayerRect()
	speed = 8
	jumpSpeed = -30
	gravity = 1
	AnimPlayer.play("Idle")
