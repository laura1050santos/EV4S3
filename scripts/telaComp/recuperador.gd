extends Control

const CARTAO := "res://recursos/Backup03.tres"
const LEITOR := "leitor_sd_pc"
var origem: Control
var recuperando: bool = false
var operacao: int = 0

func _ready() -> void:
	$Voltar.pressed.connect(fechar)
	$Corpo/Recuperar.pressed.connect(recuperar)
	$Corpo/AbrirRegistro.pressed.connect(abrir_registro)
	visibility_changed.connect(_cancelar_se_oculto)

func abrir(pasta_origem: Control = null) -> bool:
	if not bool(Progresso.carregar("zip_aberto", false)):
		return false
	origem = pasta_origem
	operacao += 1
	recuperando = false
	$Corpo/Progresso.value = 0
	_atualizar()
	if is_instance_valid(origem):
		origem.hide()
	show()
	return true

func cartao_conectado() -> bool:
	return Objetos.get_recurso_em_estacao(LEITOR) == CARTAO

func recuperar() -> void:
	if recuperando or not is_visible_in_tree():
		return
	if not bool(Progresso.carregar("zip_aberto", false)) or not cartao_conectado():
		_atualizar()
		return
	if bool(Progresso.carregar("registro_excluido_recuperado", false)):
		_atualizar()
		return
	recuperando = true
	operacao += 1
	var tentativa: int = operacao
	$Corpo/Recuperar.disabled = true
	for etapa in range(1, 4):
		$Corpo/Status.text = ["Lendo BACKUP-03…", "Localizando registro excluído…", "Reconstruindo registro_excluido.dat…"][etapa - 1]
		await get_tree().create_timer(0.4).timeout
		if tentativa != operacao:
			return
		if not cartao_conectado() or not bool(Progresso.carregar("zip_aberto", false)):
			recuperando = false
			_atualizar()
			return
		$Corpo/Progresso.value = etapa * 100.0 / 3.0
	Progresso.salvar("registro_excluido_recuperado", true)
	recuperando = false
	_atualizar()

func abrir_registro() -> void:
	if not recuperando and bool(Progresso.carregar("registro_excluido_recuperado", false)):
		$"../RegistroRecuperado".abrir(self)

func _atualizar() -> void:
	var recuperado: bool = bool(Progresso.carregar("registro_excluido_recuperado", false))
	var conectado: bool = cartao_conectado()
	$Corpo/Midia.text = "Mídia: BACKUP-03 conectado" if conectado else "Mídia: nenhum cartão detectado"
	$Corpo/Recuperar.disabled = recuperado or not conectado or not bool(Progresso.carregar("zip_aberto", false))
	$Corpo/AbrirRegistro.disabled = not recuperado
	if recuperado:
		$Corpo/Progresso.value = 100
		$Corpo/Status.text = "Registro recuperado. Salvo em Arquivos → Recuperados → registro_excluido.dat."
	else:
		$Corpo/Status.text = "Pronto para recuperar os dados do cartão." if conectado else "Encaixe BACKUP-03 no leitor do gabinete e reabra o recuperador."

func fechar() -> void:
	hide()
	if is_instance_valid(origem):
		origem.show()

func _cancelar_se_oculto() -> void:
	if not is_visible_in_tree():
		operacao += 1
		recuperando = false
