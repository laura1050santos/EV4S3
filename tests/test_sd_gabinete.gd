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
	objetos.salvar_objetos("BACKUP-03", "res://recursos/Backup03.tres", objetos.pos_para_json(589, 180), "ZoomCuco", "compartimento_cuco")
	banco.query("DELETE FROM Cenarios WHERE cena='GabineteAberto';")
	banco.query("UPDATE Objetos SET coletado=1 WHERE recurso IN ('res://recursos/gpu.tres','res://recursos/placaMae.tres','res://recursos/processador.tres');")
	var global = root.get_node("GlobalSingleton")
	global.fase_liberada = 3
	global.fases_concluidas = [true, true, false, false]
	global.dica_inicio_fase1_exibida = true
	var inventario = root.get_node("Inventario/WordDropArea")
	inventario.limpar_inventario()
	var slots = root.get_node("Inventario/canvasLayer/inventory/GridContainer").get_children()
	var entrada := Node2D.new()
	root.add_child(entrada)
	current_scene = entrada
	var backup = load("res://recursos/Backup03.tres")
	var pc = load("res://scenes/fase1/zoom_pc.tscn").instantiate()
	root.add_child(pc)
	current_scene = pc
	var alvo = pc.get_node("GabinetePc/slotSD")
	conferir(alvo.is_in_group("item_drop_targets"), "Leitor aceita arraste pelo sistema existente")
	conferir(not pc.gabinete_aberto and not pc.sd_inserido(), "Inicia com gabinete fechado e leitor vazio")
	conferir(not pc.receber_item_drop(load("res://recursos/gpu.tres"), alvo), "Rejeita peça incorreta no leitor")
	conferir(not pc.receber_item_drop(backup, alvo), "Não insere cartão ainda não coletado")
	objetos.marcar_coletado_por_recurso(backup.resource_path)
	conferir(inventario.guardar_no_inventario(backup), "Cartão coletado no inventário")
	conferir(pc.receber_item_drop(backup, alvo), "SD encaixa com tampa fechada")
	inventario.remover_item_por_recurso(backup.resource_path)
	conferir(pc.sd_inserido() and pc.get_node("GabinetePc/CartaoSD").visible, "Visual de SD encaixado aparece")
	conferir(pc.get_node("GabinetePc/CartaoSD").transform == Transform2D.IDENTITY, "Overlay herda perspectiva do gabinete")
	conferir(objetos.get_recurso_em_estacao("leitor_sd_pc") == backup.resource_path and not objetos.esta_coletado(backup.resource_path), "SD instalado salvo sem duplicação no inventário")
	conferir(not pc.receber_item_drop(backup, alvo), "Leitor ocupado rejeita duplicação")
	pc._definir_gabinete_aberto(true, false)
	conferir(pc.get_node("GabinetePc/CartaoSD").visible, "SD externo continua visível ao abrir tampa")
	pc._definir_gabinete_aberto(false, false)
	conferir(pc.get_node("GabinetePc/CartaoSD").visible, "SD externo continua visível ao fechar tampa")
	pc.queue_free()
	await process_frame
	current_scene = entrada
	pc = load("res://scenes/fase1/zoom_pc.tscn").instantiate()
	root.add_child(pc)
	current_scene = pc
	conferir(pc.sd_inserido() and pc.get_node("GabinetePc/CartaoSD").visible, "Revisita restaura SD inserido")
	for slot in slots:
		slot.item = load("res://recursos/lanterna.tres")
	conferir(not pc.retirar_sd() and pc.sd_inserido(), "Inventário cheio preserva SD no leitor")
	slots[0].item = null
	var clique := InputEventMouseButton.new()
	clique.button_index = MOUSE_BUTTON_LEFT
	clique.pressed = true
	pc._on_sd_input_event(root, clique, 0)
	conferir(slots[0].item == backup and not pc.sd_inserido(), "Clique retira SD para inventário")
	conferir(not pc.get_node("GabinetePc/CartaoSD").visible and objetos.esta_coletado(backup.resource_path), "Retirada persistida e overlay oculto")
	pc.queue_free()
	await process_frame
	current_scene = entrada
	progresso.salvar("cuco_compartimento_aberto", false)
	var oeste = load("res://scenes/fase1/ParedeOeste.tscn").instantiate()
	root.add_child(oeste)
	conferir(oeste.get_node("Sprite2D").texture.resource_path.ends_with("salaestar_cucofechado.png"), "Sala mostra cuco fechado antes da resolução")
	oeste.queue_free()
	await process_frame
	progresso.salvar("cuco_minutos", 705.0)
	var cuco = load("res://scenes/fase3/zoom_cuco.tscn").instantiate()
	root.add_child(cuco)
	current_scene = cuco
	cuco.clicar_mostrador(cuco.get_node("Arte").to_global(cuco.CENTRO))
	conferir(cuco.compartimento_aberto, "Aciona cuco às 12h")
	cuco.queue_free()
	await process_frame
	current_scene = entrada
	oeste = load("res://scenes/fase1/ParedeOeste.tscn").instantiate()
	root.add_child(oeste)
	conferir(oeste.get_node("Sprite2D").texture.resource_path.ends_with("salaestar.png"), "Sala muda para cuco aberto após acionamento")
	oeste.queue_free()
	await process_frame
	var leste = load("res://scenes/fase1/ParedeLeste.tscn").instantiate()
	entrada.add_child(leste)
	leste._on_pc_input_event(root, clique, 0)
	await process_frame
	await process_frame
	conferir(current_scene.scene_file_path == "res://scenes/fase1/zoom_pc.tscn", "Gabinete acessível na Fase 3 para encaixar SD")
	conferir(not global.fases_concluidas[2], "Mudanças não concluem fase nem recuperam registro")
	current_scene.queue_free()
	await process_frame
	banco.query("ROLLBACK;")
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	conferir(antes == banco.get_query_result(), "Progresso original preservado")
	banco.query("SELECT * FROM Objetos ORDER BY id;")
	conferir(itens_antes == banco.get_query_result(), "Itens originais preservados")
	print("SD_GABINETE: ", verificacoes, " verificações; ", falhas, " falhas.")
	quit(0 if falhas == 0 else 1)
