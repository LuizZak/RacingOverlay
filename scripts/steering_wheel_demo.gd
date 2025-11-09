class_name SteeringWheelDemo
extends Node2D

const STEERING_CHANGE_SPEED := deg_to_rad(360)
const HAND_MOVE_SPEED := 500.0

@onready var steering_wheel: Node2D = %SteeringWheel
@onready var right_hand_pin_container: SteeringWheelPinContainer = %RightHandPinContainer
@onready var left_hand_pin_container: SteeringWheelPinContainer = %LeftHandPinContainer
@onready var right_hand: VisualNode = %RightHand
@onready var left_hand: VisualNode = %LeftHand

var _target_left_hand_pos: Vector2 = Vector2.ZERO
var _target_right_hand_pos: Vector2 = Vector2.ZERO

var steering_angle: float = 0.0
var max_steering_angle_absolute: float = PI * 1.5

func _process(delta: float) -> void:
    _handle_steering_inputs(delta)

func _handle_steering_inputs(delta: float) -> void:
    var axis := Input.get_axis("Simulated_left", "Simulated_right")

    if axis != 0.0:
        steering_angle = move_toward(steering_angle, max_steering_angle_absolute * axis, STEERING_CHANGE_SPEED * delta)

    _set_steering_angle(steering_angle)

    left_hand.global_position = left_hand.global_position.move_toward(_target_left_hand_pos, HAND_MOVE_SPEED * delta)
    right_hand.global_position = right_hand.global_position.move_toward(_target_right_hand_pos, HAND_MOVE_SPEED * delta)

    left_hand.global_rotation = (left_hand.global_position - steering_wheel.global_position).angle()
    right_hand.global_rotation = (right_hand.global_position - steering_wheel.global_position).angle() - PI

func _set_steering_angle(angle: float) -> void:
    steering_wheel.rotation = angle

    var right_closest_pin := _next_pin_from_angle(
        right_hand_pin_container,
        _angle_from_clock(9)
    )
    var left_closest_pin := _next_pin_from_angle(
        left_hand_pin_container,
        _angle_from_clock(3)
    )

    if right_closest_pin != null:
        _target_right_hand_pos = right_closest_pin.global_position
    if left_closest_pin != null:
        _target_left_hand_pos = left_closest_pin.global_position

#
#func _next_pin_from_angle(container: SteeringWheelPinContainer, target_angle: float) -> Marker2D:
    #var pins := container.get_pins()
#
    #var entries: Array[_PinEntry] = []
#
    #for pin in pins:
        #var rel_position := pin.global_position - steering_wheel.global_position
        #var angle := rel_position.angle()
#
        #var diff_angle := angle_difference(target_angle, angle)
#
        #var entry := _PinEntry.new(pin, diff_angle)
        #entries.append(entry)
#
    #entries.sort_custom(
        #func(a: _PinEntry, b: _PinEntry):
            #return a.angle_to_target < b.angle_to_target
    #)
#
    #return entries[0].pin



func _next_pin_from_angle(container: SteeringWheelPinContainer, target_angle: float) -> Marker2D:
    var pins := container.get_pins()

    var closest_pin: Marker2D = null
    var closest_pin_angle: float = 0.0

    for pin in pins:
        var rel_position := pin.global_position - steering_wheel.global_position
        var angle := rel_position.angle()

        if closest_pin == null:
            closest_pin = pin
            closest_pin_angle = angle
            continue

        var diff_angle := angle_difference(target_angle, angle)
        var diff_closest_angle := angle_difference(target_angle, closest_pin_angle)

        if absf(diff_angle) < absf(diff_closest_angle):
            closest_pin = pin
            closest_pin_angle = angle

    return closest_pin


#
#func _next_pin_from_angle(container: SteeringWheelPinContainer, target_angle: float) -> Marker2D:
    #var pins := container.get_pins()
#
    #var closest_pin: Marker2D = null
    #var closest_pin_angle: float = 0.0
#
    #for pin in pins:
        #var rel_position := pin.global_position - steering_wheel.global_position
        #var angle := rel_position.angle()
#
        #if closest_pin == null:
            #closest_pin = pin
            #closest_pin_angle = angle
            #continue
#
        #var diff_angle := angle_difference(target_angle, angle)
        #var diff_closest_angle := angle_difference(target_angle, closest_pin_angle)
#
        #if diff_angle >= 0.0 and diff_angle < absf(diff_closest_angle):
            #closest_pin = pin
            #closest_pin_angle = angle
#
    #return closest_pin

func _angle_from_clock(hour: int) -> float:
    hour = hour % 12

    var start_angle := deg_to_rad(-90)
    var angle_span := PI * 2
    var normalized_hour := float(hour) / 12

    return start_angle + angle_span * normalized_hour

class _PinEntry:
    var pin: Marker2D
    var angle_to_target: float

    func _init(pin: Marker2D, angle_to_target: float) -> void:
        self.pin = pin

        if angle_to_target < 0:
            self.angle_to_target = PI * 2 + angle_to_target
        else:
            self.angle_to_target = angle_to_target
