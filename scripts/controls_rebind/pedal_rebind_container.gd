class_name PedalRebindContainer
extends RebindContainerBase

enum State {
    AWAITING,
    CALIBRATING,
    CAPTURING,
    COMPLETE,
}

@onready
var rebind_panel_label: Label = %RebindPanelLabel
@onready
var instruction_panel_label: Label = %InstructionPanelLabel
@onready
var rebind_panel_input_label: Label = %RebindPanelInputLabel
@onready
var input_progress_bar: ProgressBar = %InputProgressBar
@onready
var accept_button: Button = %AcceptButton
@onready
var cancel_button: Button = %CancelButton

var _captured_input: InputEventJoypadMotion = null
var _latest_input: InputEvent = null
var _is_listening: bool = false
var _action_name: String = ""
var _axis_tolerance: float = 0.05
var _capture_tolerance: float = 0.5

var state: State

func start_listening(action_name: String):
    _captured_input = null
    self._action_name = _action_name

    _change_state(State.AWAITING)

    rebind_panel_label.text = "Rebind %s" % [_prepare_action_name(action_name)]
    rebind_panel_input_label.text = "Awaiting input..."

    _is_listening = true

func stop_listening():
    _change_state(State.AWAITING)

    _is_listening = false

func _change_state(state: State):
    self.state = state

    match state:
        State.AWAITING:
            instruction_panel_label.text = "Start by pressing a pedal down\nuntil it reaches +/- 5% of the\ncenter marker"

        State.CALIBRATING:
            instruction_panel_label.text = "Start by pressing a pedal down\nuntil it reaches +/- 5% of the\ncenter marker"

        State.CAPTURING:
            instruction_panel_label.text = "Now lift or press down on the\npedal to record the input\nfor %s" % [self._action_name]

        State.COMPLETE:
            instruction_panel_label.text = "Accept or Cancel to finish"

func _submit_event(event: InputEvent):
    if _is_listening:
        get_viewport().set_input_as_handled()
        _latest_input = event
        accept_button.disabled = false
        rebind_panel_input_label.text = event.as_text()
        stop_listening()

func _process_event(event: InputEvent):
    if not _is_listening:
        return

    match state:
        State.AWAITING:
            if event is InputEventJoypadMotion:
                _change_state(State.CALIBRATING)
                _captured_input = event

        State.CALIBRATING:
            if event is InputEventJoypadMotion:
                if event.axis == _captured_input.axis and event.device == _captured_input.device:
                    input_progress_bar.value = event.axis_value
                    if absf(event.axis_value) <= _axis_tolerance:
                        _change_state(State.CAPTURING)

        State.CAPTURING:
            if event is InputEventJoypadMotion:
                if event.axis == _captured_input.axis and event.device == _captured_input.device:
                    input_progress_bar.value = event.axis_value
                    if absf(event.axis_value) >= _capture_tolerance:
                        _submit_event(event)
                        _change_state(State.COMPLETE)

func _input(event: InputEvent) -> void:
    if event is InputEventKey:
        if event.pressed:
            _process_event(event)
    if event is InputEventMouseButton:
        if event.pressed:
            _process_event(event)
    if event is InputEventJoypadMotion:
        if absf(event.axis_value) >= 0.03:
            _process_event(event)
    if event is InputEventJoypadButton:
        if event.pressed == true:
            _process_event(event)

func _prepare_action_name(action_name: String) -> String:
    var components := action_name.split("_")
    for i in range(components.size()):
        components[i] = StringUtils.uppercased_first(components[i])

    return " ".join(components)

func _on_accept_button_pressed() -> void:
    if _latest_input != null:
        on_input_accepted.emit(_latest_input)

func _on_cancel_button_pressed() -> void:
    on_cancelled.emit()
