class_name PlayerState extends BaseState

func physics_step():
	apply_gravity();
	_updatePlayerRect();
	resolveCollisions()
	updateGrounded()
	
func _updatePlayerRect():
	controlledNode.playerRect = Rect2(controlledNode.position + controlledNode.PLAYER_OFFSET - controlledNode.PLAYER_SIZE/2, controlledNode.PLAYER_SIZE)

func apply_gravity():
	controlledNode.velocity.y += controlledNode.gravity
	controlledNode.position.y += controlledNode.velocity.y

func resolveCollisions():
	for f in controlledNode.stage.floorRectangles:
		var floorGlobal = Rect2(f.position + controlledNode.stage.position, f.size)
		if controlledNode.playerRect.intersects(floorGlobal):
			var playerCenter = controlledNode.playerRect.position + controlledNode.playerRect.size / 2
			var floorCenter = floorGlobal.position + floorGlobal.size / 2
			var dx = playerCenter.x - floorCenter.x
			var dy = playerCenter.y - floorCenter.y
			var overlapX = (controlledNode.playerRect.size.x / 2 + floorGlobal.size.x / 2) - abs(dx)
			var overlapY = (controlledNode.playerRect.size.y / 2 + floorGlobal.size.y / 2) - abs(dy)
			# Resolver por el eje de menor penetración
			if overlapX < overlapY:
				# Horizontal
				if dx > 0:
					controlledNode.playerRect.position.x += overlapX
				else:
					controlledNode.playerRect.position.x -= overlapX
			else:
				# Vertical (piso o techo)
				if dy > 0:
					# debajo → empujar hacia abajo (techo)
					controlledNode.playerRect.position.y += overlapY
				else:
					# arriba → empujar hacia arriba (piso)
					controlledNode.playerRect.position.y -= overlapY
					controlledNode.velocity.y = 0;
	# sincronizar posición del nodo
	controlledNode.position = controlledNode.playerRect.position + controlledNode.PLAYER_SIZE/2 - controlledNode.PLAYER_OFFSET


func updateGrounded():
	controlledNode.grounded = false
	for f in controlledNode.stage.floorRectangles:
		var floorGlobal = Rect2(f.position + controlledNode.stage.position, f.size)
		if controlledNode.playerRect.position.y + controlledNode.playerRect.size.y == floorGlobal.position.y:
			controlledNode.grounded = true
			break
