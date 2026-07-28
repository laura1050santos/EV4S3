extends Window
signal volMax

# Called when the node enters the scene tree for the first time.
func _ready() -> void: 
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_requested() -> void:
	get_node(".").visible = false

		  # Replace with function body.

func _on_som_value_changed(value: float) -> void:
	$Som/Label2.text = str(value)
	if value == 100.0:
		print("volume mais alto atingido")
		volMax.emit()
			# Replace with function body.

func _on_brilho_value_changed(value: float) -> void:
	GlobalWorldEnvironment.environment.adjustment_brightness = value
	$Brilho/Label.text = str(value)	# Replace with function body.


func _on_sair_pressed() -> void:
	
	get_tree().change_scene_to_file("res://scenes/telaInicial/start.tscn")
 # Replace with function body.
