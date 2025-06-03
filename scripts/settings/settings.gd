class_name SettingsPanel
extends MarginContainer

@onready
var pedal_mode_option_button: OptionButton = %PedalModeOptionButton
@onready
var pedal_vibration_checkbox: CheckBox = %PedalVibrationCheckbox
@onready
var pedal_vibration_slider: HSlider = %PedalVibrationSlider
@onready
var pedal_sink_checkbox: CheckBox = %PedalSinkCheckbox

signal on_close_pressed()

func _ready():
    _populate_settings()

func _populate_settings():
    _populate_pedal_mode()
    pedal_vibration_checkbox.button_pressed = Settings.instance.pedal_vibration
    pedal_vibration_slider.value = Settings.instance.pedal_vibration_strength
    pedal_sink_checkbox.button_pressed = Settings.instance.pedal_sink

func _populate_pedal_mode():
    var pedal_mode = Settings.instance.pedal_mode

    match pedal_mode:
        Settings.PedalMode.DUAL_AXIS:
            pedal_mode_option_button.selected = 0
        Settings.PedalMode.SINGLE_AXIS:
            pedal_mode_option_button.selected = 1

func _on_pedal_mode_option_button_item_selected(index: int) -> void:
    match index:
        0:
            Settings.instance.pedal_mode = Settings.PedalMode.DUAL_AXIS
        1:
            Settings.instance.pedal_mode = Settings.PedalMode.SINGLE_AXIS

    Settings.instance.save_to_disk()

func _on_smooth_textures_checkbox_toggled(toggled_on: bool) -> void:
    Settings.instance.smooth_textures = toggled_on
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

func _on_close_button_pressed() -> void:
    on_close_pressed.emit()
