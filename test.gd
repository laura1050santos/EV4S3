@tool
extends Node

var http := HTTPRequest.new()

func _ready() -> void:
	add_child(http)

	http.request_completed.connect(_on_request_completed)

	var err := http.request(
		"https://identitytoolkit.googleapis.com"
	)

	print("request() retornou: ", err)


func _on_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
) -> void:

	print("========== TESTE HTTPS ==========")
	print("result: ", result)
	print("response_code: ", response_code)
	print("headers: ", headers)
	print("body: ", body.get_string_from_utf8())
	print("=================================")
