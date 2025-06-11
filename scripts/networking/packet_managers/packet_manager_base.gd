class_name PacketManagerBase
extends Object

var _roll_angle: float
var _forward_velocity: float
var _vertical_velocity: float
var _is_end_packet: bool = false

var _networking: NetworkingBase

func _init(networking: NetworkingBase):
    _networking = networking

## Called at the start of a frame to digest packets from the Networking layer.
func process(delta: float):
    while _networking.has_packets():
        _update(_networking.fetch_packet())

func _update(packet: GamePacketBase):
    _roll_angle = packet.computed_roll_angle()
    _forward_velocity = packet.computed_forward_velocity()
    _vertical_velocity = packet.computed_vertical_velocity()
    _is_end_packet = packet.is_end_packet()

func roll_angle() -> float:
    return _roll_angle

func forward_velocity() -> float:
    return _forward_velocity

func vertical_velocity() -> float:
    return _vertical_velocity

func is_end_packet() -> bool:
    return _is_end_packet
