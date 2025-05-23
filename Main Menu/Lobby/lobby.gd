extends Control

@onready var room_code_label = $VBoxContainer/Room_code
@onready var player_list = $Player_list
@onready var start_button = $VBoxContainer/Start_game_button

var questions: Array = []

func _ready() -> void:
	_load_questions()
	
	room_code_label.text = "Room Code: %s" % Global.room_code
	start_button.visible = is_host()
	_update_player_list()

func _load_questions() -> void:
	var file = FileAccess.open("res://Data/questions.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var parsed = JSON.parse_string(content)
		if typeof(parsed) == TYPE_ARRAY:
			questions = parsed

func is_host() -> bool:
	return Global.player_id.begins_with("test_") or Global.player_id == "Host"

func _update_player_list() -> void:
	var room_path = "rooms/%s/players.json" % Global.room_code
	Firebase.read_data(room_path, Callable(self, "_on_players_loaded"))

func _check_game_started() -> void:
	var path = "rooms/%s/game_started" % Global.room_code
	Firebase.read_data(path, Callable(self, "_on_game_started_checked"))


func _on_players_loaded(result, response_code, headers, body):
	for child in player_list.get_children():
		child.queue_free()
	var json = body.get_string_from_utf8()
	var players = JSON.parse_string(json)
	if typeof(players) == TYPE_DICTIONARY:
		player_list.clear()
		for player_id in players:
			#var player_name = players[player_id].get("name", "Unknown")
			var player_data = players[player_id]
			if typeof(player_data) == TYPE_DICTIONARY:
				var player_name = player_data.get("name", "Unknown")
				var label = Label.new()
				label.text = player_name
				player_list.add_child(label)

func _on_game_started_checked(result, response_code, headers, body) -> void:
	var json = body.get_string_from_utf8()
	var data = JSON.parse_string(json)
	if typeof(data) == TYPE_DICTIONARY and data.has("value"):
		if data["value"] == true:
			get_tree().change_scene_to_file("res://Game/game.tscn")

func _on_refresh_timer_timeout() -> void:
	#print("refresh")
	_update_player_list()
	_check_game_started()

func _on_start_game_button_pressed() -> void:
	if questions.size() == 0:
		_load_questions()
	var selected = questions[randi() % questions.size()]
	Firebase.write_data("rooms/%s/questions" % Global.room_code, {
		"normal": selected.normal,
		"impostor": selected.impostor
	})
	Firebase.write_data("rooms/%s/game_started" % Global.room_code, {"value": true})


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Main Menu/main_menu.tscn")
