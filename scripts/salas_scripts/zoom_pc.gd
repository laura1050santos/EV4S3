extends Node2D

func colocar_peca_no_lugar(posicao: Vector2, peca: Node2D) -> void:
	if peca:
		peca.position = posicao
	else:
		print("Peça não encontrada")


func _on_area_placa_mae_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:

	var placa_mae = get_node_or_null("placaMae")
	if placa_mae:
		print("PLACA MAE DETECTADA")
		colocar_peca_no_lugar(Vector2(150, 560), placa_mae) # Replace with function body.

func _on_area_processador_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	var processador = get_node_or_null("processador")
	if processador:
		print("PROCESSADOR DETECTADO")
		colocar_peca_no_lugar(Vector2(250, 560), processador)

func _on_area_gpu_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	var gpu = get_node_or_null("gpu")
	if gpu:
		print("GPU DETECTADA")
		colocar_peca_no_lugar(Vector2(350, 560), gpu)
