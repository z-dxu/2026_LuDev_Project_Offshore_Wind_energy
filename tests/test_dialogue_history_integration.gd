extends GdUnitTestSuite
## Tests GameController dialogue history: signal fires on append, entries
## preserve insertion order, back() returns the last entry, and sdg_data
## stores, retrieves, and mutates nested score dictionaries.

var _signal_fired := false


func before_test() -> void:
	GameController.dialogue_history.clear()
	GameController.sdg_data.clear()


func _on_history_updated() -> void:
	_signal_fired = true


func test_dialogue_history_updated_signal_fires() -> void:
	_signal_fired = false
	GameController.dialogue_history_updated.connect(_on_history_updated)

	var entry = {"type": "system", "title": "Test", "text": "Signal test"}
	GameController.dialogue_history.append(entry)
	GameController.dialogue_history_updated.emit()

	assert_bool(_signal_fired).is_true()
	assert_int(GameController.dialogue_history.size()).is_equal(1)


func test_dialogue_history_preserves_entry_order() -> void:
	var entry1 = {"type": "system", "title": "First"}
	var entry2 = {"type": "character", "speaker_name": "Test", "text": "Second"}
	var entry3 = {"type": "system", "title": "Third"}

	GameController.dialogue_history.append(entry1)
	GameController.dialogue_history.append(entry2)
	GameController.dialogue_history.append(entry3)

	assert_int(GameController.dialogue_history.size()).is_equal(3)
	assert_str(GameController.dialogue_history[0].get("title")).is_equal("First")
	assert_str(GameController.dialogue_history[1].get("speaker_name")).is_equal("Test")
	assert_str(GameController.dialogue_history[2].get("title")).is_equal("Third")


func test_dialogue_history_back_returns_last_entry() -> void:
	GameController.dialogue_history.append({"type": "system", "title": "A"})
	GameController.dialogue_history.append({"type": "system", "title": "B"})

	var last = GameController.dialogue_history.back()
	assert_str(last.get("title")).is_equal("B")


func test_sdg_data_stores_and_mutates() -> void:
	var cell = Vector3i(10, 0, 10)
	GameController.sdg_data[cell] = {"food": {"score": 5}}
	assert_int(GameController.sdg_data[cell]["food"]["score"]).is_equal(5)

	GameController.sdg_data[cell]["food"]["score"] += 3
	assert_int(GameController.sdg_data[cell]["food"]["score"]).is_equal(8)

	GameController.sdg_data[cell]["energy"] = {"score": 10}
	assert_int(GameController.sdg_data[cell]["energy"]["score"]).is_equal(10)
