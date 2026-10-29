extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Tela/P1.pressed.connect(_pessoal)
	$Tela/P2.pressed.connect(_tecnico)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _pessoal() -> void:
	$"../Pasta_Pessoal".abrir(self)
	
func _tecnico() -> void:
	$"../Pasta_Tecnico".abrir(self)
