extends SceneTree

var verificacoes: int = 0
var falhas: int = 0

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
	var banco = root.get_node("Database").db
	var objetos = load("res://BDD/Objetos.gd")
	var progresso = load("res://BDD/Progresso.gd")
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	var antes: Array = banco.get_query_result().duplicate(true)
	banco.query("SELECT * FROM Objetos ORDER BY id;")
	var objetos_antes: Array = banco.get_query_result().duplicate(true)
	banco.query("BEGIN TRANSACTION;")
	for info in objetos.FOTOS_FAMILIA.values():
		objetos.marcar_coletado_por_recurso(info.recurso)
	var global = root.get_node("GlobalSingleton")
	global.fase_liberada = 3
	global.fases_concluidas = [true, true, false, false]
	var entrada := Node2D.new()
	root.add_child(entrada)
	current_scene = entrada
	var quadro = load("res://scenes/fase3/zoom_quadro.tscn").instantiate()
	root.add_child(quadro)
	current_scene = quadro
	await process_frame
	conferir(quadro.espacos.size() == 4, "Quatro posições acima do calendário")
	var inventario = root.get_node("Inventario/WordDropArea")
	inventario.limpar_inventario()
	var slots = root.get_node("Inventario/canvasLayer/inventory/GridContainer").get_children()
	var caminhos: Array = ["FotoAugusto", "FotoHelena", "FotoMarina", "FotoLucas"]
	for indice in range(4):
		var foto = load("res://recursos/fotos/" + caminhos[indice] + ".tres")
		slots[0].item = foto
		conferir(quadro.espacos[indice]._can_drop_data(Vector2.ZERO, slots[0]), "Aceita arraste de foto do inventário")
		quadro.espacos[indice]._drop_data(Vector2.ZERO, slots[0])
		conferir(slots[0].item == null and quadro.fotos[indice] == foto, "Foto sai do inventário e fica fixada")
		conferir(objetos.get_recurso_em_estacao("quadro_foto_" + str(indice)) == foto.resource_path, "Posição persistida no SQLite")
		conferir(not objetos.esta_coletado(foto.resource_path), "Foto fixada não duplica na recarga do inventário")
	var lanterna = load("res://recursos/lanterna.tres")
	slots[0].item = lanterna
	conferir(not quadro.espacos[0]._can_drop_data(Vector2.ZERO, slots[0]), "Rejeita itens que não são fotos")
	conferir(not quadro.fixar_foto(slots[0], 0), "Fixação valida tipo também sem GUI")
	slots[0].item = null
	var origem = quadro.fotos[0]
	var destino = quadro.fotos[3]
	quadro.espacos[3]._drop_data(Vector2.ZERO, {"quadro": quadro, "quadro_foto": 0})
	conferir(quadro.fotos[3] == origem and quadro.fotos[0] == destino, "Arraste entre fotos troca ordem")
	conferir(objetos.get_recurso_em_estacao("quadro_foto_3") == origem.resource_path, "Troca persistida")
	objetos.soltar_por_recurso(lanterna.resource_path, Vector2(750, 590), "ZoomQuadro")
	quadro.queue_free()
	await process_frame
	quadro = load("res://scenes/fase3/zoom_quadro.tscn").instantiate()
	root.add_child(quadro)
	current_scene = quadro
	await process_frame
	conferir(quadro.fotos[3] == origem and quadro.fotos[0] == destino, "Reentrada restaura ordem escolhida")
	conferir(quadro.get_node_or_null("lanterna") != null, "Lanterna deixada no zoom reaparece ao retornar")
	var tinta = quadro.espacos[3].get_node("Tinta")
	tinta._process(0.0)
	conferir(not tinta.visible, "Letra invisível sem lanterna")
	var luz := PointLight2D.new()
	luz.set_script(load("res://scripts/inventario/luz_lanterna.gd"))
	luz.name = "LuzDaLanterna"
	root.add_child(luz)
	tinta._process(0.0)
	conferir(not tinta.visible, "Luz branca não revela letra")
	luz.alternar_modo()
	tinta._process(0.0)
	conferir(tinta.visible and tinta.get_node("Texto").text == "N", "Violeta revela letra na frente da foto")
	conferir(tinta.get_node("Texto").size == quadro.espacos[3].get_node("Imagem").size, "Área da tinta alinhada à foto sem legenda")
	conferir(tinta.get_node("Texto").light_mask == 2 and tinta.get_node("Texto").material.light_mode == CanvasItemMaterial.LIGHT_MODE_LIGHT_ONLY, "Tinta usa iluminação violeta existente")
	luz.enabled = false
	tinta._process(0.0)
	conferir(not tinta.visible, "Desligar lanterna oculta letra")
	luz.queue_free()
	var dados: Dictionary = {"quadro": quadro, "quadro_foto": 3}
	var painel_inventario = root.get_node("Inventario/canvasLayer/inventory")
	painel_inventario.data_bk = dados
	painel_inventario._notification(Node.NOTIFICATION_DRAG_END)
	conferir(painel_inventario.data_bk == null, "Cancelar arraste iniciado no quadro não exige ícone de inventário")
	conferir(not inventario._can_drop_data(Vector2.ZERO, dados), "Arraste de foto fixada não cria item solto duplicado")
	conferir(slots[0]._can_drop_data(Vector2.ZERO, dados), "Aceita devolver foto ao inventário")
	slots[0]._drop_data(Vector2.ZERO, dados)
	conferir(slots[0].item == origem and quadro.fotos[3] == null, "Retirada para slot exato")
	conferir(objetos.esta_coletado(origem.resource_path) and objetos.get_recurso_em_estacao("quadro_foto_3").is_empty(), "Retirada persistida sem duplicação")
	conferir(quadro.fixar_foto(slots[0], 0) and slots[0].item == destino, "Fixar em espaço ocupado devolve foto anterior")
	quadro.trocar_fotos(0, 3)
	conferir(quadro.fotos[0] == null and quadro.fotos[3] == origem, "Pode mover para espaço vazio")
	for slot in slots:
		slot.item = lanterna
	conferir(not quadro.retirar_foto(3) and quadro.fotos[3] == origem, "Inventário cheio preserva foto fixada")
	conferir(quadro.get_node("Cenario").texture.resource_path == "res://assets/cenarios/zoom_calendario.png", "Zoom usa cenário completo do calendário")
	conferir(quadro.get_node_or_null("Conteudo/Datas") == null and quadro.get_node_or_null("Conteudo/Instrucao") == null and quadro.get_node_or_null("Conteudo/Titulo") == null, "Textos sobrepostos removidos")
	for espaco in quadro.espacos:
		conferir(espaco.get_node_or_null("Nome") == null and espaco.get_global_rect().end.y < 291.0, "Foto sem legenda fica acima do calendário desenhado")
	conferir(not global.fases_concluidas[2], "Ordem não conclui automaticamente o puzzle")
	var calendario = load("res://scenes/fase3/calendario_fisico.tscn").instantiate()
	# Pertencer à cena atual reproduz sua remoção imediata durante a troca.
	entrada.add_child(calendario)
	var miniaturas: int = 0
	for filho in calendario.get_children():
		if filho is Sprite2D:
			miniaturas += 1
	conferir(miniaturas == 4, "Parede mostra calendário e três fotos que permanecem fixadas")
	quadro.queue_free()
	await process_frame
	current_scene = entrada
	var clique := InputEventMouseButton.new()
	clique.button_index = MOUSE_BUTTON_LEFT
	clique.pressed = true
	calendario._examinar(root, clique, 0)
	await process_frame
	await process_frame
	conferir(current_scene != null and current_scene.scene_file_path == "res://scenes/fase3/zoom_quadro.tscn", "Clicar no calendário abre o zoom real")
	current_scene.queue_free()
	await process_frame
	var postit = load("res://scenes/fase2/zoom_postIt.tscn").instantiate()
	root.add_child(postit)
	conferir(postit.get_node("postit").texture.resource_path == "res://assets/cenarios/zoom_postit.png", "Zoom post-it usa cenário completo novo")
	conferir(postit.get_node("postit").get_rect().size * postit.get_node("postit").scale == Vector2(1152, 648), "Cenário do post-it alinhado ao tamanho das salas")
	postit.queue_free()
	await process_frame
	banco.query("ROLLBACK;")
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	conferir(antes == banco.get_query_result(), "Partida preservada após testes")
	banco.query("SELECT * FROM Objetos ORDER BY id;")
	conferir(objetos_antes == banco.get_query_result(), "Itens e posições originais preservados após testes")
	print("QUADRO_FOTOS: ", verificacoes, " verificações; ", falhas, " falhas.")
	quit(0 if falhas == 0 else 1)

