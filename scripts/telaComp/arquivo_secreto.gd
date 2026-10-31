extends Control

const Cifra = preload("res://scripts/criptografia/vigenere.gd")
@export var documento: Resource = preload("res://recursos/documentos/secreto.tres")
var origem: Control
var decifrando: bool = false
var recuperado: bool = false
var operacao: int = 0
@onready var campo: LineEdit = $Coluna/Bloqueado/Chave
@onready var botao: Button = $Coluna/Bloqueado/Decifrar
@onready var status: Label = $Coluna/Status

func _ready() -> void:
	$Voltar.pressed.connect(fechar)
	botao.pressed.connect(decifrar)
	campo.text_submitted.connect(func(_texto: String): decifrar())
	visibility_changed.connect(_cancelar_se_oculto)

func abrir(pasta_origem: Control = null) -> bool:
	if not bool(Progresso.carregar("secreto_dat_desbloqueado", false)):
		return false
	operacao += 1
	origem = pasta_origem
	recuperado = false
	decifrando = false
	campo.clear()
	campo.editable = true
	botao.disabled = false
	$Coluna/Metadados.text = "ARQUIVO CRIPTOGRAFADO\nMétodo: " + documento.metodo + "\nReferência: " + documento.referencia
	$Coluna/Bloqueado/Previa.text = "PRÉVIA DO TEXTO CIFRADO\n\n" + documento.criptograma.left(180) + "…"
	$Coluna/Bloqueado.show()
	$Coluna/Mensagem.hide()
	status.text = "Insira a palavra-chave para recuperar a mensagem."
	if bool(Progresso.carregar("secreto_dat_decifrado", false)):
		var chave: String = str(Progresso.carregar("secreto_dat_chave", ""))
		var texto: String = Cifra.decifrar(documento.criptograma, chave)
		if _mensagem_valida(texto):
			_mostrar_mensagem(texto)
	if is_instance_valid(origem):
		origem.hide()
	show()
	if not recuperado:
		campo.grab_focus()
	return true

func decifrar() -> void:
	if decifrando or recuperado:
		return
	if campo.text.strip_edges().is_empty():
		status.text = "Preencha a palavra-chave."
		return
	if not Cifra.chave_valida(campo.text):
		status.text = "Use apenas letras na palavra-chave."
		return
	var texto: String = Cifra.decifrar(documento.criptograma, campo.text)
	if not _mensagem_valida(texto):
		status.text = "A chave não recuperou a mensagem. Revise as pistas."
		return
	decifrando = true
	campo.editable = false
	botao.disabled = true
	operacao += 1
	var tentativa: int = operacao
	status.text = "CHAVE ACEITA"
	await get_tree().create_timer(0.35).timeout
	if tentativa != operacao:
		return
	status.text = "DECIFRANDO…"
	await get_tree().create_timer(0.65).timeout
	if tentativa != operacao:
		return
	Progresso.salvar("secreto_dat_chave", Cifra.normalizar(campo.text.strip_edges()))
	Progresso.salvar("secreto_dat_decifrado", true)
	_mostrar_mensagem(texto)

func _mensagem_valida(texto: String) -> bool:
	return not texto.is_empty() and texto.sha256_text() == documento.hash_texto

func _mostrar_mensagem(texto: String) -> void:
	recuperado = true
	decifrando = false
	$Coluna/Metadados.text = "MENSAGEM RECUPERADA — " + str(documento.titulo)
	$Coluna/Bloqueado.hide()
	$Coluna/Mensagem.text = texto
	$Coluna/Mensagem.scroll_to_line(0)
	$Coluna/Mensagem.show()
	status.text = "Documento disponível para releitura."

func fechar() -> void:
	hide()
	if is_instance_valid(origem):
		origem.show()

func _cancelar_se_oculto() -> void:
	if not is_visible_in_tree():
		operacao += 1
		decifrando = false
