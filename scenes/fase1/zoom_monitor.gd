extends Node2D

@onready var sub_viewport_container: SubViewportContainer = $SubViewportContainer

func _ready():
	if sub_viewport_container:
		# Liga/desliga a visibilidade da tela do PC de acordo com o estado do puzzle
		sub_viewport_container.visible = GlobalSingleton.pc_conectado
		
		sub_viewport_container.mouse_entered.connect(_on_entrou_na_tela)
		sub_viewport_container.mouse_exited.connect(_on_saiu_da_tela)

func _on_entrou_na_tela():
	if sub_viewport_container and sub_viewport_container.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_saiu_da_tela():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
