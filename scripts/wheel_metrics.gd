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
    wheel_entries[Wheel.REAR_LEFT].update(0.0, 0.0)
    wheel_entries[Wheel.REAR_RIGHT].update(0.0, 0.0)
    wheel_entries[Wheel.FRONT_LEFT].update(0.0, 0.0)
    wheel_entries[Wheel.FRONT_RIGHT].update(0.0, 0.0)

func update_with_packet(packet: GamePacketBase) -> void:
    queue_redraw()

    if packet is Dirt2GamePacket:
        wheel_entries[Wheel.REAR_LEFT].update(packet.speed_ms, packet.wsp_rl)
        wheel_entries[Wheel.REAR_RIGHT].update(packet.speed_ms, packet.wsp_rr)
        wheel_entries[Wheel.FRONT_LEFT].update(packet.speed_ms, packet.wsp_fl)
        wheel_entries[Wheel.FRONT_RIGHT].update(packet.speed_ms, packet.wsp_fr)

func _draw() -> void:
    # Draw background
    var bounds := _bounds_for_drawing().grow(10)

    draw_rect(bounds, back_color, true)

    # Draw power train
    const POWERTRAIN_COLOR := Color.BLACK
    const POWERTRAIN_WIDTH := 2.0

    var rl := wheel_entries[Wheel.REAR_LEFT].get_center()
    var rr := wheel_entries[Wheel.REAR_RIGHT].get_center()
    var fl := wheel_entries[Wheel.FRONT_LEFT].get_center()
    var fr := wheel_entries[Wheel.FRONT_RIGHT].get_center()

    var rear := (rl + rr) / 2.0
    var front := (fl + fr) / 2.0

    draw_line(fl, fr, POWERTRAIN_COLOR, POWERTRAIN_WIDTH, true)
    draw_line(front, rear, POWERTRAIN_COLOR, POWERTRAIN_WIDTH, true)
    draw_line(rl, rr, POWERTRAIN_COLOR, POWERTRAIN_WIDTH, true)

    # Draw wheels
    for wheel in wheel_entries.values():
        wheel.draw(self)

func _bounds_for_drawing() -> Rect2:
    var bounds := Rect2()

    for wheel in wheel_entries.values():
        bounds = bounds.merge(wheel.bounds())

    return bounds

## A wheel entry, with information about positioning and color in local node space.
class WheelEntry:
    var position: Vector2
    var size: Vector2
    var rotation: float = 0.0
    var fill_color: Color = Color.TRANSPARENT
    var is_locked: bool = false

    func _init(position: Vector2, size: Vector2 = WHEEL_SIZE) -> void:
        self.position = position
        self.size = size

    func update(vehicle_speed: float, wheel_speed: float) -> void:
        if vehicle_speed == wheel_speed:
            fill_color = Color.GREEN
            is_locked = false
            return

        var tolerance := maxf(0.1, abs(vehicle_speed) / 2.0)
        var diff := absf(vehicle_speed - wheel_speed)
        var ratio := minf(1.0, diff / tolerance)

        if wheel_speed > vehicle_speed:
            fill_color = Color.GREEN.lerp(Color.YELLOW, ratio)
        else:
            fill_color = Color.GREEN.lerp(Color.RED, ratio)

        var lock_tolerance := 0.1

        if absf(vehicle_speed) > lock_tolerance and absf(wheel_speed) < lock_tolerance:
            is_locked = true
        else:
            is_locked = false

    func draw(canvas_item: CanvasItem) -> void:
        canvas_item.draw_set_transform(position, rotation)

        var style_box = StyleBoxFlat.new()
        style_box.border_color = Color.BLACK
        style_box.bg_color = fill_color
        style_box.set_border_width_all(2.0)
        style_box.set_corner_radius_all(4)

        canvas_item.draw_style_box(style_box, local_bounds())

        if is_locked:
            draw_padlock(canvas_item)

    func draw_padlock(canvas_item: CanvasItem) -> void:
        var line_width := 0.7

        # Draw padlock body
        var padlock_body_bounds := local_bounds()
        padlock_body_bounds = padlock_body_bounds.grow(-3)
        padlock_body_bounds.size.y = padlock_body_bounds.size.x
        padlock_body_bounds.position.y = self.local_bounds().get_center().y - padlock_body_bounds.size.y * 0.3

        canvas_item.draw_rect(padlock_body_bounds, Color.BLACK, false, line_width, true)

        # Draw padlock keyhole
        var keyhole_start := padlock_body_bounds.get_center()
        var keyhole_end := keyhole_start + padlock_body_bounds.size * Vector2(0, 0.2)
        canvas_item.draw_line(
            keyhole_start, keyhole_end, Color.BLACK, line_width, true
        )

        # Draw padlock shackle
        var shackle_arc_radius := padlock_body_bounds.size.x * 0.4
        var shackle_arc_center := Vector2(
            padlock_body_bounds.get_center().x,
            padlock_body_bounds.position.y - shackle_arc_radius * 0.6
        )
        var shackle_left := Vector2(
            shackle_arc_center.x - shackle_arc_radius,
            shackle_arc_center.y
        )
        var shackle_right := Vector2(
            shackle_arc_center.x + shackle_arc_radius,
            shackle_arc_center.y
        )
        canvas_item.draw_arc(
            shackle_arc_center, shackle_arc_radius, -PI, 0, 10, Color.BLACK, line_width, true
        )
        canvas_item.draw_line(
            shackle_left, Vector2(shackle_left.x, padlock_body_bounds.position.y), Color.BLACK, line_width, true
        )
        canvas_item.draw_line(
            shackle_right, Vector2(shackle_right.x, padlock_body_bounds.position.y), Color.BLACK, line_width, true
        )

    func bounds() -> Rect2:
        return Rect2(position - size / 2, size)

    func local_bounds() -> Rect2:
        return Rect2(Vector2.ZERO - size / 2, size)

    func get_center() -> Vector2:
        return position

    func get_center_left() -> Vector2:
        return position - size * Vector2(0.5, 0.0)

    func get_center_right() -> Vector2:
        return position + size * Vector2(0.5, 0.0)

    static func make_rear_left() -> WheelEntry:
        return WheelEntry.new(WHEEL_OFFSET * Vector2(-1, 1))

    static func make_rear_right() -> WheelEntry:
        return WheelEntry.new(WHEEL_OFFSET * Vector2(1, 1))

    static func make_front_left() -> WheelEntry:
        return WheelEntry.new(WHEEL_OFFSET * Vector2(-1, -1))

    static func make_front_right() -> WheelEntry:
        return WheelEntry.new(WHEEL_OFFSET * Vector2(1, -1))
