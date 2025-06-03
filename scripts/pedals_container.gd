class_name PedalsContainer
extends Node2D

@onready var clutch_pedal: Node2D = %ClutchPedal
@onready var brake_pedal: Node2D = %BrakePedal
@onready var throttle_pedal: Node2D = %ThrottlePedal

@onready var pedals: Node2D = $PedalsOffsetContainer/Pedals
@onready var pedals_offset_container: Node2D = $PedalsOffsetContainer

var pedals_jiggle_phase: float = 0.0
var pedals_jiggle_frequency: float = 100.0
@export var pedals_jiggle_amplitude: float = 0.35
var _latest_throttle_position: float = 0.0

func _process(delta: float) -> void:
    pedals_jiggle_phase += delta

    if Settings.instance.pedal_vibration:
        var strength = Settings.instance.pedal_vibration_strength

        var x_jiggle = cos(pedals_jiggle_phase * pedals_jiggle_frequency) * pedals_jiggle_amplitude * strength
        var y_jiggle = sin(pedals_jiggle_phase * pedals_jiggle_frequency) * pedals_jiggle_amplitude * strength

        pedals_offset_container.position = Vector2(x_jiggle, y_jiggle) * _latest_throttle_position
    else:
        pedals_offset_container.position = Vector2.ZERO

func update_pedals(
    normalized_clutch: float,
    normalized_brake: float,
    normalized_throttle: float
):
    _latest_throttle_position = normalized_throttle

    update_pedal_position(clutch_pedal, normalized_clutch)
    update_pedal_position(brake_pedal, normalized_brake)
    update_pedal_position(throttle_pedal, normalized_throttle)
    update_pedals_rotation(
        normalized_clutch,
        normalized_brake,
        normalized_throttle,
    )

func update_pedal_position(pedal: Node2D, amount: float):
    pedal.position.y = amount * 25

func update_pedals_rotation(clutch: float, brake: float, throttle: float):
    if Settings.instance.pedal_sink:
        var total = clutch - throttle
        pedals.rotation_degrees = total
        pedals.position.y = clutch + brake + throttle
    else:
        pedals.rotation_degrees = 0.0
        pedals.position.y = 0
