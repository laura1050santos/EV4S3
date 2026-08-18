extends CanvasLayer

@onready var fade_rect: ColorRect = $ColorRect
@onready var completed_label: Control = $Label

func _ready():
	layer = 128
	fade_rect.color = Color(0, 0, 0, 0)
	completed_label.modulate.a = 0
	completed_label.visible = false

# Chamar quando o objetivo da fase for concluído
func show_phase_complete(next_scene_path: String, hold_time: float = 1.5):
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
	
# ==== TESTE COM ENTER ====
#func _input(event):
	#if event.is_action_pressed("ui_accept"):  # tecla Enter/Espaço por padrão
		#show_phase_complete("res://scenes/phase_select/phase_select.tscn")
