extends Node

var db: SQLite

func _ready() -> void:
	db = SQLite.new()
	db.path = "res://data.db"
	if not db.open_db():
		print("Erro ao abrir banco de dados!")
		return
	criar_tabelas()
	
func salvar_config(nome, dado):

	# "config" e "valor" são os nomes das colunas da tabela
	var sql = """
	INSERT INTO config (config, valor)
	VALUES (?, ?)
	ON CONFLICT(config)
	DO UPDATE SET valor = excluded.valor;
	"""

	db.query_with_bindings(sql, [
		nome,
		dado
	])

	print("Configuração salva:", nome)


func salvar_arrays(nome, dados):
	var sql = """
	INSERT INTO Arrays (nome, dados)
	VALUES (?, ?)
	ON CONFLICT(nome)
	DO UPDATE SET dados = excluded.dados;
	"""
	db.query_with_bindings(sql, [
		nome,
		dados
	])
	print("Array salvo:", nome)


	
func criar_tabelas():
	# =========================================
	# ARRAYS
	# =========================================

	var sql_arrays = """
	CREATE TABLE IF NOT EXISTS Arrays (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		nome TEXT NOT NULL UNIQUE,
		dados TEXT
	);
	"""

	db.query(sql_arrays)


	# =========================================
	# CONFIG JOGO
	# =========================================

	var sql_config = """
	CREATE TABLE IF NOT EXISTS config  (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		config TEXT NOT NULL UNIQUE,
		valor TEXT
	);
	"""

	db.query(sql_config)


	# =========================================
	# CENARIOS
	# =========================================

	var sql_cenarios = """
	CREATE TABLE IF NOT EXISTS Cenarios (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		cena TEXT NOT NULL UNIQUE,
		sprite TEXT
	);
	"""

	db.query(sql_cenarios)


	# =========================================
	# ENIGMAS
	# =========================================

	var sql_enigmas = """
	CREATE TABLE IF NOT EXISTS Enigmas (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		nome TEXT NOT NULL UNIQUE,
		resolvido INTEGER NOT NULL DEFAULT 0
	);
	"""

	db.query(sql_enigmas)


	# =========================================
	# OBJETOS FIXOS
	# =========================================

	var sql_objetos = """
	CREATE TABLE IF NOT EXISTS Objetos (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		Nome TEXT NOT NULL UNIQUE,
		estado INTEGER NOT NULL DEFAULT 0
	);
	"""

	db.query(sql_objetos)

	print("Tabelas criadas/verificadas!")
