extends CharacterBody2D


@export var speed = 300.0

func _physics_process(delta) -> void:

	var direction = Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	velocity = direction * speed;

	move_and_slide()
