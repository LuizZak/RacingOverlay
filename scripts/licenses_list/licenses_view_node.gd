class_name LicensesViewNode
extends PanelContainer

signal on_close_pressed()

func _on_close_button_pressed() -> void:
    on_close_pressed.emit()
