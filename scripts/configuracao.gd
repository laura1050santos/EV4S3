extends Window

signal volMax

var lanternaRes = preload("res://recursos/lanterna.tres")


func _ready() -> void:
	# Carrega os valores salvos no banco
	var volume = Config.get_config("volume")
	var brilho = Config.get_config("brilho")

	if volume:
		var valor_volume = float(volume["valor"])
		print(volume,' ',valor_volume)
		$Som.value = valor_volume
		$Som/Label2.text = str(valor_volume)
	if brilho:
		var valor_brilho = float(brilho["valor"])
		$Brilho.value = valor_brilho
		$Brilho/Label.text = str(valor_brilho)
		GlobalWorldEnvironment.environment.adjustment_brightness = valor_brilho

func _on_close_requested() -> void:
	visible = false


func _on_som_value_changed(value: float) -> void:
	Config.atualizar_configuracao("volume", str(value))
	$Som/Label2.text = str(value)
	if value == 100.0:
		print("volume mais alto atingido")
		volMax.emit()


func _on_brilho_value_changed(value: float) -> void:
	GlobalWorldEnvironment.environment.adjustment_brightness = value
	$Brilho/Label.text = str(value)
	Config.atualizar_configuracao("brilho", value)


func _on_sair_pressed() -> void:
	var root = get_tree().root
	if root.has_node("LuzDaLanterna"):
		lanternaRes.item_ativo = false
		GlobalSingleton.registrar_item(
			lanternaRes,
			Vector2(750, 590),"leste")
		root.get_node("LuzDaLanterna").queue_free()
		root.get_node("lanterna").queue_free()

	get_tree().change_scene_to_file(
		"res://scenes/telaInicial/start.tscn")
