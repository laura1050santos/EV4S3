class_name Objetos


const PADRAO := {
	"Norte": [],
	"zoom mala": [
		{"nome": "roteador", "recurso": "res://recursos/roteador.tres", "pos": Vector2(693, 471), "container_id": "interior_mala"},
	],
	"leste": [
		{"nome": "chave", "recurso": "res://recursos/chaveDeFenda.tres", "pos": Vector2(770, 590), "container_id": ""},
		{"nome": "lanterna", "recurso": "res://recursos/lanterna.tres", "pos": Vector2(500, 550), "container_id": ""},
	],
	"Sul": [
		{"nome": "fio decodificador", "recurso": "res://recursos/FioDecodificador.tres", "pos": Vector2(730, 425), "container_id": "sul_gvt_1"},
		{"nome": "processador", "recurso": "res://recursos/processador.tres", "pos": Vector2(600, 550), "container_id": ""},
		{"nome": "papel morse alcapao", "recurso": "res://recursos/PapelMorseAlcapao.tres", "pos": Vector2(727, 387), "container_id": "sul_gvt_2"},
	],
	"Oeste": [
		{"nome": "fita cassete", "recurso": "res://recursos/FitaCassete.tres", "pos": Vector2(500, 550), "container_id": ""},
	],
	"CenaTeto": [
		{"nome": "lampada quebrada", "recurso": "res://recursos/LampadaQuebrada.tres", "pos": Vector2(575, 273), "container_id": ""},
		{"nome": "flan", "recurso": "res://recursos/flan.tres", "pos": Vector2(575, 273), "container_id": ""},
	],
	"CenaChao": [
		{"nome": "placa mae", "recurso": "res://recursos/placaMae.tres", "pos": Vector2(600, 400), "container_id": ""},
	],
	"Zoom Lixeira": [
		{"nome": "gpu", "recurso": "res://recursos/gpu.tres", "pos": Vector2(600, 400), "container_id": ""},
	],
	"BuracoAberto": [
		{"nome": "lampada nova", "recurso": "res://recursos/lampada.tres", "pos": Vector2(570, 380), "container_id": ""},
	],
}


# =========================================================
# BANCO
# =========================================================

static func criar_tabela():
	Database.db.query("""
	CREATE TABLE IF NOT EXISTS Objetos (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		nome TEXT NOT NULL UNIQUE,
		recurso TEXT NOT NULL UNIQUE,
		pos TEXT,
		cena TEXT,
		coletado INTEGER NOT NULL DEFAULT 0,
		container_id TEXT NOT NULL DEFAULT ''
	);
	""")

	Database.db.query("""
	CREATE TABLE IF NOT EXISTS CenasVisitadas (
		cena TEXT PRIMARY KEY
	);
	""")


# =========================================================
# CENAS VISITADAS
# =========================================================

static func cena_ja_visitada(cena: String) -> bool:
	Database.db.query_with_bindings(
		"SELECT cena FROM CenasVisitadas WHERE cena = ?;", [cena]
	)
	return Database.db.get_query_result().size() > 0


static func marcar_cena_visitada(cena: String):
	if not Database.db.query_with_bindings(
		"INSERT OR IGNORE INTO CenasVisitadas (cena) VALUES (?);", [cena]
	):
		push_error("Erro ao marcar cena visitada: " + Database.db.error_message)


# =========================================================
# OBJETOS PADRÃO
# =========================================================

static func garantir_padrao(cena: String):
	if cena_ja_visitada(cena):
		return
	for o in PADRAO.get(cena, []):
		salvar_objetos(
			o["nome"], o["recurso"],
			pos_para_json(int(o["pos"].x), int(o["pos"].y)), cena, o.get("container_id", "")
		)
	marcar_cena_visitada(cena)


static func iniciar_objetos():
	for cena in PADRAO.keys():
		garantir_padrao(cena)
	# Inclui o item em partidas existentes, mesmo se a sala já foi visitada.
	salvar_objetos("fio decodificador", "res://recursos/FioDecodificador.tres", pos_para_json(730, 425), "Sul", "sul_gvt_1")

static func disponibilizar_chave_mala() -> void:
	if get_por_recurso("res://recursos/ChaveMala.tres") == null:
		salvar_objetos("chave mala", "res://recursos/ChaveMala.tres", pos_para_json(625, 597), "Norte")


static func migrar_roteador_para_mala() -> void:
	if not Database.db.query_with_bindings(
		"""
		UPDATE Objetos
		SET cena = ?, container_id = ?
		WHERE recurso = ? AND cena = 'Norte' AND coletado = 0;
		""",
		["zoom mala", "interior_mala", "res://recursos/roteador.tres"]
	):
		push_error("Erro ao migrar roteador para a mala: " + Database.db.error_message)


# =========================================================
# SALVAR / ATUALIZAR malditos 
# =========================================================

static func salvar_objetos(nome: String, recurso: String, pos: String, cena: String, container_id: String = ""):
	var sql = """
	INSERT OR IGNORE INTO Objetos (nome, recurso, pos, cena, container_id ,coletado)
	VALUES (?, ?, ?, ?, ?, 0);
	"""
	if not Database.db.query_with_bindings(sql, [nome, recurso, pos, cena, container_id]):
		push_error("Erro ao salvar objeto: " + Database.db.error_message)
		return
	print("Objeto salvo: ", nome, " ", container_id)


static func atualizar_objeto(nome: String, recurso: String, pos: String, cena: String):
	var sql = """
	UPDATE Objetos
	SET recurso = ?, pos = ?, cena = ?
	WHERE nome = ?;
	"""
	if not Database.db.query_with_bindings(sql, [recurso, pos, cena, nome]):
		push_error("Erro ao atualizar objeto: " + Database.db.error_message)
		return
	print("Objeto atualizado: ", nome)


# =========================================================
# ESTADO DO ITEM
# =========================================================

static func marcar_coletado_por_recurso(recurso: String) -> void:
	var sql = """
	UPDATE Objetos
	SET coletado = 1, container_id = ''
	WHERE recurso = ?;
	"""

	var sucesso = Database.db.query_with_bindings(sql, [recurso])

	if not sucesso:
		push_error("Erro ao marcar coletado: " + Database.db.error_message)


static func soltar_por_recurso(recurso: String, pos: Vector2, cena: String) -> void:
	var sql = """
	UPDATE Objetos
	SET coletado = 0, pos = ?, cena = ?, container_id = ''
	WHERE recurso = ?;
	"""

	var sucesso = Database.db.query_with_bindings(sql, [pos_para_json(int(pos.x), int(pos.y)), cena, recurso])

	if not sucesso:
		push_error("Erro ao soltar objeto: " + Database.db.error_message)


# =========================================================
# OBJETOS NO MUNDO
# =========================================================

static func get_objetos_cena(cena):
	var sql = """
	SELECT id, nome, recurso, pos, cena, container_id
	FROM Objetos
	WHERE cena = ?
	AND coletado = 0
	AND (container_id IS NULL OR container_id = '');
	"""

	Database.db.query_with_bindings(sql, [cena])

	var resultado: Array = Database.db.get_query_result()
	var objetos = []

	for info in resultado:
		var recurso = load(info["recurso"])
		var posicao = JSON.parse_string(info["pos"])

		if not (posicao is Dictionary) or recurso == null:
			push_error("Objeto inválido no banco: " + str(info["nome"]))
			continue

		objetos.append({
			"nome": info["nome"],
			"item": recurso,
			"pos": Vector2(posicao["x"], posicao["y"]),
			"cena": info["cena"],
			"container_id": info["container_id"]
		})

	return objetos

# =========================================================
# OBJETOS NAS GAVETAS
# =======================================================

static func get_objetos_container(cena: String, container_id: String) -> Array:
	var sql = """
	SELECT id, nome, recurso, pos, cena, container_id
	FROM Objetos
	WHERE cena = ?
	AND container_id = ?
	AND coletado = 0;
	"""

	Database.db.query_with_bindings(sql, [cena, container_id])

	var resultado: Array = Database.db.get_query_result()
	var objetos: Array = []

	for info in resultado:
		var recurso = load(info["recurso"])
		if recurso == null:
			push_error("Recurso inválido na gaveta: " + str(info["nome"]))
			continue

		var posicao = JSON.parse_string(info["pos"])
		if not (posicao is Dictionary):
			push_error("Posição inválida na gaveta: " + str(info["nome"]))
			continue

		objetos.append({
			"nome": info["nome"],
			"item": recurso,
			"pos": Vector2(posicao["x"], posicao["y"]),
			"cena": info["cena"],
			"container_id": info["container_id"]
		})

	return objetos

# =========================================================
# OBJETOS COLETADOS / INVENTÁRIO <---  scanagem comigo
# =========================================================

static func get_objetos_coletados() -> Array:
	var sql = """
	SELECT id, nome, recurso, pos, cena, coletado
	FROM Objetos
	WHERE coletado = 1;
	"""
	if not Database.db.query(sql):
		push_error("Erro ao buscar objetos coletados: " + Database.db.error_message)
		return []

	var resultado = Database.db.get_query_result()
	var objetos: Array = []

	for info in resultado:
		var caminho_recurso: String = info["recurso"]
		if not ResourceLoader.exists(caminho_recurso):
			push_error("Recurso coletado não encontrado: " + caminho_recurso)
			continue

		var recurso = load(caminho_recurso)
		objetos.append({
			"id": info["id"],
			"nome": info["nome"],
			"item": recurso,
			"recurso": caminho_recurso,
			"pos": info["pos"],
			"cena": info["cena"],
			"coletado": info["coletado"]
		})

	return objetos


static func get_recursos_coletados() -> Array:
	var objetos = get_objetos_coletados()
	var recursos: Array = []
	for objeto in objetos:
		if objeto.has("item"):
			recursos.append(objeto["item"])
	return recursos


static func esta_coletado(recurso: String) -> bool:
	if not Database.db.query_with_bindings(
		"SELECT id FROM Objetos WHERE recurso = ? AND coletado = 1;", [recurso]
	):
		return false
	return Database.db.get_query_result().size() > 0


# =========================================================
# BUSCA
# =========================================================

static func get_nome(nome: String):
	if not Database.db.query_with_bindings(
		"""
		SELECT id, nome, recurso, pos, cena, coletado
		FROM Objetos
		WHERE nome = ?;
		""",
		[nome]
	):
		return null
	var resultado = Database.db.get_query_result()
	if resultado.size() > 0:
		return resultado[0]
	return null


static func get_por_recurso(recurso: String):
	if not Database.db.query_with_bindings(
		"""
		SELECT id, nome, recurso, pos, cena, coletado
		FROM Objetos
		WHERE recurso = ?;
		""",
		[recurso]
	):
		return null
	var resultado = Database.db.get_query_result()
	if resultado.size() > 0:
		return resultado[0]
	return null


# =========================================================
# DELETAR
# =========================================================

static func delete_objeto(nome: String):
	if not Database.db.query_with_bindings(
		"DELETE FROM Objetos WHERE nome = ?;", [nome]
	):
		push_error("Erro ao deletar objeto: " + Database.db.error_message)
		return
	print("Objeto deletado: ", nome)


# =========================================================
# POSIÇÃO
# =========================================================

static func pos_para_json(x: int, y: int) -> String:
	return JSON.stringify({"x": x, "y": y})


# =========================================================
# RESET
# =========================================================

static func resetar():
	Database.db.query("DELETE FROM Objetos;")
	Database.db.query("DELETE FROM CenasVisitadas;")


# =========================================================
# TOCA-FITAS / ESTAÇÕES
# =========================================================

static func guardar_em_estacao(recurso: String, estacao_id: String):
	if not Database.db.query_with_bindings(
		"UPDATE Objetos SET coletado = 2, cena = ? WHERE recurso = ?;",
		["estacao:" + estacao_id, recurso]
	):
		push_error("Erro ao guardar na estação: " + Database.db.error_message)


static func retirar_de_estacao(recurso: String):
	if not Database.db.query_with_bindings(
		"UPDATE Objetos SET coletado = 1 WHERE recurso = ?;", [recurso]
	):
		push_error("Erro ao retirar da estação: " + Database.db.error_message)


static func marcar_instalado_por_recurso(recurso: String) -> void:
	if not Database.db.query_with_bindings(
		"UPDATE Objetos SET coletado = 3, container_id = '' WHERE recurso = ?;",
		[recurso]
	):
		push_error("Erro ao marcar item instalado: " + Database.db.error_message)


static func get_recurso_em_estacao(estacao_id: String) -> String:
	if not Database.db.query_with_bindings(
		"SELECT recurso FROM Objetos WHERE coletado = 2 AND cena = ?;",
		["estacao:" + estacao_id]
	):
		return ""
	var resultado = Database.db.get_query_result()
	if resultado.size() > 0:
		return resultado[0]["recurso"]
	return ""
