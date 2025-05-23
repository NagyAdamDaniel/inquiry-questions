extends Control

@onready var question_label = $VBoxContainer/QuestionLabel
@onready var line_edit = $VBoxContainer/LineEdit

func _ready() -> void:
	var path = "rooms/%s/questions" % Global.room_code
	Firebase.read_data(path, Callable(self, "_on_questions_loaded"))

func _on_questions_loaded(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var json: String = body.get_string_from_utf8()
	var data = JSON.parse_string(json)

	if typeof(data) == TYPE_DICTIONARY:
		var questions = [data.get("normal", ""), data.get("impostor", "")]
		var selected = questions[randi() % questions.size()]
		question_label.text = selected
	else:
		question_label.text = "Failed to load question."


func _on_ready_button_pressed() -> void:
	Root.answer = line_edit.text
	get_tree().change_scene_to_file("res://Game/Debate_screen/debate_screen.tscn")
