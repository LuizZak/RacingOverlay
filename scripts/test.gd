extends Node

@onready var ui_container: MarginContainer = %UIContainer
@onready var controls_rebind: ControlsRebind = %ControlsRebind
@onready var settings_panel: SettingsPanel = %SettingsPanel

@onready var container: Node2D = $Container

@onready var clutch_progress: ProgressBar = %ClutchProgress
@onready var brake_progress: ProgressBar = %BrakeProgress
@onready var throttle_progress: ProgressBar = %ThrottleProgress

@onready var steering_wheel: Node2D = %SteeringWheel
@onready var right_hand_pin: Marker2D = $Container/SteeringWheel/RightHandPin

@onready var ebrake: Sprite2D = %Ebrake
@onready var ebrake_marker: Marker2D = %EbrakeMarker

@onready var right_foot: Sprite2D = %RightFoot
@onready var left_foot: Sprite2D = %LeftFoot

@onready var pedals_container: PedalsContainer = $Container/PedalsContainer

@onready var pedals: Node2D = $Container/PedalsContainer/PedalsOffsetContainer/Pedals
@onready var clutch_pedal: Node2D = %ClutchPedal
@onready var brake_pedal: Node2D = %BrakePedal
@onready var throttle_pedal: Node2D = %ThrottlePedal

@onready var shifter_container: ShifterContainer = $Container/ShifterContainer
@onready var shifter_knob: Sprite2D = %ShifterKnob

@onready var steering_wheel_sprite: Sprite2D = %SteeringWheelSprite
@onready var ebrake_base: Sprite2D = %EbrakeBase
@onready var shifter_base: Sprite2D = %ShifterBase
@onready var pedal_throttle: Sprite2D = %PedalThrottle
@onready var throttle_pedal_fixture: Sprite2D = %ThrottlePedalFixture
@onready var pedal_brake: Sprite2D = %PedalBrake
@onready var brake_pedal_fixture: Sprite2D = %BrakePedalFixture
@onready var pedal_clutch: Sprite2D = %PedalClutch
@onready var clutch_pedal_fixture: Sprite2D = %ClutchPedalFixture
@onready var pedal_base: Sprite2D = %PedalBase

@onready var left_hand: Sprite2D = %LeftHand
@onready var right_hand: Sprite2D = %RightHand

var ui_container_tween: Tween = null

var input_manager: InputManagerBase
var keyboard_handler: KeyboardInputHandler

var right_hand_manager: RightHandManager
var feet_manager: FeetManager

func _ready() -> void:
    if not container.get_viewport_rect().has_point(container.get_local_mouse_position()):
        hide_ui()

    input_manager = InputManagerBase.new()
    #keyboard_handler = KeyboardInputHandler.new(input_manager)

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

    _reload_assets()

    Settings.instance.on_settings_changed.connect(_on_settings_changed)

    # Force-apply current settings
    _on_settings_changed()

func _process(delta: float) -> void:
    clutch_progress.value = input_manager.clutch_amount() * 100
    brake_progress.value = input_manager.brake_amount() * 100
    throttle_progress.value = input_manager.throttle_amount() * 100
    steering_wheel.rotation_degrees = input_manager.steering_amount() * -450

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

    right_hand_manager.process(delta)
    feet_manager.process(delta)

    if keyboard_handler != null:
        keyboard_handler.process(delta)

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_MOUSE_ENTER:
        show_ui()
    elif what == NOTIFICATION_WM_MOUSE_EXIT:
        hide_ui()

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
    ebrake.global_rotation = amount * deg_to_rad(10)

func update_button(sprite: AnimatedSprite2D, is_pressed: bool):
    sprite.frame = 1 if is_pressed else 0

func _reload_assets():
    left_foot.texture = CustomResourceLoader.instance.load_texture(
        CustomResourceLoader.FOOT_LEFT
    )
    right_foot.texture = CustomResourceLoader.instance.load_texture(
        CustomResourceLoader.FOOT_RIGHT
    )
    ebrake.texture = CustomResourceLoader.instance.load_texture(
        CustomResourceLoader.EBRAKE
    )
    ebrake_base.texture = CustomResourceLoader.instance.load_texture(
        CustomResourceLoader.EBRAKE_BASE
    )
    left_hand.texture = CustomResourceLoader.instance.load_texture(
        CustomResourceLoader.HAND_LEFT
    )
    pedal_base.texture = CustomResourceLoader.instance.load_texture(
        CustomResourceLoader.PEDAL_BASE
    )
    pedal_clutch.texture = CustomResourceLoader.instance.load_texture(
        CustomResourceLoader.PEDAL_CLUTCH
    )
    clutch_pedal_fixture.texture = CustomResourceLoader.instance.load_texture(
        CustomResourceLoader.PEDAL_FIXTURE
    )
    brake_pedal_fixture.texture = CustomResourceLoader.instance.load_texture(
        CustomResourceLoader.PEDAL_FIXTURE
    )
    throttle_pedal_fixture.texture = CustomResourceLoader.instance.load_texture(
        CustomResourceLoader.PEDAL_FIXTURE
    )
    shifter_base.texture = CustomResourceLoader.instance.load_texture(
        CustomResourceLoader.SHIFTER_BASE
    )
    shifter_knob.texture = CustomResourceLoader.instance.load_texture(
        CustomResourceLoader.SHIFTER_KNOB
    )
    steering_wheel_sprite.texture = CustomResourceLoader.instance.load_texture(
        CustomResourceLoader.STEERING_WHEEL
    )
    right_hand_manager.transition(
        RightHandManager.OnSteeringWheelState.new()
    )

func _on_settings_changed():
    var filter = Node2D.TEXTURE_FILTER_NEAREST
    if Settings.instance.smooth_textures:
        filter = Node2D.TEXTURE_FILTER_LINEAR

    container.texture_filter = filter

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
