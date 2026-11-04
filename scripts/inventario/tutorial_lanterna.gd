extends CanvasLayer

const FONTE = preload("res://assets/Myfont-Regular.ttf")
const PEGAR_MOUSE = preload("res://recursos/tutorial/pegar_mouse.tres")
const PEGAR_SETA = preload("res://recursos/tutorial/pegar_seta.tres")
const INVENTARIO_SETA = preload("res://recursos/tutorial/inventario_seta.tres")
const USAR_MOUSE = preload("res://recursos/tutorial/usar_mouse.tres")
const UTILIZADA := "tutorial_lanterna_utilizada"
const APRENDIDO := "tutorial_lanterna_modo_aprendido"
const ETAPA := "tutorial_lanterna_etapa"
const DICAS := {
	1: "Está muito escuro. Procure a lanterna.",
	2: "Arraste a lanterna do inventário para devolvê-la ao cenário.",
	3: "Clique com o botão direito para usar ou examinar objetos.",
	4: 'Pressione "F" para alternar o modo da lanterna'
}
var etapa: int = 0
var pendente: bool = false
var texto: Label
var animacao: Tween
var exibindo: bool = false
var guia: Control
var seta: TextureRect
var mouse: TextureRect
var movimento: Tween
var deslocamento_seta: float = 0.0
var chave_apresentacao: String = ""
var tipo_exibido: String = ""
var alvo_exibido := Vector2.ZERO
var alvo_desejado := Vector2.ZERO

func _ready() -> void:
	layer = 25
	var tela := Control.new()
	tela.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tela.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tela)
	texto = Label.new()
	tela.add_child(texto)
	texto.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	texto.offset_left = 190
	texto.offset_right = -190
	texto.offset_top = 24
	texto.offset_bottom = 100
	texto.text = 'Pressione "F" para alternar o modo da lanterna'
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texto.add_theme_font_override("font", FONTE)
	texto.add_theme_font_size_override("font_size", 22)
	texto.add_theme_color_override("font_shadow_color", Color.BLACK)
	texto.add_theme_constant_override("shadow_outline_size", 6)
	texto.modulate.a = 0
	guia = Control.new()
	guia.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tela.add_child(guia)
	seta = TextureRect.new()
	mouse = TextureRect.new()
	for imagem in [seta, mouse]:
		imagem.mouse_filter = Control.MOUSE_FILTER_IGNORE
		imagem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		imagem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		guia.add_child(imagem)
	guia.modulate.a = 0
	hide()
	restaurar.call_deferred()

func restaurar() -> void:
	var padrao: int = 0
	if bool(Progresso.carregar(APRENDIDO, false)):
		padrao = 5
	elif bool(Progresso.carregar(UTILIZADA, false)):
		padrao = 4
	elif bool(Progresso.carregar("tutorial_lanterna_coletada", false)):
		padrao = 2
	var salva: int = clampi(int(Progresso.carregar(ETAPA, padrao)), 0, 5)
	_aplicar_etapa(salva)

func iniciar() -> void:
	restaurar()
	if etapa == 0:
		_avancar_para(1)

func registrar_coleta() -> void:
	Progresso.salvar("tutorial_lanterna_coletada", true)
	restaurar()
	if etapa < 2:
		_avancar_para(2)

func registrar_devolucao() -> void:
	restaurar()
	if etapa < 3:
		_avancar_para(3)

func registrar_uso() -> void:
	Progresso.salvar(UTILIZADA, true)
	restaurar()
	if etapa < 4:
		_avancar_para(4)

func aprender_modo() -> void:
	Progresso.salvar(APRENDIDO, true)
	_avancar_para(5)

func _avancar_para(nova_etapa: int) -> void:
	Progresso.salvar(ETAPA, nova_etapa)
	_aplicar_etapa(nova_etapa)

func _aplicar_etapa(nova_etapa: int) -> void:
	etapa = nova_etapa
	pendente = DICAS.has(etapa)
	if not pendente and etapa == 5:
		_trocar_apresentacao("", "")
	elif not pendente:
		_ocultar()

func _process(_delta: float) -> void:
	if not pendente:
		return
	var cena := get_tree().current_scene
	var em_jogo: bool = cena != null and (cena.scene_file_path.begins_with("res://scenes/fase1/") or cena.scene_file_path.begins_with("res://scenes/fase2/") or cena.scene_file_path.begins_with("res://scenes/fase3/"))
	if not em_jogo:
		_ocultar()
	else:
		var dica: String = str(DICAS[etapa])
		var tipo: String = ""
		var lanterna := _lanterna_visual(cena)
		var slot := _slot_lanterna()
		if etapa == 1:
			if lanterna != null:
				dica += "\nClique com o botão esquerdo para pegar a lanterna."
				tipo = "pegar"
				alvo_desejado = lanterna.get_global_transform_with_canvas().origin
		elif etapa == 2 and slot != null:
			tipo = "inventario"
			var retangulo: Rect2 = slot.get_global_rect()
			alvo_desejado = Vector2(retangulo.position.x, retangulo.get_center().y)
		elif etapa == 3:
			if lanterna != null:
				tipo = "usar"
				alvo_desejado = lanterna.get_global_transform_with_canvas().origin
			elif slot != null:
				tipo = "usar_inventario"
				var retangulo: Rect2 = slot.get_global_rect()
				alvo_desejado = Vector2(retangulo.position.x, retangulo.get_center().y)
		if tipo == tipo_exibido:
			alvo_exibido = alvo_desejado
		_trocar_apresentacao(dica, tipo)
		_posicionar_guia()

func _lanterna_visual(cena: Node) -> Sprite2D:
	for visual in cena.find_children("*", "Sprite2D", true, false):
		var item = visual.get_meta("item_data", null)
		if item is Resource and item.resource_path == "res://recursos/lanterna.tres" and visual.is_visible_in_tree():
			return visual
	return null

func _slot_lanterna() -> Control:
	var slots := get_tree().root.get_node_or_null("Inventario/canvasLayer/inventory/GridContainer")
	if slots == null or not slots.is_visible_in_tree():
		return null
	for slot in slots.get_children():
		if slot.item != null and slot.item.resource_path == "res://recursos/lanterna.tres":
			return slot
	return null

func _trocar_apresentacao(novo_texto: String, tipo: String) -> void:
	var chave: String = novo_texto + "|" + tipo
	if chave == chave_apresentacao:
		return
	chave_apresentacao = chave
	if animacao != null:
		animacao.kill()
	animacao = create_tween()
	# A etapa anterior termina antes de a próxima entrar.
	if texto.modulate.a > 0.01 or guia.modulate.a > 0.01:
		animacao.tween_property(texto, "modulate:a", 0.0, 0.25)
		animacao.parallel().tween_property(guia, "modulate:a", 0.0, 0.25)
	animacao.tween_callback(_apresentar.bind(novo_texto, tipo))
	if not novo_texto.is_empty():
		animacao.tween_property(texto, "modulate:a", 1.0, 0.4)
		animacao.parallel().tween_property(guia, "modulate:a", 1.0, 0.4)

func _apresentar(novo_texto: String, tipo: String) -> void:
	texto.text = novo_texto
	tipo_exibido = tipo
	alvo_exibido = alvo_desejado
	exibindo = not novo_texto.is_empty()
	if not exibindo:
		if movimento != null:
			movimento.kill()
		hide()
		return
	show()
	seta.visible = tipo in ["pegar", "inventario"]
	mouse.visible = tipo in ["pegar", "usar", "usar_inventario"]
	seta.texture = PEGAR_SETA if tipo == "pegar" else INVENTARIO_SETA
	mouse.texture = PEGAR_MOUSE if tipo == "pegar" else USAR_MOUSE
	if movimento != null:
		movimento.kill()
	deslocamento_seta = 0.0
	if seta.visible:
		movimento = create_tween().set_loops()
		movimento.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		movimento.tween_property(self, "deslocamento_seta", 6.0, 0.55)
		movimento.tween_property(self, "deslocamento_seta", 0.0, 0.55)
	_posicionar_guia()

func _posicionar_guia() -> void:
	match tipo_exibido:
		"pegar":
			seta.size = Vector2(51, 67)
			seta.position = alvo_exibido + Vector2(-27, -80 + deslocamento_seta)
			mouse.size = Vector2(71, 107)
			mouse.position = alvo_exibido + Vector2(35, -150)
		"inventario":
			seta.size = Vector2(80, 58)
			seta.position = alvo_exibido + Vector2(-100 + deslocamento_seta, -29)
		"usar", "usar_inventario":
			mouse.size = Vector2(67, 100)
			mouse.position = alvo_exibido + (Vector2(-85, -50) if tipo_exibido == "usar_inventario" else Vector2(40, -100))

func _ocultar() -> void:
	if animacao != null:
		animacao.kill()
	if movimento != null:
		movimento.kill()
	chave_apresentacao = ""
	tipo_exibido = ""
	exibindo = false
	texto.modulate.a = 0
	guia.modulate.a = 0
	hide()
