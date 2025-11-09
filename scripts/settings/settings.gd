class_name SettingsPanel
extends MarginContainer

@onready
var pedal_mode_option_button: OptionButton = %PedalModeOptionButton
@onready
var rest_hand_position_option_button: OptionButton = %RestHandPositionOptionButton
@onready
var steering_range_spin_box: SpinBox = %SteeringRangeSpinBox
@onready
var smooth_textures_checkbox: CheckBox = %SmoothTexturesCheckbox
@onready
var steering_wheel_progress_bar: CheckBox = %SteeringWheelProgressBar
@onready
var shifter_fill_color_button: ColorPickerButton = %ShifterFillColorButton
@onready
var shifter_outline_color_button: ColorPickerButton = %ShifterOutlineColorButton
@onready
var pedal_bar_fill_color_button: ColorPickerButton = %PedalBarFillColorButton
@onready
var pedal_vibration_checkbox: CheckBox = %PedalVibrationCheckbox
@onready
var pedal_vibration_slider: HSlider = %PedalVibrationSlider
@onready
var pedal_sink_checkbox: CheckBox = %PedalSinkCheckbox
@onready
var dynamic_steering_hand_animation_checkbox: CheckBox = %DynamicSteeringHandAnimationCheckbox

signal on_close_pressed()

func _ready() -> void:
    _populate_settings()

func _populate_settings() -> void:
    _populate_pedal_mode()
    _populate_rest_hand_position()
    pedal_vibration_checkbox.button_pressed = Settings.instance.pedal_vibration
    steering_range_spin_box.value = Settings.instance.steering_range
    smooth_textures_checkbox.button_pressed = Settings.instance.smooth_textures
    steering_wheel_progress_bar.button_pressed = Settings.instance.steering_wheel_progress
    shifter_fill_color_button.color = Settings.instance.shifter_shaft_fill_color
    shifter_outline_color_button.color = Settings.instance.shifter_shaft_outline_color
    pedal_bar_fill_color_button.color = Settings.instance.pedal_bar_fill_color
    pedal_vibration_slider.value = Settings.instance.pedal_vibration_strength
    pedal_sink_checkbox.button_pressed = Settings.instance.pedal_sink
    dynamic_steering_hand_animation_checkbox.button_pressed = Settings.instance.dynamic_steering_hand_animation

func _populate_pedal_mode() -> void:
    var pedal_mode := Settings.instance.pedal_mode

    match pedal_mode:
        Settings.PedalMode.DUAL_AXIS:
            pedal_mode_option_button.selected = 0
        Settings.PedalMode.SINGLE_AXIS:
            pedal_mode_option_button.selected = 1

func _populate_rest_hand_position() -> void:
    var rest_hand_position := Settings.instance.rest_hand_position

    match rest_hand_position:
        Settings.RestHandPosition.STEERING_WHEEL:
            rest_hand_position_option_button.selected = 0
        Settings.RestHandPosition.SHIFTER:
            rest_hand_position_option_button.selected = 1

func _on_pedal_mode_option_button_item_selected(index: int) -> void:
    match index:
        0:
            Settings.instance.pedal_mode = Settings.PedalMode.DUAL_AXIS
        1:
            Settings.instance.pedal_mode = Settings.PedalMode.SINGLE_AXIS

    Settings.instance.save_to_disk()

func _on_rest_hand_position_option_button_item_selected(index: int) -> void:
    match index:
        0:
            Settings.instance.rest_hand_position = Settings.RestHandPosition.STEERING_WHEEL
        1:
            Settings.instance.rest_hand_position = Settings.RestHandPosition.SHIFTER

    Settings.instance.save_to_disk()

func _on_steering_range_spin_box_value_changed(value: float) -> void:
    Settings.instance.steering_range = value
    Settings.instance.save_to_disk()

func _on_smooth_textures_checkbox_toggled(toggled_on: bool) -> void:
    Settings.instance.smooth_textures = toggled_on
    Settings.instance.save_to_disk()

func _on_steering_wheel_progress_bar_toggled(toggled_on: bool) -> void:
    Settings.instance.steering_wheel_progress = toggled_on
    Settings.instance.save_to_disk()

func _on_shifter_fill_color_button_color_changed(color: Color) -> void:
    Settings.instance.shifter_shaft_fill_color = color
    Settings.instance.save_to_disk()

func _on_reset_shifter_fill_color_button_pressed() -> void:
    Settings.instance.shifter_shaft_fill_color = Color.from_rgba8(99, 155, 255) # TODO: Move this constant somewhere else
    shifter_fill_color_button.color = Color.from_rgba8(99, 155, 255)
    Settings.instance.save_to_disk()

func _on_shifter_outline_color_button_color_changed(color: Color) -> void:
    Settings.instance.shifter_shaft_outline_color = color
    Settings.instance.save_to_disk()

func _on_reset_shifter_outline_color_button_pressed() -> void:
    Settings.instance.shifter_shaft_outline_color = Color.WHITE # TODO: Move this constant somewhere else
    shifter_outline_color_button.color = Color.WHITE
    Settings.instance.save_to_disk()

func _on_pedal_bar_fill_color_button_color_changed(color: Color) -> void:
    Settings.instance.pedal_bar_fill_color = color
    Settings.instance.save_to_disk()

func _on_reset_pedal_bar_fill_color_button_pressed() -> void:
    Settings.instance.pedal_bar_fill_color = Color(0.082, 0.219, 0.225) # TODO: Move this constant somewhere else
    pedal_bar_fill_color_button.color = Settings.instance.pedal_bar_fill_color
    Settings.instance.save_to_disk()

func _on_pedal_vibration_checkbox_toggled(toggled_on: bool) -> void:
    Settings.instance.pedal_vibration = toggled_on
    Settings.instance.save_to_disk()

func _on_pedal_vibration_slider_value_changed(value: float) -> void:
    Settings.instance.pedal_vibration_strength = value
    Settings.instance.save_to_disk()

func _on_pedal_sink_checkbox_toggled(toggled_on: bool) -> void:
    Settings.instance.pedal_sink = toggled_on
    Settings.instance.save_to_disk()

func _on_dynamic_steering_hand_animation_checkbox_toggled(toggled_on: bool) -> void:
    Settings.instance.dynamic_steering_hand_animation = toggled_on
    Settings.instance.save_to_disk()

func _on_close_button_pressed() -> void:
    on_close_pressed.emit()
