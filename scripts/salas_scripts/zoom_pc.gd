extends Node2D


func colocar_peca_no_lugar(peca_data: itemData, slot: Area2D) -> bool:

	if peca_data == null:
		return false

	print("Tentando colocar: ", peca_data.item_name)
	print("Slot: ", slot.name)
	
	if slot.name == "slotPlacaMae":

		if peca_data.item_name != "placa":
			print("Essa peça não é a placa-mãe!")
			return false

		print("PLACA-MÃE INSTALADA")

		var placa = get_node_or_null("placaMae")

		if placa:
			placa.visible = true
			placa.position = Vector2(635, 169)

		remover_do_inventario(peca_data)

		return true

	if slot.name == "slotProcessador":

		if peca_data.item_name != "processador":
			print("Essa peça não é o processador!")
			return false

		print("PROCESSADOR INSTALADO")

		var processador = get_node_or_null("processador")

		if processador:
			processador.visible = true
			processador.position = Vector2(527, 390)

		remover_do_inventario(peca_data)

		return true

	if slot.name == "slotGPU":

		if peca_data.item_name != "gpu":
			print("Essa peça não é a GPU!")
			return false

		print("GPU INSTALADA")

		var gpu = get_node_or_null("gpu")

		if gpu:
			gpu.visible = true
			gpu.position = Vector2(656, 217)

		remover_do_inventario(peca_data)

		return true


	return false


func remover_do_inventario(peca_data: itemData) -> void:

	GlobalSingleton.remover_item(peca_data)

	print("Peça removida do inventário: ", peca_data.item_name)

func _on_slot_gpu_input_event(
	viewport: Node,
	event: InputEvent,
	shape_idx: int
) -> void:

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			print("Clique no slot da placa-mãe")

			if GlobalSingleton.item_mao == null:
				print("Nenhum item na mão.")
				return

			colocar_peca_no_lugar(
				GlobalSingleton.item_mao,
				$slotGPU
			)
			
func _on_slot_processador_input_event(
	viewport: Node,
	event: InputEvent,
	shape_idx: int
) -> void:

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			print("Clique no slot do processador")

			if GlobalSingleton.item_mao == null:
				print("Nenhum item na mão.")
				return

			colocar_peca_no_lugar(
				GlobalSingleton.item_mao,
				$slotProcessador
			)
			
func _on_slot_placa_mae_input_event(
	viewport: Node,
	event: InputEvent,
	shape_idx: int
) -> void:

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			print("Clique no slot da placa-mãe")

			if GlobalSingleton.item_mao == null:
				print("Nenhum item na mão.")
				return

			colocar_peca_no_lugar(
				GlobalSingleton.item_mao,
				$slotPlacaMae
			)
