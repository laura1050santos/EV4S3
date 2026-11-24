class_name AjudaContextual
extends RefCounted

const FONTE := preload("res://assets/Myfont-Regular.ttf")

static func exibir(pai: Control, identificador: String, titulo: String, texto: String) -> void:
	var nome_popup := "Ajuda_" + identificador
	if pai.get_node_or_null(nome_popup) != null:
		return

	var fundo := ColorRect.new()
	fundo.name = nome_popup
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fundo.color = Color(0.02, 0.02, 0.035, 0.82)
	fundo.mouse_filter = Control.MOUSE_FILTER_STOP
	fundo.z_index = 80
	pai.add_child(fundo)

	var painel := Panel.new()
	painel.set_anchors_preset(Control.PRESET_CENTER)
	painel.offset_left = -500.0
	painel.offset_top = -245.0
	painel.offset_right = 500.0
	painel.offset_bottom = 245.0
	painel.mouse_filter = Control.MOUSE_FILTER_STOP
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color("fffdf5")
	estilo.border_color = Color("9a3838")
	estilo.set_border_width_all(5)
	estilo.set_corner_radius_all(16)
	painel.add_theme_stylebox_override("panel", estilo)
	fundo.add_child(painel)

	var cabecalho := Label.new()
	cabecalho.position = Vector2(42, 34)
	cabecalho.size = Vector2(916, 52)
	cabecalho.text = titulo
	cabecalho.add_theme_font_override("font", FONTE)
	cabecalho.add_theme_font_size_override("font_size", 32)
	cabecalho.add_theme_color_override("font_color", Color("8f3139"))
	painel.add_child(cabecalho)

	var corpo := Label.new()
	corpo.position = Vector2(44, 102)
	corpo.size = Vector2(912, 250)
	corpo.text = texto
	corpo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	corpo.add_theme_font_override("font", FONTE)
	corpo.add_theme_font_size_override("font_size", 24)
	corpo.add_theme_color_override("font_color", Color("24212a"))
	painel.add_child(corpo)

	var fechar := Button.new()
	fechar.position = Vector2(670, 385)
	fechar.size = Vector2(286, 70)
	fechar.text = "Entendi"
	fechar.add_theme_font_override("font", FONTE)
	fechar.add_theme_font_size_override("font_size", 25)
	fechar.pressed.connect(fundo.queue_free)
	painel.add_child(fechar)
