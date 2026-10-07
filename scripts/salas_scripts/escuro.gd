extends Node
@onready var luz = $LuzLampada
func _ready():
	aplicar_estado()

	if not GlobalSingleton.lampada_alterada.is_connected(aplicar_estado):
		GlobalSingleton.lampada_alterada.connect(aplicar_estado)

func aplicar_estado():
	luz.visible = GlobalSingleton.lampada_ligada
