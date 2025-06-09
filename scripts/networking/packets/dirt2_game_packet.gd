class_name Dirt2GamePacket
extends GamePacketBase

const PACKET_SIZE: int = 264

var run_time: float
var lap_time: float
var distance: float
## Note: 0.0 to 1.0
var progress: float
var pos: Vector3
var speed_ms: float
var vel: Vector3
var roll: Vector3
var pitch: Vector3
var susp_rl: float
var susp_rr: float
var susp_fl: float
var susp_fr: float
var susp_vel_rl: float
var susp_vel_rr: float
var susp_vel_fl: float
var susp_vel_fr: float
var wsp_rl: float
var wsp_rr: float
var wsp_fl: float
var wsp_fr: float
## Note: 0.0 to 1.0
var throttle: float
## Note: -1.0 to 1.0
var steering: float
## Note: 0.0 to 1.0
var brakes: float
## Note: 0.0 to 1.0
var clutch: float
## Note: 0 for neutral, 10 for reverse
var gear: float
var g_force_lat: float
var g_force_lon: float
var current_lap: float
## Note: * 10 for realistic values
var rpm: float
var car_pos: float
## Note: * 10 for realistic values
var max_rpm: float
## Note: * 10 for realistic values
var idle_rpm: float
var max_gears: float

## Gets the game associated with this packet type.
func get_game() -> Game:
    return Game.DIRT_2

#region Required

## Gets the computed roll angle of the packet's information.
func computed_roll_angle() -> float:
    var roll_angle = Vector3.UP.angle_to(roll)
    return -roll_angle + PI / 2

## Gets the computed vertical velocity of the packet's information.
func computed_vertical_velocity() -> float:
    return vel.y

## Gets the computed forward velocity of the packet's information.
func computed_forward_velocity() -> float:
    return speed_ms

## Returns `true` if this packet has been detected as a valid game packet.
func is_valid_game_packet() -> bool:
    return true

## Returns `true` if this is an end-of-signal packet.
func is_end_packet() -> bool:
    return roll == Vector3.ZERO and pitch == Vector3.ZERO

#endregion

## Returns a Dirt 2.0-compatible data packet. Some sections of the packet that
## are unused are filled with zeroes.
func to_data() -> PackedByteArray:
    var data: PackedByteArray = []
    data.resize(PACKET_SIZE)
    data.fill(0)

    data.encode_float(0, run_time)
    data.encode_float(4, lap_time)
    data.encode_float(8, distance)
    data.encode_float(12, progress)
    data.encode_float(16, pos.x)
    data.encode_float(20, pos.y)
    data.encode_float(24, pos.z)
    data.encode_float(28, speed_ms)
    data.encode_float(32, vel.x)
    data.encode_float(36, vel.y)
    data.encode_float(40, vel.z)
    data.encode_float(44, roll.x)
    data.encode_float(48, roll.y)
    data.encode_float(52, roll.z)
    data.encode_float(56, pitch.x)
    data.encode_float(60, pitch.y)
    data.encode_float(64, pitch.z)
    data.encode_float(68, susp_rl)
    data.encode_float(72, susp_rr)
    data.encode_float(76, susp_fl)
    data.encode_float(80, susp_fr)
    data.encode_float(84, susp_vel_rl)
    data.encode_float(88, susp_vel_rr)
    data.encode_float(92, susp_vel_fl)
    data.encode_float(96, susp_vel_fr)
    data.encode_float(100, wsp_rl)
    data.encode_float(104, wsp_rr)
    data.encode_float(108, wsp_fl)
    data.encode_float(112, wsp_fr)
    data.encode_float(116, throttle)
    data.encode_float(120, steering)
    data.encode_float(124, brakes)
    data.encode_float(128, clutch)
    data.encode_float(132, gear)
    data.encode_float(136, g_force_lat)
    data.encode_float(140, g_force_lon)
    data.encode_float(144, current_lap)
    data.encode_float(148, rpm)
    data.encode_float(156, car_pos)
    data.encode_float(252, max_rpm)
    data.encode_float(256, idle_rpm)
    data.encode_float(260, max_gears)

    return data

## Creates a new game packet from a given set of data.
static func from_data(data: PackedByteArray) -> GamePacketBase:
    var packet = Dirt2GamePacket.new()

    packet.run_time = data.decode_float(0)
    packet.lap_time = data.decode_float(4)
    packet.distance = max(0, data.decode_float(8))
    packet.progress = data.decode_float(12)
    packet.pos.x = data.decode_float(16)
    packet.pos.y = data.decode_float(20)
    packet.pos.z = data.decode_float(24)
    packet.speed_ms = data.decode_float(28)
    packet.vel.x = data.decode_float(32)
    packet.vel.y = data.decode_float(36)
    packet.vel.z = data.decode_float(40)
    packet.roll.x = data.decode_float(44)
    packet.roll.y = data.decode_float(48)
    packet.roll.z = data.decode_float(52)
    packet.pitch.x = data.decode_float(56)
    packet.pitch.y = data.decode_float(60)
    packet.pitch.z = data.decode_float(64)
    packet.susp_rl = data.decode_float(68)
    packet.susp_rr = data.decode_float(72)
    packet.susp_fl = data.decode_float(76)
    packet.susp_fr = data.decode_float(80)
    packet.susp_vel_rl = data.decode_float(84)
    packet.susp_vel_rr = data.decode_float(88)
    packet.susp_vel_fl = data.decode_float(92)
    packet.susp_vel_fr = data.decode_float(96)
    packet.wsp_rl = data.decode_float(100)
    packet.wsp_rr = data.decode_float(104)
    packet.wsp_fl = data.decode_float(108)
    packet.wsp_fr = data.decode_float(112)
    packet.throttle = data.decode_float(116)
    packet.steering = data.decode_float(120)
    packet.brakes = data.decode_float(124)
    packet.clutch = data.decode_float(128)
    packet.gear = data.decode_float(132)
    packet.g_force_lat = data.decode_float(136)
    packet.g_force_lon = data.decode_float(140)
    packet.current_lap = data.decode_float(144)
    packet.rpm = data.decode_float(148)
    packet.car_pos = data.decode_float(156)
    packet.max_rpm = data.decode_float(252)
    packet.idle_rpm = data.decode_float(256)
    packet.max_gears = data.decode_float(260)

    return packet
