class_name AnalogRebindContainer
extends RebindContainerBase

@onready
var rebind_panel_label: Label = %RebindPanelLabel
@onready
var rebind_panel_input_label: Label = %RebindPanelInputLabel
@onready
var accept_button: Button = %AcceptButton
@onready
var cancel_button: Button = %CancelButton

var _latest_input: InputEvent = null
var _is_listening: bool = false

func start_listening(action_name: String) -> void:
    rebind_panel_label.text = "Rebind %s" % [StringUtils.prepare_action_name(action_name)]
    rebind_panel_input_label.text = "Awaiting input..."

    _is_listening = true

func stop_listening() -> void:
    _is_listening = false

func _submit_event(event: InputEvent) -> void:
    if _is_listening:
        get_viewport().set_input_as_handled()
        _latest_input = event
        accept_button.disabled = false
        rebind_panel_input_label.text = event.as_text()
        stop_listening()

func _input(event: InputEvent) -> void:
    if event is InputEventKey:
        if event.pressed:
            _submit_event(event)
    if event is InputEventMouseButton:
        if event.pressed:
            _submit_event(event)
    if event is InputEventJoypadMotion:
        if absf(event.axis_value) >= 0.2:
            _submit_event(event)
    if event is InputEventJoypadButton:
        if event.pressed == true:
            _submit_event(event)

func _on_accept_button_pressed() -> void:
    if _latest_input != null:
        on_input_accepted.emit(_latest_input)

func _on_cancel_button_pressed() -> void:
    on_cancelled.emit()
