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
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	var antes: Array = banco.get_query_result().duplicate(true)
	banco.query("BEGIN TRANSACTION;")
	banco.query("DELETE FROM Cenarios WHERE cena='GabineteAberto';")
	banco.query("UPDATE Objetos SET coletado=1 WHERE recurso IN ('res://recursos/gpu.tres','res://recursos/placaMae.tres','res://recursos/processador.tres');")
	var global = root.get_node("GlobalSingleton")
	global.fase_liberada = 1
	global.fases_concluidas = [false, false, false, false]
	global.item_mao = null
	var entrada := Node2D.new()
	root.add_child(entrada)
	current_scene = entrada
	var pc = load("res://scenes/fase1/zoom_pc.tscn").instantiate()
	root.add_child(pc)
	current_scene = pc
	var nomes: Array = ["GuiaPlacaMae", "GuiaProcessador", "GuiaGPU"]
	for nome in nomes:
		conferir(not pc.get_node("GabinetePc/" + nome).visible, "Guia oculta com tampa fechada")
	conferir(not pc.receber_item_drop(load("res://recursos/gpu.tres"), pc.get_node("slotGPU")), "Gabinete fechado impede instalação")
	var clique := InputEventMouseButton.new()
	clique.button_index = MOUSE_BUTTON_LEFT
	clique.pressed = true
	pc._on_area_2d_input_event(root, clique, 0)
	conferir(not pc.gabinete_aberto, "Ainda exige chave de fenda")
	global.item_mao = load("res://recursos/chaveDeFenda.tres")
	pc._on_area_2d_input_event(root, clique, 0)
	conferir(pc.gabinete_aberto, "Chave de fenda abre gabinete")
	for nome in nomes:
		conferir(pc.get_node("GabinetePc/" + nome).visible, "Guia aparece ao abrir")
	# Cada pixel do arquivo original deve aparecer em exatamente uma região.
	var desenho: Image = pc.get_node("GabinetePc/GuiaGPU").texture.get_image()
	var regioes: Array = []
	for nome in nomes:
		var guia = pc.get_node("GabinetePc/" + nome)
		regioes.append(guia.polygon)
		conferir(guia.uv == guia.polygon and guia.offset == -Vector2(desenho.get_size()) / 2.0, "Recorte preserva alinhamento da arte")
	var retangulo: Rect2i = desenho.get_used_rect()
	var incorretos: int = 0
	for y in range(retangulo.position.y, retangulo.end.y):
		for x in range(retangulo.position.x, retangulo.end.x):
			if desenho.get_pixel(x, y).a == 0:
				continue
			var quantidade: int = 0
			for regiao in regioes:
				if Geometry2D.is_point_in_polygon(Vector2(x + 0.5, y + 0.5), regiao):
					quantidade += 1
			if quantidade != 1:
				incorretos += 1
	conferir(incorretos == 0, "Serrilhado inteiro preservado sem cortes nem duplicação de pixels")
	conferir(not pc.receber_item_drop(load("res://recursos/gpu.tres"), pc.get_node("slotPlacaMae")), "Peça errada não remove guia")
	var recursos: Array = ["placaMae", "processador", "gpu"]
	var slots: Array = ["slotPlacaMae", "slotProcessador", "slotGPU"]
	for indice in range(3):
		conferir(pc.receber_item_drop(load("res://recursos/" + recursos[indice] + ".tres"), pc.get_node(slots[indice])), "Instala peça correta")
		conferir(not pc.get_node("GabinetePc/" + nomes[indice]).visible, "Some somente guia da peça instalada")
		if indice < 2:
			conferir(pc.get_node("GabinetePc/" + nomes[indice + 1]).visible, "Guia da próxima peça continua visível")
		if indice == 0:
			pc.queue_free()
			await process_frame
			current_scene = entrada
			pc = load("res://scenes/fase1/zoom_pc.tscn").instantiate()
			root.add_child(pc)
			current_scene = pc
			conferir(pc.gabinete_aberto and not pc.get_node("GabinetePc/GuiaPlacaMae").visible and pc.get_node("GabinetePc/GuiaGPU").visible, "Reentrada restaura somente guias pendentes")
	conferir(not pc.gabinete_aberto, "Última peça mantém fechamento automático")
	for nome in nomes:
		conferir(not pc.get_node("GabinetePc/" + nome).visible, "Nenhuma guia sobre tampa fechada")
	conferir(not global.fases_concluidas[0], "Montagem continua exigindo boot para concluir fase")
	pc.queue_free()
	await process_frame
	banco.query("ROLLBACK;")
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	conferir(antes == banco.get_query_result(), "Progresso original preservado")
	print("GUIAS_PC: ", verificacoes, " verificações; ", falhas, " falhas.")
	quit(0 if falhas == 0 else 1)
