extends Control

func _ready() -> void:
	$Navegador.pressed.connect(_nav)
	$menu/Navegador.pressed.connect(_nav)
	$Email.pressed.connect(_email)
	$menu/Email.pressed.connect(_email)
	$Menu.pressed.connect(_menu)
	$Pasta.pressed.connect(_p1_pessoal)
	$Pasta2.pressed.connect(_p2_tecnico)
	$Pastas.pressed.connect(_pastas)

func _nav() -> void:
	$"../Tela_Navegador".show()
	$menu.hide()

func _email() -> void:
	$"../Tela_Email".show()
	$menu.hide()

func _menu() -> void:
	$menu.visible = not $menu.visible

func _pastas() -> void:
	$"../Tela_Pastas".show()
	$menu.hide()
	
func _p1_pessoal() -> void:
	$"../Pasta_Pessoal".abrir()
	$menu.hide()

func _p2_tecnico() -> void:
	$"../Pasta_Tecnico".abrir()
	$menu.hide()
