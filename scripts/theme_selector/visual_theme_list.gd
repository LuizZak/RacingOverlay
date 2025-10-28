class_name VisualThemeList
extends PanelContainer

@onready
var theme_items_container: VBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer

## Signal invoked whenever the user clicks a theme on the theme list.
signal on_theme_clicked(theme: VisualTheme)

func load_theme_list(themes: Array[VisualTheme]):
    _populate_list(themes)

func _populate_list(themes: Array[VisualTheme]):
    for child in theme_items_container.get_children():
        theme_items_container.remove_child(child)

    for theme in themes:
        var theme_node := preload("res://nodes/theme_selector/visual_theme_node.tscn").instantiate() as VisualThemeNode
        theme_items_container.add_child(theme_node)

        theme_node.load_visual_theme(theme)

        theme_node.on_click.connect(
            _on_theme_node_clicked.bind(theme_node)
        )

func _on_theme_node_clicked(node: VisualThemeNode):
    on_theme_clicked.emit(node.visual_theme)
