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
	var progresso = load("res://BDD/Progresso.gd")
	var objetos = load("res://BDD/Objetos.gd")
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	var antes: Array = banco.get_query_result().duplicate(true)
	banco.query("SELECT * FROM Objetos ORDER BY id;")
	var itens_antes: Array = banco.get_query_result().duplicate(true)
	banco.query("BEGIN TRANSACTION;")
	banco.query("DELETE FROM Objetos WHERE recurso='res://recursos/Backup03.tres';")
	progresso.salvar("cuco_compartimento_aberto", false)
	banco.query("DELETE FROM Progresso WHERE chave='cuco_minutos';")
	var global = root.get_node("GlobalSingleton")
	global.fase_liberada = 1
	global.fases_concluidas = [false, false, false, false]
	global.dica_inicio_fase1_exibida = true
	var inventario = root.get_node("Inventario/WordDropArea")
	inventario.limpar_inventario()
	var slots = root.get_node("Inventario/canvasLayer/inventory/GridContainer").get_children()
	var entrada := Node2D.new()
	root.add_child(entrada)
	current_scene = entrada
	var cuco = load("res://scenes/fase3/zoom_cuco.tscn").instantiate()
	root.add_child(cuco)
	current_scene = cuco
	conferir(cuco.minutos == 180 and not cuco.compartimento_aberto, "Inicia às 3h sem bloqueio de fase")
	conferir(is_equal_approx(cuco.get_node("Arte/PonteiroMinutos").rotation_degrees, 0.0), "Minutos iniciam no topo")
	conferir(is_equal_approx(cuco.get_node("Arte/PonteiroHoras").rotation_degrees, 90.0), "Horas iniciam em 3")
	conferir(not cuco.coletar_cartao(), "Portinha fechada impede coleta")
	conferir(not cuco.get_node("SomCuco").playing, "Entrar não toca som de vitória")
	conferir(not cuco.clicar_mostrador(Vector2(1000, 600)) and cuco.minutos == 180, "Clique fora do mostrador não altera horário")
	var centro: Vector2 = cuco.CENTRO
	var arte = cuco.get_node("Arte")
	conferir(cuco.clicar_mostrador(arte.to_global(centro)), "Clique no mostrador avança ponteiro maior")
	conferir(cuco.minutos == 195.0 and is_equal_approx(cuco.get_node("Arte/PonteiroHoras").rotation_degrees, 97.5), "Cada clique avança 15 minutos com horas proporcionais")
	for passo in range(3):
		cuco.clicar_mostrador(arte.to_global(centro))
	conferir(is_equal_approx(cuco.minutos, 240.0), "Quatro cliques completam uma hora")
	conferir(is_equal_approx(cuco.get_node("Arte/PonteiroHoras").rotation_degrees, 120.0), "Horas acompanham automaticamente os cliques")
	var movimento := InputEventMouseMotion.new()
	cuco._unhandled_input(movimento)
	conferir(cuco.minutos == 240.0, "Mover mouse não arrasta os ponteiros")
	conferir(not cuco.compartimento_aberto, "Minutos no topo às 4h não resolvem puzzle")
	cuco.queue_free()
	await process_frame
	current_scene = entrada
	cuco = load("res://scenes/fase3/zoom_cuco.tscn").instantiate()
	root.add_child(cuco)
	current_scene = cuco
	conferir(is_equal_approx(cuco.minutos, 240.0), "Reentrada restaura horário salvo")
	arte = cuco.get_node("Arte")
	for passo in range(31):
		cuco.clicar_mostrador(arte.to_global(centro))
	conferir(not cuco.compartimento_aberto and cuco.minutos == 705.0, "11h45 ainda fechado")
	cuco.clicar_mostrador(arte.to_global(centro))
	conferir(cuco.compartimento_aberto and cuco.minutos == 0.0, "Último clique chega a meio-dia e abre compartimento")
	conferir(cuco.cartao_disponivel and cuco.get_node("Arte/AreaCartao").input_pickable, "Revela cartão na portinha")
	conferir(cuco.get_node("SomCuco").playing, "Cuco toca ao abrir")
	var som_cuco = cuco.get_node("SomCuco")
	conferir(cuco.toques_restantes == 2, "Primeira abertura inicia sequência de três toques")
	for restantes in [1, 0]:
		som_cuco.stop()
		som_cuco.finished.emit()
		conferir(som_cuco.playing and cuco.toques_restantes == restantes, "Fim do toque inicia o próximo sem sobreposição")
	som_cuco.stop()
	som_cuco.finished.emit()
	conferir(not som_cuco.playing and cuco.toques_restantes == 0, "Sequência termina após o terceiro toque")
	conferir(bool(progresso.carregar("cuco_compartimento_aberto", false)), "Abertura persistida")
	var lanterna = load("res://recursos/lanterna.tres")
	for slot in slots:
		slot.item = lanterna
	conferir(not cuco.coletar_cartao() and cuco.cartao_disponivel, "Inventário cheio deixa cartão disponível")
	cuco.queue_free()
	await process_frame
	current_scene = entrada
	cuco = load("res://scenes/fase3/zoom_cuco.tscn").instantiate()
	root.add_child(cuco)
	current_scene = cuco
	conferir(cuco.compartimento_aberto and cuco.cartao_disponivel, "Compartimento permanece aberto para coleta posterior")
	conferir(not cuco.get_node("SomCuco").playing, "Revisitar não repete o som")
	slots[0].item = null
	var clique := InputEventMouseButton.new()
	clique.button_index = MOUSE_BUTTON_LEFT
	clique.pressed = true
	cuco._clicar_cartao(root, clique, 0)
	var backup = load("res://recursos/Backup03.tres")
	conferir(slots[0].item == backup and not cuco.cartao_disponivel, "Clique coleta BACKUP-03 antecipadamente na Fase 1")
	conferir(objetos.esta_coletado(backup.resource_path), "Cartão persiste no inventário pelo sistema existente")
	conferir(cuco.get_node("Arte/Relogio").texture == cuco.ABERTO_SEM_CARTAO, "Arte aberta sem cartão após coleta")
	conferir(not cuco.coletar_cartao(), "Sem duplicação de cartão")
	conferir(backup.pode_inspecionar(), "Botão direito examina cartão em vez de ativar item sem textura")
	cuco.queue_free()
	await process_frame
	current_scene = entrada
	cuco = load("res://scenes/fase3/zoom_cuco.tscn").instantiate()
	root.add_child(cuco)
	current_scene = cuco
	conferir(not cuco.cartao_disponivel and cuco.compartimento_aberto, "Cartão coletado não reaparece")
	var solto = cuco.spawnar_itens(backup, Vector2(600, 550))
	inventario.usar_item(backup, solto)
	conferir(inventario.inspecao_item.visible and solto.texture != null and not backup.item_ativo, "Examinar cartão no cenário não o faz desaparecer")
	inventario.inspecao_item.fechar()
	objetos.soltar_por_recurso(backup.resource_path, solto.position, cuco.name)
	slots[0].item = null
	cuco.queue_free()
	await process_frame
	current_scene = entrada
	cuco = load("res://scenes/fase3/zoom_cuco.tscn").instantiate()
	root.add_child(cuco)
	current_scene = cuco
	conferir(cuco.get_node_or_null("BACKUP-03") != null and not cuco.cartao_disponivel, "Cartão solto é restaurado sem voltar ao compartimento")
	conferir(not global.fases_concluidas[2] and not bool(progresso.carregar("registro_excluido_recuperado", false)), "Cartão sozinho não recupera registro nem conclui fase")
	cuco.queue_free()
	await process_frame
	current_scene = entrada
	var oeste = load("res://scenes/fase1/ParedeOeste.tscn").instantiate()
	entrada.add_child(oeste)
	oeste._on_cuckoo_input_event(root, clique, 0)
	await process_frame
	await process_frame
	conferir(current_scene.scene_file_path == "res://scenes/fase3/zoom_cuco.tscn", "Clique no relógio da parede abre zoom real")
	current_scene.queue_free()
	await process_frame
	banco.query("ROLLBACK;")
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	conferir(antes == banco.get_query_result(), "Progresso original preservado após testes")
	banco.query("SELECT * FROM Objetos ORDER BY id;")
	conferir(itens_antes == banco.get_query_result(), "Itens originais preservados após testes")
	print("CUCO: ", verificacoes, " verificações; ", falhas, " falhas.")
	quit(0 if falhas == 0 else 1)
