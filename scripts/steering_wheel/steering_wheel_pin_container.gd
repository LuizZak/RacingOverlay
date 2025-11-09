@tool
class_name SteeringWheelPinContainer
extends Node2D

@export_custom(PROPERTY_HINT_RANGE, "-360,360,radians_as_degrees")
var pin_offset_angle: float = 0.0:
    set(value):
        pin_offset_angle = value
        _regenerate_pins()

@export_range(1, 20)
var pin_count: int = 1:
    set(value):
        pin_count = value
        _regenerate_pins()

@export_range(1.0, 200.0)
var pin_radius: float = 10.0:
    set(value):
        pin_radius = value
        _regenerate_pins()

var _pins: Array[Marker2D] = []

func _ready() -> void:
    _regenerate_pins()

func get_pins() -> Array[Marker2D]:
    return _pins

func _regenerate_pins() -> void:
    for pin in get_pins():
        var parent := pin.get_parent()
        if parent != null:
            parent.remove_child(pin)

    _pins.clear()

    for i in range(pin_count):
        var pin := Marker2D.new()
        add_child(pin)
        _pins.append(pin)

        var angle := float(i) / pin_count * PI * 2 + pin_offset_angle
        pin.position = Vector2.from_angle(angle) * pin_radius
