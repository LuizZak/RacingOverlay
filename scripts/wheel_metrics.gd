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
const WHEEL_SIZE := Vector2(17, 30)

const ENGINE_SIZE := Vector2(20, 30)

@onready var spinner_container: PanelContainer = $SpinnerContainer

@export
var back_color: Color = Color.WHITE:
    set(value):
        back_color = value
        queue_redraw()

@export
var show_engine: bool = true:
    set(value):
        show_engine = value
        queue_redraw()

@export
var show_spinner: bool = true:
    set(value):
        show_spinner = value
        if spinner_container != null:
            _update_spinner()

var engine_display: EngineDisplay = EngineDisplay.new(Vector2.ZERO)
var wheel_entries: Dictionary[Wheel, WheelEntry] = {
    Wheel.REAR_LEFT: WheelEntry.make_rear_left(),
    Wheel.REAR_RIGHT: WheelEntry.make_rear_right(),
    Wheel.FRONT_LEFT: WheelEntry.make_front_left(),
    Wheel.FRONT_RIGHT: WheelEntry.make_front_right(),
}

func _ready() -> void:
    reset()
    _update_spinner()

func reset() -> void:
    engine_display.update(1000, 7000, 1000)

    wheel_entries[Wheel.REAR_LEFT].update(0.0, 0.0)
    wheel_entries[Wheel.REAR_RIGHT].update(0.0, 0.0)
    wheel_entries[Wheel.FRONT_LEFT].update(0.0, 0.0)
    wheel_entries[Wheel.FRONT_RIGHT].update(0.0, 0.0)

func update_with_packet(packet: GamePacketBase) -> void:
    queue_redraw()

    if packet is Dirt2GamePacket:
        engine_display.update(packet.idle_rpm, packet.max_rpm, packet.rpm)

        wheel_entries[Wheel.REAR_LEFT].update(packet.speed_ms, packet.wsp_rl)
        wheel_entries[Wheel.REAR_RIGHT].update(packet.speed_ms, packet.wsp_rr)
        wheel_entries[Wheel.FRONT_LEFT].update(packet.speed_ms, packet.wsp_fl, packet.steering * deg_to_rad(25))
        wheel_entries[Wheel.FRONT_RIGHT].update(packet.speed_ms, packet.wsp_fr, packet.steering * deg_to_rad(25))
    elif packet is ACRallyGamePacket:
        engine_display.update(1000, 2000, 1000)

        wheel_entries[Wheel.REAR_LEFT].update(packet.speed_kph, packet.wheel_speed_rl)
        wheel_entries[Wheel.REAR_RIGHT].update(packet.speed_kph, packet.wheel_speed_rr)
        wheel_entries[Wheel.FRONT_LEFT].update(packet.speed_kph, packet.wheel_speed_fl, packet.steering * deg_to_rad(25))
        wheel_entries[Wheel.FRONT_RIGHT].update(packet.speed_kph, packet.wheel_speed_fr, packet.steering * deg_to_rad(25))

func _draw() -> void:
    # Draw background
    var bounds := _bounds_for_drawing().grow(10)

    var style_box := StyleBoxFlat.new()
    style_box.border_color = Color.BLACK
    style_box.bg_color = back_color
    style_box.border_blend = true
    style_box.set_border_width_all(2)
    style_box.set_corner_radius_all(8)

    draw_style_box(style_box, bounds)

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

    # Draw engine
    if show_engine:
        engine_display.draw(self)

    # Draw wheels
    for wheel in wheel_entries.values():
        wheel.draw(self)

func _bounds_for_drawing() -> Rect2:
    var bounds := Rect2()

    bounds.merge(engine_display.bounds())

    for wheel in wheel_entries.values():
        bounds = bounds.merge(wheel.bounds())

    return bounds

func _update_spinner() -> void:
    spinner_container.visible = show_spinner

## TODO: Add support for displaying 'no engine info' by passing zeroes to update()
## Manages the display of the engine on the power train.
class EngineDisplay:
    var position: Vector2
    var size: Vector2
    var idle_rpm: float = 0.0
    var max_rpm: float = 0.0
    var current_rpm: float = 0.0

    func _init(position: Vector2, size: Vector2 = ENGINE_SIZE) -> void:
        self.position = position
        self.size = size

    func update(idle_rpm: float, max_rpm: float, current_rpm: float) -> void:
        self.idle_rpm = idle_rpm
        self.max_rpm = max_rpm
        self.current_rpm = current_rpm

    func draw(canvas_item: CanvasItem) -> void:
        canvas_item.draw_set_transform(position)

        # Draw background
        var bg_style_box := StyleBoxFlat.new()
        bg_style_box.set_border_width_all(2)
        bg_style_box.set_corner_radius_all(4)
        bg_style_box.bg_color = Color.WHITE
        bg_style_box.border_color = Color.TRANSPARENT

        canvas_item.draw_style_box(bg_style_box, local_bounds())

        # Draw fill
        var segments := minf(11, maxf(4, int(max_rpm / 1000.0)))
        var seg_height := size.y / segments
        for i in range(segments):
            var start_y := seg_height * i
            var relative := 1 - float(i) / segments

            if max_rpm != 0.0 and current_rpm / max_rpm >= relative:
                canvas_item.draw_rect(
                    Rect2(-size.x / 2, -size.y / 2 + start_y, size.x, seg_height),
                    Color.RED.lerp(Color.GREEN, float(i) / segments),
                    true,
                )

        for i in range(segments - 1):
            var start_y := seg_height * (i + 1)
            canvas_item.draw_line(
                Vector2(-size.x / 2, -size.y / 2 + start_y),
                Vector2(size.x / 2, -size.y / 2 + start_y),
                Color.WHITE
            )

        # Draw outline
        var outline_style_box := StyleBoxFlat.new()
        outline_style_box.set_border_width_all(2)
        outline_style_box.bg_color = Color.TRANSPARENT
        outline_style_box.expand_margin_top = 0.0
        outline_style_box.border_color = Color.BLACK

        canvas_item.draw_style_box(outline_style_box, local_bounds())

    func _fill_color() -> Color:
        if current_rpm >= max_rpm:
            return Color.RED
        if current_rpm <= idle_rpm:
            return Color.BLUE

        var lower_range := idle_rpm
        var upper_range := max_rpm

        var normalized := (current_rpm - lower_range) / (upper_range - lower_range)

        if normalized <= 0.5:
            return Color.RED # Color.BLUE.lerp(Color.ORANGE, normalized * 2.0) #LCH.lerp_color(Color.BLUE, Color.YELLOW, normalized * 2.0)
        else:
            return Color.RED # Color.ORANGE.lerp(Color.RED, (normalized - 0.5) * 2.0) # LCH.lerp_color(Color.YELLOW, Color.RED, (normalized - 0.5) * 2.0)

    func bounds() -> Rect2:
        return Rect2(position - size / 2, size)

    func local_bounds() -> Rect2:
        return Rect2(Vector2.ZERO - size / 2, size)

## A wheel entry, with information about positioning and color in local node space.
class WheelEntry:
    var position: Vector2
    var size: Vector2
    var rotation: float = 0.0
    var fill_color: Color = Color.TRANSPARENT
    var is_locked: bool = false
    var relative_rev: float = 0.0
    var show_chevrons: bool = false

    func _init(position: Vector2, size: Vector2 = WHEEL_SIZE) -> void:
        self.position = position
        self.size = size

    func update(vehicle_speed: float, wheel_speed: float, wheel_rotation_radians: float = 0.0) -> void:
        rotation = wheel_rotation_radians

        if vehicle_speed == wheel_speed:
            fill_color = Color.GREEN
            is_locked = false
            return

        var tolerance := maxf(0.1, abs(vehicle_speed) / 2.0)
        var diff := absf(vehicle_speed - absf(wheel_speed))
        var ratio := minf(1.0, diff / tolerance)

        if wheel_speed >= vehicle_speed:
            fill_color = LCH.lerp_color(Color.GREEN, Color.YELLOW, ratio)
            relative_rev = ratio
        else:
            fill_color = LCH.lerp_color(Color.GREEN, Color.RED, ratio)
            relative_rev = -ratio

        const LOCK_TOLERANCE := 0.1

        if absf(vehicle_speed) > LOCK_TOLERANCE and absf(wheel_speed) < LOCK_TOLERANCE:
            is_locked = true
        else:
            is_locked = false

        const CHEVRON_TOLERANCE := 0.1

        show_chevrons = absf(vehicle_speed) > CHEVRON_TOLERANCE

    func draw(canvas_item: CanvasItem) -> void:
        canvas_item.draw_set_transform(position, rotation)

        var style_box := StyleBoxFlat.new()
        style_box.border_color = Color.BLACK
        style_box.bg_color = fill_color
        style_box.set_border_width_all(2)
        style_box.set_corner_radius_all(4)

        canvas_item.draw_style_box(style_box, local_bounds())

        if is_locked:
            draw_padlock(canvas_item)
        elif show_chevrons and relative_rev > 0.8:
            draw_over_spin(canvas_item)
        elif show_chevrons and relative_rev < -0.8:
            draw_under_spin(canvas_item)

    func draw_padlock(canvas_item: CanvasItem) -> void:
        var line_width := 0.7

        # Draw padlock body
        var padlock_body_bounds := local_bounds()
        padlock_body_bounds = padlock_body_bounds.grow(-4)
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

    func draw_over_spin(canvas_item: CanvasItem) -> void:
        var bounds := local_bounds().grow(-3)

        var chevron: PackedVector2Array = []

        chevron.append(Vector2(-bounds.size.x / 2, 2))
        chevron.append(Vector2(0.0, -2))
        chevron.append(Vector2(bounds.size.x / 2, 2))

        var xtrans_up := Transform2D.IDENTITY.translated(Vector2(0, -6))
        var xtrans_down := Transform2D.IDENTITY.translated(Vector2(0, 4))

        canvas_item.draw_polyline(xtrans_up * chevron, Color.BLACK, 0.5, true)
        canvas_item.draw_polyline(xtrans_down * chevron, Color.BLACK, 0.5, true)

    func draw_under_spin(canvas_item: CanvasItem) -> void:
        var bounds := local_bounds().grow(-3)

        var chevron: PackedVector2Array = []

        chevron.append(Vector2(-bounds.size.x / 2, -2))
        chevron.append(Vector2(0.0, 2))
        chevron.append(Vector2(bounds.size.x / 2, -2))

        var xtrans_up := Transform2D.IDENTITY.translated(Vector2(0, -4))
        var xtrans_down := Transform2D.IDENTITY.translated(Vector2(0, 6))

        canvas_item.draw_polyline(xtrans_up * chevron, Color.BLACK, 0.5, true)
        canvas_item.draw_polyline(xtrans_down * chevron, Color.BLACK, 0.5, true)

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
