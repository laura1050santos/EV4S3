extends Node

var db: SQLite


func _ready() -> void:
	db = SQLite.new()
	db.path = "res://data.db"

	var sucesso = db.open_db()

	if not sucesso:
		print("Erro ao abrir o banco de dados.")
		return

	criar_tabelas()
	inicializar_dados()


func criar_tabelas() -> void:
	Cenarios.criar_tabela()
	Objetos.criar_tabela()
	Enigmas.criar_tabela()
	Arrays.criar_tabela()
	Config.criar_tabelas()

	# NOVO:
	Progresso.criar_tabela()


func inicializar_dados() -> void:
	Objetos.iniciar_objetos()
	Arrays.iniciar_array()
	Enigmas.iniciar_enigmas()
	Cenarios.iniciar_cenarios()
	Config.iniciar_config()


# =========================================================
# NOVO JOGO
# =========================================================

func novo_jogo() -> void:
	print("Resetando dados da partida...")


	# -----------------------------------------------------
	# PROGRESSO GERAL
	# -----------------------------------------------------

	Progresso.resetar()


	# -----------------------------------------------------
	# OBJETOS
	# -----------------------------------------------------

	Objetos.resetar()


	# -----------------------------------------------------
	# OUTRAS TABELAS DE PROGRESSO
	# -----------------------------------------------------

	db.query("DELETE FROM Arrays;")
	db.query("DELETE FROM Enigmas;")
	db.query("DELETE FROM Cenarios;")

	# -----------------------------------------------------
	# RECRIAR ESTADO INICIAL
	# -----------------------------------------------------

	Objetos.iniciar_objetos()
	Arrays.iniciar_array()
	Enigmas.iniciar_enigmas()
	Cenarios.iniciar_cenarios()

	print("Banco resetado para novo jogo.")
