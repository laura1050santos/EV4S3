class_name ArtigoNavegador
extends Resource

@export var termos: PackedStringArray = []
@export var titulo: String = ""
@export var endereco: String = ""
@export_multiline var conteudo: String = ""
@export_enum("Artigo", "TecnoLar", "Vigia", "Arquivo") var estilo: int = 0
