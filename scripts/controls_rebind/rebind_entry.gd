class_name RebindEntry
extends HBoxContainer

@export var action_name: String

@onready var label: Label = $Label
@onready var button: Button = $Button

## Event to rebind the action to when settings are applied.
##
## If `null`, no changes are made to the action.
var rebound_event: InputEvent = null

signal did_click_rebind()

func _ready() -> void:
    label.text = _prepare_action_name()
    button.text = _prepare_action_input()

func _on_button_pressed() -> void:
    did_click_rebind.emit()

func _prepare_action_name() -> String:
    var components := action_name.split("_")
    for i in range(components.size()):
        components[i] = StringUtils.uppercased_first(components[i])

    return " ".join(components)

func _prepare_action_input() -> String:
    var events := InputMap.action_get_events(action_name)
    if not events.is_empty():
        return events[0].as_text()

    return ""
