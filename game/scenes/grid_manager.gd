class_name GridManager
extends Node

const GRID_SIZE = 32;

@export var ground : TileMapLayer

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return ground.local_to_map(ground.to_local(world_pos))

func grid_to_world(cell: Vector2i) -> Vector2:
	return ground.to_global(ground.map_to_local(cell))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
