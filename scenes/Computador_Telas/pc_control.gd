extends Control

@export var pular_boot := true # se estiver falso, ele inicia. Deixe em true para pular.

@onready var telas = $Telas
@onready var tela_boot = $Telas/Tela_Boot

func _ready() -> void:
	_iniciar_computador()

func _iniciar_computador() -> void:

	# Nota para eu mesma (SARA):
	# -----------------------
	# coomentar nesse trecho abaixo para desativar a cutscene/disparo para a 2 fase
	# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	
	if pular_boot:
		#$Telas/Tela_Senha.show()
		return

	#if not GlobalSingleton.fases_concluidas[0]:
		#tela_boot.iniciar()
	#else:
		#$Telas/Tela_Senha.show()
		#pass
		
	# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
