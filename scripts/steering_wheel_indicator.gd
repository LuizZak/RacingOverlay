class_name SteeringWheelIndicator
extends Node2D

var normalized_value: float:
    set(value):
        normalized_value = value
        queue_redraw()

@export
var radius: float = 80.0

func _draw() -> void:
    var width: float = 10.0
    var start_angle: float = deg_to_rad(-180.0)
    var end_angle: float = deg_to_rad(0.0)
    var steps = 100

    var points_back: PackedVector2Array = []
    var points_front: PackedVector2Array = []

    # Fill background
    for step in steps:
        var angle := lerpf(start_angle, end_angle, float(step) / float(steps))
        var next_point := Vector2.from_angle(angle) * radius
        points_back.push_back(next_point)

    # Fill foreground
    var fill_start_angle := deg_to_rad(-90)
    var fill_end_angle := deg_to_rad(-90) + deg_to_rad(-90) * normalized_value
    for step in steps:
        var angle := lerpf(fill_start_angle, fill_end_angle, float(step) / float(steps))
        var next_point := Vector2.from_angle(angle) * radius
        points_front.push_back(next_point)

    draw_polyline(points_back, Color.BLACK.lerp(Color.TRANSPARENT, 0.5), width, true)
    draw_polyline(points_front, Color.RED, width, true)
