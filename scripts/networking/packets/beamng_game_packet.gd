class_name BeamNGGamePacket
extends GamePacketBase

const PACKET_SIZE: int = 88

var magic: PackedByteArray

var pos: Vector3
var vel: Vector3
var acc: Vector3

var upVec: Vector3

var rollPos: float
var pitchPos: float
var yawPos: float

var rollRate: float
var pitchRate: float
var yawRate: float

var rollAcc: float
var pitchAcc: float
var yawAcc: float

## Gets the game associated with this packet type.
func get_game() -> Game:
    return Game.BEAMNG

#region Required

## Gets the computed roll angle of the packet's information.
func computed_roll_angle() -> float:
    return -rollPos

## Gets the computed vertical velocity of the packet's information.
func computed_vertical_velocity() -> float:
    return vel.z

## Gets the computed forward velocity of the packet's information.
func computed_forward_velocity() -> float:
    return 0.0

## Returns `true` if this is an end-of-signal packet.
func is_end_packet() -> bool:
    return upVec == Vector3.ZERO

#endregion

## Returns a BeamNG-compatible data packet. Some sections of the packet that
## are unused are filled with zeroes.
func to_data() -> PackedByteArray:
    var data: PackedByteArray = []
    data.resize(PACKET_SIZE)
    data.fill(0)

    data.encode_u64(0, magic.decode_u64(0))
    data.encode_float(4, pos.x)
    data.encode_float(8, pos.y)
    data.encode_float(12, pos.z)
    data.encode_float(16, vel.x)
    data.encode_float(20, vel.y)
    data.encode_float(24, vel.z)
    data.encode_float(28, acc.x)
    data.encode_float(32, acc.y)
    data.encode_float(36, acc.z)
    data.encode_float(40, upVec.x)
    data.encode_float(44, upVec.y)
    data.encode_float(48, upVec.z)
    data.encode_float(52, rollPos)
    data.encode_float(56, pitchPos)
    data.encode_float(60, yawPos)
    data.encode_float(64, rollRate)
    data.encode_float(68, pitchRate)
    data.encode_float(72, yawRate)
    data.encode_float(76, rollAcc)
    data.encode_float(80, pitchAcc)
    data.encode_float(84, yawAcc)

    return data

## Creates a new game packet from a given set of data.
static func from_data(data: PackedByteArray) -> GamePacketBase:
    var packet = BeamNGGamePacket.new()

    packet.magic = data.slice(0, 4)
    packet.pos.x = data.decode_float(4)
    packet.pos.y = data.decode_float(8)
    packet.pos.z = data.decode_float(12)
    packet.vel.x = data.decode_float(16)
    packet.vel.y = data.decode_float(20)
    packet.vel.z = data.decode_float(24)
    packet.acc.x = data.decode_float(28)
    packet.acc.y = data.decode_float(32)
    packet.acc.z = data.decode_float(36)
    packet.upVec.x = data.decode_float(40)
    packet.upVec.y = data.decode_float(44)
    packet.upVec.z = data.decode_float(48)
    packet.rollPos = data.decode_float(52)
    packet.pitchPos = data.decode_float(56)
    packet.yawPos = data.decode_float(60)
    packet.rollRate = data.decode_float(64)
    packet.pitchRate = data.decode_float(68)
    packet.yawRate = data.decode_float(72)
    packet.rollAcc = data.decode_float(76)
    packet.pitchAcc = data.decode_float(80)
    packet.yawAcc = data.decode_float(84)

    return packet
