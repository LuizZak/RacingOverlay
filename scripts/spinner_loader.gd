@tool
class_name SpinnerLoader
extends Control

## The spin rate of the widget, in radians per seconds.
@export_custom(PROPERTY_HINT_RANGE, "0,1800,radians_as_degrees")
var spin_rate: float = PI

## The radius of the spinner widget.
@export
var spinner_radius: float = 10.0

@export
var spinner_start_color: Color = Color(0.74509805, 0.74509805, 0.74509805, 0.0):
    set(value):
        spinner_start_color = value
        queue_redraw()

@export
var spinner_end_color: Color = Color.GRAY:
    set(value):
        spinner_end_color = value
        queue_redraw()

var spin_rotation: float = 0.0

func _process(delta: float) -> void:
    if not Engine.is_editor_hint():
        spin_rotation = fmod(spin_rotation + spin_rate * delta, PI * 2)
        queue_redraw()

func _draw() -> void:
    var point_count := 32

    var center := size / 2

    var points: PackedVector2Array = []
    var colors: PackedColorArray = []

    for i in range(point_count):
        var ratio := float(i) / point_count
        var angle := ratio * PI * 2 + spin_rotation
        var color := spinner_start_color.lerp(spinner_end_color, ratio)
        var point := center + Vector2.from_angle(angle) * spinner_radius

        points.append(point)
        colors.append(color)

    draw_polyline_colors(points, colors, 2.0, true)

func _get_minimum_size() -> Vector2:
    return Vector2(spinner_radius * 2, spinner_radius * 2)
