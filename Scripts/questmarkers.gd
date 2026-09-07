extends Node3D
const STORY_FOLDER = "res://assets/Story/"
const RAMSAR_PATH_STORY_FOLDER = "res://assets/Story/ramsar_wetland_path/"
const FISHING_PATH_STORY_FOLDER = "res://assets/Story/fishing_ground_path/"
const PORT_PATH_STORY_FOLDER = "res://assets/Story/port_path/"
const FISHING_OFFSHORE_WIND_PARK_POSITIONS = [
	[2, 0, -52],
	[4, 0, -52],
	[6, 0, -52],
	[8, 0, -52],
	[10, 0, -52],
	[12, 0, -52],
	[3, 0, -54],
	[5, 0, -54],
	[7, 0, -54],
	[9, 0, -54],
	[11, 0, -54],
	[2, 0, -55],
	[4, 0, -55],
	[6, 0, -55],
	[8, 0, -55],
	[10, 0, -55],
	[12, 0, -55],
]
@export var points = {
	"seasonal_shutdown": 3,
	"paint_blades": 2.5,
	"lower_turbines": 2,
	"artificial_reefs": 2.5,
	"relocate_wind_park": 1,
	"keep_port": 1,
	"move_port": 2,
	"suction_buckets": 2.5,
	"bubble_curtains": 2,
}
var ramsar_quest_markers: Array[Node3D] = []
var fishing_quest_markers: Array[Node3D] = []
var port_quest_markers: Array[Node3D] = []
var quest_folders = []
var current_quest = 0
var current_fishing_quest = 0
var current_port_quest = 0
var windmills_built = false
var wind_park_relocated_offshore = false
var temp_holder = null
@onready var windmills_builds_quests: Node3D = $windmills_builds_quests
@onready var ramsar_path: Node3D = $ramsar_path
@onready var fishing_ground_path: Node3D = $fishing_ground_path
@onready var port_path: Node3D = $port_path
@onready var cut_plyr: AnimationPlayer = $"../../Animations/Intro/intro_cutscene_player"
@onready var outro_player: AnimationPlayer = $"../../Animations/Outro/outro_player"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameController.next_phase.connect(_load_content)
	GameController.story_flag_appended.connect(_show_next_active_quest_markers)
	for c in self.get_children():
		if c.name == "windmills_builds_quests":  # handled by cutscene
			continue
		c.visible = false
		for c2 in c.get_children():  # quest marker visibilty determines if it is ray pickable
			c2.visible = false


func _load_content():
	var location = GameController.story_flags["windmill_location"]
	cut_plyr.gui.visible = false

	GameController.story_flags["phase"] += 1
	var phase = GameController.story_flags.get("phase")
	if (phase == 3 && location == "ramsar") or phase == 4:
		outro_player.play_outro()
		return
	# start transitions animations
	cut_plyr.cutscene_visible(true)
	if !windmills_built:
		cut_plyr.play("windmill_construction_transition")
		cut_plyr.windmill_quest_markers(false)
		await get_tree().create_timer(0.1).timeout
	else:
		cut_plyr.play("normal_transition_4_weeks")
		await get_tree().create_timer(0.1).timeout

	match location:
		"ramsar":
			load_ramsar_content()
		"fishing":
			load_fishing_content()
		"port":
			load_port_content()
		"shore":
			pass
		"":
			print("no windmill location flag stored")

	#cleanup
	await cut_plyr.animation_finished
	cut_plyr.gui.visible = true
	cut_plyr.cutscene_visible(false)


## Decide which phase of ramsar currently is by looking at Gamecontroller.story_flags
##load content based on that phase
func load_ramsar_content():
	ramsar_path.visible = false
	var phase = GameController.story_flags["phase"]
	var prev_folder = ramsar_path.get_child(phase - 2)
	if prev_folder != null:  # turn of previous
		for c in prev_folder.get_children():
			c.visible = false
	# phase 1 is child 0 folder of ramsar path etc...
	var phase_folder = ramsar_path.get_child(phase - 1)
	if !phase_folder:
		print("phase: " + str(phase) + " folder does not exist")
		return

	phase_folder.visible = true
	ramsar_quest_markers.clear()
	for c in phase_folder.get_children():
		ramsar_quest_markers.append(c)
		c.visible = false
	match phase:
		1:
			quest_folders.clear()
			current_quest = 0
			ramsar_quest_markers[0].quest_path = (
				"res://assets/Story/ramsar_wetland_path/phase_1_early_warning/"
				+ "economic_report.json"
			)
			ramsar_quest_markers[1].quest_path = (
				"res://assets/Story/ramsar_wetland_path/phase_1_early_warning/"
				+ "Tourism_report.json"
			)
			ramsar_quest_markers[2].quest_path = (
				"res://assets/Story/ramsar_wetland_path/phase_1_early_warning/"
				+ "town_hall_emergency_meeting.json"
			)
			quest_folders.append_array(
				[ramsar_quest_markers[0], ramsar_quest_markers[1], ramsar_quest_markers[2]]
			)
			_show_next_quest_markers()
		2:
			quest_folders.clear()
			current_quest = 0
			var choice_1 = GameController.story_flags.get("choice_1")
			var choice_2 = GameController.story_flags.get("choice_2")
			var ending = null
			var all_choices = [choice_1, choice_2]
			if !choice_1 or !choice_2:
				print("one of the choices chosen is null")
				return
			# show poi based on the previous choices
			if "Painting the rotor blades" in all_choices:
				ramsar_quest_markers[1].quest_path = (
					"res://assets/Story/ramsar_wetland_path/phase_2_mitigations_effects/"
					+ "painting_measure.json"
				)
				for c in GameController.all_windmills:
					c.set_blades_red(true)
				quest_folders.append(ramsar_quest_markers[1])
			if "Seasonal Shutdown" in all_choices:
				ramsar_quest_markers[2].quest_path = (
					"res://assets/Story/ramsar_wetland_path/phase_2_mitigations_effects/"
					+ "seasonal_shutdowns.json"
				)
				quest_folders.append(ramsar_quest_markers[2])
			if "Lower Turbines" in all_choices:
				ramsar_quest_markers[0].quest_path = (
					"res://assets/Story/ramsar_wetland_path/phase_2_mitigations_effects/"
					+ "lower_turbines_measure.json"
				)
				for c in GameController.all_windmills:
					c.shorten_windmill()
				quest_folders.append(ramsar_quest_markers[0])

			# decide the ending
			if "Seasonal Shutdown" in all_choices && "Lower Turbines" in all_choices:
				ending = (
					"res://assets/Story/ramsar_wetland_path/phase_3_ending/" + "bad_ending.json"
				)
				GameController.story_flags["ending_score"] = 3
				GameController.story_flags["ending"] = "Ramsar's bad ending"
			elif "Painting the rotor blades" in all_choices && "Lower Turbines" in all_choices:
				ending = (
					"res://assets/Story/ramsar_wetland_path/phase_3_ending/" + "mixed_ending.json"
				)
				GameController.story_flags["ending_score"] = 6
				GameController.story_flags["ending"] = "Ramsar's somewhat good ending"
			elif "Painting the rotor blades" in all_choices && "Seasonal Shutdown" in all_choices:
				# paint + season shutdown
				ending = (
					"res://assets/Story/ramsar_wetland_path/phase_3_ending/" + "good_ending.json"
				)
				GameController.story_flags["ending_score"] = 8
				GameController.story_flags["ending"] = "Ramsar's good ending"
			ramsar_quest_markers[3].quest_path = ending
			quest_folders.append(ramsar_quest_markers[3])
			_show_next_quest_markers()
		3:
			#outro plays alraedy
			pass
	ramsar_path.visible = true


func _get_first_fishing_flag(flag_name: String, fallback: String = "") -> String:
	if not GameController.story_flags.has(flag_name):
		return fallback
	if GameController.story_flags[flag_name].is_empty():
		return fallback
	return str(GameController.story_flags[flag_name])


func _get_story_flag(flag_name: String, fallback: String = "") -> String:
	if not GameController.story_flags.has(flag_name):
		return fallback
	return str(GameController.story_flags.get(flag_name, fallback))


func load_fishing_content():
	fishing_ground_path.visible = false
	var phase = GameController.story_flags["phase"]

	# make prev phase questmarkers invisible
	var prev_folder = fishing_ground_path.get_child(phase - 2)
	if prev_folder != null:
		for c in prev_folder.get_children():
			c.visible = false

	var phase_folder = fishing_ground_path.get_child(phase - 1)
	if !phase_folder:
		print("fishing phase: " + str(phase) + " folder does not exist")
		return
	phase_folder.visible = true
	fishing_quest_markers.clear()
	for c in phase_folder.get_children():
		fishing_quest_markers.append(c)
		c.visible = false

	match phase:
		1:
			current_fishing_quest = 0
			fishing_quest_markers[0].quest_path = (
				FISHING_PATH_STORY_FOLDER + "phase_1_exploration/fishers_guild_report.json"
			)
			#aquanautulis
			fishing_quest_markers[1].quest_path = (
				FISHING_PATH_STORY_FOLDER + "phase_1_exploration/marine_biodiversity_report.json"
			)
			fishing_quest_markers[2].quest_path = (
				FISHING_PATH_STORY_FOLDER + "phase_1_exploration/featherwings.json"
			)
			fishing_quest_markers[3].quest_path = (
				FISHING_PATH_STORY_FOLDER + "phase_1_exploration/port.json"
			)
			_show_next_fishing_quest_markers()
		2:
			current_fishing_quest = 0
			fishing_quest_markers[0].quest_path = (
				FISHING_PATH_STORY_FOLDER + "phase_2_interventions/fishing_meeting.json"
			)
			#aquanautulis
			fishing_quest_markers[1].quest_path = (
				FISHING_PATH_STORY_FOLDER + "phase_2_interventions/port_meeting.json"
			)
			fishing_quest_markers[2].quest_path = (
				FISHING_PATH_STORY_FOLDER + "phase_2_interventions/bird_meeting.json"
			)
			fishing_quest_markers[3].quest_path = (
				FISHING_PATH_STORY_FOLDER + "phase_2_interventions/underwater_noise_meeting.json"
			)
			_show_next_fishing_quest_markers()
		3:
			current_fishing_quest = 0
			var fishing_strategy = _get_first_fishing_flag("fishing_strategy", "")
			var port_strategy = _get_first_fishing_flag("port_strategy", "")
			var bird_strategy = _get_first_fishing_flag("bird_strategy", "")
			var noise_strategy = _get_first_fishing_flag("noise_strategy", "")
			var ending_score = GameController.story_flags["ending_score"]
			var ending_path = null
			for val in GameController.story_flags.values():
				if val in points.keys():
					ending_score += points[val]
			GameController.story_flags["ending_score"] = ending_score
			if ending_score == 10:
				ending_path = FISHING_PATH_STORY_FOLDER + "phase_3_ending/good_ending.json"
				GameController.story_flags["ending"] = "good ending"
			elif ending_score >= 6:
				ending_path = FISHING_PATH_STORY_FOLDER + "phase_3_ending/mixed_ending.json"
				GameController.story_flags["ending"] = "somewhat good ending?"
			else:
				ending_path = FISHING_PATH_STORY_FOLDER + "phase_3_ending/bad_ending.json"
				GameController.story_flags["ending"] = "bad ending"
			fishing_quest_markers[0].quest_path = ending_path
			#if fishing_strategy == "move_wind_park":
			#fishing_quest_markers[0].quest_path = (
			#FISHING_PATH_STORY_FOLDER + "phase_3_ending/bad_ending.json"
			#)
			#GameController.story_flags["ending_score"] = 3
			#GameController.story_flags["ending"] = "Fishing's bad ending"
			#elif noise_strategy == "suction_buckets":
			#fishing_quest_markers[0].quest_path = (
			#FISHING_PATH_STORY_FOLDER + "phase_3_ending/good_ending.json"
			#)
			#GameController.story_flags["ending_score"] = 6
			#GameController.story_flags["ending"] = "Fishing's somewhat good ending?"
			#else:
			#fishing_quest_markers[0].quest_path = (
			#FISHING_PATH_STORY_FOLDER + "phase_3_ending/mixed_ending.json"
			#)
			#GameController.story_flags["ending_score"] = 8
			#GameController.story_flags["ending"] = "Fishing's good ending"
			_show_next_fishing_quest_markers()
	fishing_ground_path.visible = true


func _move_wind_park_outside_territorial_sea() -> void:
	if wind_park_relocated_offshore:
		return
	wind_park_relocated_offshore = true
	GameController.story_flags["build_positions"] = FISHING_OFFSHORE_WIND_PARK_POSITIONS
	GameController.story_flags["wind_park_outside_territorial_sea"] = true
	GameController.relocate_wind_park.emit(FISHING_OFFSHORE_WIND_PARK_POSITIONS)


func load_port_content():
	port_path.visible = false
	var phase = GameController.story_flags["phase"]
	var prev_folder = port_path.get_child(phase - 2)
	if prev_folder != null:
		for c in prev_folder.get_children():
			c.visible = false
	var phase_folder = port_path.get_child(phase - 1)
	if !phase_folder:
		print("port phase: " + str(phase) + " folder does not exist")
		return
	phase_folder.visible = true
	port_quest_markers.clear()
	for c in phase_folder.get_children():
		port_quest_markers.append(c)
		c.visible = false

	match phase:
		1:
			current_port_quest = 0
			port_quest_markers[0].quest_path = (
				PORT_PATH_STORY_FOLDER + "phase_1_exploration/port_authority_report.json"
			)
			port_quest_markers[1].quest_path = (
				PORT_PATH_STORY_FOLDER + "phase_1_exploration/legal_advisor_report.json"
			)
			port_quest_markers[2].quest_path = (
				PORT_PATH_STORY_FOLDER + "phase_1_exploration/port_intervention_meeting.json"
			)
			_show_next_port_quest_markers()
		2:
			current_port_quest = 0
			var port_strategy = _get_story_flag("port_strategy", "leave_port")
			if port_strategy == "move_port":
				_build_kalymera_bridge_for_port()
				port_quest_markers[0].quest_path = (
					PORT_PATH_STORY_FOLDER + "phase_2_interventions/move_port_response.json"
				)
			else:
				port_quest_markers[0].quest_path = (
					PORT_PATH_STORY_FOLDER + "phase_2_interventions/leave_port_response.json"
				)
			port_quest_markers[1].quest_path = (
				PORT_PATH_STORY_FOLDER + "phase_2_interventions/port_budget_review.json"
			)
			_show_next_port_quest_markers()
		3:
			current_port_quest = 0
			var port_strategy = _get_story_flag("port_strategy", "")
			if port_strategy == "move_port":
				port_quest_markers[0].quest_path = (
					PORT_PATH_STORY_FOLDER + "phase_3_ending/good_ending.json"
				)
				GameController.story_flags["ending_score"] = 10
				GameController.story_flags["ending"] = "Port's good ending"
			else:
				port_quest_markers[0].quest_path = (
					PORT_PATH_STORY_FOLDER + "phase_3_ending/bad_ending.json"
				)
				GameController.story_flags["ending_score"] = 0
				GameController.story_flags["ending"] = "Port's bad ending"
			_show_next_port_quest_markers()
	port_path.visible = true


func _build_kalymera_bridge_for_port() -> void:
	if not GameController.story_flags.get("kalymera_bridge_built", false):
		GameController.story_flags["kalymera_bridge_built"] = true
		GameController.build_kalymera_bridge.emit()
	if not GameController.story_flags.get("port_relocated_to_kalymera", false):
		GameController.story_flags["port_relocated_to_kalymera"] = true
		GameController.relocate_port_to_kalymera.emit()


func _show_next_active_quest_markers():
	var location = GameController.story_flags.get("windmill_location", "")
	if location == "fishing":
		_show_next_fishing_quest_markers()
	elif location == "port":
		_show_next_port_quest_markers()
	else:
		_show_next_quest_markers()


func _show_next_quest_markers():
	if !ramsar_quest_markers or !quest_folders or current_quest >= quest_folders.size():
		return
	if current_quest - 1 < 0:
		quest_folders[current_quest].visible = true
		current_quest += 1
		return
	quest_folders[current_quest - 1].visible = false
	quest_folders[current_quest].visible = true
	current_quest += 1


func _show_next_fishing_quest_markers():
	var response_folder = "res://assets/Story/fishing_ground_path/phase_2_interventions/responses/"
	if !fishing_quest_markers or current_fishing_quest >= fishing_quest_markers.size():
		return

	var last_key_val = str(GameController.story_flags.values().back())
	if (
		GameController.story_flags["phase"] == 2
		and current_fishing_quest >= 1
		and last_key_val != temp_holder
	):
		var file = response_folder + last_key_val + ".json"
		await ConversationManager._start_dialogue(ConversationManager._load_dialogue_json(file))
		temp_holder = last_key_val

		# response to the decision made, another flag appended
	if current_fishing_quest - 1 < 0:
		fishing_quest_markers[current_fishing_quest].visible = true
		current_fishing_quest += 1
		return
	fishing_quest_markers[current_fishing_quest - 1].visible = false
	fishing_quest_markers[current_fishing_quest].visible = true
	current_fishing_quest += 1


func _show_next_port_quest_markers():
	if !port_quest_markers or current_port_quest >= port_quest_markers.size():
		return
	if current_port_quest - 1 < 0:
		port_quest_markers[current_port_quest].visible = true
		current_port_quest += 1
		return
	port_quest_markers[current_port_quest - 1].visible = false
	port_quest_markers[current_port_quest].visible = true
	current_port_quest += 1


func spawn_windmills():
	if GameController.story_flags.has("build_positions"):
		windmills_built = true
		var positions = GameController.story_flags.get("build_positions")
		for c in positions:
			var data = BuildingData.new()
			data.building_name = "windmill"
			data.build_position = Vector3i(c[0], c[1], c[2])
			GameController.spawn_building.emit(data)
	else:
		print("no windmill positions found in json")
