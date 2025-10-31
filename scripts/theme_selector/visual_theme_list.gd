class_name VisualThemeList
extends PanelContainer

@onready
var theme_items_container: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer

## Signal invoked whenever the user clicks a theme on the theme list.
signal on_theme_clicked(theme: VisualTheme)

var _theme_to_edit: VisualTheme = null
var _theme_to_edit_index: int = 0
var _theme_editor: VisualThemeEditor = null

func load_theme_list(themes: Array[VisualTheme]) -> void:
    _populate_list(themes)

func _populate_list(themes: Array[VisualTheme]) -> void:
    for child in theme_items_container.get_children():
        theme_items_container.remove_child(child)

    var index := 0
    for theme in themes:
        var theme_node := preload("res://nodes/theme_selector/visual_theme_node.tscn").instantiate() as VisualThemeNode
        theme_items_container.add_child(theme_node)

        theme_node.load_visual_theme(theme)

        theme_node.on_click.connect(
            _on_theme_node_clicked.bind(theme_node)
        )
        theme_node.on_edit_colors_pressed.connect(
            _on_edit_color_button_pressed.bind(theme_node, index)
        )

        if theme.identifier == Settings.instance.active_theme_identifier:
            theme_node.is_selected = true

        index += 1

func _on_theme_node_clicked(node: VisualThemeNode) -> void:
    on_theme_clicked.emit(node.visual_theme)

func _on_edit_color_button_pressed(node: VisualThemeNode, index: int) -> void:
    var edit_color_node: VisualThemeEditor = preload("res://nodes/theme_selector/visual_theme_editor.tscn").instantiate()
    self.add_child(edit_color_node)

    edit_color_node.load_theme(node.visual_theme)

    edit_color_node.on_save_pressed.connect(_on_edit_color_node_save_pressed)
    edit_color_node.on_cancel_pressed.connect(_on_edit_color_node_cancel_pressed)

    _theme_to_edit = node.visual_theme
    _theme_editor = edit_color_node
    _theme_to_edit_index = index

func _on_edit_color_node_save_pressed(
    shifter_fill_color: Color,
    shifter_outline_color: Color,
    pedal_bar_fill_color: Color,
) -> void:
    _theme_to_edit.theme_settings.shifter_fill_color = shifter_fill_color
    _theme_to_edit.theme_settings.shifter_outline_color = shifter_outline_color
    _theme_to_edit.theme_settings.pedal_bar_fill_color = pedal_bar_fill_color

    _theme_to_edit.save_settings_to_disk()

    var theme_node: VisualThemeNode = theme_items_container.get_child(_theme_to_edit_index)
    if theme_node != null:
        theme_node.load_visual_theme(_theme_to_edit)

    _close_theme_editor()

func _on_edit_color_node_cancel_pressed() -> void:
    _close_theme_editor()

func _close_theme_editor() -> void:
    _theme_editor.get_parent().remove_child(_theme_editor)

    _theme_to_edit = null
    _theme_editor = null

func _on_open_theme_folder_button_pressed() -> void:
    var folder := VisualThemeManager.theme_lookup_folder()
    if not DirAccess.dir_exists_absolute(folder):
        OS.shell_open(OS.get_executable_path().get_base_dir())
    else:
        OS.shell_open(folder)
