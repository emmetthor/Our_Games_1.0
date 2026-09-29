class_name GridManager
extends Node

const GRID_SIZE = 32;

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		floor(world_pos.x / GRID_SIZE),
		floor(world_pos.y / GRID_SIZE)
	)

func grid_to_world(cell: Vector2i) -> Vector2:
	return Vector2(
		cell.x * GRID_SIZE,
		cell.y * GRID_SIZE
	)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
