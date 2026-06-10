extends Control

@onready var env_value: Label = $Scores/EnvironmentCard/VBox/Header/ValueLabel
@onready var env_bar: ProgressBar = $Scores/EnvironmentCard/VBox/Bar
@onready var env_caption: Label = $Scores/EnvironmentCard/VBox/Caption

@onready var soc_value: Label = $Scores/SocialCard/VBox/Header/ValueLabel
@onready var soc_bar: ProgressBar = $Scores/SocialCard/VBox/Bar
@onready var soc_caption: Label = $Scores/SocialCard/VBox/Caption
@onready var end_title: Label = $EndTitle


func _ready() -> void:
	# TEMP for testing — delete when the game drives scores
	SDGManager.set_metric("ecosystem_health", 34)
	SDGManager.set_metric("social_stability", 68)

	var env: int = int(SDGManager.get_metric("ecosystem_health"))
	var soc: int = int(SDGManager.get_metric("social_stability"))

	env_bar.value = 0
	soc_bar.value = 0
	env_value.text = "0"
	soc_value.text = "0"

	env_caption.text = _caption(env, "ecosystem")
	soc_caption.text = _caption(soc, "community")

	end_title.modulate.a = 0.0
	_animate_end_title()

	_animate_score(env_bar, env_value, env, 1.5)
	_animate_score(soc_bar, soc_value, soc, 1.5)


func _animate_end_title() -> void:
	var tween := create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(end_title, "modulate:a", 1.0, 2.4).set_trans(Tween.TRANS_SINE).set_ease(
		Tween.EASE_OUT
	)


func _animate_score(bar: ProgressBar, label: Label, target: int, duration: float) -> void:
	var tween := create_tween().set_parallel(true)
	(
		tween
		. tween_property(bar, "value", float(target), duration)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)
	(
		tween
		. tween_method(
			func(v: float): label.text = str(int(round(v))), 0.0, float(target), duration
		)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)


func _caption(score: int, subject: String) -> String:
	if score >= 75:
		return "The %s is thriving." % subject
	if score >= 50:
		return "The %s is holding up." % subject
	if score >= 25:
		return "The %s is strained." % subject
	return "The %s is in crisis." % subject


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_CloseButton_pressed() -> void:
	_on_exit_button_pressed()
