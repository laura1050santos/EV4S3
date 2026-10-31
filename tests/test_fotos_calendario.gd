extends SceneTree

var verificacoes: int = 0
var falhas: int = 0
var banco
var objetos
var progresso

func _initialize() -> void:
	_run.call_deferred()

func conferir(condicao: bool, descricao: String) -> void:
	verificacoes += 1
	if not condicao:
		falhas += 1
		push_error(descricao)

func _run() -> void:
	await process_frame
	await process_frame
	banco = root.get_node("Database").db
	objetos = load("res://BDD/Objetos.gd")
	progresso = load("res://BDD/Progresso.gd")
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	var antes: Array = banco.get_query_result().duplicate(true)
	banco.query("BEGIN TRANSACTION;")
	var global = root.get_node("GlobalSingleton")
	global.fase_liberada = 3
	global.fases_concluidas = [true, true, false, false]
	global.pc_conectado = true
	global.lampada_ligada = true
	global.gavetas = {"leste": {"1": false, "2": false, "3": false}, "sul": {"1": false, "2": false, "3": false}}
	var drop = root.get_node("Inventario/WordDropArea")
	var inspecao = drop.inspecao_item
	var entrada := Node2D.new()
	root.add_child(entrada)
	var letras: String = ""
	var cenas: Array = ["ParedeLeste", "ParedeSul", "ParedeOeste", "ParedeNorte"]
	var salas: Array = ["leste", "Sul", "Oeste", "Norte"]
	for indice in range(cenas.size()):
		var dados: Dictionary = objetos.FOTOS_FAMILIA[salas[indice]]
		banco.query_with_bindings("UPDATE Objetos SET coletado=0, cena=?, pos=?, container_id=? WHERE recurso=?;", [salas[indice], objetos.pos_para_json(int(dados.pos.x), int(dados.pos.y)), dados.container_id, dados.recurso])
		var sala = load("res://scenes/fase1/" + cenas[indice] + ".tscn").instantiate()
		current_scene = entrada
		root.add_child(sala)
		current_scene = sala
		await process_frame
		await physics_frame
		if indice < 2:
			conferir(sala.get_node_or_null(NodePath(dados.nome)) == null, "Foto oculta na gaveta fechada")
			sala.gavetas_controller.alternar_gaveta("2" if indice == 0 else "3")
		var visual = sala.get_node_or_null(NodePath(dados.nome))
		conferir(visual != null, "Foto aparece no local real: " + salas[indice])
		if visual == null:
			continue
		var foto = visual.get_meta("item_data")
		conferir(foto.icon != null and foto.pode_inspecionar(), "Imagem e exame disponíveis")
		conferir(visual.scale == Vector2(0.1, 0.1), "Escala da foto no mundo")
		drop.usar_item(foto, visual)
		conferir(inspecao.visible and inspecao.fotografia == foto, "Exame por botão direito")
		conferir(not inspecao.get_node("Painel/Verso").visible and inspecao.get_node("Painel/Identidade").text == foto.nome_fotografado, "Frente identifica familiar e oculta letra")
		conferir(not inspecao.get_node("Painel/Virar").visible, "Foto não revela mais a letra pelo verso")
		letras += foto.letra_violeta
		inspecao.fechar()
		inspecao.abrir(foto)
		conferir(not inspecao.verso and inspecao.get_node("Painel/Virar").text == "Virar foto", "Novo exame começa pela frente")
		inspecao.fechar()
		conferir(drop.guardar_no_inventario(foto), "Foto coletável pelo inventário atual")
		for slot in root.get_node("Inventario/canvasLayer/inventory/GridContainer").get_children():
			if slot.item == foto:
				var direito := InputEventMouseButton.new()
				direito.button_index = MOUSE_BUTTON_RIGHT
				direito.pressed = true
				slot._gui_input(direito)
				conferir(inspecao.visible and inspecao.fotografia == foto, "Foto também examinável pelo inventário")
				inspecao.fechar()
				break
		global.remover_item(foto)
		visual.queue_free()
		await process_frame
		objetos.garantir_padrao(salas[indice])
		conferir(int(objetos.get_por_recurso(dados.recurso).coletado) == 1, "Revisita não recria foto coletada")
		var solto = sala.spawnar_itens(foto, Vector2(500, 550))
		objetos.soltar_por_recurso(foto.resource_path, solto.position, sala.name)
		conferir(solto.scale == Vector2(0.1, 0.1), "Soltar preserva tamanho")
		objetos.garantir_padrao(salas[indice])
		banco.query_with_bindings("SELECT container_id FROM Objetos WHERE recurso=?;", [dados.recurso])
		conferir(banco.get_query_result()[0].container_id == "", "Revisita não devolve foto solta à gaveta")
		if indice == 0:
			var calendario = sala.get_node("Calendario")
			conferir(not calendario.has_meta("item_data"), "Calendário é fixo, fora do inventário")
			conferir(ResourceLoader.exists("res://scenes/fase3/zoom_quadro.tscn"), "Calendário tem zoom do quadro")
		sala.queue_free()
		await process_frame
	conferir(letras == "NEXO", "Identidades ordenadas produzem NEXO")
	conferir(not global.fases_concluidas[2] and global.fase_liberada == 3, "Pistas não concluem a Fase 3")
	# Regressão do visualizador de papel, sem virar foto nem modo calendário.
	inspecao.abrir(load("res://recursos/PapelMorseAlcapao.tres"))
	conferir(not inspecao.get_node("Painel/Virar").visible and not inspecao.get_node("Painel/CalendarioTexto").visible, "Papel Morse mantém seu visualizador")
	inspecao.fechar()
	banco.query("ROLLBACK;")
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	conferir(antes == banco.get_query_result(), "Partida preservada após rollback")
	print("FOTOS_CALENDARIO: ", verificacoes, " verificações; ", falhas, " falhas.")
	quit(0 if falhas == 0 else 1)
