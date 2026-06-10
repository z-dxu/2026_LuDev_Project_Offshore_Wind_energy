extends Node

signal metrics_changed

# --- Impacts per turbine ---

# Positive impacts
const ENERGY_INDUSTRY_PER_TURBINE := 3.0  # SDG 7.2 (+3)
const ENERGY_HOUSEHOLD_PER_TURBINE := 1.0  # part of SDG 7.3 (+2, split)
const ENERGY_TRAIN_PER_TURBINE := 1.0  # part of SDG 7.3 (+2, split)
const CO2_REDUCTION_PER_TURBINE := 3.0  # SDG 13 (+3)
const INFRA_SCORE_PER_TURBINE := 7.0  # SDG 9.1 (+3) + 9.2 (+2) + 9.4 (+2)

# Negative impacts
const ECONOMIC_LOSS_PER_TURBINE := 1.0  # SDG 8.5 (-1)
const SOCIAL_IMPACT_PER_TURBINE := 4.0  # SDG 1.2 (-2) + 2.3 (-2)
const ECOSYSTEM_DAMAGE_PER_TURBINE := 6.0  # SDG 14 net (-2) + SDG 15 (-4)

# --- Metrics (NEW SDG-BASED SYSTEM) ---
var metrics = {
	"economic_stability": 100,  # SDG 8 (jobs + income combined)
	"social_stability": 100,  # SDG 1 + 2 (people + food + wellbeing)
	"ecosystem_health": 100,  # SDG 14 + 15 (marine + birds + biodiversity)
	"climate_pressure": 100,  # SDG 13 (CO2 impact, lower is better)
	"renewable_energy": 0,  # SDG 7
	"infrastructure_score": 0  # SDG 9
}

# Keep track of total turbines placed
var turbines_placed := 0


# --- Metric functions ---
# Added prints for debugging, of course they have to go for the full
# actual game
func add_metric(metric_name: String, value: float) -> void:
	if metrics.has(metric_name):
		metrics[metric_name] += value
		metrics[metric_name] = clamp(metrics[metric_name], 0, 100)
		print("Metric ", metric_name, " updated to ", metrics[metric_name])
	else:
		push_warning("Metric '" + metric_name + "' does not exist.")


func set_metric(metric_name: String, value: float) -> void:
	if metrics.has(metric_name):
		metrics[metric_name] = clamp(value, 0, 100)
		print("Metric ", metric_name, " set to ", metrics[metric_name])
	else:
		push_warning("Metric '" + metric_name + "' does not exist.")


func get_metric(metric_name: String) -> float:
	if metrics.has(metric_name):
		return metrics[metric_name]
	push_warning("Metric '" + metric_name + "' does not exist.")
	return 0


# --- Turbine placement impacts ---
func place_turbine():
	turbines_placed += 1

	# Positive impacts
	add_metric(
		"renewable_energy",
		ENERGY_INDUSTRY_PER_TURBINE + ENERGY_HOUSEHOLD_PER_TURBINE + ENERGY_TRAIN_PER_TURBINE
	)

	add_metric("climate_pressure", -CO2_REDUCTION_PER_TURBINE)
	add_metric("infrastructure_score", INFRA_SCORE_PER_TURBINE)

	# Negative impacts
	add_metric("economic_stability", -ECONOMIC_LOSS_PER_TURBINE)
	add_metric("social_stability", -SOCIAL_IMPACT_PER_TURBINE)
	add_metric("ecosystem_health", -ECOSYSTEM_DAMAGE_PER_TURBINE)

	print("Turbine placed! Total turbines:", turbines_placed)


func remove_turbine():
	if turbines_placed <= 0:
		return

	turbines_placed -= 1

	# Undo positive impacts
	add_metric(
		"renewable_energy",
		-(ENERGY_INDUSTRY_PER_TURBINE + ENERGY_HOUSEHOLD_PER_TURBINE + ENERGY_TRAIN_PER_TURBINE)
	)

	add_metric("climate_pressure", CO2_REDUCTION_PER_TURBINE)
	add_metric("infrastructure_score", -INFRA_SCORE_PER_TURBINE)

	# Undo negative impacts
	add_metric("economic_stability", ECONOMIC_LOSS_PER_TURBINE)
	add_metric("social_stability", SOCIAL_IMPACT_PER_TURBINE)
	add_metric("ecosystem_health", ECOSYSTEM_DAMAGE_PER_TURBINE)

	print("Turbine removed! Total turbines:", turbines_placed)
