extends SceneTree

var verificacoes: int = 0
var falhas: int = 0
var arquivos: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func conferir(valor: bool, descricao: String) -> void:
	verificacoes += 1
	if not valor:
		falhas += 1
		push_error(descricao)

func listar(pasta: String) -> void:
	for nome in DirAccess.get_files_at(pasta):
		if nome.ends_with(".tscn"):
			arquivos.append(pasta.path_join(nome))
	for nome in DirAccess.get_directories_at(pasta):
		listar(pasta.path_join(nome))

func _run() -> void:
	await process_frame
	await process_frame
	var banco = root.get_node("Database").db
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	var antes = banco.get_query_result().duplicate(true)
	banco.query("BEGIN TRANSACTION;")
	var global = root.get_node("GlobalSingleton")
	global.fase_liberada = 1
	global.fases_concluidas = [false, false, false, false]
	global.pc_conectado = false
	global.dica_inicio_fase1_exibida = true
	listar("res://scenes")
	for caminho in arquivos:
		conferir(load(caminho) is PackedScene, "Cena válida: " + caminho)
	var cenas: Dictionary = {
		"fase1/ParedeLeste": "Sprite2D", "fase1/ParedeNorte": "Sprite2D",
		"fase1/ParedeOeste": "Sprite2D", "fase1/ParedeSul": "cena",
		"fase1/cena_chao": "Sprite2D", "fase1/cena_teto": "Sprite2D",
		"fase1/lixeiraZoom": "back", "fase1/zoom_buraco": "Sprite2D",
		"fase1/buraco_abertoZoom": "Sprite2D", "fase1/zoom_pc": "GabinetePc",
		"fase1/zoom_monitor": "Sprite2D", "fase1/zoom_tele": "CenaTelegrafoInicial",
		"fase2/zoomMala": "CenarioFechado", "fase2/zoom_postIt": "postit",
		"fase2/zoom_tocafitas": "ZoomTocafitas", "fase2/puzzleRoteador": "Fios",
		"fase3/zoom_cuco": "Arte/Cenario", "fase3/zoom_quadro": "Cenario"
	}
	var entrada := Node2D.new()
	root.add_child(entrada)
	current_scene = entrada
	for nome in cenas:
		var cena = load("res://scenes/" + nome + ".tscn").instantiate()
		root.add_child(cena)
		current_scene = cena
		await process_frame
		var sprite: Sprite2D = cena.get_node(cenas[nome])
		var retangulo: Rect2 = sprite.global_transform * sprite.get_rect()
		var esperado := Rect2(0, 0, 1152, 648)
		conferir(retangulo.position.distance_to(esperado.position) < 0.1 and retangulo.size.distance_to(esperado.size) < 0.1, "Enquadramento padrão: " + nome)
		var config: Button = cena.get_node("BotaoConfig")
		conferir(config.get_global_rect().position.distance_to(Vector2(16, 16)) < 0.1, "Configurações no mesmo lugar: " + nome)
		conferir(Rect2(0, 0, 1152, 648).encloses(config.get_global_rect()), "Configurações dentro da tela: " + nome)
		config.pressed.emit()
		conferir(config.get_node("configuracao").visible, "Configurações abre: " + nome)
		config.pressed.emit()
		conferir(not config.get_node("configuracao").visible, "Configurações fecha: " + nome)
		if nome == "fase1/zoom_monitor":
			conferir(cena.get_node("SubViewportContainer").size.is_equal_approx(Vector2(1815, 932)), "Monitor mantém resolução virtual")
			var alerta: Sprite2D = cena.get_node("sem conexão")
			var usado: Rect2 = alerta.texture.get_image().get_used_rect()
			usado.position += alerta.get_rect().position
			usado = alerta.global_transform * usado
			conferir(cena.get_node("SubViewportContainer").get_global_rect().grow(0.1).encloses(usado), "Aviso sem internet cabe na tela do monitor")
			var telas = cena.get_node("SubViewportContainer/SubViewport/pcControl/Telas")
			for tela_nome in ["Tela_Inicial", "Tela_Senha", "Tela_Boot", "Tela_Email", "Tela_Navegador", "Pasta_Pessoal", "Pasta_Tecnico"]:
				conferir(telas.get_node(tela_nome).size.is_equal_approx(Vector2(1815, 932)), "Tela virtual completa: " + tela_nome)
		if nome == "fase2/zoomMala":
			conferir(cena.get_node("MalaFechada").texture.resource_path.ends_with("maletazoomfechada.png"), "Zoom usa mala fechada nova")
			global.fase_liberada = 2
			cena.mala_aberta = true
			cena._atualizar_visual()
			conferir(cena.mala_sprite.visible and not cena.get_node("MalaFechada").visible and cena.cenario_fechado.visible, "Mala aberta troca a arte mantendo o cenário")
			conferir(cena.mala_sprite.texture.resource_path.ends_with("maletazoomaberta.png"), "Mala aberta usa arte nova")
			var recorte: Control = cena.get_node("RecorteMala")
			conferir(recorte.clip_contents and esperado.encloses(recorte.get_global_rect()), "Close da mala aberta fica limitado à moldura")
			conferir(cena.cenario_fechado.texture.resource_path.ends_with("zoom_malafechada.png"), "Preserva exatamente a composição antiga aprovada")
			global.fase_liberada = 1
		if nome == "fase1/ParedeNorte":
			conferir(cena.get_node("ObjetoMalaSala").texture.atlas.resource_path.ends_with("maletazoomfechada.png"), "Sala usa mala nova")
		current_scene = entrada
		cena.queue_free()
		await process_frame
	banco.query("ROLLBACK;")
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	conferir(antes == banco.get_query_result(), "Partida preservada após revisão")
	print("LAYOUT_CENAS: ", arquivos.size(), " cenas; ", verificacoes, " verificações; ", falhas, " falhas.")
	quit(0 if falhas == 0 else 1)
