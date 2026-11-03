extends Area2D
@onready var som_carta=$SomCarta
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			$"../Node/mensagem".visible = true
			som_carta.play()
