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

func verificar_reproducao(player: Node, descricao: String) -> void:
	await physics_frame
	await process_frame
	conferir(player.stream != null and player.stream.get_length() > 0 and player.playing, descricao)

func _run() -> void:
	await process_frame
	await process_frame
	var banco = root.get_node("Database").db
	var progresso = load("res://BDD/Progresso.gd")
	var enigmas = load("res://BDD/Enigmas.gd")
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	var antes: Array = banco.get_query_result().duplicate(true)
	banco.query("BEGIN TRANSACTION;")
	var global = root.get_node("GlobalSingleton")
	global.fase_liberada = 2
	global.dica_inicio_fase1_exibida = true
	global.gavetas = {"leste": {"1": false, "2": false, "3": false}, "sul": {"1": false, "2": false, "3": false}}
	var entrada := Node2D.new()
	root.add_child(entrada)
	current_scene = entrada
	var clique := InputEventMouseButton.new()
	clique.button_index = MOUSE_BUTTON_LEFT
	clique.pressed = true
	for caminho in ["ParedeLeste", "ParedeSul"]:
		var sala = load("res://scenes/fase1/" + caminho + ".tscn").instantiate()
		root.add_child(sala)
		sala.gavetas_controller.alternar_gaveta("1")
		await verificar_reproducao(sala.som_gaveta_abrindo, "Abrir gaveta: " + caminho)
		sala.gavetas_controller.alternar_gaveta("1")
		await verificar_reproducao(sala.som_gaveta_fechando, "Fechar gaveta: " + caminho)
		if caminho == "ParedeSul":
			enigmas.atualizar_enigma("aquario", 0)
			sala.ativar_enigma_som()
			await verificar_reproducao(sala.SomVidroQuebrando, "Vidro do aquário")
		sala.queue_free()
		await process_frame
	var oeste = load("res://scenes/fase1/ParedeOeste.tscn").instantiate()
	root.add_child(oeste)
	progresso.salvar("cuco_compartimento_aberto", false)
	progresso.salvar("cuco_minutos", 719.0)
	var cuco = load("res://scenes/fase3/zoom_cuco.tscn").instantiate()
	root.add_child(cuco)
	cuco.avancar_minutos(1.0)
	await verificar_reproducao(cuco.get_node("SomCuco"), "Cuco toca ao chegar ao meio-dia")
	cuco.queue_free()
	oeste.queue_free()
	await process_frame
	var norte = load("res://scenes/fase1/ParedeNorte.tscn").instantiate()
	root.add_child(norte)
	norte._on_area_porta_input_event(root, clique, 0)
	await verificar_reproducao(norte.som_Porta, "Porta trancada")
	norte._on_area_interruptor_input_event(root, clique, 0)
	await verificar_reproducao(norte.som_Interruptor, "Interruptor")
	norte.queue_free()
	await process_frame
	var lixeira = load("res://scenes/fase1/lixeiraZoom.tscn").instantiate()
	root.add_child(lixeira)
	var chave = lixeira.spawnar_itens(load("res://recursos/chaveDeFenda.tres"), Vector2(600, 400))
	chave.name = "chave"
	lixeira._on_area_2d_input_event(root, clique, 0)
	await verificar_reproducao(lixeira.som_lixeira_abrindo, "Abrir lixeira")
	lixeira.queue_free()
	await process_frame
	progresso.salvar("emails_concluidos", false)
	var pc = load("res://scenes/fase1/sub_viewport_container.tscn").instantiate()
	root.add_child(pc)
	var email = pc.get_node("SubViewport/pcControl/Telas/Tela_Email")
	email.show()
	for id in email.sorteados:
		if email.emails[id].eh_phishing:
			email.abrir_email(id)
			email.responder(false)
			break
	conferir(email.som_alerta is AudioStreamPlayer, "Alerta do e-mail usa áudio sem atenuação espacial no SubViewport")
	await verificar_reproducao(email.som_alerta, "Alerta ao marcar phishing como legítimo")
	pc.queue_free()
	await process_frame
	banco.query("ROLLBACK;")
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	conferir(antes == banco.get_query_result(), "Partida original preservada")
	print("EFEITOS_AUDIO: ", verificacoes, " verificações; ", falhas, " falhas.")
	quit(0 if falhas == 0 else 1)
