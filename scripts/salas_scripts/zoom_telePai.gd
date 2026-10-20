extends "res://scripts/salas_scripts/salas_manager.gd"

const RECURSO_FIO := "res://recursos/FioDecodificador.tres"
const ESTACAO_FIO := "telegrafo_decodificador"
const MORSE := {
	".-": "A", "-...": "B", "-.-.": "C", "-..": "D", ".": "E", "..-.": "F",
	"--.": "G", "....": "H", "..": "I", ".---": "J", "-.-": "K", ".-..": "L",
	"--": "M", "-.": "N", "---": "O", ".--.": "P", "--.-": "Q", ".-.": "R",
	"...": "S", "-": "T", "..-": "U", "...-": "V", ".--": "W", "-..-": "X",
	"-.--": "Y", "--..": "Z", "-----": "0", ".----": "1", "..---": "2",
	"...--": "3", "....-": "4", ".....": "5", "-....": "6", "--...": "7",
	"---..": "8", "----.": "9"
}
var fio_instalado: bool = false
var codigo_atual: String = ""
var mensagem: String = ""
@onready var label: Label = $Label

func _ready() -> void:
	GlobalSingleton.registrar_cena_atual(scene_file_path)
	iniciar_itens_cena(name, Objetos.get_objetos_cena(name))
	fio_instalado = Objetos.get_recurso_em_estacao(ESTACAO_FIO) == RECURSO_FIO
	_atualizar_visor()

func receber_item_drop(item: itemData, slot: Area2D) -> bool:
	if fio_instalado or item == null or item.resource_path != RECURSO_FIO or slot != $SlotFio:
		return false
	Objetos.guardar_em_estacao(RECURSO_FIO, ESTACAO_FIO)
	fio_instalado = true
	_atualizar_visor()
	return true

func _on_ponto_pressed() -> void:
	_adicionar_sinal(".")

func _on_traco_pressed() -> void:
	_adicionar_sinal("-")

func _adicionar_sinal(sinal: String) -> void:
	if mensagem.length() >= 4 or codigo_atual.length() >= 5:
		return
	codigo_atual += sinal
	_atualizar_visor()

func _on_confirmar_pressed() -> void:
	if mensagem.length() >= 4 or not MORSE.has(codigo_atual):
		return
	mensagem += str(MORSE[codigo_atual])
	codigo_atual = ""
	_atualizar_visor()

func _on_apagar_pressed() -> void:
	if not codigo_atual.is_empty():
		codigo_atual = codigo_atual.left(-1)
	elif not mensagem.is_empty():
		mensagem = mensagem.left(-1)
	_atualizar_visor()

func _on_reset_pressed() -> void:
	codigo_atual = ""
	mensagem = ""
	_atualizar_visor()

func _atualizar_visor() -> void:
	$FioInstalado.visible = fio_instalado
	label.visible = fio_instalado
	$MorseAtual.text = "Morse: " + (codigo_atual if not codigo_atual.is_empty() else "—")
	$Status.text = "Conecte o fio ao decodificador." if not fio_instalado else "Confirme cada caractere. Máximo: 4."
	if fio_instalado:
		var previa: String = str(MORSE.get(codigo_atual, "?")) if not codigo_atual.is_empty() else ""
		if not codigo_atual.is_empty() and not MORSE.has(codigo_atual):
			$Status.text = "Código Morse inválido. Apague para corrigir."
		label.text = mensagem + (" [" + previa + "]" if not previa.is_empty() else "")
		if mensagem.is_empty() and codigo_atual.is_empty():
			label.text = "_ _ _ _"
	$ponto.disabled = mensagem.length() >= 4 or codigo_atual.length() >= 5
	$traco.disabled = $ponto.disabled
	$Confirmar.disabled = mensagem.length() >= 4 or not MORSE.has(codigo_atual)
