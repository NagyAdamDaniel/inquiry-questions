extends Control

@onready var answer = $VBoxContainer/Answer
@onready var real_question = $Real_question

func _ready() -> void:
	answer.text = Root.answer
	var path = "rooms/%s/questions/normal" % Global.room_code
	Firebase.read_data(path, Callable(self, "_on_normal_question_loaded"))

func _on_normal_question_loaded(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var raw_string := body.get_string_from_utf8()
		var question := raw_string.strip_edges()  # remove whitespace
		# Manually remove quotes if present
		if question.begins_with('"') and question.ends_with('"'):
			question = question.substr(1, question.length() - 2)
		real_question.text = question
	else:
		real_question.text = "Failed to load question"


func _on_lobby_button_pressed() -> void:
	Firebase.write_data("rooms/%s/game_started" % Global.room_code, {"value": false})
	
	get_tree().change_scene_to_file("res://Main Menu/Lobby/lobby.tscn")
