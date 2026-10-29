extends PointLight2D

var modo_violeta: bool = false

func _ready() -> void:
	texture = preload("res://assets/itens/luzLanterna.png")
	# Cobre também o topo e o rodapé, afastando o limite da textura da sala.
	texture_scale = 1.25
	global_position = Vector2(650, 325)
	_aplicar_modo()

func alternar_modo() -> void:
	modo_violeta = not modo_violeta
	_aplicar_modo()

func _aplicar_modo() -> void:
	color = Color(0.65, 0.3, 1.0) if modo_violeta else Color.WHITE
	# Camada 1: ambiente. Camada 2: tinta revelada apenas pelo modo violeta.
	range_item_cull_mask = 3 if modo_violeta else 1

func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var foco = get_viewport().gui_get_focus_owner()
	if foco is LineEdit or foco is TextEdit:
		return
	if event.keycode == KEY_F:
		alternar_modo()
		get_viewport().set_input_as_handled()
