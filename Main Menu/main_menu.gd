extends Control

@onready var join_button = $VBoxContainer/Join_Room_button
@onready var create_button = $VBoxContainer/Create_Room_button
@onready var room_input = $LineEdit

var current_room_code := ""

func _on_create_room_button_pressed() -> void:
	current_room_code = generate_room_code()
	#var player_id = str(OS.get_unique_id())
	var player_id = "test_" + generate_random_id()
	var room_data = {
		"players": {
			player_id: {
				"name": "Host",
				"joined_at": Time.get_unix_time_from_system()
			}
		},
		"status": "waiting"
	}
	Firebase.write_data("rooms/%s" % current_room_code, room_data)
	Global.room_code = current_room_code
	Global.player_id = player_id
	get_tree().change_scene_to_file("res://Main Menu/Lobby/lobby.tscn")

func _on_join_room_button_button_up() -> void:
	current_room_code = room_input.text.strip_edges().to_upper()
	Firebase.read_data("rooms/%s.json" % current_room_code, Callable(self, "_on_room_check_complete"))

func _on_room_check_complete(result, response_code, headers, body):
	var json = body.get_string_from_utf8()
	var data = JSON.parse_string(json)
	if typeof(data) == TYPE_DICTIONARY:
		var player_id = str(OS.get_unique_id())
		Firebase.write_data("rooms/%s/players/%s" % [current_room_code, player_id], {
			"name": "Guest",
			"joined_at": Time.get_unix_time_from_system()
		})
		Global.room_code = current_room_code
		Global.player_id = player_id
		get_tree().change_scene_to_file("res://Main Menu/Lobby/lobby.tscn")
	else:
		print("Room not found")

func generate_room_code(length := 5) -> String:
	var charset := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var code := ""
	for i in length:
		code += charset[randi() % charset.length()]
	return code
func generate_random_id(length := 8) -> String:
	var charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var id = ""
	for i in length:
		id += charset[randi() % charset.length()]
	return id


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Main Menu/main_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
