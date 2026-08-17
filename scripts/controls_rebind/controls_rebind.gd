class_name ControlsRebind
extends MarginContainer

@onready
var rebind_steer_left: RebindEntry = %RebindSteerLeft
@onready
var rebind_steer_right: RebindEntry = %RebindSteerRight

@onready
var rebind_clutch_mode: RebindEnumEntry = %RebindClutchMode
@onready
var rebind_clutch_down: RebindEntry = %RebindClutchDown
@onready
var rebind_clutch_up: RebindEntry = %RebindClutchUp

@onready
var rebind_brake_mode: RebindEnumEntry = %RebindBrakeMode
@onready
var rebind_brake_down: RebindEntry = %RebindBrakeDown
@onready
var rebind_brake_up: RebindEntry = %RebindBrakeUp

@onready
var rebind_throttle_mode: RebindEnumEntry = %RebindThrottleMode
@onready
var rebind_throttle_down: RebindEntry = %RebindThrottleDown
@onready
var rebind_throttle_up: RebindEntry = %RebindThrottleUp

@onready
var rebind_shift_1_st: RebindEntry = %RebindShift1st
@onready
var rebind_shift_2_nd: RebindEntry = %RebindShift2nd
@onready
var rebind_shift_3_rd: RebindEntry = %RebindShift3rd
@onready
var rebind_shift_4_th: RebindEntry = %RebindShift4th
@onready
var rebind_shift_5_th: RebindEntry = %RebindShift5th
@onready
var rebind_shift_6_th: RebindEntry = %RebindShift6th
@onready
var rebind_shift_reverse: RebindEntry = %RebindShiftReverse
@onready
var rebind_shift_up: RebindEntry = %RebindShiftUp
@onready
var rebind_shift_down: RebindEntry = %RebindShiftDown
@onready
var rebind_handbrake: RebindEntry = %RebindHandbrake

@onready
var all_action_rebinds: Array[RebindEntry] = [
    rebind_steer_left,
    rebind_steer_right,
    rebind_clutch_down,
    rebind_clutch_up,
    rebind_brake_down,
    rebind_brake_up,
    rebind_throttle_down,
    rebind_throttle_up,
    rebind_shift_1_st,
    rebind_shift_2_nd,
    rebind_shift_3_rd,
    rebind_shift_4_th,
    rebind_shift_5_th,
    rebind_shift_6_th,
    rebind_shift_reverse,
    rebind_shift_up,
    rebind_shift_down,
    rebind_handbrake,
]

@onready
var active_binding_option_button: OptionButton = %ActiveBindingOptionButton

@onready
var load_defaults_button: Button = %LoadDefaultsButton

@onready
var pedal_rebind_container: PedalRebindContainer = %PedalRebindContainer
@onready
var analog_rebind_container: AnalogRebindContainer = %AnalogRebindContainer
@onready
var rebind_save_list: RebindSaveList = %RebindSaveList

signal on_close_pressed()

var _current_rebind_action: String = ""

func _ready() -> void:
    if FileAccess.file_exists(Inputty.activeFilePath):
        var workingMap := InputtyMap.new()
        workingMap.loadFromFile(Inputty.activeFilePath)
        if workingMap.version == Inputty.current_version:
            workingMap.applyToMain()

    Inputty.inputFileList.onFileNamesChanged.connect(_on_input_files_changed)
    Inputty.inputFileList.onActiveFileNameChanged.connect(_on_active_file_name_changed)

    _refresh_rebind_entries()
    _reload_active_binding_option_button()

    pedal_rebind_container.on_input_accepted.connect(_rebind_container_on_input_accepted)
    pedal_rebind_container.on_cancelled.connect(_rebind_container_on_cancelled)

    analog_rebind_container.on_input_accepted.connect(_rebind_container_on_input_accepted)
    analog_rebind_container.on_cancelled.connect(_rebind_container_on_cancelled)

    load_defaults_button.pressed.connect(_on_load_defaults_button_pressed)

func _on_load_defaults_button_pressed() -> void:
    InputMap.load_from_project_settings()

    Inputty.resetBindingsToDefault()

    _refresh_rebind_entries()

func _refresh_rebind_entries() -> void:
    rebind_brake_mode.refresh()
    rebind_clutch_mode.refresh()
    rebind_throttle_mode.refresh()

    for rebind_entry in all_action_rebinds:
        rebind_entry.refresh()

func _reload_active_binding_option_button() -> void:
    active_binding_option_button.clear()
    active_binding_option_button.selected = -1

    var manager := InputtyBindingsManager.new()
    var all_bindings := manager.get_all_bindings()

    for i in range(all_bindings.size()):
        var bindings := all_bindings[i]
        active_binding_option_button.add_item(bindings.display_name)
        if bindings.is_active:
            active_binding_option_button.selected = i

func _rebind_container_on_input_accepted(event: InputEvent) -> void:
    if not _current_rebind_action.is_empty():
        InputMap.action_erase_events(_current_rebind_action)
        InputMap.action_add_event(_current_rebind_action, event)

        var workingMap := InputtyMap.new()
        workingMap.copyFromMain()
        workingMap.saveToFile(Inputty.activeFilePath)

        _refresh_rebind_entries()

    _end_rebind()

func _rebind_container_on_cancelled() -> void:
    _end_rebind()

func _end_rebind() -> void:
    _current_rebind_action = ""
    pedal_rebind_container.stop_listening()
    pedal_rebind_container.hide()
    analog_rebind_container.stop_listening()
    analog_rebind_container.hide()

func _begin_pedal_rebind(action_name: String) -> void:
    _current_rebind_action = action_name
    pedal_rebind_container.show()
    pedal_rebind_container.start_listening(action_name)

func _begin_analog_rebind(action_name: String) -> void:
    _current_rebind_action = action_name
    analog_rebind_container.show()
    analog_rebind_container.start_listening(action_name)

func _begin_button_rebind(action_name: String) -> void:
    _current_rebind_action = action_name
    analog_rebind_container.show()
    analog_rebind_container.start_listening(action_name)

func _on_did_click_rebind(action_name: String) -> void:
    if _is_action_pedal(action_name):
        _begin_pedal_rebind(action_name)
    elif _is_action_analog(action_name):
        _begin_analog_rebind(action_name)
    else:
        _begin_button_rebind(action_name)

func _is_action_pedal(action_name: String) -> bool:
    match action_name:
        "Clutch_down":
            return true
        "Clutch_up":
            return true
        "Brake_down":
            return true
        "Brake_up":
            return true
        "Throttle_down":
            return true
        "Throttle_up":
            return true
        _:
            return false

func _is_action_analog(action_name: String) -> bool:
    match action_name:
        "Steer_left":
            return true
        "Steer_right":
            return true
        "Clutch_down":
            return true
        "Clutch_up":
            return true
        "Brake_down":
            return true
        "Brake_up":
            return true
        "Throttle_down":
            return true
        "Throttle_up":
            return true
        "Handbrake":
            return true
        _:
            return false

func _on_rebind_save_list_on_close_pressed() -> void:
    _reload_active_binding_option_button()

    rebind_save_list.visible = false

func _on_active_binding_option_button_item_selected(index: int) -> void:
    var manager := InputtyBindingsManager.new()

    var all_bindings := manager.get_all_bindings()
    if all_bindings[index].is_active:
        return

    manager.set_active_binding(all_bindings[index].file_name)

    _refresh_rebind_entries()

func _on_manage_binding_files_button_pressed() -> void:
    rebind_save_list.visible = true

func _on_input_files_changed(_value: PackedStringArray) -> void:
    _reload_active_binding_option_button()

func _on_active_file_name_changed(_value: String) -> void:
    _reload_active_binding_option_button()
    _refresh_rebind_entries()

func _on_close_button_pressed() -> void:
    on_close_pressed.emit()
