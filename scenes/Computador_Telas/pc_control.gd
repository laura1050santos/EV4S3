extends Control

@onready var telas: Control = $Telas


func _ready() -> void:
	for tela in telas.get_children():
		if tela is CanvasItem:
			tela.hide()

	if GlobalSingleton.pc_conectado:
		$Telas/Tela_Senha.show()
