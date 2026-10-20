extends "res://scripts/salas_scripts/salas_manager.gd"

const POS_LAMPADA := Vector2(575, 273)
const RECURSO_LAMPADA := "res://recursos/lampada.tres"
const RECURSO_FLAN := "res://recursos/flan.tres"

func _ready() -> void:
	GlobalSingleton.registrar_cena_atual(scene_file_path)
	Objetos.garantir_padrao(name)
	iniciar_itens_cena(name, Objetos.get_objetos_cena(name))
	_atualizar_visual_lampada()
	lampada_arrumada()
	var enigma = Enigmas.get_nome("lampada")
	if enigma != null and int(enigma["resolvido"]) == 1:
		_fixar_conserto()
	GlobalSingleton.lampada_alterada.connect(_atualizar_visual_lampada)

func receber_item_drop(item: itemData, alvo: Area2D) -> bool:
	var enigma = Enigmas.get_nome("lampada")
	if enigma != null and int(enigma["resolvido"]) == 1:
		return false
	if item == null or alvo != $AreaLampada:
		return false
	if item.resource_path not in [RECURSO_LAMPADA, RECURSO_FLAN]:
		return false
	var existente = get_node_or_null(NodePath(item.item_name))
	if existente != null and existente.position.distance_to(POS_LAMPADA) < 2.0:
		return false
	var visual = spawnar_itens(item, POS_LAMPADA)
	if visual == null:
		return false
	visual.position = POS_LAMPADA
	Objetos.soltar_por_recurso(item.resource_path, POS_LAMPADA, name)
	_atualizar_visual_lampada()
	lampada_arrumada()
	return true

func _on_area_lampada_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_atualizar_visual_lampada()
		lampada_arrumada()

func _atualizar_visual_lampada() -> void:
	var lamp = get_node_or_null("lampadaNova")
	if lamp != null and lamp.position.distance_to(POS_LAMPADA) < 2.0:
		lamp.texture = preload("res://assets/itens/lampadatetoapagada.png") if GlobalSingleton.lampada_ligada else preload("res://assets/itens/lampadatetoacesa.png")
	var flan = get_node_or_null("flan")
	if flan != null and flan.position.distance_to(POS_LAMPADA) < 2.0:
		flan.z_index = 1

func lampada_arrumada() -> void:
	var lamp = get_node_or_null("lampadaNova")
	var flan = get_node_or_null("flan")
	if lamp == null or flan == null:
		return
	if lamp.position.distance_to(POS_LAMPADA) >= 2.0 or flan.position.distance_to(POS_LAMPADA) >= 2.0:
		return
	var enigma = Enigmas.get_nome("lampada")
	if enigma == null or int(enigma["resolvido"]) == 1:
		return
	Enigmas.atualizar_enigma("lampada", 1)
	Objetos.soltar_por_recurso(RECURSO_LAMPADA, POS_LAMPADA, name)
	Objetos.soltar_por_recurso(RECURSO_FLAN, POS_LAMPADA, name)
	_fixar_conserto()
	_atualizar_visual_lampada()
	SaveManager.salvar()

func _fixar_conserto() -> void:
	var drop_area = get_tree().get_first_node_in_group("world_drop_area")
	for caminho in [RECURSO_LAMPADA, RECURSO_FLAN, "res://recursos/LampadaQuebrada.tres"]:
		if drop_area != null:
			drop_area.remover_item_por_recurso(caminho)
		if GlobalSingleton.item_mao != null and GlobalSingleton.item_mao.resource_path == caminho:
			GlobalSingleton.item_mao = null
	GlobalSingleton.itens_no_mundo = GlobalSingleton.itens_no_mundo.filter(func(info):
		return info["data"] not in [RECURSO_LAMPADA, RECURSO_FLAN, "res://recursos/LampadaQuebrada.tres"]
	)
	Objetos.delete_objeto("lampada quebrada")
	for filho in get_children():
		if _eh_lampada_quebrada(filho):
			filho.hide()
			filho.queue_free()
	for caminho in [RECURSO_LAMPADA, RECURSO_FLAN]:
		var visual = spawnar_itens(load(caminho), POS_LAMPADA)
		visual.position = POS_LAMPADA
		# Mantém o visual no teto, sem permitir coleta pelo inventário.
		if visual.has_meta("item_data"):
			visual.remove_meta("item_data")
		var area: Area2D = visual.get_node("Area2D")
		area.input_pickable = false
		area.set_deferred("collision_layer", 0)
		area.set_deferred("collision_mask", 0)
		Objetos.marcar_instalado_por_recurso(caminho)
	_atualizar_visual_lampada()

func _eh_lampada_quebrada(objeto: Node) -> bool:
	if not objeto.has_meta("item_data"):
		return false
	var item: itemData = objeto.get_meta("item_data")
	return item != null and item.resource_path == "res://recursos/LampadaQuebrada.tres"
