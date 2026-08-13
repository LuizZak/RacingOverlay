class_name RebindEnumEntry
extends HBoxContainer

@export var enum_name: String
@export_multiline var button_tooltip: String

@onready var label: Label = $Label
@onready var option_button: OptionButton = $OptionButton

signal did_select_option(option_index: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    option_button.tooltip_text = button_tooltip

    _load_settings()

func _load_settings() -> void:
    var property := _get_property()
    if property == null:
        return

    option_button.clear()
    for item in property.values:
        option_button.add_item(StringUtils.prepare_camel_case_name(item))

    refresh()

func _on_option_button_item_selected(index: int) -> void:
    var property := _get_property()
    if property == null:
        return

    InputtyHelpers.change_axis_mode(enum_name, index)

    did_select_option.emit(index)

func refresh() -> void:
    var property := _get_property()
    if property == null:
        return

    label.text = StringUtils.prepare_camel_case_name(enum_name)
    option_button.selected = property.valueIndex

func _get_property() -> InputtyPropertyEnum:
    var property := Inputty.get_raw_property(enum_name) as InputtyPropertyEnum
    if property == null:
        push_error("No Inputty property named '%s' or it's not an enum" % [enum_name])

    return property
