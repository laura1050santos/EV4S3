extends Node

var db: SQLite


func _ready() -> void:
	db = SQLite.new()
	db.path = "res://data.db"
	var sucesso = db.open_db()
	criar_tabelas()
	novo_jogo()
	if not sucesso:
		print("Erro ao abrir o banco de dados.")
		return

func criar_tabelas():
	Cenarios.criar_tabela()
	Objetos.criar_tabela()
	Enigmas.criar_tabela()
	Arrays.criar_tabela()
	Config.criar_tabelas()

func novo_jogo():
	Objetos.resetar()
	Objetos.iniciar_objetos()
	Arrays.iniciar_array()
	Enigmas.iniciar_enigmas()
	Cenarios.iniciar_cenarios()
	Config.iniciar_config()
