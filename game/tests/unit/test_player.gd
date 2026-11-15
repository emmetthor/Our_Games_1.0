extends GutTest

var player: Player

func before_each() -> void:
    player = autofree(Player.new())

# 1. Cannot dash without movement direction
func test_dash_without_direction() -> void:
    player.start_dash(Vector2.ZERO)

    assert_false(player.is_dashing)
    assert_eq(player.velocity, Vector2.ZERO)
    assert_eq(player.cooldown_timer, 0.0)


# 2. Dash velocity should match dash_speed
func test_dash_speed() -> void:
    player.start_dash(Vector2.RIGHT)

    assert_eq(player.velocity, Vector2(420, 0))


# 3. Diagonal dash should have normalized velocity
func test_diagonal_dash() -> void:
    player.start_dash(Vector2(1, 1))

    assert_almost_eq(
        player.velocity.length(),
        player.dash_speed,
        0.001
    )


# 4. Dash should initialize timers
func test_dash_initialization() -> void:
    player.start_dash(Vector2.RIGHT)

    assert_true(player.is_dashing)
    assert_eq(player.dash_timer, player.dash_duration)
    assert_eq(player.cooldown_timer, player.dash_cooldown)
    assert_eq(player.dash_direction, Vector2.RIGHT)


# 5. Dash should maintain velocity
func test_dash_movement() -> void:
    player.start_dash(Vector2.RIGHT)

    player.update_movement(Vector2.UP, 0.05)

    assert_true(player.is_dashing)
    assert_eq(player.velocity, Vector2(420, 0))
    assert_almost_eq(player.dash_timer, 0.10, 0.0001)


# 6. Dash should stop after its duration
func test_dash_ends() -> void:
    player.start_dash(Vector2.RIGHT)

    player.update_movement(Vector2.RIGHT, 0.2)

    assert_false(player.is_dashing)


# 7. Water drag should decrease velocity
func test_water_drag() -> void:
    player.velocity = Vector2(100, 0)

    player.update_movement(Vector2.ZERO, 0.25)

    var expected_speed: float = 100.0 * exp(-1.0)

    assert_almost_eq(
        player.velocity.length(),
        expected_speed,
        0.001
    )


# 8. Acceleration should approach terminal velocity
func test_acceleration() -> void:
    player.velocity = Vector2.ZERO

    player.update_movement(Vector2.RIGHT, 0.25)

    var terminal_speed: float = player.acceleration / player.water_drag
    var expected_speed: float = terminal_speed * (1.0 - exp(-1.0))

    assert_almost_eq(
        player.velocity.x,
        expected_speed,
        0.001
    )

    assert_almost_eq(player.velocity.y, 0.0, 0.001)


# 9. Cooldown should never become negative
func test_cooldown() -> void:
    player.cooldown_timer = 0.1

    player.update_movement(Vector2.ZERO, 0.5)

    assert_eq(player.cooldown_timer, 0.0)