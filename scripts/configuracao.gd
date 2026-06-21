extends Window


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_requested() -> void:
	get_node(".").queue_free() # Replace with function body.


func _on_som_value_changed(value: float) -> void:
	$Som/Label2.text = str(value)	# Replace with function body.


func _on_brilho_value_changed(value: float) -> void:
	$Brilho/Label.text = str(value)	# Replace with function body.
 # Replace with function body.
