@tool
class_name WheelMetrics
extends Node2D

enum Wheel {
    REAR_LEFT,
    REAR_RIGHT,
    FRONT_LEFT,
    FRONT_RIGHT,
}

const WHEEL_OFFSET := Vector2(20, 30)
const WHEEL_SIZE := Vector2(15, 30)

@export
var back_color: Color = Color.WHITE:
    set(value):
        back_color = value
        queue_redraw()

var wheel_entries: Dictionary[Wheel, WheelEntry] = {
    Wheel.REAR_LEFT: WheelEntry.make_rear_left(),
    Wheel.REAR_RIGHT: WheelEntry.make_rear_right(),
    Wheel.FRONT_LEFT: WheelEntry.make_front_left(),
    Wheel.FRONT_RIGHT: WheelEntry.make_front_right(),
}

func _ready() -> void:
    reset()

func reset() -> void:
    wheel_entries[Wheel.REAR_LEFT].fill_color = _color_for_wheel(0.0, 0.0)
    wheel_entries[Wheel.REAR_RIGHT].fill_color = _color_for_wheel(0.0, 0.0)
    wheel_entries[Wheel.FRONT_LEFT].fill_color = _color_for_wheel(0.0, 0.0)
    wheel_entries[Wheel.FRONT_RIGHT].fill_color = _color_for_wheel(0.0, 0.0)

func update_with_packet(packet: GamePacketBase) -> void:
    queue_redraw()

    if packet is Dirt2GamePacket:
        wheel_entries[Wheel.REAR_LEFT].fill_color = _color_for_wheel(packet.speed_ms, packet.wsp_rl)
        wheel_entries[Wheel.REAR_RIGHT].fill_color = _color_for_wheel(packet.speed_ms, packet.wsp_rr)
        wheel_entries[Wheel.FRONT_LEFT].fill_color = _color_for_wheel(packet.speed_ms, packet.wsp_fl)
        wheel_entries[Wheel.FRONT_RIGHT].fill_color = _color_for_wheel(packet.speed_ms, packet.wsp_fr)

func _color_for_wheel(vehicle_speed: float, wheel_speed: float) -> Color:
    if vehicle_speed == wheel_speed:
        return Color.GREEN

    var tolerance := maxf(0.1, abs(vehicle_speed) / 2.0)
    var diff := absf(vehicle_speed - wheel_speed)
    var ratio = minf(1.0, diff / tolerance)

    if wheel_speed > vehicle_speed:
        Color.GREEN.lerp(Color.YELLOW, ratio)

    return Color.GREEN.lerp(Color.RED, ratio)

func _draw() -> void:
    # Draw background
    var bounds = _bounds_for_drawing().grow(10)

    draw_rect(bounds, back_color, true)

    # Draw power train
    const POWERTRAIN_COLOR := Color.BLACK
    const POWERTRAIN_WIDTH := 2.0

    var rl = wheel_entries[Wheel.REAR_LEFT].get_center_right()
    var rr = wheel_entries[Wheel.REAR_RIGHT].get_center_left()
    var fl = wheel_entries[Wheel.FRONT_LEFT].get_center_right()
    var fr = wheel_entries[Wheel.FRONT_RIGHT].get_center_left()

    var rear = (rl + rr) / 2.0
    var front = (fl + fr) / 2.0

    draw_line(fl, fr, POWERTRAIN_COLOR, POWERTRAIN_WIDTH, true)
    draw_line(front, rear, POWERTRAIN_COLOR, POWERTRAIN_WIDTH, true)
    draw_line(rl, rr, POWERTRAIN_COLOR, POWERTRAIN_WIDTH, true)

    # Draw wheels
    for wheel in wheel_entries.values():
        wheel.draw(self)

func _bounds_for_drawing() -> Rect2:
    var bounds = Rect2()

    for wheel in wheel_entries.values():
        bounds = bounds.merge(wheel.bounds())

    return bounds

## A wheel entry, with information about positioning and color in local node space.
class WheelEntry:
    var position: Vector2
    var size: Vector2
    var fill_color: Color = Color.TRANSPARENT

    func _init(position: Vector2, size: Vector2) -> void:
        self.position = position
        self.size = size

    func draw(canvas_item: CanvasItem) -> void:
        canvas_item.draw_rect(bounds(), fill_color, true)
        canvas_item.draw_rect(bounds(), Color.BLACK, false, 1, true)

    func bounds() -> Rect2:
        return Rect2(position - size / 2, size)

    func get_center_left() -> Vector2:
        return position - size * Vector2(0.5, 0.0)

    func get_center_right() -> Vector2:
        return position + size * Vector2(0.5, 0.0)

    static func make_rear_left() -> WheelEntry:
        return WheelEntry.new(
            WHEEL_OFFSET * Vector2(-1, 1), WHEEL_SIZE
        )

    static func make_rear_right() -> WheelEntry:
        return WheelEntry.new(
            WHEEL_OFFSET * Vector2(1, 1), WHEEL_SIZE
        )

    static func make_front_left() -> WheelEntry:
        return WheelEntry.new(
            WHEEL_OFFSET * Vector2(-1, -1), WHEEL_SIZE
        )

    static func make_front_right() -> WheelEntry:
        return WheelEntry.new(
            WHEEL_OFFSET * Vector2(1, -1), WHEEL_SIZE
        )
