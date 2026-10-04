extends Node2D

@export var grid_manager: GridManager
@export var building_scene: PackedScene
@export var preview: Node2D

var build_mode := false

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if not build_mode:
		return

	var mouse_world := get_global_mouse_position()
	var cell := grid_manager.world_to_grid(mouse_world)
	var world_pos := grid_manager.grid_to_world(cell)

	preview.global_position = world_pos


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("build_mode"):
		print("start build mode")
		start_build_mode()

	if not build_mode:
		return

	if event.is_action_pressed("build_place"):
		print("start placing")
		place_building()

	if event.is_action_pressed("ui_cancel"):
		print("stop print mode")
		cancel_build_mode()


func start_build_mode() -> void:
	build_mode = true
	preview.visible = true


func cancel_build_mode() -> void:
	build_mode = false
	preview.visible = false


func place_building() -> void:
	var building := building_scene.instantiate()

	building.global_position = preview.global_position

	get_parent().add_child(building)
