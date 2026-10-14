extends Node2D

@onready var sub_viewport_container: SubViewportContainer = $SubViewportContainer
@onready var telaSemConexao = $"sem conexão"
@export var forcar_ligado_debug := true # ligar true para ver a animação de boot

func _ready():
	if sub_viewport_container:
		# Liga/desliga a visibilidade do container
		sub_viewport_container.visible = GlobalSingleton.pc_conectado or forcar_ligado_debug
		
		
		# Conecta os sinais do mouse
		sub_viewport_container.mouse_entered.connect(_on_entrou_na_tela)
		sub_viewport_container.mouse_exited.connect(_on_saiu_da_tela)
		
		# Exibe a tela sem conexão caso o PC NÃO esteja conectado
		#if not GlobalSingleton.pc_conectado and GlobalSingleton.fase_liberada==2:
			#telaSemConexao.visible = true
		#else:
			#telaSemConexao.visible = false
func _on_entrou_na_tela():
	if sub_viewport_container and sub_viewport_container.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_saiu_da_tela():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
