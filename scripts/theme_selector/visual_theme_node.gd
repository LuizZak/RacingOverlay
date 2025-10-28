class_name VisualThemeNode
extends MarginContainer

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

@onready var theme_name_label: Label = %ThemeNameLabel

signal on_click()

var visual_theme: VisualTheme = null

func load_visual_theme(theme: VisualTheme):
    self.visual_theme = theme
    self.theme_name_label.text = theme.display_name

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


func _on_button_pressed() -> void:
    on_click.emit()
