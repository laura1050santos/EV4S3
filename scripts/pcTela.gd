extends Node2D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$SubViewportContainer.visible = false

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
