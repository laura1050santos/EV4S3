extends Node2D

@onready var sub_viewport_container: SubViewportContainer = $SubViewportContainer
@onready var telaSemConexao = $"sem conexão"
func _ready():
	if sub_viewport_container:
		var boot_pendente: bool = not GlobalSingleton.fases_concluidas[0] and bool(Progresso.carregar("pc_consertado", false))
		sub_viewport_container.visible = GlobalSingleton.pc_conectado or boot_pendente
		telaSemConexao.visible = GlobalSingleton.fases_concluidas[0] and not GlobalSingleton.pc_conectado
		if boot_pendente:
			sub_viewport_container.get_node("SubViewport/pcControl/Telas/Tela_Boot").iniciar.call_deferred()

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
