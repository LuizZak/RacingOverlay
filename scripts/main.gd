extends Node

const CONTAINER_SCALE_SPEED: float = 0.1
const CONTAINER_MOVE_SPEED: float = 10

@onready var ui_container: MarginContainer = %UIContainer
@onready var controls_rebind: ControlsRebind = %ControlsRebind
@onready var settings_panel: SettingsPanel = %SettingsPanel

@onready var container: Node2D = %Container

@onready var clutch_progress: ProgressBar = %ClutchProgress
@onready var brake_progress: ProgressBar = %BrakeProgress
@onready var throttle_progress: ProgressBar = %ThrottleProgress

@onready var steering_wheel_indicator: SteeringWheelIndicator = %SteeringWheelIndicator
@onready var steering_wheel: Node2D = %SteeringWheel
@onready var right_hand_pin: Marker2D = %SteeringWheel/RightHandPin

@onready var ebrake: VisualNode = %Ebrake
@onready var ebrake_marker: Marker2D = %EbrakeMarker

@onready var right_foot: VisualNode = %RightFoot
@onready var left_foot: VisualNode = %LeftFoot

@onready var pedals_container: PedalsContainer = %Container/PedalsContainer

@onready var pedals: Node2D = %Container/PedalsContainer/PedalsOffsetContainer/Pedals
@onready var clutch_pedal: Node2D = %ClutchPedal
@onready var brake_pedal: Node2D = %BrakePedal
@onready var throttle_pedal: Node2D = %ThrottlePedal

@onready var shifter_container: ShifterContainer = %Container/ShifterContainer
@onready var shifter_knob: VisualNode = %ShifterKnob

@onready var steering_wheel_sprite: VisualNode = %SteeringWheelSprite
@onready var ebrake_base: VisualNode = %EbrakeBase
@onready var shifter_base: VisualNode = %ShifterBase
@onready var pedal_throttle: VisualNode = %PedalThrottle
@onready var throttle_pedal_fixture: VisualNode = %ThrottlePedalFixture
@onready var pedal_brake: VisualNode = %PedalBrake
@onready var brake_pedal_fixture: VisualNode = %BrakePedalFixture
@onready var pedal_clutch: VisualNode = %PedalClutch
@onready var clutch_pedal_fixture: VisualNode = %ClutchPedalFixture
@onready var pedal_base: VisualNode = %PedalBase

@onready var left_hand: VisualNode = %LeftHand
@onready var right_hand: VisualNode = %RightHand

var ui_container_tween: Tween = null

var input_manager: InputManagerBase
var keyboard_handler: KeyboardInputHandler

var right_hand_manager: RightHandManager
var feet_manager: FeetManager
var sequential_shifter_manager: SequentialShifterManager

var target_container_rotation: float = 0.0
var target_container_scale: Vector2 = Vector2.ONE
var target_container_position: Vector2 = Vector2.ONE

var packet_manager: PacketManagerBase

func _ready() -> void:
    if not container.get_viewport_rect().has_point(container.get_global_mouse_position()):
        hide_ui()

    packet_manager = PacketManagerBase.new(Networking.instance)

    input_manager = InputManagerBase.new()
    #keyboard_handler = KeyboardInputHandler.new(input_manager)
    sequential_shifter_manager = SequentialShifterManager.new()

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

    right_hand_manager.parameters[RightHandManager.RHM_GLOBAL_CONTAINER] = container

    right_hand_manager.parameters[RightHandManager.RHM_SEQUENTIAL_SHIFTER_MANAGER] = sequential_shifter_manager

    right_hand_manager.transition(
        RightHandManager.OnSteeringWheelState.new()
    )

    _reload_assets()

    Settings.instance.on_settings_changed.connect(_on_settings_changed)

    # Force-apply current settings
    _on_settings_changed()
    _reset_game_state()

func _process(delta: float) -> void:
    Networking.instance.poll_connections()

    if Networking.instance.is_connected_to_game():
        packet_manager.process(delta)
        _update_game_state()
    else:
        _reset_game_state()

    container.rotation = target_container_rotation
    container.scale = container.scale.move_toward(target_container_scale, CONTAINER_SCALE_SPEED * delta)
    container.position = container.position.move_toward(target_container_position, CONTAINER_MOVE_SPEED * delta)

    clutch_progress.value = input_manager.clutch_amount() * 100
    brake_progress.value = input_manager.brake_amount() * 100
    throttle_progress.value = input_manager.throttle_amount() * 100
    steering_wheel.rotation_degrees = input_manager.steering_amount() * -(Settings.instance.steering_range / 2.0)
    steering_wheel_indicator.normalized_value = input_manager.steering_amount()

    pedals_container.update_pedals(
        input_manager.normalized_clutch_amount(),
        input_manager.normalized_brake_amount(),
        input_manager.normalized_throttle_amount(),
    )

    update_handbrake_position(input_manager.handbrake_amount())

    feet_manager.update_with_pedals(
        input_manager.normalized_clutch_amount(),
        input_manager.normalized_brake_amount(),
        input_manager.normalized_throttle_amount(),
    )

    sequential_shifter_manager.update_inputs(input_manager)

    right_hand_manager.process(delta)
    feet_manager.process(delta)

    if keyboard_handler != null:
        keyboard_handler.process(delta)

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_MOUSE_ENTER:
        show_ui()
    elif what == NOTIFICATION_WM_MOUSE_EXIT:
        hide_ui()

func _reset_game_state():
    target_container_rotation = 0.0
    target_container_scale = Vector2.ONE
    target_container_position = Vector2.ZERO

func _update_game_state():
    # Zeroed out packet means this is a close packet
    if packet_manager.is_end_packet():
        _reset_game_state()
        return

    if Settings.instance.active_game_settings().move_vertically:
        target_container_position.y = packet_manager.vertical_velocity()
    else:
        target_container_position = Vector2.ZERO

    if Settings.instance.active_game_settings().scale_with_speed:
        target_container_scale = Vector2.ONE - Vector2.ONE * (sqrt(packet_manager.forward_velocity()) / 100)
    else:
        target_container_scale = Vector2.ONE

    if Settings.instance.active_game_settings().roll_with_vehicle:
        target_container_rotation = packet_manager.roll_angle()
    else:
        target_container_rotation = 0.0

func show_ui():
    if not is_inside_tree():
        return

    if ui_container_tween != null && ui_container_tween.is_running():
        ui_container_tween.kill()

    ui_container_tween = get_tree().create_tween()
    ui_container_tween.tween_property(ui_container, "modulate:a", 1.0, 0.3)

func hide_ui():
    if not is_inside_tree():
        return

    if ui_container_tween != null && ui_container_tween.is_running():
        ui_container_tween.kill()

    ui_container_tween = get_tree().create_tween()
    ui_container_tween.tween_property(ui_container, "modulate:a", 0.0, 0.3)

func update_handbrake_position(amount: float):
    ebrake.rotation = amount * deg_to_rad(10)

func update_button(sprite: AnimatedSprite2D, is_pressed: bool):
    sprite.frame = 1 if is_pressed else 0

func _reload_assets():
    left_foot.refresh_display()
    right_foot.refresh_display()
    ebrake.refresh_display()
    ebrake_base.refresh_display()
    left_hand.refresh_display()
    pedal_base.refresh_display()
    pedal_clutch.refresh_display()
    clutch_pedal_fixture.refresh_display()
    pedal_brake.refresh_display()
    brake_pedal_fixture.refresh_display()
    throttle_pedal_fixture.refresh_display()
    shifter_base.refresh_display()
    shifter_knob.refresh_display()
    steering_wheel_sprite.refresh_display()
    right_hand_manager.transition(
        RightHandManager.OnSteeringWheelState.new()
    )

func _on_settings_changed():
    var filter = Node2D.TEXTURE_FILTER_NEAREST
    if Settings.instance.smooth_textures:
        filter = Node2D.TEXTURE_FILTER_LINEAR

    container.texture_filter = filter

    steering_wheel_indicator.visible = Settings.instance.steering_wheel_progress

    Networking.instance.set_port(
        Settings.instance.active_game_settings().port
    )
    Networking.instance.set_game(
        GamePacketBase.game_from_game_connection_settings(
            Settings.instance.active_game
        )
    )
    if Settings.instance.connect_to_game:
        Networking.instance.set_mode(NetworkingBase.Mode.CONNECT)
    else:
        Networking.instance.set_mode(NetworkingBase.Mode.DISCONNECT)

func _on_bindings_button_pressed() -> void:
    controls_rebind.show()

func _on_controls_rebind_on_close_pressed() -> void:
    controls_rebind.hide()

func _on_reload_assets_button_pressed() -> void:
    _reload_assets()

func _on_settings_button_pressed() -> void:
    settings_panel.show()

func _on_settings_panel_on_close_pressed() -> void:
    settings_panel.hide()

func _on_reset_transforms_button_pressed() -> void:
    _reset_game_state()
