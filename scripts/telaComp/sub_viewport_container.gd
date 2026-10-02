extends SubViewportContainer

@onready var tela_computador: SubViewportContainer = $"."

func _ready():
	# Ativa o SubViewport (tela ligada) apenas quando o pc_conectado for true
	#visible = GlobalSingleton.pc_conectado
	
	#tela_computador.mouse_entered.connect(_on_entrou_na_tela)
	#tela_computador.mouse_exited.connect(_on_saiu_da_tela)
	pass

func _on_entrou_na_tela():
	#if visible:
		#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pass
