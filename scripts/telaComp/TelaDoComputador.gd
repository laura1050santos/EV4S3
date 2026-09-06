extends SubViewport

@onready var cursor_falso: Sprite2D = $pcControl/CursorPc
var textura_normal = preload("res://assets/cursor_normal.png")
var textura_hover = preload("res://assets/cursor_hover.png")

func _process(_delta):
	cursor_falso.position = get_viewport().get_mouse_position()
	
func _ready():
	for botao in get_tree().get_nodes_in_group("botoes_computador"):
		botao.mouse_entered.connect(_on_botao_hover.bind(true))
		botao.mouse_exited.connect(_on_botao_hover.bind(false))
		
func _on_botao_hover(esta_em_cima: bool):
	cursor_falso.texture = textura_hover if esta_em_cima else textura_normal
