extends Node

@export var atraso: float = 3.0
@export var volume: float = -14.0
var tempo: float = 0.0
var executado: bool = false
var ultima_cena: String = ""
var som: AudioStreamPlayer

func _ready() -> void:
	som = AudioStreamPlayer.new()
	var audio := AudioStreamMP3.new()
	audio.data = FileAccess.get_file_as_bytes("res://assets/Sons/toc-toc.mp3")
	audio.loop = false
	som.stream = audio
	som.volume_db = volume
	add_child(som)
	som.finished.connect(func(): Progresso.salvar("toc_porta_fase2_exibido", true))

func _process(delta: float) -> void:
	if TransicaoFase.em_transicao:
		_suspender()
		return
	if GlobalSingleton.fase_liberada != 2 or not GlobalSingleton.fases_concluidas[0]:
		_suspender()
		executado = false
		return
	var cena = get_tree().current_scene
	if cena == null:
		_suspender()
		return
	var caminho: String = cena.scene_file_path
	var em_jogo: bool = caminho.begins_with("res://scenes/fase1/") or caminho.begins_with("res://scenes/fase2/")
	if not em_jogo or caminho == "res://scenes/fase1/sub_viewport_container.tscn":
		_suspender()
		return
	if caminho != ultima_cena:
		ultima_cena = caminho
		executado = som.playing or bool(Progresso.carregar("toc_porta_fase2_exibido", false))
	if executado:
		return
	tempo += delta
	if tempo >= atraso:
		executado = true
		som.play()

func _suspender() -> void:
	tempo = 0.0
	ultima_cena = ""
	if som.playing:
		som.stop()

func registrar_porta_vista() -> void:
	if GlobalSingleton.fase_liberada != 2:
		return
	Progresso.salvar("porta_com_chave_vista", true)
	Progresso.salvar("toc_porta_fase2_exibido", true)
	_suspender()
	executado = true
