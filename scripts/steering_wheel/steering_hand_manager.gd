class_name SteeringHandManager

const HAND_MOVE_SPEED := 500.0

## Type: VisualNode
const RIGHT_HAND := "right_hand"
## Type: bool
const IS_RIGHT_HAND_AVAILABLE := "is_right_hand_available"
## Type: VisualNode
const LEFT_HAND := "left_hand"
## Type: Node2D
const ROTATION_REFERENCE_NODE := "rotation_reference_node"
## Type: Node2D
const STEERING_WHEEL_CONTAINER := "steering_wheel_container"
## Type: SteeringWheelPinContainer
const RIGHT_HAND_PIN_CONTAINER := "right_hand_pin_container"
## Type: SteeringWheelPinContainer
const LEFT_HAND_PIN_CONTAINER := "left_hand_pin_container"

var parameters: Dictionary = { }

var _is_dynamic_animation_enabled: bool = true
var _target_right_hand_pos: Vector2 = Vector2.ZERO
var _target_left_hand_pos: Vector2 = Vector2.ZERO

func process(delta: float) -> void:
    _handle_steering_inputs(delta)

func set_dynamic_animation_enabled(is_enabled: bool) -> void:
    _is_dynamic_animation_enabled = is_enabled

func make_right_hand_available() -> void:
    parameters[IS_RIGHT_HAND_AVAILABLE] = true

func make_right_hand_unavailable() -> void:
    parameters[IS_RIGHT_HAND_AVAILABLE] = false

func _handle_steering_inputs(delta: float) -> void:
    var left_hand := _left_hand()
    var right_hand := _right_hand()
    var steering_wheel := _steering_wheel()
    var is_right_hand_available := _is_right_hand_available()

    _set_steering_angle()

    left_hand.global_position = left_hand.global_position.move_toward(_target_left_hand_pos, HAND_MOVE_SPEED * delta)
    left_hand.global_rotation = (left_hand.global_position - steering_wheel.global_position).angle()

    if is_right_hand_available:
        right_hand.global_position = right_hand.global_position.move_toward(_target_right_hand_pos, HAND_MOVE_SPEED * delta)
        right_hand.global_rotation = (right_hand.global_position - steering_wheel.global_position).angle() - PI

func _set_steering_angle() -> void:
    var right_hand_pin_container := _right_hand_pin_container()
    var left_hand_pin_container := _left_hand_pin_container()

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

    var steering_wheel := _steering_wheel()
    var reference_rotation := _rotation_reference_node().global_rotation

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

func _left_hand() -> VisualNode:
    return parameters[LEFT_HAND]

func _is_right_hand_available() -> bool:
    return parameters[IS_RIGHT_HAND_AVAILABLE]

func _right_hand() -> VisualNode:
    return parameters[RIGHT_HAND]

func _rotation_reference_node() -> Node2D:
    return parameters[ROTATION_REFERENCE_NODE]

func _steering_wheel() -> Node2D:
    return parameters[STEERING_WHEEL_CONTAINER]

func _right_hand_pin_container() -> SteeringWheelPinContainer:
    return parameters[RIGHT_HAND_PIN_CONTAINER]

func _left_hand_pin_container() -> SteeringWheelPinContainer:
    return parameters[LEFT_HAND_PIN_CONTAINER]

func _angle_from_clock(hour: int) -> float:
    hour = hour % 12

    var start_angle := deg_to_rad(-90)
    var angle_span := PI * 2
    var normalized_hour := float(hour) / 12

    return start_angle + angle_span * normalized_hour

#endregion
