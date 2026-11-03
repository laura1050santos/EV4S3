extends Control

signal fechado_apos_leitura
@export var documento: Resource = preload("res://recursos/documentos/registro_excluido.tres")
var origem: Control
var leitura_ativa: bool = false
var lido: bool = false

func _ready() -> void:
	$Voltar.pressed.connect(fechar)
	$Corpo/Texto.get_v_scroll_bar().value_changed.connect(func(_valor: float): _verificar_leitura())

func abrir(pasta_origem: Control = null) -> bool:
	if not bool(Progresso.carregar("registro_excluido_recuperado", false)):
		return false
	origem = pasta_origem
	$Titulo.text = documento.titulo
	$Corpo/Texto.text = documento.texto
	$Corpo/Texto.scroll_to_line(0)
	leitura_ativa = true
	lido = bool(Progresso.carregar("registro_excluido_lido", false))
	if is_instance_valid(origem):
		origem.hide()
	show()
	return true

func _process(_delta: float) -> void:
	if leitura_ativa and is_visible_in_tree():
		_verificar_leitura()

func _verificar_leitura() -> void:
	if lido or not leitura_ativa or not is_visible_in_tree() or $Corpo/Texto.size.y <= 0:
		return
	var barra: VScrollBar = $Corpo/Texto.get_v_scroll_bar()
	var altura: float = $Corpo/Texto.get_content_height()
	var cabe_na_tela: bool = altura > 0 and altura <= $Corpo/Texto.size.y + 2
	var chegou_ao_fim: bool = barra.page > 0 and barra.max_value > barra.page and barra.value + barra.page >= barra.max_value - 2
	if cabe_na_tela or chegou_ao_fim:
		lido = true
		Progresso.salvar("registro_excluido_lido", true)

func fechar() -> void:
	var fechamento_valido: bool = leitura_ativa and is_visible_in_tree()
	_verificar_leitura()
	leitura_ativa = false
	hide()
	if is_instance_valid(origem):
		origem.show()
	if fechamento_valido and bool(Progresso.carregar("registro_excluido_lido", false)) and not bool(Progresso.carregar("mensageiro_concluido", false)):
		Progresso.salvar("mensageiro_pendente", true)
		fechado_apos_leitura.emit()
