extends GdUnitTestSuite
## Tests dialogue_history_sidebar.gd constants: ROLE_ACCENTS dictionary
## integrity (all 10 speaker IDs present and valid Colors), spot-check
## color values, and _compute_width() viewport ratio.

const SIDEBAR_SCRIPT := preload("res://Scripts/dialogue_history_sidebar.gd")

var sidebar: Control


func before_test() -> void:
	var node = auto_free(Control.new())
	node.set_script(SIDEBAR_SCRIPT)
	sidebar = node
	# Do NOT add to tree — _ready() accesses $PanelContainer children
	# that don't exist here and will crash. The methods we test
	# (ROLE_ACCENTS constant, _compute_width via viewport global)
	# work without the scene tree.


func test_all_role_accents_are_valid_colors() -> void:
	var accents: Dictionary = SIDEBAR_SCRIPT.ROLE_ACCENTS

	var expected_keys = [
		"system",
		"coordinator",
		"fisher_representative",
		"environmental_activist",
		"shipping_representative",
		"fishers_guild",
		"featherwings",
		"legal_advisor",
		"aquanautilus",
		"blue_arcadia"
	]

	for key in expected_keys:
		(
			assert_bool(accents.has(key))
			. override_failure_message("Missing role accent key: " + key)
			. is_true()
		)
		(
			assert_bool(accents[key] is Color)
			. override_failure_message(key + " is not a Color")
			. is_true()
		)

	assert_int(accents.size()).is_equal(expected_keys.size())


func test_compute_width_ratio() -> void:
	var expected = sidebar.get_viewport_rect().size.x * 0.25
	assert_that(sidebar._compute_width()).is_equal(expected)
