extends Control

signal finalizado

@onready var painel_novos: Control = $PainelNovos
@onready var painel_erro: Control = $PainelErro
@onready var botao_visualizar: Button = $PainelNovos/BotaoVisualizar
@onready var botao_ok: Button = $PainelErro/BotaoOk

func _ready() -> void:
	hide()
	painel_novos.hide()
	painel_erro.hide()
	botao_visualizar.pressed.connect(_visualizar_arquivo)
	botao_ok.pressed.connect(_finalizar)

func iniciar() -> void:
	show()
	painel_erro.hide()
	painel_novos.show()

func _visualizar_arquivo() -> void:
	painel_novos.hide()
	painel_erro.show()

func _finalizar() -> void:
	hide()
	finalizado.emit()
