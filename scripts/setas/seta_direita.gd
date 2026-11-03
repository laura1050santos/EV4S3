extends Area2D

signal seta_clicada
@export_file("*.tscn") var destino_cena: String
var trocando: bool = false

func _ready() -> void:
	input_event.connect(_inout_event)

func _inout_event(viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if viewport is Viewport:
			viewport.set_input_as_handled()
		trocar()

func trocar() -> void:
	if trocando:
		return
	if destino_cena.is_empty() or not ResourceLoader.exists(destino_cena, "PackedScene"):
		push_warning("Seta sem destino válido: " + destino_cena)
		return
	trocando = true
	_trocar_cena.call_deferred()

func _trocar_cena() -> void:
	var erro: Error = get_tree().change_scene_to_file(destino_cena)
	if erro != OK:
		trocando = false
		push_error("Não foi possível abrir " + destino_cena + ": " + error_string(erro))
