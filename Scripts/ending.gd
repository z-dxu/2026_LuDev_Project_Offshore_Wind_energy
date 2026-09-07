extends Control

const START_MENU = "uid://dooem6rr3gh2l"
@export var speed = 30
@onready var credits: RichTextLabel = $RichTextLabel
@onready var score_label: RichTextLabel = $score_label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# get text
	var ending_score = GameController.story_flags.get("ending_score")
	var total_endings = GameController.total_endings
	var ending_title = GameController.story_flags.get("ending")

	# check if you achieved the same ending
	if ending_title not in total_endings && ending_title && ending_title != "null":
		total_endings.append(ending_title)

	var score_label_text = "[b]Your score:" + str(ending_score) + "/10 [/b]" + "\n"
	#score_label_text += (
	#"[b]You achieved " + str(total_endings.size()) + "/8 total endings [/b]" + "\n\n\n\n"
	#)
	score_label.text = score_label_text

	# position credits below the screen
	var choices = get_choices()
	var credit_text = credits.text
	choices += "\n\n\n\n\n" + credit_text
	credits.text = choices
	credits.position.y = get_viewport_rect().size.y

	# animation work
	score_label.modulate.a = 0
	var tween = create_tween()
	await tween.tween_property(score_label, "modulate:a", 1, 3)


func _process(delta: float) -> void:
	if score_label.modulate.a == 1:  # dpne tweening the score conitnue
		credits.position.y -= speed * delta
		score_label.position.y -= speed * delta
	if credits.position.y + credits.size.y < 0:
		SceneTransition.change_scene(START_MENU)


func get_choices():
	var location = GameController.story_flags.get("windmill_location", "")
	var label_text = ""
	var c1 = ""
	var c2 = ""
	var c3 = ""
	var c4 = ""
	match location:
		"ramsar":
			c1 = GameController.story_flags.get("choice_1", "")
			c2 = GameController.story_flags.get("choice_2", "")
		"fishing":
			c1 = GameController.story_flags.get("fishing_strategy", "")
			c2 = GameController.story_flags.get("bird_strategy", "")
			c4 = GameController.story_flags.get("port_strategy", "")
			c3 = GameController.story_flags.get("noise_strategy", "")
		"port":
			c1 = GameController.story_flags.get("port_strategy", "")
	#label_text += "[b]You chose to build on " + str(location) + " location [/b]" + "\n\n"
	label_text += (
		(
			'[b]You chose for the option "'
			+ str(c1)
			+ '" [/b]'
			+ "\n\n"
			+ '[b]You chose for the option "'
			+ str(c2)
			+ '" [/b]'
			+ "\n\n"
			+ '[b]You chose for the option "'
			+ str(c3)
			+ '" [/b]'
			+ "\n\n"
			+ '[b]You chose for the option "'
			+ str(c4)
			+ '" [/b]'
			+ "\n\n"
		)
		. replace("_", " ")
	)
	return label_text
