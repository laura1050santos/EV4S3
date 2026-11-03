extends Area2D

@export var estacao_id: String = ""
@export var item_aceito: itemData
@onready var toca_fitas: AudioStreamPlayer2D = $"../../AudioListener2D/TocaFitas"

var item_guardado: itemData = null
var operacao_som: int = 0

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
		tocar_sons_com_delay()

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
	tocar_sons_com_delay()
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
	operacao_som += 1
	som.stop()
	toca_fitas.stop()
	Objetos.marcar_coletado_por_recurso(item_guardado.resource_path)
	item_guardado = null
	get_viewport().set_input_as_handled()
	
func tocar_sons_com_delay() -> void:
	operacao_som += 1
	var tentativa: int = operacao_som
	toca_fitas.play() # Toca o primeiro som imediatamente
	await get_tree().create_timer(2.5).timeout 
	if tentativa == operacao_som and item_guardado != null and is_inside_tree():
		som.play()
