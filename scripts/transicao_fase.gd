extends CanvasLayer
var em_transicao: bool = false

@onready var fade_rect: ColorRect = $ColorRect
@onready var completed_label: Control = $Label

func _ready():
	itemData.desativar_item_global(get_tree())
	layer = 128
	fade_rect.color = Color(0, 0, 0, 0)
	completed_label.modulate.a = 0
	completed_label.visible = false

# Chamar quando o objetivo da fase for concluído
func show_phase_complete(next_scene_path: String, hold_time: float = 1.5):
	em_transicao = true
	completed_label.visible = true

	var tween = create_tween()
	# Fade in do texto "Fase Concluída"
	tween.tween_property(completed_label, "modulate:a", 1.0, 0.5)
	# Segura na tela por um tempo
	tween.tween_interval(hold_time)
	# Fade out do texto
	tween.tween_property(completed_label, "modulate:a", 0.0, 0.4)

	tween.tween_callback(func():
		completed_label.visible = false
		_fade_to_scene(next_scene_path)
	)

func _fade_to_scene(next_scene_path: String):
	var tween = create_tween()
	# Fade OUT (escurece a tela)
	tween.tween_property(fade_rect, "color:a", 1.0, 0.6)
	tween.tween_callback(func():
		get_tree().change_scene_to_file(next_scene_path)
	)
	# Fade IN (direciona a seleção de fases)
	tween.tween_property(fade_rect, "color:a", 0.0, 0.6)
	tween.tween_callback(func(): em_transicao = false)


# Transição sem aviso de objetivo, usada pela abertura narrativa.
func transicionar_para_cena(next_scene_path: String, duracao_escurecer := 0.7, duracao_revelar := 1.6, pausa_escuro := 0.75, revelar_inventario := false) -> void:
	em_transicao = true
	var painel_inventario: CanvasItem = null
	if revelar_inventario:
		# CanvasLayer controla a visibilidade geral; o Panel é o elemento que
		# pode receber transparência durante a revelação da cena.
		var canvas_inventario := Inventario.get_node_or_null("canvasLayer") as CanvasLayer
		if canvas_inventario != null:
			canvas_inventario.show()
		painel_inventario = Inventario.get_node_or_null("canvasLayer/inventory") as CanvasItem
		if painel_inventario != null:
			painel_inventario.modulate.a = 0.0
			painel_inventario.show()
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, duracao_escurecer)
	tween.tween_interval(pausa_escuro)
	tween.tween_callback(func(): get_tree().change_scene_to_file(next_scene_path))
	tween.tween_property(fade_rect, "color:a", 0.0, duracao_revelar)
	if painel_inventario != null:
		tween.parallel().tween_property(painel_inventario, "modulate:a", 1.0, duracao_revelar)
	tween.tween_callback(func(): em_transicao = false)
	
# ==== TESTE COM ENTER ====
#func _input(event):
	#if event.is_action_pressed("ui_accept"):  # tecla Enter/Espaço por padrão
		#show_phase_complete("res://scenes/phase_select/phase_select.tscn")
