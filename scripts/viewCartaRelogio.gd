extends Area2D
@onready var som_carta = $"../AudioListener2D/somCarta"
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var carta: Sprite2D = $"../carta/carta_relogio2"
			carta.show()
			som_carta.play()
			carta.get_node("Area2D").input_pickable = true
			carta.get_node("Area2D/CollisionShape2D").set_deferred("disabled", false)
			input_pickable = false
			get_viewport().set_input_as_handled()
			
