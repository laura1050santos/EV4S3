extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Navegador.pressed.connect(func(): _nav())
	$menu/Navegador.pressed.connect(func(): _nav())
	$Email.pressed.connect(func(): _email())
	$Menu.pressed.connect(func(): _menu())
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _nav() -> void:
	$"../Tela_Navegador".show()
	$menu.hide()
	
func _email() -> void:
	$"../Tela_Email".show()
	$menu.hide()
	
func _menu() -> void:
	$menu.show()
	
#func _menuFechar() -> void:
	#if $menu.show():
		#$menu.hide()
