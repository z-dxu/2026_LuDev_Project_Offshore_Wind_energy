extends GdUnitTestSuite
## Async scene-instantiation tests for Conversation.tscn with a 3-entry
## dialogue: renders system and character entries, accumulates history,
## and hides the background panel on completion.

const TEST_DIALOGUE := "res://tests/data/simple_dialogue.json"

var conversation: Control


func before_test() -> void:
	var scene: PackedScene = load("res://Scenes/Conversation.tscn")
	conversation = auto_free(scene.instantiate())
	conversation.dialogue_path = TEST_DIALOGUE
	conversation.start_on_ready = false
	conversation.close_on_finish = false
	add_child(conversation)
	await get_tree().process_frame
	GameController.dialogue_history.clear()


func test_renders_first_entry() -> void:
	conversation.lmb_clicked.emit()
	await get_tree().process_frame

	var speaker_label: Label = conversation.find_child("SpeakerName")
	var dialogue_text: RichTextLabel = conversation.find_child("DialogueText")

	assert_str(speaker_label.text).is_equal("System")
	assert_str(dialogue_text.text).is_equal("System message here.")


func test_advances_to_character_entry() -> void:
	conversation.lmb_clicked.emit()
	await get_tree().process_frame

	conversation.lmb_clicked.emit()
	await get_tree().process_frame

	var speaker_label: Label = conversation.find_child("SpeakerName")
	var dialogue_text: RichTextLabel = conversation.find_child("DialogueText")

	assert_str(speaker_label.text).is_equal("Test Speaker")
	assert_str(dialogue_text.text).is_equal("Character message here.")


func test_dialogue_history_accumulates() -> void:
	conversation.lmb_clicked.emit()
	await get_tree().process_frame
	conversation.lmb_clicked.emit()
	await get_tree().process_frame
	conversation.lmb_clicked.emit()
	await get_tree().process_frame

	assert_int(GameController.dialogue_history.size()).is_equal(3)
	assert_str(GameController.dialogue_history[0].get("type")).is_equal("system")
	assert_str(GameController.dialogue_history[1].get("type")).is_equal("character")
	assert_str(GameController.dialogue_history[2].get("type")).is_equal("system")


func test_hides_panel_on_completion() -> void:
	conversation.lmb_clicked.emit()
	await get_tree().process_frame
	conversation.lmb_clicked.emit()
	await get_tree().process_frame
	conversation.lmb_clicked.emit()
	await get_tree().process_frame
	conversation.lmb_clicked.emit()
	await get_tree().process_frame

	var background = conversation.find_child("Background")
	assert_bool(background.visible).is_false()
