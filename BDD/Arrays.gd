class_name Arrays
var db = Database.db

# Called when the node enters the scene tree for the first time.

static func criar_tabela(db):

	var sql_arrays = """
	CREATE TABLE IF NOT EXISTS Arrays (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		nome TEXT NOT NULL UNIQUE,
		dados TEXT
	);
	"""
	db.query(sql_arrays)

static func salvar_arrays(db, nome, dados):
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
	
static func get_array( db, nome, dados):
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
	
static func delete_array(db, nome,dados):
	var sql = """
	DELETE INTO Arrays (nome, dados)
	VALUES (?, ?)
	ON CONFLICT(nome)
	DO UPDATE SET dados = excluded.dados;
	"""
	db.query_with_bindings(sql, [
		nome,
		dados
	])
	print("Array salvo:", nome)
	
