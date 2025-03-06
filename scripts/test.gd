extends Node2D

@onready var clutch_progress: ProgressBar = %ClutchProgress
@onready var brake_progress: ProgressBar = %BrakeProgress
@onready var throttle_progress: ProgressBar = %ThrottleProgress

@onready var steering_wheel: Node2D = %SteeringWheel
@onready var right_hand_pin: Marker2D = $SteeringWheel/RightHandPin

@onready var ebrake: Sprite2D = %Ebrake
@onready var ebrake_marker: Marker2D = %EbrakeMarker

@onready var button_1_st: AnimatedSprite2D = $ShifterHints/Button_1st
@onready var button_2_nd: AnimatedSprite2D = $ShifterHints/Button_2nd
@onready var button_3_rd: AnimatedSprite2D = $ShifterHints/Button_3rd
@onready var button_4_th: AnimatedSprite2D = $ShifterHints/Button_4th
@onready var button_5_th: AnimatedSprite2D = $ShifterHints/Button_5th
@onready var button_6_th: AnimatedSprite2D = $ShifterHints/Button_6th
@onready var button_reverse: AnimatedSprite2D = $ShifterHints/Button_reverse

@onready var right_foot: Sprite2D = %RightFoot
@onready var left_foot: Sprite2D = %LeftFoot

@onready var clutch_pedal: Node2D = %ClutchPedal
@onready var brake_pedal: Node2D = %BrakePedal
@onready var throttle_pedal: Node2D = %ThrottlePedal

@onready var shifter_container: ShifterContainer = $ShifterContainer
@onready var shifter_knob: Sprite2D = $ShifterContainer/ShifterKnob

@onready var right_hand: AnimatedSprite2D = %RightHand

var input_manager: InputManagerBase
var keyboard_handler: KeyboardInputHandler

var right_hand_manager: RightHandManager
var feet_manager: FeetManager

func _ready() -> void:
    input_manager = SimulatedInputManager.new()
    keyboard_handler = KeyboardInputHandler.new(input_manager)

    shifter_container.input_manager = input_manager

    feet_manager = FeetManager.new()

    feet_manager.parameters[FeetManager.FM_LEFT_FOOT] = left_foot
    feet_manager.parameters[FeetManager.FM_RIGHT_FOOT] = right_foot

    feet_manager.parameters[FeetManager.FM_CLUTCH_PEDAL] = clutch_pedal
    feet_manager.parameters[FeetManager.FM_BRAKE_PEDAL] = brake_pedal
    feet_manager.parameters[FeetManager.FM_THROTTLE_PEDAL] = throttle_pedal

    right_hand_manager = RightHandManager.new()

    right_hand_manager.parameters[RightHandManager.RHM_INPUT_MANAGER] = input_manager

    right_hand_manager.parameters[RightHandManager.RHM_RIGHT_HAND] = right_hand

    right_hand_manager.parameters[RightHandManager.RHM_SHIFTER_KNOB] = shifter_knob
    right_hand_manager.parameters[RightHandManager.RHM_SHIFTER_CONTAINER] = shifter_container

    right_hand_manager.parameters[RightHandManager.RHM_STEERING_PIN] = right_hand_pin

    right_hand_manager.parameters[RightHandManager.RHM_HANDBRAKE_PIN] = ebrake_marker

    right_hand_manager.parameters[RightHandManager.RHM_GLOBAL_CONTAINER] = self

    right_hand_manager.transition(
        RightHandManager.OnSteeringWheelState.new()
    )

func _process(delta: float) -> void:
    clutch_progress.value = input_manager.clutch_amount() * 100
    brake_progress.value = input_manager.brake_amount() * 100
    throttle_progress.value = input_manager.throttle_amount() * 100
    steering_wheel.rotation_degrees = input_manager.steering_amount() * -450

    update_pedal_position(clutch_pedal, input_manager.normalized_clutch_amount())
    update_pedal_position(brake_pedal, input_manager.normalized_brake_amount())
    update_pedal_position(throttle_pedal, input_manager.normalized_throttle_amount())

    update_handbrake_position(input_manager.handbrake_amount())

    update_button(button_1_st, input_manager.shift_1st())
    update_button(button_2_nd, input_manager.shift_2nd())
    update_button(button_3_rd, input_manager.shift_3rd())
    update_button(button_4_th, input_manager.shift_4th())
    update_button(button_5_th, input_manager.shift_5th())
    update_button(button_6_th, input_manager.shift_6th())
    update_button(button_reverse, input_manager.shift_reverse())

    feet_manager.update_with_pedals(
        input_manager.normalized_clutch_amount(),
        input_manager.normalized_brake_amount(),
        input_manager.normalized_throttle_amount(),
    )

    right_hand_manager.process(delta)
    feet_manager.process(delta)
    keyboard_handler.process(delta)

func update_pedal_position(pedal: Node2D, amount: float):
    pedal.position.y = amount * 25

func update_handbrake_position(amount: float):
    ebrake.global_rotation = amount * deg_to_rad(10)

func update_button(sprite: AnimatedSprite2D, is_pressed: bool):
    sprite.frame = 1 if is_pressed else 0
