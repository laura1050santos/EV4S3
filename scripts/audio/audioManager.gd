extends Node

const SomCompativel = preload("res://scripts/audio/audio_compativel.gd")
@onready var musica_fase_1: AudioStreamPlayer = $fase1
@onready var musica_fase_2: AudioStreamPlayer = $fase2
@onready var som__lanterna: AudioStreamPlayer2D = $"som_ Lanterna"
var faixa_atual: AudioStreamPlayer

func _ready() -> void:
	for player in [musica_fase_1, musica_fase_2, $fase3]:
		SomCompativel.configurar(player, true)

func _process(_delta: float) -> void:
	var cena := get_tree().current_scene
	# During change_scene_to_file the tree has no current scene for one frame.
	if cena == null:
		return
	var caminho: String = cena.scene_file_path
	var em_jogo: bool = cena is Node2D and (caminho.begins_with("res://scenes/fase1/") or caminho.begins_with("res://scenes/fase2/") or caminho.begins_with("res://scenes/fase3/") or caminho.begins_with("res://scenes/fase4/"))
	if not em_jogo:
		_definir_faixa(null)
	elif GlobalSingleton.fase_liberada == 1:
		_definir_faixa(musica_fase_1)
	else:
		_definir_faixa(musica_fase_2)

func _definir_faixa(alvo: AudioStreamPlayer) -> void:
	if alvo == faixa_atual:
		return
	for player in [musica_fase_1, musica_fase_2, $fase3]:
		player.stop()
	faixa_atual = alvo
	if faixa_atual != null:
		faixa_atual.play()

func tocar_musica_fase1() -> void:
	_definir_faixa(musica_fase_1)

func tocar_musica_fase2() -> void:
	_definir_faixa(musica_fase_2)

func tocar_som_lanterna() -> void:
	som__lanterna.play(0.2)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_IN and is_node_ready():
		_retomar_se_necessario.call_deferred()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		_retomar_se_necessario()

func _retomar_se_necessario() -> void:
	if faixa_atual != null and not faixa_atual.playing and not faixa_atual.stream_paused:
		faixa_atual.play()
