extends CanvasLayer

var cena_origem: Node
var modo_consulta: bool = false
var fotografia: itemData
var verso: bool = false
var calendario: bool = false
@onready var painel: Control = $Painel

func _ready() -> void:
	hide()
	$Painel/Fechar.pressed.connect(fechar)
	$Fundo.gui_input.connect(_clicar_fora)
	get_viewport().size_changed.connect(_ajustar_janela)

func abrir(item: itemData) -> void:
	cena_origem = get_tree().current_scene
	calendario = false
	fotografia = item if not item.nome_fotografado.is_empty() else null
	verso = false
	modo_consulta = fotografia == null and cena_origem != null and cena_origem.scene_file_path == "res://scenes/fase1/zoom_tele.tscn"
	var textura: Texture2D = item.ativo_icon if item.ativo_icon != null else item.icon
	var imagem: Image = textura.get_image()
	var recorte := AtlasTexture.new()
	recorte.atlas = textura
	recorte.region = imagem.get_used_rect()
	$Painel/Papel.texture = recorte
	$Painel/Papel.modulate = Color.WHITE
	$Painel/Papel.offset_bottom = -100.0 if fotografia != null else -28.0
	$Painel/Identidade.text = item.nome_fotografado
	$Painel/Identidade.visible = fotografia != null
	$Painel/Virar.hide()
	$Painel/Virar.text = "Virar foto"
	$Painel/Verso.hide()
	$Painel/CalendarioTexto.hide()
	$Painel/Papel.show()
	$Fundo.mouse_filter = Control.MOUSE_FILTER_IGNORE if modo_consulta else Control.MOUSE_FILTER_STOP
	$Fundo.color.a = 0.0 if modo_consulta else 0.45
	_ajustar_janela()
	show()
	if fotografia != null:
		Progresso.salvar("foto_examinada_" + fotografia.resource_path.get_file().get_basename(), true)

func abrir_calendario(textura: Texture2D) -> void:
	cena_origem = get_tree().current_scene
	fotografia = null
	calendario = true
	modo_consulta = false
	$Painel/Papel.texture = textura
	$Painel/Papel.offset_bottom = -28.0
	$Painel/Papel.modulate = Color(1, 1, 1, 0.12)
	$Painel/Papel.show()
	$Painel/Identidade.hide()
	$Painel/Virar.hide()
	$Painel/Verso.hide()
	$Painel/CalendarioTexto.show()
	$Fundo.mouse_filter = Control.MOUSE_FILTER_STOP
	$Fundo.color.a = 0.45
	_ajustar_janela()
	show()
	Progresso.salvar("calendario_examinado", true)

func fechar() -> void:
	hide()
	$Painel/Papel.texture = null
	fotografia = null

func bloqueia_interacao() -> bool:
	return visible and (not modo_consulta or painel.get_global_rect().has_point(painel.get_global_mouse_position()))

func _ajustar_janela() -> void:
	var tela: Vector2 = get_viewport().get_visible_rect().size
	var largura: float = minf(500.0, tela.x * (0.27 if modo_consulta else 0.48))
	painel.size = Vector2(largura, minf(largura * 0.85, tela.y * 0.7))
	if fotografia != null or calendario:
		painel.size = Vector2(largura, minf(largura * 1.15, tela.y * 0.88))
	$Painel/CalendarioTexto.add_theme_font_size_override("font_size", int(clampf((painel.size.y - 95.0) / 14.0, 14.0, 24.0)))
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
