class_name Config


static func criar_tabelas():
	var sql_config = """
	CREATE TABLE IF NOT EXISTS config  (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		config TEXT NOT NULL UNIQUE,
		valor TEXT
	);
	"""

	Database.db.query(sql_config)
	
static func salvar_configuracao( config, valor):
	var sql = """
	INSERT INTO Config (config, valor)
	VALUES (?, ?)
	ON CONFLICT(config)
	DO UPDATE SET valor = excluded.valor;
	"""
	
	Database.db.query_with_bindings(sql, [
		config,
		valor
	])
	
	print("Cena salva: ", config)


static func get_config( config):
	var sql = """
	SELECT id, config, valor
	FROM Config
	WHERE config = ?;
	"""
	
	Database.db.query_with_bindings(sql, [config])
	
	var resultado = Database.db.get_query_result()
	
	if resultado.size() > 0:
		return resultado
	
	return null


static func delete_config( config):
	var sql = """
	DELETE FROM Config
	WHERE config = ?;
	"""
	
	Database.db.query_with_bindings(sql, [config])
	
	print("Cena deletada: ", config)
