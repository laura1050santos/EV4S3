extends SceneTree
var verificacoes: int = 0
var falhas: int = 0
func _initialize() -> void:
	_run.call_deferred()
func conferir(valor: bool, descricao: String) -> void:
	verificacoes += 1
	if not valor:
		falhas += 1
		push_error(descricao)
func _run() -> void:
	await process_frame
	await process_frame
	var banco = root.get_node("Database").db
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	var antes = banco.get_query_result().duplicate(true)
	banco.query("BEGIN TRANSACTION;")
	var global = root.get_node("GlobalSingleton")
	global.dica_inicio_fase1_exibida = true
	var drop = root.get_node("Inventario/WordDropArea")
	drop._notification(Control.NOTIFICATION_DRAG_BEGIN)
	conferir(drop.mouse_filter == Control.MOUSE_FILTER_STOP, "Arrasto recebe objeto")
	drop._notification(Control.NOTIFICATION_DRAG_END)
	conferir(drop.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Fim do arrasto libera cliques nas setas e cenário")
	change_scene_to_file("res://scenes/fase1/ParedeNorte.tscn")
	await process_frame
	await process_frame
	for direcao in ["Esquerda", "Direita"]:
		var destinos = ["Oeste", "Sul", "Leste", "Norte"] if direcao == "Esquerda" else ["Leste", "Sul", "Oeste", "Norte"]
		for destino in destinos:
			var seta = current_scene.get_node("Seta" + direcao)
			var clique := InputEventMouseButton.new()
			clique.button_index = MOUSE_BUTTON_RIGHT
			clique.pressed = true
			seta._inout_event(root, clique, 0)
			conferir(not seta.trocando, "Botão direito não navega")
			clique.button_index = MOUSE_BUTTON_LEFT
			seta._inout_event(root, clique, 0)
			seta.trocar()
			await process_frame
			await process_frame
			conferir(current_scene.scene_file_path == "res://scenes/fase1/Parede" + destino + ".tscn", direcao + " chega a " + destino)
	var sala = current_scene
	current_scene = null
	root.remove_child(sala)
	sala.queue_free()
	await process_frame
	banco.query("ROLLBACK;")
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	conferir(antes == banco.get_query_result(), "Progresso original preservado")
	print("SETAS: ", verificacoes, " verificações; ", falhas, " falhas.")
	quit(0 if falhas == 0 else 1)
