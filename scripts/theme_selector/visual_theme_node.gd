class_name VisualThemeNode
extends MarginContainer

@onready var button: Button = $VBoxContainer/MarginContainer/Button

@onready var shifter_container: ShifterContainer = %ShifterContainer

@onready var right_foot: VisualNode = %RightFoot
@onready var left_foot: VisualNode = %LeftFoot

@onready var shifter_knob: VisualNode = %ShifterKnob

@onready var steering_wheel_sprite: VisualNode = %SteeringWheelSprite
@onready var ebrake_base: VisualNode = %EbrakeBase
@onready var ebrake_effect: VisualNode = %EbrakeEffect
@onready var shifter_base: VisualNode = %ShifterBase
@onready var pedal_throttle: VisualNode = %PedalThrottle
@onready var throttle_pedal_fixture: VisualNode = %ThrottlePedalFixture
@onready var pedal_brake: VisualNode = %PedalBrake
@onready var brake_pedal_fixture: VisualNode = %BrakePedalFixture
@onready var pedal_clutch: VisualNode = %PedalClutch
@onready var clutch_pedal_fixture: VisualNode = %ClutchPedalFixture
@onready var pedal_base: VisualNode = %PedalBase

@onready var left_hand: VisualNode = %LeftHand
@onready var right_hand: VisualNode = %RightHand

@onready var theme_name_panel_container: PanelContainer = %ThemeNamePanelContainer
@onready var theme_name_label: Label = %ThemeNameLabel

@onready var selection_status_panel: Panel = %SelectionStatusPanel

@onready var clutch_progress: ProgressBar = %ClutchProgress
@onready var brake_progress: ProgressBar = %BrakeProgress
@onready var throttle_progress: ProgressBar = %ThrottleProgress

@onready var edit_colors_button: Button = %EditColorsButton

@export
var is_theme_name_visible: bool = true:
    set(value):
        is_theme_name_visible = value
        if theme_name_panel_container != null:
            theme_name_panel_container.visible = value

@export
var is_button_visible: bool = true:
    set(value):
        is_button_visible = value
        if button != null:
            button.visible = is_button_visible

@export
var is_edit_colors_button_visible: bool = true:
    set(value):
        is_edit_colors_button_visible = value
        if edit_colors_button != null:
            edit_colors_button.visible = is_edit_colors_button_visible

@export
var shifter_shaft_color: Color = Color.BLACK:
    set(value):
        shifter_shaft_color = value
        if shifter_container != null:
            shifter_container.shifter_shaft_color = value

@export
var shifter_shaft_outline_color: Color = Color.WHITE:
    set(value):
        shifter_shaft_outline_color = value
        if shifter_container != null:
            shifter_container.shifter_shaft_outline_color = value

@export
var pedal_fill_color: Color = Color(0.082, 0.219, 0.225):
    set(value):
        pedal_fill_color = value
        _set_pedal_fill_color(value)

signal on_click()
signal on_edit_colors_pressed()

var visual_theme: VisualTheme = null

var is_selected: bool = false:
    set(value):
        is_selected = true
        selection_status_panel.visible = is_selected

func _ready() -> void:
    theme_name_panel_container.visible = is_theme_name_visible
    button.visible = is_button_visible
    edit_colors_button.visible = is_edit_colors_button_visible

    shifter_container.shifter_shaft_color = shifter_shaft_color
    shifter_container.shifter_shaft_outline_color = shifter_shaft_outline_color

    _set_pedal_fill_color(pedal_fill_color)

func _set_pedal_fill_color(color: Color) -> void:
    if clutch_progress == null:
        return

    var style := StyleBoxFlat.new()
    style.set_corner_radius_all(8)
    style.bg_color = color

    clutch_progress.add_theme_stylebox_override("fill", style)
    brake_progress.add_theme_stylebox_override("fill", style)
    throttle_progress.add_theme_stylebox_override("fill", style)

func load_visual_theme(theme: VisualTheme) -> void:
    self.visual_theme = theme
    self.theme_name_label.text = theme.display_name

    if theme.theme_settings.is_empty:
        shifter_shaft_color = Settings.instance.shifter_shaft_fill_color
        shifter_shaft_outline_color = Settings.instance.shifter_shaft_outline_color
        pedal_fill_color = Settings.instance.pedal_bar_fill_color

        _disable_edit_color_button()
    else:
        shifter_shaft_color = theme.theme_settings.shifter_fill_color
        shifter_shaft_outline_color = theme.theme_settings.shifter_outline_color
        pedal_fill_color = theme.theme_settings.pedal_bar_fill_color

        _enable_edit_color_button()

    right_foot.visual_theme = theme
    right_foot.refresh_display()

    left_foot.visual_theme = theme
    left_foot.refresh_display()

    shifter_knob.visual_theme = theme
    shifter_knob.refresh_display()

    steering_wheel_sprite.visual_theme = theme
    steering_wheel_sprite.refresh_display()

    ebrake_base.visual_theme = theme
    ebrake_base.refresh_display()

    ebrake_effect.visual_theme = theme
    ebrake_effect.refresh_display()

    shifter_base.visual_theme = theme
    shifter_base.refresh_display()

    pedal_throttle.visual_theme = theme
    pedal_throttle.refresh_display()

    throttle_pedal_fixture.visual_theme = theme
    throttle_pedal_fixture.refresh_display()

    pedal_brake.visual_theme = theme
    pedal_brake.refresh_display()

    brake_pedal_fixture.visual_theme = theme
    brake_pedal_fixture.refresh_display()

    pedal_clutch.visual_theme = theme
    pedal_clutch.refresh_display()

    clutch_pedal_fixture.visual_theme = theme
    clutch_pedal_fixture.refresh_display()

    pedal_base.visual_theme = theme
    pedal_base.refresh_display()

    left_hand.visual_theme = theme
    left_hand.refresh_display()

    right_hand.visual_theme = theme
    right_hand.refresh_display()

func _disable_edit_color_button() -> void:
    edit_colors_button.tooltip_text = "The provided theme lacks a settings.json file\nto edit the colors of."
    edit_colors_button.disabled = true

func _enable_edit_color_button() -> void:
    edit_colors_button.tooltip_text = "Edit the accompanying colors for this theme."

func _on_button_pressed() -> void:
    on_click.emit()

func _on_edit_colors_button_pressed() -> void:
    on_edit_colors_pressed.emit()
