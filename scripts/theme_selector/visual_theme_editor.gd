class_name VisualThemeEditor
extends PanelContainer

@onready var shifter_fill_color_button: ColorPickerButton = %ShifterFillColorButton
@onready var shifter_outline_color_button: ColorPickerButton = %ShifterOutlineColorButton
@onready var pedal_bar_fill_color_button: ColorPickerButton = %PedalBarFillColorButton

@onready var visual_theme_node: VisualThemeNode = %VisualThemeNode

signal on_save_pressed(shifter_fill_color: Color, shifter_outline_color: Color, pedal_bar_fill_color: Color)
signal on_cancel_pressed()

func load_theme(visual_theme: VisualTheme) -> void:
    shifter_fill_color_button.color = visual_theme.theme_settings.shifter_fill_color
    shifter_outline_color_button.color = visual_theme.theme_settings.shifter_outline_color
    pedal_bar_fill_color_button.color = visual_theme.theme_settings.pedal_bar_fill_color

    visual_theme_node.load_visual_theme(visual_theme)

func _on_reset_shifter_fill_color_button_pressed() -> void:
    var color := VisualTheme.DEFAULT_SHIFTER_FILL_COLOR

    shifter_fill_color_button.color = color
    visual_theme_node.shifter_shaft_color = color

func _on_reset_shifter_outline_color_button_pressed() -> void:
    var color := VisualTheme.DEFAULT_SHIFTER_OUTLINE_COLOR

    shifter_outline_color_button.color = color
    visual_theme_node.shifter_shaft_outline_color = color

func _on_reset_pedal_bar_fill_color_button_pressed() -> void:
    var color := VisualTheme.DEFAULT_PEDAL_FILL_COLOR

    pedal_bar_fill_color_button.color = color
    visual_theme_node.pedal_fill_color = color

func _on_shifter_fill_color_button_color_changed(color: Color) -> void:
    visual_theme_node.shifter_shaft_color = color

func _on_shifter_outline_color_button_color_changed(color: Color) -> void:
    visual_theme_node.shifter_shaft_outline_color = color

func _on_pedal_bar_fill_color_button_color_changed(color: Color) -> void:
    visual_theme_node.pedal_fill_color = color

func _on_save_button_pressed() -> void:
    on_save_pressed.emit(
        shifter_fill_color_button.color,
        shifter_outline_color_button.color,
        pedal_bar_fill_color_button.color,
    )

func _on_cancel_button_pressed() -> void:
    on_cancel_pressed.emit()
