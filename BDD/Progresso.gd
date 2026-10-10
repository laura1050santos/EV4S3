class_name Progresso


static func criar_tabela() -> void:
	Database.db.query("""
	CREATE TABLE IF NOT EXISTS Progresso (
		chave TEXT PRIMARY KEY,
		valor TEXT
	);
	""")

static func salvar(chave: String, valor) -> void:
	var valor_json := JSON.stringify(valor)

	var sql := """
	INSERT INTO Progresso (chave, valor)
	VALUES (?, ?)
	ON CONFLICT(chave)
	DO UPDATE SET valor = excluded.valor;
	"""

	if not Database.db.query_with_bindings(
		sql,
		[chave, valor_json]
	):
		push_error(
			"Erro ao salvar progresso [" +
			chave +
			"]: " +
			Database.db.error_message
		)


static func carregar(chave: String, padrao = null):
	var sql := """
	SELECT valor
	FROM Progresso
	WHERE chave = ?;
	"""

	if not Database.db.query_with_bindings(
		sql,
		[chave]
	):
		push_error(
			"Erro ao carregar progresso [" +
			chave +
			"]: " +
			Database.db.error_message
		)
		return padrao

	var resultado = Database.db.get_query_result()

	if resultado.is_empty():
		return padrao

	var texto = resultado[0]["valor"]
	var valor = JSON.parse_string(texto)

	if valor == null and texto != "null":
		return padrao

	return valor


static func existe_partida() -> bool:
	var sql := """
	SELECT valor
	FROM Progresso
	WHERE chave = 'partida_criada';
	"""

	if not Database.db.query(sql):
		return false

	return not Database.db.get_query_result().is_empty()


static func marcar_partida_criada() -> void:
	salvar("partida_criada", true)


static func resetar() -> void:
	Database.db.query(
		"DELETE FROM Progresso;"
	)
