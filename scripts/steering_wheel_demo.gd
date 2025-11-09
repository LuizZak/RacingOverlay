class_name SteeringWheelDemo
extends Node2D

const STEERING_CHANGE_SPEED := deg_to_rad(540)
const HAND_MOVE_SPEED := 500.0

@onready var steering_wheel: Node2D = %SteeringWheel
@onready var right_hand_pin_container: SteeringWheelPinContainer = %RightHandPinContainer
@onready var left_hand_pin_container: SteeringWheelPinContainer = %LeftHandPinContainer
@onready var right_hand: VisualNode = %RightHand
@onready var left_hand: VisualNode = %LeftHand

var steering_hand_manager: SteeringHandManager = SteeringHandManager.new()
var input_manager: InputManagerBase
var keyboard_input_handler: KeyboardInputHandler

func _ready() -> void:
    input_manager = SimulatedInputManager.new()
    keyboard_input_handler = KeyboardInputHandler.new(input_manager)

    steering_hand_manager.parameters[SteeringHandManager.ROTATION_REFERENCE_NODE] = self
    steering_hand_manager.parameters[SteeringHandManager.LEFT_HAND] = left_hand
    steering_hand_manager.parameters[SteeringHandManager.RIGHT_HAND] = right_hand
    steering_hand_manager.parameters[SteeringHandManager.STEERING_WHEEL_CONTAINER] = steering_wheel
    steering_hand_manager.parameters[SteeringHandManager.RIGHT_HAND_PIN_CONTAINER] = right_hand_pin_container
    steering_hand_manager.parameters[SteeringHandManager.LEFT_HAND_PIN_CONTAINER] = left_hand_pin_container

    steering_hand_manager.make_right_hand_available()

func _process(delta: float) -> void:
    var steering_angle := input_manager.steering_amount() * deg_to_rad(Settings.instance.steering_range)

    steering_wheel.rotation = steering_angle

    keyboard_input_handler.process(delta)
    steering_hand_manager.process(delta)

func _on_enable_check_button_toggled(toggled_on: bool) -> void:
    steering_hand_manager.set_dynamic_animation_enabled(toggled_on)
