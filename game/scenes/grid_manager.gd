class_name GridManager
extends Node

const GRID_SIZE = 32;

var occupied_cells: Dictionary = {}

@export var ground : TileMapLayer

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return ground.local_to_map(ground.to_local(world_pos))

func grid_to_world(cell: Vector2i) -> Vector2:
	return ground.to_global(ground.map_to_local(cell))

func occupy(cell: Vector2i, building: Node) -> void:
	occupied_cells[cell] = building

func clear_occupy(cell: Vector2i) -> void:
	occupied_cells.erase(cell)

func is_occupied(cell: Vector2i) -> bool:
	return occupied_cells.has(cell)

func get_building(cell: Vector2i) -> Node:
	return occupied_cells.get(cell)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
