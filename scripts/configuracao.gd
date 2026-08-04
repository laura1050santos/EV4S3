extends Window
signal volMax
var lanternaRes = preload("res://recursos/lanterna.tres")
# Called when the node enters the scene tree for the first time.
func _ready() -> void: 
	%Som.value = GlobalSingleton.volume
	
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_requested() -> void:
	get_node(".").visible = false

		  # Replace with function body.

func _on_som_value_changed(value: float) -> void:
	GlobalSingleton.volume = value
	$Som/Label2.text = str(value)
	if value == 100.0:
		print("volume mais alto atingido")
		volMax.emit()
			# Replace with function body.

func _on_brilho_value_changed(value: float) -> void:
	GlobalWorldEnvironment.environment.adjustment_brightness = value
	$Brilho/Label.text = str(value)	# Replace with function body.


func _on_sair_pressed() -> void:
	#var lanterna = get_tree().current_scene.get_node_or_null("lanterna")
	#if lanterna:
		#lanterna.queue_free()
	var root = self.get_tree().root
	if root.has_node("LuzDaLanterna"):
		lanternaRes.item_ativo = false
		GlobalSingleton.registrar_item(lanternaRes,Vector2(750,590),"leste")
		root.get_node("LuzDaLanterna").queue_free()
		root.get_node("lanterna").queue_free()
		
	get_tree().change_scene_to_file("res://scenes/telaInicial/start.tscn")
