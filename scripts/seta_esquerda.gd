extends Sprite2D
# Called when the node enters the scene tree for the first time.

func _on_area_2d_input_event(viewport: Node, event: InputEventMouseButton, shape_idx: int):
	get_node("../../paredes/parede1").show()
	
