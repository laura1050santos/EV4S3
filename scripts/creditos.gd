extends Node2D


# Called when the node enters the scene tree for the first time.


func _on_sair_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/telaInicial/start.tscn")
 # Replace with function body.
