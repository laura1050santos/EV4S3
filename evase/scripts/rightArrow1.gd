extends Sprite2D

func _input(event) -> void:
	if event.is_action_pressed("click"):
		print("clicou")
		get_tree().change_scene_to_file("res://scenes/cena2.tscn")
