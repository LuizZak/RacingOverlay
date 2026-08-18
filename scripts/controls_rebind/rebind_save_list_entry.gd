class_name RebindSaveListEntry
extends MarginContainer

enum State {
    NORMAL,
    RENAMING,
}

@onready
var rename_line_edit: LineEdit = %RenameLineEdit
@onready
var save_name_label: Label = %SaveNameLabel
@onready
var duplicate_button: Button = %DuplicateButton
@onready
var rename_button: Button = %RenameButton
@onready
var delete_button: Button = %DeleteButton

@onready
var rename_error_panel_container: PanelContainer = %RenameErrorPanelContainer
@onready
var rename_error_reason_label: Label = %RenameErrorReasonLabel

var save_name: String:
    set(value):
        save_name = value
        save_name_label.text = value

signal on_duplicate_pressed()
signal on_delete_pressed()

signal on_rename_requested(request: RenameRequest)

var _state: State

func _set_state(new_state: State) -> void:
    _state = new_state

    match new_state:
        State.NORMAL:
            rename_line_edit.visible = false
            rename_error_panel_container.visible = false

            save_name_label.visible = true
            duplicate_button.visible = true
            rename_button.visible = true
            delete_button.visible = true

        State.RENAMING:
            rename_line_edit.text = save_name
            rename_line_edit.caret_column = save_name.length()
            rename_line_edit.visible = true

            save_name_label.visible = false
            duplicate_button.visible = false
            rename_button.visible = false
            delete_button.visible = false

            await get_tree().process_frame

            rename_line_edit.grab_focus()

func _on_duplicate_button_pressed() -> void:
    on_duplicate_pressed.emit()

func _on_rename_button_pressed() -> void:
    _set_state(State.RENAMING)

func _on_delete_button_pressed() -> void:
    on_delete_pressed.emit()

func _on_rename_line_edit_text_submitted(new_text: String) -> void:
    var request := RenameRequest.new(new_text)
    on_rename_requested.emit(request)

    if not request.cancelled:
        save_name = new_text
        rename_line_edit.release_focus()
    else:
        rename_error_panel_container.visible = true
        rename_error_reason_label.text = request.reason

        await get_tree().process_frame

        rename_line_edit.edit()

func _on_rename_line_edit_text_changed(_new_text: String) -> void:
    rename_error_panel_container.visible = false

func _on_rename_line_edit_focus_exited() -> void:
    _set_state(State.NORMAL)

func _on_rename_line_edit_gui_input(event: InputEvent) -> void:
    if event is InputEventKey:
        if event.pressed and event.keycode == KEY_ESCAPE:
            _set_state(State.NORMAL)

class RenameRequest:
    var new_name: String
    var cancelled: bool
    var reason: String

    @warning_ignore("shadowed_variable")
    func _init(new_name: String) -> void:
        self.new_name = new_name

    func cancel(reason: String) -> void:
        cancelled = true
        self.reason = reason
