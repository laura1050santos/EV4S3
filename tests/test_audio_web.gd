extends SceneTree

var verificacoes: int = 0
var falhas: int = 0

func _initialize() -> void:
	_run.call_deferred()

func conferir(valor: bool, descricao: String) -> void:
	verificacoes += 1
	if not valor:
		falhas += 1
		push_error(descricao)

func _run() -> void:
	await process_frame
	await process_frame
	var banco = root.get_node("Database").db
	var progresso = load("res://BDD/Progresso.gd")
	var objetos = load("res://BDD/Objetos.gd")
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	var antes = banco.get_query_result().duplicate(true)
	banco.query("BEGIN TRANSACTION;")
	var global = root.get_node("GlobalSingleton")
	global.fase_liberada = 1
	global.fases_concluidas = [true, false, false, false]
	global.dica_inicio_fase1_exibida = true
	var evento = global.get_node("EventoPortaFase2")
	evento.set_process(false)
	var entrada := Node2D.new()
	root.add_child(entrada)
	current_scene = entrada
	var sala = load("res://scenes/fase1/ParedeLeste.tscn").instantiate()
	root.add_child(sala)
	current_scene = sala
	var audio = root.get_node("AudioManager")
	audio._process(0.0)
	conferir(audio.musica_fase_1.playing and audio.musica_fase_1.stream.loop, "Ambiente inicia e tem loop no recurso MP3")
	audio.musica_fase_1.play(audio.musica_fase_1.stream.get_length() - 0.05)
	await create_timer(0.25).timeout
	conferir(audio.musica_fase_1.playing, "Ambiente continua após o fim do arquivo")
	global.fase_liberada = 2
	audio._process(0.0)
	conferir(not audio.musica_fase_1.playing and audio.musica_fase_2.playing, "Troca para som do PC sem sobrepor ambiente")
	audio.musica_fase_2.play(audio.musica_fase_2.stream.get_length() - 0.05)
	await create_timer(0.25).timeout
	conferir(audio.musica_fase_2.playing and audio.musica_fase_2.stream.loop, "Som do PC continua após o fim do arquivo")
	var posicao: float = audio.musica_fase_2.get_playback_position()
	audio._process(0.0)
	conferir(audio.musica_fase_2.get_playback_position() >= posicao, "Mesmo cenário não reinicia a faixa a cada frame")
	current_scene = null
	audio._process(0.0)
	conferir(audio.musica_fase_2.playing, "Troca de sala não interrompe nem reinicia a trilha")
	current_scene = sala
	global.fase_liberada = 3
	audio._process(0.0)
	conferir(audio.faixa_atual == audio.musica_fase_2 and not audio.get_node("fase3").playing, "Fase 3 mantém um único loop do PC")
	current_scene = entrada
	audio._process(0.0)
	conferir(not audio.musica_fase_1.playing and not audio.musica_fase_2.playing, "Fora do jogo para a trilha")
	current_scene = sala
	global.fase_liberada = 2
	for chave in ["toc_porta_fase2_exibido", "porta_com_chave_vista"]:
		progresso.salvar(chave, false)
	evento._suspender()
	evento.executado = false
	evento._process(evento.atraso + 0.1)
	conferir(evento.SOM_PORTA.resource_path.ends_with("toc-toc.mp3") and evento.som.stream.get_length() > 0, "Toc-toc carrega pelo recurso importado exportável")
	conferir(evento.som.playing and not evento.som.stream.loop, "Toc-toc dispara na Fase 2")
	current_scene = entrada
	evento._process(0.1)
	conferir(not evento.som.playing and not bool(progresso.carregar("toc_porta_fase2_exibido", false)), "Menu suspende toc-toc sem marcar concluído")
	current_scene = sala
	evento._process(evento.atraso + 0.1)
	conferir(evento.som.playing, "Toc-toc pode retomar após voltar ao jogo")
	evento.registrar_porta_vista()
	evento._process(evento.atraso + 0.1)
	conferir(not evento.som.playing and bool(progresso.carregar("porta_com_chave_vista", false)), "Ver porta com chave encerra aviso")
	objetos.marcar_coletado_por_recurso("res://recursos/FitaCassete.tres")
	var toca = load("res://scenes/fase2/zoom_tocafitas.tscn").instantiate()
	root.add_child(toca)
	var estacao = toca.get_node("ZoomTocafitas/Estacao")
	estacao.colocar_item(load("res://recursos/FitaCassete.tres"))
	await create_timer(2.7).timeout
	conferir(estacao.som is AudioStreamPlayer and estacao.som.playback_type != AudioServer.PLAYBACK_TYPE_STREAM, "Fita não força streaming nem posicionamento 2D")
	conferir(estacao.som.playing and estacao.som.stream.loop, "Fita inicia com loop nativo")
	estacao.som.play(estacao.som.stream.get_length() - 0.05)
	await create_timer(0.25).timeout
	conferir(estacao.som.playing, "Fita atravessa o fim sem depender de finished")
	estacao._coletar()
	conferir(not estacao.som.playing, "Retirar fita para reprodução")
	conferir(ProjectSettings.get_setting("audio/general/default_playback_type.web") == AudioServer.PLAYBACK_TYPE_SAMPLE, "Web usa Sample")
	toca.queue_free()
	current_scene = entrada
	sala.queue_free()
	await process_frame
	banco.query("ROLLBACK;")
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	conferir(antes == banco.get_query_result(), "Progresso preservado")
	print("AUDIO_WEB: ", verificacoes, " verificações; ", falhas, " falhas.")
	quit(0 if falhas == 0 else 1)
