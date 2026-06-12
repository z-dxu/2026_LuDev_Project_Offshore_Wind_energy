extends Control

var tween
var prev_pos
var sdg_data
var used_sdg = []
var total_score = {}  # type = score
var sdg_imgs
@onready var panel: Panel = $Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	position = Vector2(-267.0, 0)
	prev_pos = position  # for tween animation


func _show_left_slide_bar(mouse_hover: bool, _poi_cel_pos):
	tween = create_tween()
	if mouse_hover:
		_update_sdg_scores()
		visible = true
		tween.tween_property(self, "position", Vector2(0, 0), 0.1)
		await tween.finished
	else:
		tween.tween_property(self, "position", prev_pos, 0.1)
		await tween.finished
		visible = false


func _update_sdg_scores():
	for child in panel.get_children():
		var sdg_texture_rect: TextureRect = child.get_child(0)
		if sdg_texture_rect.texture is PlaceholderTexture2D:
			child.visible = false
			continue

		GameController.get_poi_score.emit(self)  # get poi score for all types
		for sdg_name in sdg_imgs.keys():
			var sdg_score_label: Label = child.get_child(1)
			if sdg_texture_rect.texture == sdg_imgs[sdg_name]:
				if not total_score.has(sdg_name):
					continue
				sdg_score_label.text = str(total_score[sdg_name])


func _get_all_scores(data):
	total_score = data
