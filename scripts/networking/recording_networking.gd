class_name RecordingNetworking
extends NetworkingBase

const FILE_NAME := "user://networking_data.bin"

var _is_recording: bool
var _base_networking: Networking

var _file: FileAccess
var _time: float = 0.0

var _packet_index: int = 0
var _packet_buffer: Array[EncodedPacket] = []

func _init(is_recording: bool) -> void:
    _is_recording = is_recording
    _base_networking = Networking.new()

    if _is_recording:
        _file = FileAccess.open(FILE_NAME, FileAccess.WRITE_READ)
    else:
        _file = FileAccess.open(FILE_NAME, FileAccess.READ)
        _decode_packets_from_file()
        _file.close()

func _decode_packets_from_file() -> void:
    _packet_buffer = []

    if _file.get_length() == 0:
        return

    while _file.get_position() < _file.get_length():
        var time := _file.get_float()
        var length := _file.get_32()
        var data := _file.get_buffer(length)

        var packet := EncodedPacket.new(time, data)
        _packet_buffer.append(packet)

func get_status() -> Status:
    if _is_recording:
        return _base_networking.get_status()

    return Status.CONNECTED

func set_port(port: int) -> void:
    _base_networking.set_port(port)

func set_mode(mode: Mode) -> void:
    _base_networking.set_mode(mode)

func set_game(game: GamePacketBase.Game) -> void:
    _base_networking.set_game(game)

func process(delta: float) -> void:
    _time += delta

func has_packets() -> bool:
    if _is_recording:
        return _base_networking.has_packets()

    return _peek_encoded_packet() != null

func poll_connections() -> Error:
    return _base_networking.poll_connections()

func is_connected_to_game() -> bool:
    if _is_recording:
        return _base_networking.is_connected_to_game()

    return true

func is_connection_available() -> bool:
    if _is_recording:
        return _base_networking.is_connected_to_game()

    return true

func connect_to_game() -> Error:
    if _is_recording:
        return _base_networking.connect_to_game()

    return OK

func disconnect_from_game() -> Error:
    if _is_recording:
        return _base_networking.disconnect_from_game()

    return OK

func fetch_packet() -> GamePacketBase:
    if _is_recording:
        var packet := _base_networking.fetch_packet()

        if packet != null:
            var data := packet.to_data()

            _file.store_float(_time)
            _file.store_32(data.size())
            _file.store_buffer(data)

        return packet

    var next_packet := _next_encoded_packet()
    if next_packet == null:
        return null

    return next_packet.decode_packet(_base_networking._game)

func _next_encoded_packet() -> EncodedPacket:
    var packet := _peek_encoded_packet()
    if packet:
        _packet_index += 1

    return packet

func _peek_encoded_packet() -> EncodedPacket:
    if _packet_index >= _packet_buffer.size():
        return null

    if _packet_buffer[_packet_index].is_available(_time):
        return _packet_buffer[_packet_index]

    return null

class EncodedPacket:
    var time: float
    var data: PackedByteArray

    @warning_ignore("shadowed_variable")
    func _init(time: float, data: PackedByteArray) -> void:
        self.time = time
        self.data = data

    func is_available(total_time: float) -> bool:
        return total_time >= time

    func decode_packet(game: GamePacketBase.Game) -> GamePacketBase:
        return GamePacketBase.from_generic_data(game, data)
