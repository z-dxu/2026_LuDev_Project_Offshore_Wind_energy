extends GdUnitTestSuite
## Unit tests for pure functions in conversation.gd: speaker-to-filename
## normalization, entry speaker extraction, and dialogue JSON file loading
## (valid, nonexistent, and empty files).

var conversation: Control


func before_test() -> void:
	# Attach Conversation script to a bare Control — avoids _ready()
	# which accesses $DialoguePanel children that don't exist here
	var node = auto_free(Control.new())
	node.set_script(load("res://Scripts/conversation.gd"))
	conversation = node


func test_speaker_to_file_name() -> void:
	assert_str(conversation._speaker_to_file_name("Fisher Rep")).is_equal("fisher_rep")
	assert_str(conversation._speaker_to_file_name("Blue Arcadia")).is_equal("blue_arcadia")
	assert_str(conversation._speaker_to_file_name("Blue-Arcadia")).is_equal("blue_arcadia")
	assert_str(conversation._speaker_to_file_name("coordinator")).is_equal("coordinator")
	assert_str(conversation._speaker_to_file_name("Fisher Guild Rep")).is_equal("fisher_guild_rep")
	assert_str(conversation._speaker_to_file_name("")).is_equal("")


func test_get_entry_speaker_system() -> void:
	var entry = {"type": "system", "title": "Test", "text": "Hello"}
	assert_str(conversation._get_entry_speaker(entry)).is_equal("System")


func test_get_entry_speaker_character() -> void:
	var entry = {"type": "character", "speaker_name": "Coordinator", "text": "Hi"}
	assert_str(conversation._get_entry_speaker(entry)).is_equal("Coordinator")


func test_get_entry_speaker_fallback() -> void:
	var entry = {"type": "character", "speaker": "Fallback Name", "text": "Hi"}
	assert_str(conversation._get_entry_speaker(entry)).is_equal("Fallback Name")


func test_get_entry_speaker_no_name() -> void:
	var entry = {"type": "character", "text": "Mystery voice"}
	assert_str(conversation._get_entry_speaker(entry)).is_equal("")


func test_load_dialogue_json_valid() -> void:
	var data = conversation._load_dialogue_json("res://assets/Story/Opening.json")
	assert_bool(data is Array).is_true()
	assert_int(data.size()).is_greater(0)
	var first = data[0]
	assert_bool(first is Dictionary).is_true()
	assert_bool(first.has("type")).is_true()


func test_load_dialogue_json_nonexistent() -> void:
	var data = conversation._load_dialogue_json("res://nonexistent_file_12345.json")
	assert_bool(data == null or data.is_empty()).is_true()


func test_load_dialogue_json_empty() -> void:
	var data = conversation._load_dialogue_json("res://tests/data/empty_dialogue.json")
	assert_bool(data is Array).is_true()
	assert_int(data.size()).is_equal(0)
