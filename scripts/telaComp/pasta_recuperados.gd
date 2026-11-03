extends Control

var origem: Control

func _ready() -> void:
	$Voltar.pressed.connect(fechar)
	$Corpo/Registro.pressed.connect(func(): $"../RegistroRecuperado".abrir(self))

func abrir(pasta_origem: Control = null) -> bool:
	if not bool(Progresso.carregar("registro_excluido_recuperado", false)):
		return false
	origem = pasta_origem
	if is_instance_valid(origem):
		origem.hide()
	show()
	return true

func fechar() -> void:
	hide()
	if is_instance_valid(origem):
		origem.show()
