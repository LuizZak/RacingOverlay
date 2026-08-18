class_name RebindSaveList
extends PanelContainer

var bindings_manager: InputtyBindingsManager

@onready
var delete_confirm_panel_container: PanelContainer = %DeleteConfirmPanelContainer
@onready
var rebind_list_v_box: VBoxContainer = %RebindListVBox

@onready
var delete_confirm_label: Label = %DeleteConfirmLabel

signal on_close_pressed()

var _index_to_delete: int = -1

func _ready() -> void:
    if bindings_manager == null:
        bindings_manager = InputtyBindingsManager.new()

    _reload_list()

func _reload_list() -> void:
    for child in rebind_list_v_box.get_children():
        child.queue_free()

    var bindings := bindings_manager.get_all_bindings()

    for i in range(bindings.size()):
        var binding := bindings[i]
        var entry := preload("res://nodes/controls_rebind/rebind_save_list_entry.tscn").instantiate() as RebindSaveListEntry
        rebind_list_v_box.add_child(entry)
        entry.save_name = binding.display_name

        entry.on_delete_pressed.connect(_on_rebind_save_list_entry_on_delete_pressed.bind(i))
        entry.on_duplicate_pressed.connect(_on_rebind_save_list_entry_on_duplicate_pressed.bind(i))
        entry.on_rename_requested.connect(_on_rebind_save_list_entry_on_rename_requested.bind(i))

func _on_rebind_save_list_entry_on_delete_pressed(index: int) -> void:
    var bindings := _get_bindings_entry(index)
    _index_to_delete = index
    delete_confirm_panel_container.visible = true

    delete_confirm_label.text = "Are you sure you want to delete\nbindings '%s'?" % [bindings.display_name]

func _on_rebind_save_list_entry_on_duplicate_pressed(index: int) -> void:
    var bindings := _get_bindings_entry(index)
    bindings_manager.duplicate_binding(bindings.file_name)

    _reload_list()

func _on_rebind_save_list_entry_on_rename_requested(request: RebindSaveListEntry.RenameRequest, index: int) -> void:
    if request.new_name.strip_edges() == "":
        request.cancel("Name cannot be empty")
        return

    var bindings := _get_bindings_entry(index)
    bindings_manager.rename_binding(bindings.file_name, request.new_name)

func _on_confirm_delete_button_pressed() -> void:
    if _index_to_delete >= 0:
        var bindings := _get_bindings_entry(_index_to_delete)
        bindings_manager.delete_binding(bindings.file_name)

        _reload_list()

    delete_confirm_panel_container.visible = false

func _on_confirm_cancel_button_pressed() -> void:
    delete_confirm_panel_container.visible = false

func _get_bindings_entry(index: int) -> InputtyBindingsManager.BindingEntry:
    return bindings_manager.get_all_bindings()[index]

func _on_create_new_button_pressed() -> void:
    bindings_manager.create_new_binding()

    _reload_list()

func _on_close_button_pressed() -> void:
    on_close_pressed.emit()
