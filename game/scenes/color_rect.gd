extends ColorRect

@export var grid_manager: GridManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_world := get_global_mouse_position();
	var cell = grid_manager.world_to_grid(mouse_world)
	var snapped_pos = grid_manager.grid_to_world(cell)

	position = snapped_pos