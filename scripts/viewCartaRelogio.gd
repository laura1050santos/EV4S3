extends Area2D

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var carta: Sprite2D = $"../Node/carta_relogio2"
			carta.show()
			carta.get_node("Area2D").input_pickable = true
			carta.get_node("Area2D/CollisionShape2D").set_deferred("disabled", false)
			input_pickable = false
			get_viewport().set_input_as_handled()
