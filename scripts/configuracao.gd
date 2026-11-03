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
	
	# 1. Pega o índice do canal Master (Global)
	var bus_index = AudioServer.get_bus_index("Master")
	
	# 2. Transforma a escala de 0-100 para 0.0-1.0
	var valor_linear = value / 100.0 
	
	# 3. Converte para Decibéis e aplica no Godot
	var volume_db = linear_to_db(valor_linear)
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	
	# 4. Se o volume for muito baixo (ex: zero), muta o canal para evitar ruídos
	AudioServer.set_bus_mute(bus_index, valor_linear <= 0.01)

	if value == 100.0:
		print("volume mais alto atingido")
		volMax.emit()


func _on_brilho_value_changed(value: float) -> void:
	GlobalWorldEnvironment.environment.adjustment_brightness = value
	$Brilho/Label.text = str(value)
	Config.atualizar_configuracao("brilho", value)


func _on_sair_pressed() -> void:
	SaveManager.salvar()
	itemData.desativar_item_global(get_tree())
	get_tree().change_scene_to_file("res://scenes/telaInicial/start.tscn")
	

func _on_salvar_pressed() -> void:
	SaveManager.salvar()


func _on_selecao_fases_pressed() -> void:
	SaveManager.salvar()
	get_tree().change_scene_to_file("res://scenes/telaInicial/selecao_fases.tscn")
	pass # Replace with function body.
