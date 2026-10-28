extends CanvasLayer

var cena_origem: Node
var modo_consulta: bool = false
@onready var painel: Control = $Painel

func _ready() -> void:
	hide()
	$Painel/Fechar.pressed.connect(fechar)
	$Fundo.gui_input.connect(_clicar_fora)
	get_viewport().size_changed.connect(_ajustar_janela)

func abrir(item: itemData) -> void:
	cena_origem = get_tree().current_scene
	modo_consulta = cena_origem != null and cena_origem.scene_file_path == "res://scenes/fase1/zoom_tele.tscn"
	var textura: Texture2D = item.ativo_icon if item.ativo_icon != null else item.icon
	var imagem: Image = textura.get_image()
	var recorte := AtlasTexture.new()
	recorte.atlas = textura
	recorte.region = imagem.get_used_rect()
	$Painel/Papel.texture = recorte
	$Fundo.mouse_filter = Control.MOUSE_FILTER_IGNORE if modo_consulta else Control.MOUSE_FILTER_STOP
	$Fundo.color.a = 0.0 if modo_consulta else 0.45
	_ajustar_janela()
	show()

func fechar() -> void:
	hide()
	$Painel/Papel.texture = null

func bloqueia_interacao() -> bool:
	return visible and (not modo_consulta or painel.get_global_rect().has_point(painel.get_global_mouse_position()))

func _ajustar_janela() -> void:
	var tela: Vector2 = get_viewport().get_visible_rect().size
	var largura: float = minf(500.0, tela.x * (0.27 if modo_consulta else 0.48))
	painel.size = Vector2(largura, minf(largura * 0.85, tela.y * 0.7))
	painel.position = Vector2(tela.x * 0.025, (tela.y - painel.size.y) * 0.5) if modo_consulta else (tela - painel.size) * 0.5

func _clicar_fora(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		fechar()
		get_viewport().set_input_as_handled()

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		fechar()
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if visible and get_tree().current_scene != cena_origem:
		fechar()
