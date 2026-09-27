extends Node

var db: SQLite

func _ready() -> void:
	db = SQLite.new()
	db.path = "res://data.db"
	if not db.open_db():
		pass
	print("banco criado")
	criar_tabelas()
	novo_jogo()
	return
	
func novo_jogo():
	Objetos.iniciar_objetos()
	Arrays.iniciar_array()
	Enigmas.iniciar_enigmas()
	Cenarios.iniciar_cenarios()	
	Config.iniciar_config()
	
func criar_tabelas():
	Cenarios.criar_tabela()
	Objetos.criar_tabela()
	Enigmas.criar_tabela()
	Arrays.criar_tabela()
	Config.criar_tabelas()


	var sql_enigmas = """
	CREATE TABLE IF NOT EXISTS Enigmas (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		nome TEXT NOT NULL UNIQUE,
		resolvido INTEGER NOT NULL DEFAULT 0
	);
	"""

	db.query(sql_enigmas)


	var sql_objetos = """
	CREATE TABLE IF NOT EXISTS Objetos (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		Nome TEXT NOT NULL UNIQUE,
		estado INTEGER NOT NULL DEFAULT 0
	);
	"""

	db.query(sql_objetos)
