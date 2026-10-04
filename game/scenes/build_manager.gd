extends Node2D

@export var grid_manager: GridManager
@export var building_scene: PackedScene
@export var preview: Node2D
@export var preview_square: ColorRect

var current_cell: Vector2i

var build_mode := false
var is_drag_building := false
const INIT_BUILD_CELL = Vector2i(-999999, -999999)
var last_build_cell = INIT_BUILD_CELL

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if not build_mode:
		return

	var mouse_world := get_global_mouse_position()
	current_cell = grid_manager.world_to_grid(mouse_world)
	var world_pos := grid_manager.grid_to_world(current_cell)

	preview.global_position = world_pos

	if grid_manager.is_occupied(current_cell):
		preview_square.color = Color(1.0, 0.2, 0.2, 0.5)
	else:
		preview_square.color = Color(0.2, 1.0, 0.2, 0.5)

	if is_drag_building and last_build_cell != current_cell:
		place_building()
		last_build_cell = current_cell


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("build_mode") and build_mode == false:
		print("start build mode")
		start_build_mode()
	elif event.is_action_pressed("build_mode") and build_mode == true:
		print("stop build mode")
		cancel_build_mode()

	if not build_mode:
		return

	if event.is_action_pressed("build_place"):
		print("start placing")
		is_drag_building = true;
		last_build_cell = INIT_BUILD_CELL
		place_building()

	if event.is_action_released("build_place"):
		is_drag_building = false;

	if event.is_action_pressed("remove_building"):
		print("start removing")
		remove_building()

	if event.is_action_pressed("ui_cancel"):
		print("stop build mode")
		cancel_build_mode()


func start_build_mode() -> void:
	build_mode = true
	preview.visible = true


func cancel_build_mode() -> void:
	build_mode = false
	preview.visible = false


func place_building() -> void:
	if (current_cell == last_build_cell):
		return

	if grid_manager.is_occupied(current_cell):
		print("you can't build here")
		return

	var building := building_scene.instantiate()

	grid_manager.occupy(current_cell, building)

	building.global_position = preview.global_position

	get_parent().add_child(building)
	
	print("built at", preview.global_position)

func remove_building() -> void:
	if not grid_manager.is_occupied(current_cell):
		return
	
	var building := grid_manager.get_building(current_cell)
	
	grid_manager.clear_occupy(current_cell)
	building.queue_free()