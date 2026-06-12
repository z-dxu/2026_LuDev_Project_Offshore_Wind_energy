extends Node
#signal that every script can read cuz this is a global script set by me -zdxu
signal spawn_building(data: BuildingData)
signal relocate_wind_park(positions: Array)
signal build_kalymera_bridge
signal relocate_port_to_kalymera

signal story_flag_appended
signal next_phase
# Dialogue history — populated by dialogue_controller.gd as player advances
# Dialogue history — populated by conversation.gd as player advances
signal dialogue_history_updated
var dialogue_history: Array[Dictionary] = []

# al of these should be reset to these same value
var story_flags = {"phase": 0, "ending": "null", "ending_score": 0}
var all_windmills = []
#allows the highlighter to move around, and prevent moving during animation
var allow_highlighter_move := true

# ship pathing
var total_endings = []
var harbor_pos = []
