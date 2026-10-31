extends Control

@export var senha: String = "24091998"
@export var imagem: Texture2D
var origem: Control
var desbloqueado: bool = false

func _ready() -> void:
	$Voltar.pressed.connect(fechar)
	$Bloqueado/Abrir.pressed.connect(tentar_abrir)
	$Bloqueado/Senha.text_submitted.connect(func(_texto: String): tentar_abrir())
	$Conteudo/Imagem.pressed.connect(visualizar_imagem)

func abrir(pasta_origem: Control = null) -> void:
	origem = pasta_origem
	$VisualizadorArquivo.hide()
	$Bloqueado/Senha.clear()
	desbloqueado = bool(Progresso.carregar("zip_aberto", false))
	_atualizar()
	if is_instance_valid(origem):
		origem.hide()
	show()
	if not desbloqueado:
		$Bloqueado/Senha.grab_focus()
	else:
		$Conteudo/Imagem.grab_focus()

func tentar_abrir() -> void:
	if desbloqueado:
		return
	var tentativa: String = $Bloqueado/Senha.text.strip_edges()
	if tentativa.is_empty():
		$Bloqueado/Feedback.text = "Digite a senha do arquivo."
		return
	if tentativa != senha:
		$Bloqueado/Feedback.text = "Senha incorreta. Verifique a mensagem recuperada."
		return
	desbloqueado = true
	Progresso.salvar("zip_aberto", true)
	_atualizar()

func visualizar_imagem() -> void:
	if desbloqueado:
		$VisualizadorArquivo.abrir("arquivo.zip → imagem.png", imagem)

func _atualizar() -> void:
	$Bloqueado.visible = not desbloqueado
	$Conteudo.visible = desbloqueado
	$Bloqueado/Feedback.text = "Este arquivo está protegido por senha."
	if desbloqueado:
		$Conteudo/Imagem.grab_focus()

func fechar() -> void:
	$VisualizadorArquivo.hide()
	hide()
	if is_instance_valid(origem):
		origem.show()
