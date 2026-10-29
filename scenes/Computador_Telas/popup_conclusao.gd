extends Control

signal finalizado

@onready var painel_novos: Control = $PainelNovos
@onready var painel_erro: Control = $PainelErro
@onready var botao_visualizar: TextureButton = $PainelNovos/BotaoVisualizar
@onready var botao_ok: TextureButton = $PainelErro/BotaoOk

func _ready() -> void:
	hide()
	painel_novos.hide()
	painel_erro.hide()
	botao_visualizar.pressed.connect(_visualizar_arquivo)
	botao_ok.pressed.connect(_finalizar)
	for botao in [botao_visualizar, botao_ok]:
		var mascara := BitMap.new()
		mascara.create_from_image_alpha(botao.texture_normal.get_image(), 0.1)
		botao.texture_click_mask = mascara

func iniciar() -> void:
	show()
	painel_erro.hide()
	painel_novos.show()

func _visualizar_arquivo() -> void:
	if not visible or not painel_novos.visible:
		return
	painel_novos.hide()
	painel_erro.show()

func _finalizar() -> void:
	if not visible or not painel_erro.visible:
		return
	hide()
	finalizado.emit()
