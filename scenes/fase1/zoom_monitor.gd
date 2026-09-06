extends Node2D

func _ready():
	$SubViewportContainer.visible = false

func _process(_delta):
	if Input.is_key_pressed(KEY_Q):
		$SubViewportContainer.visible = true
