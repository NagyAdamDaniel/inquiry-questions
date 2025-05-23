extends Node

var database_url = "https://inquiry-questions-default-rtdb.europe-west1.firebasedatabase.app"
var api_key = "AIzaSyC2qmPXzdZRBbuWwSL0L18Oj7HpjQ-wuTY"

func write_data(path: String, data: Dictionary):
	var url = "%s/%s.json?auth=%s" % [database_url, path, api_key]
	var json_data = JSON.stringify(data)

	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_http_request_request_completed.bind(http))
	http.request(url, [], HTTPClient.METHOD_PUT, json_data)

func read_data(path: String, callback: Callable):
	var url = "%s/%s.json?auth=%s" % [database_url, path, api_key]

	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(callback)
	http.request(url, [], HTTPClient.METHOD_GET)

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http):
	print("Firebase response:", body.get_string_from_utf8())
	http.queue_free()
