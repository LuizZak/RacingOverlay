class_name MockNetworking
extends NetworkingBase

var _is_mocking: bool = false
var _mock_data: Array = []
var _next_packet_index: int = 0
var _fail_next_packet: bool = false

func save_mock_data(packets: Array):
    _mock_data = packets

    var file = FileAccess.open("user://mock_data.bin", FileAccess.WRITE)
    if !file:
        print("Failed to open mock data file!")
        return

    var count = packets.size()
    file.store_32(count)

    for packet: GamePacket in packets:
        file.store_buffer(packet.to_data())

func load_mock_data():
    _mock_data = []

    var file = FileAccess.open("user://mock_data.bin", FileAccess.READ)
    if !file:
        print("Failed to open mock data file!")
        return

    var count = file.get_32()

    for i in count:
        var packet_data = file.get_buffer(GamePacket.PACKET_SIZE)
        var packet = GamePacket.from_data(packet_data)
        _mock_data.append(packet)

func begin_mock():
    _is_mocking = true

func poll_connections() -> Error:
    if _is_mocking:
        return Error.OK

    return Error.FAILED

func connect_to_game() -> Error:
    if _is_mocking:
        return Error.OK

    return Error.FAILED

func disconnect_from_game() -> Error:
    return Error.OK

func is_connected_to_game() -> bool:
    return _is_mocking

func has_packets() -> bool:
    if !_is_mocking or _fail_next_packet:
        _fail_next_packet = false
        return false

    return _next_packet_index < _mock_data.size()

func fetch_packet() -> GamePacket:
    _fail_next_packet = true

    _next_packet_index += 1

    return _mock_data[_next_packet_index - 1]

func is_connection_available() -> bool:
    return _is_mocking
