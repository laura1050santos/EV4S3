class_name Config
static func criar_tabelas():
	var sql_config = """
	CREATE TABLE IF NOT EXISTS Config  (
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
	"""
	Database.db.query_with_bindings(sql, [
		config,
		valor
	])
	
	print("Cena salva: ", config)

static func atualizar_configuracao(config: String, valor):
	var sql = """
	UPDATE Config
	SET valor = ?
	WHERE config = ?;
	"""
	Database.db.query_with_bindings(sql, [
		str(valor),
		config
	])
	print("Configuração atualizada: ", config, " = ", valor)


static func get_config( config):
	var sql = """
	SELECT id, config, valor
	FROM Config
	WHERE config = ?;
	"""
	Database.db.query_with_bindings(sql, [config])
	var resultado = Database.db.get_query_result()
	if resultado.size() > 0:
		return resultado[0]
	
	return null


static func delete_config( config):
	var sql = """
	DELETE FROM Config
	WHERE config = ?;
	"""
	Database.db.query_with_bindings(sql, [config])
	print("Cena deletada: ", config)

static func iniciar_config():
	if get_config("volume") == null:
		salvar_configuracao("volume", 40)
	if get_config("brilho") == null:
		salvar_configuracao("brilho", 1)
