class_name Arrays

# Called when the node enters the scene tree for the first time.

static func criar_tabela():

	var sql_arrays = """
	CREATE TABLE IF NOT EXISTS Arrays (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		nome TEXT NOT NULL UNIQUE,
		dados TEXT
	);
	"""
	Database.db.query(sql_arrays)

static func salvar_arrays (nome, dados):
	var dados_json = JSON.stringify(dados)

	var sql = """
	INSERT INTO Arrays (nome, dados)
	VALUES (?, ?)
	"""
	Database.db.query_with_bindings(sql, [
		nome,
		dados_json
	])
	print("Array salvo:", nome)

static func atualizar_array(nome, dados):
	var dados_json = JSON.stringify(dados)
	var sql = """
	UPDATE Arrays
	SET dados = ?
	WHERE nome = ?;
	"""
	Database.db.query_with_bindings(sql, [
		dados_json,
		nome
	])

	print("Array atualizado: ", nome)

static func get_array(nome):
	var sql = """
	SELECT id, nome, dados
	FROM Arrays
	WHERE nome = ?;
	"""
	Database.db.query_with_bindings(sql, [nome])
	
	var resultado = Database.db.get_query_result()
	
	if resultado.is_empty():
		return []
	var dados_json = resultado[0]["dados"]
	var json = JSON.parse_string(dados_json)
	if json == null:
		return []
	return json

static func delete_array(nome):
	var sql = """
	DELETE FROM Arrays
	WHERE nome = ?;
	"""
	Database.db.query_with_bindings(sql, [nome])
	
	print("Array deletado: ", nome)
	
static func iniciar_array():
	Objetos.get_objetos()
	salvar_arrays("itens_no_mundo","") 
	salvar_arrays("cenasVisitadas","")
	salvar_arrays("historico_cenas","")
