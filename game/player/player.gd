extends CharacterBody2D

@export var acceleration: float = 800.0
@export var water_drag: float = 4.0

@export var dash_speed: float = 420.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 1.0

var is_dashing: bool = false
var dash_timer: float = 0.0
var cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

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

    # update dash cooldown
    cooldown_timer = maxf(cooldown_timer - delta, 0.0)

    if is_dashing:
        dash_timer -= delta

        velocity = dash_direction * dash_speed

        if dash_timer <= 0.0:
            is_dashing = false

    else:
        if get_sprint_input() and cooldown_timer <= 0.0:
            start_dash(direction)
        else:
            var target_velocity := direction * acceleration / water_drag
            velocity = target_velocity + (velocity - target_velocity) * exp(-water_drag * delta)

# collect player sprints
func get_sprint_input() -> bool:
    return Input.is_action_just_pressed("dash")

# start dashing
func start_dash(direction: Vector2) -> void:
    if direction == Vector2.ZERO:
        return

    is_dashing = true
    dash_direction = direction.normalized()
    dash_timer = dash_duration
    cooldown_timer = dash_cooldown

    velocity = dash_direction * dash_speed