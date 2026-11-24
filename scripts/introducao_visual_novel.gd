extends Control

const CENA_JOGO := "res://scenes/fase1/ParedeNorte.tscn"
const CASA := preload("res://assets/visualnovel/cenario-casa-flashback.png")
const ESCADA := preload("res://assets/visualnovel/cenario-escada-flashback.png")
const PAREDE := preload("res://assets/visualnovel/cenario-parede-flashback.png")
const SomCompativel := preload("res://scripts/audio/audio_compativel.gd")

@onready var fundo: TextureRect = $Fundo/Cenario
@onready var personagem: ColorRect = $Personagem
@onready var caixa: Panel = $CaixaDialogo
@onready var nome: Label = $CaixaDialogo/Nome
@onready var fala: Label = $CaixaDialogo/Fala
@onready var avancar: Label = $CaixaDialogo/Avancar
@onready var ambiente: AudioStreamPlayer = $SomAmbiente
@onready var respiracao: AudioStreamPlayer = $SomRespiracao
@onready var escada: AudioStreamPlayer = $SomEscada
@onready var pancada: AudioStreamPlayer = $SomPancada

var indice := -1
var bloqueado := false
var eventos: Array[Dictionary] = []

func _ready() -> void:
	SomCompativel.configurar(ambiente, true)
	for efeito in [respiracao, escada, pancada]:
		SomCompativel.configurar(efeito, false)
	ambiente.play()
	_eventos_iniciais()
	_mostrar_proximo()

func _unhandled_input(event: InputEvent) -> void:
	if bloqueado:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_mostrar_proximo()
	elif event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
		_mostrar_proximo()

func _eventos_iniciais() -> void:
	eventos = [
		_narracao("Primeiro, o calor. Um ar tão pesado que não deixa o suor secar."),
		_narracao("Depois, o gosto de ferro na boca."),
		_narracao("Por último, a lembrança de que eu não deveria estar aqui."),
		_fala("Lilith", "Minha cabeça…", true, false, "respiracao"),
		_fala("Lilith", "Sem janelas. A porta... trancada, mas é claro.", true),
		_fala("Lilith", "Distintivo, arma, celular. Tudo sumiu. Quem fez isso sabia o que estava fazendo.", true),
		_fala("Lilith", "Mas isso não levaram. Meu precioso gravador.", true),
		_fala("Lilith", "Registro pessoal da Investigadora Lilith Quill. Se alguém estiver ouvindo isso, eu provavelmente não estou bem.", true),
		_fala("Lilith", "Há três semanas, começaram a aparecer os corpos. Cada vítima era da mesma família. Cada morte era diferente, e todas eram bizarras demais para serem acaso.", true),
		_fala("Lilith", "Nada de arrombamento. Nada de pistas óbvias. Só um padrão: o assassino fazia questão de ser entendido. Ainda não sabemos o motivo.", true),
		_fala("Lilith", "Segui os registros, os nomes, as certidões. Tudo levava ao mesmo sobrenome.", true),
		_fala("Lilith", "Lin'Barde.", true, true),
		_fala("Lilith", "A última coisa de que me lembro é da casa deles, vazia.", true),
		_cenario(CASA),
		_fala("Lilith", "Entrei sozinha. Foi burrice, eu sei. Mas eu estava curiosa.", false),
		_cenario(ESCADA),
		_fala("Lilith", "Havia uma luz acesa no andar de cima. Subi.", false),
		_cenario(PAREDE, "escada"),
		_fala("Lilith", "Depois, encontrei algo escrito na parede em alguma criptografia. Eu estava pensando em qual tipo seria, mas aí…", false),
		_flash_preto(),
		_fala("Lilith", "E agora estou aqui. Ele não me matou. Se quisesse, já teria feito.", true),
		_fala("Lilith", "Isso significa que quer algo de mim. Algo nesse lugar pode ser a chave para entender tudo.", true),
		_fala("Lilith", "Eu sou policial. Foi isso que me trouxe até aqui, e é isso que vai me tirar daqui.", true),
		_fala("Lilith", "Vamos ver o que os Lin'Barde esconderam.", true),
	]

func _narracao(texto: String) -> Dictionary:
	return {"tipo": "fala", "nome": "???", "texto": texto, "personagem": false}

func _fala(quem: String, texto: String, mostrar_personagem: bool, destaque := false, som := "") -> Dictionary:
	return {"tipo": "fala", "nome": quem, "texto": texto, "personagem": mostrar_personagem, "destaque": destaque, "som": som}

func _cenario(textura: Texture2D, som_antes := "") -> Dictionary:
	return {"tipo": "cenario", "textura": textura, "som_antes": som_antes}

func _flash_preto() -> Dictionary:
	return {"tipo": "flash"}

func _mostrar_proximo() -> void:
	indice += 1
	if indice >= eventos.size():
		_iniciar_jogo()
		return
	var evento := eventos[indice]
	match str(evento["tipo"]):
		"fala":
			_aplicar_fala(evento)
		"cenario":
			await _ocultar_dialogo()
			await _tocar_efeito_ate_terminar(str(evento.get("som_antes", "")))
			await _trocar_cenario(evento["textura"])
			_mostrar_proximo()
		"flash":
			await _ocultar_dialogo()
			await _flash_e_retorno()
			_mostrar_proximo()

func _ocultar_dialogo() -> void:
	if not caixa.visible:
		return
	bloqueado = true
	var tween := create_tween()
	tween.tween_property(caixa, "modulate:a", 0.0, 0.2)
	await tween.finished
	caixa.hide()
	caixa.modulate.a = 1.0
	bloqueado = false

func _aplicar_fala(evento: Dictionary) -> void:
	personagem.visible = bool(evento.get("personagem", false))
	nome.text = str(evento["nome"])
	fala.text = str(evento["texto"])
	if bool(evento.get("destaque", false)):
		fala.add_theme_font_size_override("font_size", 34)
		fala.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		fala.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	else:
		fala.add_theme_font_size_override("font_size", 23)
		fala.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		fala.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	caixa.show()
	if str(evento.get("som", "")) == "respiracao":
		respiracao.play()

func _tocar_efeito_ate_terminar(nome_efeito: String) -> void:
	var player: AudioStreamPlayer = null
	if nome_efeito == "escada":
		player = escada
	if player == null:
		return
	player.play()
	await player.finished

func _trocar_cenario(textura: Texture2D) -> void:
	bloqueado = true
	var tween := create_tween()
	tween.tween_property(fundo, "modulate:a", 0.0, 0.2)
	await tween.finished
	fundo.texture = textura
	fundo.show()
	personagem.hide()
	var entrada := create_tween()
	entrada.tween_property(fundo, "modulate:a", 1.0, 0.35)
	await entrada.finished
	bloqueado = false

func _flash_e_retorno() -> void:
	bloqueado = true
	var flash := $Flash
	flash.show()
	flash.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(flash, "modulate:a", 1.0, 0.08)
	await tween.finished
	# A pancada acontece com a tela já preta; só então Lilith retorna ao presente.
	pancada.play()
	await pancada.finished
	fundo.hide()
	personagem.show()
	var retorno := create_tween()
	retorno.tween_property(flash, "modulate:a", 0.0, 0.65)
	await retorno.finished
	flash.hide()
	bloqueado = false

func _iniciar_jogo() -> void:
	bloqueado = true
	ambiente.stop()
	respiracao.stop()
	caixa.hide()
	personagem.hide()
	fundo.hide()
	GlobalSingleton.ultima_cena = CENA_JOGO
	GlobalSingleton.ultima_cena_por_fase[1] = CENA_JOGO
	SaveManager.salvar()
	# A seleção de fases normalmente mostra este CanvasLayer. Como a introdução
	# vai direto para o quarto, precisamos restaurá-lo antes da troca de cena.
	# A camada global permanece entre cenas e revela o quarto lentamente.
	TransicaoFase.transicionar_para_cena(CENA_JOGO, 0.7, 1.6, 0.75, true)
