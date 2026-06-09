extends Sprite2D

func _input_event(_viewport, event, _shape_idx) -> void:
	if event.is_action_pressed("click"):
		print("clicou")
		get_tree().change_scene_to_file("res://scenes/zoom.tscn")
