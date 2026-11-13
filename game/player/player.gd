extends CharacterBody2D

@export var acceleration: float = 800.0
@export var water_drag: float = 4.0

func _physics_process(delta: float) -> void:
    var direction := get_movement_input()
    update_movement(direction, delta)
    move_and_slide()

# collect player inputs
func get_movement_input() -> Vector2:
    return Input.get_vector(
        "move_left",
        "move_right",
        "move_up",
        "move_down"
    )

# calculate player movement physics
func update_movement(direction: Vector2, delta: float) -> void:
    var target_velocity := direction * acceleration / water_drag

    velocity = target_velocity + (velocity - target_velocity) * exp(-water_drag * delta)