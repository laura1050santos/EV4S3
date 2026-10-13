extends Control

@onready var status: Label = $Status
@onready var boas_vindas: Label = $BoasVindas
@onready var progresso: ProgressBar = $Progresso
@onready var logo: Sprite2D = $Logo

var executando := false

func iniciar() -> void:
	if executando:
		return

	executando = true
	z_index = 100
	show()
	move_to_front()

	status.show()
	boas_vindas.hide()
	progresso.hide()
	logo.hide()

	await _animacao_ligando()
	await _boas_vindas()
	await _carregar()

	_finalizar_boot()

func _animacao_ligando() -> void:
	status.text = "Ligando."
	await get_tree().create_timer(0.8).timeout
	status.text = "Ligando.."
	await get_tree().create_timer(1).timeout
	status.text = "Ligando..."
	await get_tree().create_timer(1.2).timeout

func _boas_vindas() -> void:
	status.hide()
	logo.show()
	boas_vindas.text = "Boas-vindas"
	boas_vindas.show()
	await get_tree().create_timer(1.2).timeout

func _carregar() -> void:
	progresso.value = 0
	progresso.show()

	var tween = create_tween()
	tween.tween_property(progresso, "value", 100.0, 2.0)
	await tween.finished

func _finalizar_boot() -> void:
	GlobalSingleton.concluir_fase(1)
	TransicaoFase.show_phase_complete(
		"res://scenes/telaInicial/selecao_fases.tscn"
	)
