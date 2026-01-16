class_name ACRallyGamePacket
extends GamePacketBase

const PACKET_SIZE: int = 92

var ac_version: String
var rpm: int
var max_rpm: int
var speed_kph: float
var wheel_speed_fl: float
var wheel_speed_fr: float
var wheel_speed_rl: float
var wheel_speed_rr: float
var heading: float
var pitch: float
var roll: float
var car_model: String

func get_game() -> Game:
    return Game.ACRALLY

#region Required

## Gets the computed roll angle of the packet's information.
func computed_roll_angle() -> float:
    return roll

## Gets the computed vertical velocity of the packet's information.
func computed_vertical_velocity() -> float:
    return 0.0

## Gets the computed forward velocity of the packet's information.
func computed_forward_velocity() -> float:
    return speed_kph

## Returns `true` if this packet has been detected as a valid game packet.
func is_valid_game_packet() -> bool:
    return true

## Returns `true` if this is an end-of-signal packet.
func is_end_packet() -> bool:
    return false

#endregion

func to_data() -> PackedByteArray:
    var data: PackedByteArray = []
    data.resize(PACKET_SIZE)
    data.fill(0)

    PbaHelpers.encode_fixed_length_ascii(data, ac_version, 0, 15)
    data.encode_s32(15, rpm)
    data.encode_s32(19, max_rpm)
    data.encode_float(23, speed_kph)
    data.encode_float(27, wheel_speed_fl)
    data.encode_float(31, wheel_speed_fr)
    data.encode_float(35, wheel_speed_rl)
    data.encode_float(39, wheel_speed_rr)
    data.encode_float(43, heading)
    data.encode_float(47, pitch)
    data.encode_float(51, roll)
    PbaHelpers.encode_fixed_length_ascii(data, car_model, 55, 33)

    return data

## Creates a new game packet from a given set of data.
static func from_data(data: PackedByteArray) -> GamePacketBase:
    var packet := ACRallyGamePacket.new()

    packet.ac_version = data.slice(0, 15).get_string_from_ascii()
    packet.rpm = data.decode_s32(15)
    packet.max_rpm = data.decode_s32(19)
    packet.speed_kph = data.decode_float(23)
    packet.wheel_speed_fl = data.decode_float(27)
    packet.wheel_speed_fr = data.decode_float(31)
    packet.wheel_speed_rl = data.decode_float(35)
    packet.wheel_speed_rr = data.decode_float(39)
    packet.heading = data.decode_float(43)
    packet.pitch = data.decode_float(47)
    packet.roll = data.decode_float(51)
    packet.car_model = data.slice(55, 55 + 33).get_string_from_ascii()

    return packet
