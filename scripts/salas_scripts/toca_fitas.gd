extends Area2D

@export var estacao_id: String = ""
@export var item_aceito: itemData

var item_guardado: itemData = null

@onready var som: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	if estacao_id == "":
		estacao_id = name
	add_to_group("estacao")
	input_pickable = true
	som.finished.connect(_on_som_terminou)

	# Restaura se o jogador saiu da cena e voltou (ou carregou o jogo)
	var caminho := Objetos.get_recurso_em_estacao(estacao_id)
	if caminho != "":
		item_guardado = load(caminho)
		som.play()

func _on_som_terminou() -> void:
	# loop; se o stream já estiver com Loop marcado, isso nunca dispara
	if item_guardado != null:
		som.play()

func esta_vazia() -> bool:
	return item_guardado == null

func colocar_item(item: itemData) -> bool:
	if not esta_vazia():
		return false
	if item_aceito != null and item.resource_path != item_aceito.resource_path:
		return false
	item_guardado = item
	Objetos.guardar_em_estacao(item.resource_path, estacao_id)
	som.play()
	return true

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if item_guardado == null:
		return
	if event is InputEventMouseButton \
			and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		_coletar()

func _coletar() -> void:
	var drop_area = get_tree().get_first_node_in_group("world_drop_area")
	if drop_area == null or not drop_area.guardar_no_inventario(item_guardado):
		return   # inventário cheio: o som continua e o item fica na estação
	som.stop()
	Objetos.marcar_coletado_por_recurso(item_guardado.resource_path)
	item_guardado = null
	get_viewport().set_input_as_handled()
