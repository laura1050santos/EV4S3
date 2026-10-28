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
