extends GridMap
@export var windmill_scene:PackedScene
#@export var sdg_offset:Vector3 = Vector3(0,21,0)
@export var building_range = 5

var Sdg_cells = {}
@onready var highlight: Node3D = $Highlight
@onready var sdg_2_food: Sprite3D = $SDG2_food
@onready var sdg_images: Node3D = $SDG_images
@onready var number_mesh: MeshInstance3D = $Number_mesh
@onready var sdg_text_meshes: Node3D = $SdgTextMeshes

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameController.spawn_building.connect(_spawn_building)
	_spawn_SDG_goals()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _spawn_building(building_name:String):
	var highlight_pos = self.to_local(highlight.global_position) #current highlight position at the point of clicking
	var cel_pos = local_to_map(highlight_pos) # get the center of the cell position 
	var build_pos = map_to_local(cel_pos) + Vector3(-4,0,0) # get local pos for building. The building is a child of this node (no need for global)
	print("building... " + str(building_name) + " Building on cell: " +str(cel_pos) )
	match building_name:
		"windmill":
			var building = windmill_scene.instantiate()
			self.add_child(building)
			building.position = build_pos	
			var sdgs_in_range = _SDG_in_range(cel_pos) # returns vector3i with sdg imgs
			print("sdg cells: " + str(sdgs_in_range))
			var SDG_cel_pos = sdgs_in_range
			for pos in SDG_cel_pos:
				var mesh_dupe:TextMesh = number_mesh.mesh.duplicate() # avoid number change for all meshes
				var new_mesh_inst = MeshInstance3D.new()
				new_mesh_inst.mesh = mesh_dupe
				
				var mesh_pos = map_to_local(pos)
				new_mesh_inst.position = mesh_pos
				new_mesh_inst.rotation_degrees= Vector3(-90,0,0)
				mesh_dupe.text = str(-2)
				sdg_text_meshes.add_child(new_mesh_inst)
				new_mesh_inst.visible = true
				
			
					
	pass
func _spawn_SDG_goals():
	
	var food_pos = [Vector3i(23,1,-21),Vector3i(23,1,-20),Vector3i(22,1,-20), Vector3i(23,1,-19)]
	Sdg_cells.set("food",food_pos)
	for cel_pos in food_pos:
		var food:Sprite3D = sdg_2_food.duplicate()
		var img_pos = map_to_local(cel_pos)#+ sdg_offset
		food.position = img_pos
		food.visible = true	
		sdg_images.add_child(food)
		
	pass
	
func _SDG_in_range(current_cel_pos: Vector3i):
	return Sdg_cells["food"] # temp 
