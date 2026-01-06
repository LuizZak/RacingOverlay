class_name SteeringHandManager

const HAND_MOVE_SPEED := 500.0

var right_hand: VisualNode
var is_right_hand_available: bool
var left_hand: VisualNode
var rotation_reference_node: Node2D
var steering_wheel_container: Node2D
var right_hand_pin_container: SteeringWheelPinContainer
var left_hand_pin_container: SteeringWheelPinContainer

var _is_dynamic_animation_enabled: bool = true
var _target_right_hand_pos: Vector2 = Vector2.ZERO
var _target_left_hand_pos: Vector2 = Vector2.ZERO

func process(delta: float) -> void:
    _handle_steering_inputs(delta)

func set_dynamic_animation_enabled(is_enabled: bool) -> void:
    _is_dynamic_animation_enabled = is_enabled

func make_right_hand_available() -> void:
    is_right_hand_available = true

func make_right_hand_unavailable() -> void:
    is_right_hand_available = false

func _handle_steering_inputs(delta: float) -> void:
    _set_steering_angle()

    if _is_dynamic_animation_enabled:
        left_hand.global_position = left_hand.global_position.move_toward(_target_left_hand_pos, HAND_MOVE_SPEED * delta)
        left_hand.global_rotation = (left_hand.global_position - steering_wheel_container.global_position).angle()

        if is_right_hand_available:
            right_hand.global_position = right_hand.global_position.move_toward(_target_right_hand_pos, HAND_MOVE_SPEED * delta)
            right_hand.global_rotation = (right_hand.global_position - steering_wheel_container.global_position).angle() - PI
    else:
        left_hand.global_position = _target_left_hand_pos
        left_hand.global_rotation = (left_hand.global_position - steering_wheel_container.global_position).angle()

        if is_right_hand_available:
            right_hand.global_position = _target_right_hand_pos
            right_hand.global_rotation = (right_hand.global_position - steering_wheel_container.global_position).angle() - PI

func _set_steering_angle() -> void:
    var right_closest_pin := _closest_pin_from_angle(
        right_hand_pin_container,
        _angle_from_clock(9)
    )
    var left_closest_pin := _closest_pin_from_angle(
        left_hand_pin_container,
        _angle_from_clock(3)
    )

    if right_closest_pin != null:
        _target_right_hand_pos = right_closest_pin.global_position
    if left_closest_pin != null:
        _target_left_hand_pos = left_closest_pin.global_position

func _closest_pin_from_angle(container: SteeringWheelPinContainer, target_angle: float) -> Marker2D:
    var pins := container.get_pins()

    var closest_pin: Marker2D = null
    var closest_pin_diff: float = 0.0

    var steering_wheel := steering_wheel_container
    var reference_rotation := rotation_reference_node.global_rotation

    if not _is_dynamic_animation_enabled:
        target_angle = target_angle + steering_wheel.rotation

    for pin in pins:
        var rel_position := pin.global_position - steering_wheel.global_position
        var angle := rel_position.angle() - reference_rotation

        if closest_pin == null:
            closest_pin = pin
            closest_pin_diff = absf(angle_difference(target_angle, angle))
            continue

        var diff_angle := absf(angle_difference(target_angle, angle))

        if diff_angle < closest_pin_diff:
            closest_pin = pin
            closest_pin_diff = diff_angle

    return closest_pin

#region Parameter Getters

func _angle_from_clock(hour: int) -> float:
    hour = hour % 12

    var start_angle := deg_to_rad(-90)
    var angle_span := PI * 2
    var normalized_hour := float(hour) / 12

    return start_angle + angle_span * normalized_hour

#endregion
