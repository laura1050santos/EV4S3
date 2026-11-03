extends Control

@onready var telas: Control = $Telas


func _ready() -> void:
	for tela in telas.get_children():
		if tela is CanvasItem:
			tela.hide()

	if get_tree().current_scene == get_parent().get_parent() or get_tree().current_scene == self:
		$Telas/Tela_Inicial.show()
	elif GlobalSingleton.pc_conectado:
		if GlobalSingleton.fases_concluidas[1]:
			$Telas/Tela_Inicial.show()
		else:
			$Telas/Tela_Senha.show()
	$Telas/RegistroRecuperado.fechado_apos_leitura.connect(_retomar_mensageiro)
	$Telas/Mensageiro.conversa_concluida.connect(_concluir_fase_3)
	visibility_changed.connect(func(): _retomar_mensageiro.call_deferred())
	_retomar_mensageiro.call_deferred()

func _retomar_mensageiro() -> void:
	if not is_visible_in_tree() or $Telas/Mensageiro.visible:
		return
	if not bool(Progresso.carregar("mensageiro_pendente", false)) or bool(Progresso.carregar("mensageiro_concluido", false)):
		return
	var origem: Control
	for tela in telas.get_children():
		if tela is Control and tela != $Telas/Mensageiro and tela.visible:
			if origem == null or tela.z_index >= origem.z_index:
				origem = tela
	$Telas/Mensageiro.abrir(origem)

func _concluir_fase_3() -> void:
	if GlobalSingleton.fase_liberada != 3 or GlobalSingleton.fases_concluidas[2]:
		return
	if not bool(Progresso.carregar("mensageiro_concluido", false)):
		return
	for tela in telas.get_children():
		if tela is CanvasItem:
			tela.hide()
	$Telas/Tela_Inicial.show()
	GlobalSingleton.ultima_cena_por_fase[3] = "res://scenes/fase1/zoom_monitor.tscn"
	GlobalSingleton.ultima_cena_por_fase[4] = "res://scenes/fase1/ParedeNorte.tscn"
	GlobalSingleton.concluir_fase(3)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	TransicaoFase.show_phase_complete("res://scenes/telaInicial/selecao_fases.tscn")
