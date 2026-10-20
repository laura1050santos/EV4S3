extends "res://scripts/salas_scripts/salas_manager.gd"

const ID_SALA := "leste"
@onready var telaSemConexao := $monitorLigado
var gavetas_controller: GavetasController

@onready var gavetas_sprites := {
	"1": $Gaveta1Pc,
	"2": $Gaveta2Pc,
	"3": $Gaveta3Pc
}

@onready var gavetas_areas := {
	"1": $Area2D,
	"2": $Area2D2,
	"3": $Area2D3
}

func _ready() -> void:
	GlobalSingleton.registrar_cena_atual(get_tree().current_scene.scene_file_path)

	var nome_desta_cena = self.name
	Objetos.garantir_padrao(nome_desta_cena)
	var objetos = Objetos.get_objetos_cena(nome_desta_cena)
	iniciar_itens_cena(nome_desta_cena, objetos)

	gavetas_controller = GavetasController.new()
	add_child(gavetas_controller)
	gavetas_controller.configurar(ID_SALA, gavetas_sprites, gavetas_areas)
	gavetas_controller.gaveta_alterada.connect(_on_gaveta_alterada)

	for id in GlobalSingleton.gavetas[ID_SALA].keys():
		if GlobalSingleton.gavetas[ID_SALA][id]:
			_mostrar_itens_gaveta(id)

	_atualizar_estado_fase()

func _on_gaveta_alterada(id: String, aberta: bool) -> void:
	if aberta:
		_mostrar_itens_gaveta(id)
	else:
		_esconder_itens_gaveta(id)

func _container_id(id: String) -> String:
	return ID_SALA + "_gvt_" + id

func _mostrar_itens_gaveta(id: String) -> void:
	var objetos = Objetos.get_objetos_container(self.name, _container_id(id))
	for info in objetos:
		spawnar_itens(info["item"], info["pos"])

func _esconder_itens_gaveta(id: String) -> void:
	var objetos = Objetos.get_objetos_container(self.name, _container_id(id))
	for info in objetos:
		var node = get_node_or_null(NodePath(info["item"].item_name))
		if node != null:
			node.queue_free()

func _clique_esquerdo(event: InputEvent) -> bool:
	return (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
	)

func _atualizar_estado_fase() -> void:
	telaSemConexao.visible = GlobalSingleton.fase_liberada >= 2
	if GlobalSingleton.fase_liberada >= 2:
		print("Sala do PC configurada para a Fase 2")

func _on_pc_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not _clique_esquerdo(event):
		return
	if GlobalSingleton.fase_liberada == 1:
		get_tree().change_scene_to_file("res://scenes/fase1/zoom_pc.tscn")
	else:
		print("O gabinete já está montado com todas as peças.")
		telaSemConexao.visible= true
func _on_monitor_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not _clique_esquerdo(event):
		return
	if GlobalSingleton.fase_liberada == 1:
		get_tree().change_scene_to_file("res://scenes/fase1/zoom_monitor.tscn")
	elif GlobalSingleton.fase_liberada == 2:
		get_tree().change_scene_to_file("res://scenes/fase1/zoom_monitor.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		TransicaoFase.show_phase_complete("res://scenes/telaInicial/selecao_fases.tscn")

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not _clique_esquerdo(event):
		return
	if GlobalSingleton.fase_liberada == 1:
		get_tree().change_scene_to_file("res://scenes/fase2/zoom_postIt.tscn")
