class_name Objetos

static func criar_tabela():
	var sql_objetos = """
	CREATE TABLE IF NOT EXISTS Objetos (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		nome TEXT NOT NULL UNIQUE,
		coordenada TEXT
	);
	"""
	Database.db.query(sql_objetos)
	
static func salvar_objetos( nome,coordenada):
	var sql = """
	INSERT INTO Objetos (nome,coordenada )
	VALUES (?, ?)
	ON CONFLICT(nome)
	DO UPDATE SET  = excluded.coordenada;
	"""
	
	Database.db.query_with_bindings(sql, [
		nome,
		coordenada
	])
	
	print("Objeto salvo: ", nome)

static func get_objetos():
	var sql = """
	SELECT id, objeto, 
	FROM Objetos;
	"""
	
	Database.db.query(sql)
	return Database.db.get_query_result()



static func get_nome(nome):
	var sql = """
	SELECT id, objeto, ,coordenada
	FROM Objetos
	WHERE objeto = ?;
	"""
	
	Database.db.query_with_bindings(sql, [nome])
	return Database.db.get_query_result()


static func delete_objeto(nome):
	var sql = """
	DELETE FROM Objetos
	WHERE nome = ?;
	"""
	Database.db.query_with_bindings(sql, [nome])
	print("Objeto deletado: ", nome)
