extends SubViewportContainer

@export var forcar_ligado_debug := false
@onready var tela_computador: SubViewportContainer = $"."

func _ready() -> void:
	var boot_pendente: bool = not GlobalSingleton.fases_concluidas[0] and bool(Progresso.carregar("pc_consertado", false))
	visible = get_tree().current_scene == self or GlobalSingleton.pc_conectado or boot_pendente or forcar_ligado_debug

func _on_entrou_na_tela() -> void:
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_saiu_da_tela() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
