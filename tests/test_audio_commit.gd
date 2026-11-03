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
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	var antes = banco.get_query_result().duplicate(true)
	banco.query("BEGIN TRANSACTION;")
	var progresso = load("res://BDD/Progresso.gd")
	var objetos = load("res://BDD/Objetos.gd")
	var global = root.get_node("GlobalSingleton")
	global.fase_liberada = 1
	global.roteador_coletado = false
	global.roteador_instalado = false
	progresso.salvar("mala_aberta", false)
	var entrada := Node2D.new()
	root.add_child(entrada)
	current_scene = entrada
	objetos.soltar_por_recurso("res://recursos/roteador.tres", Vector2(693, 471), "zoom mala")
	var mala = load("res://scenes/fase2/zoomMala.tscn").instantiate()
	root.add_child(mala)
	conferir(not mala._abrir_com_chave() and not mala.som_abrindo_mala.playing, "Fase 1 não abre mala nem toca chave")
	global.fase_liberada = 2
	conferir(mala.receber_item_drop(load("res://recursos/ChaveMala.tres"), mala.get_node("Area2D")), "Mala abre com chave arrastada")
	conferir(mala.som_abrindo_mala.playing, "Novo som da mala toca também por encaixe")
	conferir(mala.get_node("roteador").texture.resource_path == "res://assets/itens/roteadornamala.png", "Roteador na mala usa a arte em perspectiva")
	mala.queue_free()
	await process_frame
	objetos.marcar_coletado_por_recurso("res://recursos/FitaCassete.tres")
	var cena = load("res://scenes/fase2/zoom_tocafitas.tscn").instantiate()
	root.add_child(cena)
	var estacao = cena.get_node("ZoomTocafitas/Estacao")
	conferir(estacao.colocar_item(load("res://recursos/FitaCassete.tres")), "Fita encaixa")
	conferir(estacao.toca_fitas.playing and not estacao.som.playing, "Som de encaixe antecede a fita")
	estacao._coletar()
	await create_timer(2.7).timeout
	conferir(not estacao.som.playing and estacao.item_guardado == null, "Retirar fita cancela reprodução pendente")
	estacao.colocar_item(load("res://recursos/FitaCassete.tres"))
	await create_timer(2.7).timeout
	conferir(estacao.som.playing, "Fita toca após novo encaixe e espera")
	cena.queue_free()
	await process_frame
	var chao = load("res://scenes/fase1/cena_chao.tscn").instantiate()
	root.add_child(chao)
	var digito = chao.get_node("Sprite2D/PainelSenha/Digito1")
	digito.pressed.emit()
	conferir(digito.som_senha.playing, "Novo beep do painel do chão toca")
	chao.queue_free()
	await process_frame
	banco.query("ROLLBACK;")
	banco.query("SELECT * FROM Progresso ORDER BY chave;")
	conferir(antes == banco.get_query_result(), "Save preservado")
	print("AUDIO_COMMIT: ", verificacoes, " verificações; ", falhas, " falhas.")
	quit(0 if falhas == 0 else 1)
