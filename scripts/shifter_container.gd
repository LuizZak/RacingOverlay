class_name ShifterContainer
extends Node2D

var input_manager: InputManagerBase

@onready var shifter_base: Sprite2D = $ShifterBase
@onready var shifter_knob: Sprite2D = $ShifterKnob
@onready var shifter_label: Label = $PanelContainer/ShifterLabel

@export var shifter_shaft_thickness: float = 10.0
@export var shifter_shaft_color: Color = Color.WHITE

var shifter_animation: ShifterAnimationBase
var shifter_animation_factor: float = 0.0
var shifter_origin: Vector2

func _ready() -> void:
    shifter_animation = ShifterAnimationNeutral.new()
    shifter_origin = shifter_knob.position

func _draw() -> void:
    draw_line(shifter_base.position, shifter_knob.position, shifter_shaft_color, shifter_shaft_thickness, true)

func _process(delta: float) -> void:
    if input_manager != null:
        shifter_label.text = input_manager.readable_gear()

    shifter_animation.update_shifter_position(shifter_knob, clampf(shifter_animation_factor, 0.0, 1.0), shifter_origin)
    queue_redraw()

func set_shifter_animation_gear(gear: int):
    shifter_animation = ShifterAnimationNeutral.new()

    if gear == 1:
        shifter_animation = ShifterAnimationFirstGear.new()
    if gear == 2:
        shifter_animation = ShifterAnimationSecondGear.new()
    if gear == 3:
        shifter_animation = ShifterAnimationThirdGear.new()
    if gear == 4:
        shifter_animation = ShifterAnimationFourthGear.new()
    if gear == 5:
        shifter_animation = ShifterAnimationFifthGear.new()
    if gear == 6:
        shifter_animation = ShifterAnimationSixthGear.new()

class ShifterAnimationBase:
    func update_shifter_position(shifter: Node2D, factor: float, origin: Vector2):
        pass

    func numerical_gear() -> int:
        return 0

class ShifterAnimationNeutral extends ShifterAnimationBase:
    func update_shifter_position(shifter, factor, origin):
        shifter.position = origin

    func numerical_gear() -> int:
        return 0

class ShifterAnimationFirstGear extends ShifterAnimationBase:
    func update_shifter_position(shifter, factor, origin):
        shifter.position = origin

        if factor >= 0.5:
            shifter.position += Vector2(13, 0)
            shifter.position += Vector2(-10, 10) * ((factor - 0.5) * 2)
        else:
            shifter.position += Vector2(13, 0) * (factor * 2)

    func numerical_gear() -> int:
        return 1

class ShifterAnimationSecondGear extends ShifterAnimationBase:
    func update_shifter_position(shifter, factor, origin):
        shifter.position = origin

        if factor >= 0.5:
            shifter.position += Vector2(5, 0)
            shifter.position += Vector2(10, 10) * ((factor - 0.5) * 2)
        else:
            shifter.position += Vector2(5, 0) * (factor * 2)

    func numerical_gear() -> int:
        return 2

class ShifterAnimationThirdGear extends ShifterAnimationBase:
    func update_shifter_position(shifter, factor, origin):
        shifter.position = origin

        shifter.position += Vector2(-10, 10) * ((factor - 0.5) * 2)

    func numerical_gear() -> int:
        return 3

class ShifterAnimationFourthGear extends ShifterAnimationBase:
    func update_shifter_position(shifter, factor, origin):
        shifter.position = origin

        shifter.position += Vector2(10, 10) * ((factor - 0.5) * 2)

    func numerical_gear() -> int:
        return 4

class ShifterAnimationFifthGear extends ShifterAnimationBase:
    func update_shifter_position(shifter, factor, origin):
        shifter.position = origin

        if factor >= 0.5:
            shifter.position += Vector2(-13, 0)
            shifter.position += Vector2(-10, 10) * ((factor - 0.5) * 2)
        else:
            shifter.position += Vector2(-13, 0) * (factor * 2)

    func numerical_gear() -> int:
        return 5

class ShifterAnimationSixthGear extends ShifterAnimationBase:
    func update_shifter_position(shifter, factor, origin):
        shifter.position = origin

        if factor >= 0.5:
            shifter.position += Vector2(-12, 0)
            shifter.position += Vector2(10, 10) * ((factor - 0.5) * 2)
        else:
            shifter.position += Vector2(-12, 0) * (factor * 2)

    func numerical_gear() -> int:
        return 6
