extends SubViewportContainer

@export var forcar_ligado_debug := true
@onready var tela_computador: SubViewportContainer = $"."

func _ready() -> void:
	visible = GlobalSingleton.pc_conectado or forcar_ligado_debug

func _on_entrou_na_tela() -> void:
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_saiu_da_tela() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
