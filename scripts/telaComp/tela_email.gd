extends Control  # TelaEmails

signal todos_classificados  # quem estiver escutando usa isso pra avançar de fase

@export var emails: Array[email_data] = []  # arraste os .tres aqui no Inspector

@onready var lista_inbox: VBoxContainer = $ListaEmails
@onready var visualizador: Control = $VisualizadorEmail
@onready var imagem_email: TextureRect = $VisualizadorEmail/ImagemEmail
@onready var botao_phishing: Button = $VisualizadorEmail/BotaoPhishing
@onready var botao_legitimo: Button = $VisualizadorEmail/BotaoLegitimo
@onready var enviados: Button = $VisualizadorEmail/Enviados
@onready var label_feedback: Label = $VisualizadorEmail/LabelFeedback

var item_cena = preload("res://scenes/Computador_Telas/item_email.tscn")
var email_atual: email_data = null
var itens_por_email: Dictionary = {}       # email_data -> Button da lista
var ja_classificados: Array[email_data] = []

func _ready():
	visualizador.hide()
	botao_phishing.pressed.connect(func(): responder(true))
	botao_legitimo.pressed.connect(func(): responder(false))

	for email in emails:
		var item = item_cena.instantiate()
		item.get_node("Label").text = email.titulo_na_caixa
		item.pressed.connect(func(): abrir_email(email))
		lista_inbox.add_child(item)
		itens_por_email[email] = item

func abrir_email(email: email_data):
	email_atual = email
	imagem_email.texture = email.imagem
	label_feedback.text = ""
	visualizador.show()
	lista_inbox.hide()
	
func voltar():
	visualizador.hide()
	lista_inbox.show()

func responder(marcou_como_phishing: bool):
	if email_atual == null:
		return

	var acertou = marcou_como_phishing == email_atual.eh_phishing

	if acertou:
		label_feedback.text = "Classificado corretamente."
		label_feedback.modulate = Color.GREEN
		marcar_como_resolvido(email_atual)

		if email_atual not in ja_classificados:
			ja_classificados.append(email_atual)

		verificar_conclusao()
	else:
		label_feedback.text = "Hmm, algo não bate. Olhe de novo."
		label_feedback.modulate = Color.RED

func marcar_como_resolvido(email: email_data):
	var item: Button = itens_por_email[email]
	item.modulate = Color(0.5, 0.5, 0.5)
	item.disabled = true  # opcional: impede clicar de novo

func verificar_conclusao():
	if ja_classificados.size() == emails.size():
		travar_tela()
		todos_classificados.emit()

func travar_tela():
	mouse_filter = Control.MOUSE_FILTER_STOP  # bloqueia qualquer clique na tela
