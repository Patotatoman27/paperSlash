extends Node2D

#Stage Collision //Posicion, Dimensiones, Dimensiones
var floorRectangles = [
	Rect2(Vector2(6, 412) - Vector2(1113, 271)/2, Vector2(1113, 271)),
]

func _draw():
	# Dibujar pisos
	for f in floorRectangles:
		draw_rect(f, Color(0, 0, 1, 0.5), true)
