extends GdUnitTestSuite
## Async tests for the conversation branch-jump engine: verifies that
## choosing option 0 routes to Path A content, option 1 routes to Path B
## content, and both paths converge at the same merge point.
##
## Note: The intro_cutscene conversation system starts via _start_dialogue()
## directly, not via lmb_clicked in _ready().

const CHOICE_DIALOGUE := "res://tests/data/choice_dialogue.json"
const CONVERSATION_SCENE := preload("res://Scenes/Conversation.tscn")

var conversation: Control


func before_test() -> void:
	var scene: PackedScene = CONVERSATION_SCENE
	conversation = auto_free(scene.instantiate())
	conversation.dialogue_path = CHOICE_DIALOGUE
	conversation.start_on_ready = false
	conversation.close_on_finish = false
	add_child(conversation)
	await get_tree().process_frame
	GameController.dialogue_history.clear()


func test_choice_path_a() -> void:
	# Start dialogue directly
	conversation._start_dialogue(conversation.dialogue_json)
	await get_tree().process_frame  # entry 0 renders, awaits lmb_clicked
	await get_tree().process_frame  # another frame skipped, because start already skips one
	# Advance past entry 0 — choice page shown
	conversation.lmb_clicked.emit()
	await get_tree().process_frame  # entry 0 → history, choice page awaits
	await get_tree().process_frame
	# Pick option 0 (Path A: branch_end=2, skip_to=4)
	conversation.option_chosen.emit(0)
	await get_tree().process_frame  # branch jump: entry 2 renders
	await get_tree().process_frame
	var dialogue_text: RichTextLabel = conversation.find_child("DialogueText")
	assert_str(dialogue_text.text).is_equal("You chose path A.")

	# Advance — entry 2 → history, jump to entry 4 (merge)
	conversation.lmb_clicked.emit()
	await get_tree().process_frame

	assert_str(dialogue_text.text).is_equal("Both paths converge.")


func test_choice_path_b() -> void:
	conversation._start_dialogue(conversation.dialogue_json)
	await get_tree().process_frame
	await get_tree().process_frame
	conversation.lmb_clicked.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	# Pick option 1 (Path B: branch_end=1, skip_to=3)
	conversation.option_chosen.emit(1)
	await get_tree().process_frame  # jump immediately: entry 3 renders
	await get_tree().process_frame
	var dialogue_text: RichTextLabel = conversation.find_child("DialogueText")
	assert_str(dialogue_text.text).is_equal("You chose path B.")

	# Advance to merge
	conversation.lmb_clicked.emit()
	await get_tree().process_frame  # entry 4 renders

	assert_str(dialogue_text.text).is_equal("Both paths converge.")


func test_both_paths_converge() -> void:
	var dialogue_text: RichTextLabel = conversation.find_child("DialogueText")

	# Path A
	conversation._start_dialogue(conversation.dialogue_json)
	await get_tree().process_frame
	await get_tree().process_frame
	conversation.lmb_clicked.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	conversation.option_chosen.emit(0)
	await get_tree().process_frame
	await get_tree().process_frame
	conversation.lmb_clicked.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_str(dialogue_text.text).is_equal("Both paths converge.")

	# Clean up and create new instance for Path B
	conversation.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame

	var conv2: Control = auto_free(CONVERSATION_SCENE.instantiate())
	conv2.dialogue_path = CHOICE_DIALOGUE
	conv2.start_on_ready = false
	conv2.close_on_finish = false
	add_child(conv2)
	await get_tree().process_frame
	await get_tree().process_frame
	var dt2: RichTextLabel = conv2.find_child("DialogueText")

	# Path B
	conv2._start_dialogue(conv2.dialogue_json)
	await get_tree().process_frame
	await get_tree().process_frame
	conv2.lmb_clicked.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	conv2.option_chosen.emit(1)
	await get_tree().process_frame
	await get_tree().process_frame
	conv2.lmb_clicked.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_str(dt2.text).is_equal("Both paths converge.")
