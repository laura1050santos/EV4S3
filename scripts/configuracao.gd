extends Window


# Called when the node enters the scene tree for the first time.
func _ready() -> void: 
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_requested() -> void:
	get_node(".").queue_free() # Replace with function body.

func _on_som_value_changed(value: float) -> void:
	var db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),db)
	$Som/Label2.text = str(value)	# Replace with function body.

func _on_brilho_value_changed(value: float) -> void:
	GlobalWorldEnvironment.environment.adjustment_brightness = value
	$Brilho/Label.text = str(value)	# Replace with function body.


func _on_sair_pressed() -> void:
	
	get_tree().change_scene_to_file("res://scenes/telaInicial/start.tscn")
 # Replace with function body.
