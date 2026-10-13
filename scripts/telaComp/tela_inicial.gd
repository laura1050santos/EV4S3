extends Control

func _ready() -> void:
	$Navegador.pressed.connect(_nav)
	$menu/Navegador.pressed.connect(_nav)
	$Email.pressed.connect(_email)
	$Menu.pressed.connect(_menu)

func _nav() -> void:
	$"../Tela_Navegador".show()
	$menu.hide()

func _email() -> void:
	$"../Tela_Email".show()
	$menu.hide()

func _menu() -> void:
	$menu.visible = not $menu.visible
