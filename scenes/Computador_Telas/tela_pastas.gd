extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Tela/P1.pressed.connect(_pessoal)
	$Tela/P2.pressed.connect(_tecnico)
	$Tela/Secreto.pressed.connect(_abrir_secreto)
	$Tela/Zip.pressed.connect(_abrir_zip)
	$Tela/Recuperados.pressed.connect(_abrir_recuperados)
	visibility_changed.connect(_atualizar_secreto)
	_atualizar_secreto()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _pessoal() -> void:
	$"../Pasta_Pessoal".abrir(self)
	
func _tecnico() -> void:
	$"../Pasta_Tecnico".abrir(self)

func _atualizar_secreto() -> void:
	var descoberto: bool = bool(Progresso.carregar("secreto_dat_desbloqueado", false))
	$Tela/Secreto.visible = descoberto
	$Tela/Nome_Secreto.visible = descoberto
	var recuperado: bool = bool(Progresso.carregar("registro_excluido_recuperado", false))
	$Tela/Recuperados.visible = recuperado
	$Tela/Nome_Recuperados.visible = recuperado

func _abrir_secreto() -> void:
	$"../Arquivo_DAT".abrir(self)

func _abrir_zip() -> void:
	$"../Arquivo_ZIP".abrir(self)

func _abrir_recuperados() -> void:
	$"../PastaRecuperados".abrir(self)
