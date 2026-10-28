extends Area2D

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			get_parent().hide()
			input_pickable = false
			$CollisionShape2D.set_deferred("disabled", true)
			get_node("../../../Carta").set_deferred("input_pickable", true)
			get_viewport().set_input_as_handled()
