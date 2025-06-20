class_name RebindEntry
extends HBoxContainer

@export var action_name: String

@onready var label: Label = $Label
@onready var button: Button = $Button

## Event to rebind the action to when settings are applied.
##
## If `null`, no changes are made to the action.
var rebound_event: InputEvent = null

signal did_click_rebind(action_name: String)

func _ready() -> void:
    refresh()

func _on_button_pressed() -> void:
    did_click_rebind.emit(action_name)

func refresh():
    label.text = StringUtils.prepare_action_name(action_name)
    button.text = _prepare_action_input()

func _prepare_action_input() -> String:
    var events := InputMap.action_get_events(action_name)
    if not events.is_empty():
        return events[0].as_text()

    return ""
