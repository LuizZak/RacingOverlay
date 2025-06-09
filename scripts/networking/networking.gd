class_name Networking
extends NetworkingBase

static var instance: Networking = Networking.new()

var server: UDPServer = UDPServer.new()
var _game: GamePacketBase.Game
var _peer: PacketPeerUDP
var _port: int = 20777
var _mode: Mode = Mode.CONNECT
var _status: Status = Status.AWAITING

signal on_status_changed(status: Status)

func _init():
    if _mode == Mode.CONNECT:
        server.listen(_port)

func _set_status(status: Status):
    if status == _status:
        return

    _status = status
    on_status_changed.emit(status)

func set_game(game: GamePacketBase.Game):
    if _game == game:
        return

    _game = game

    match _mode:
        Mode.DISCONNECT:
            pass
        Mode.CONNECT:
            _set_status(Status.AWAITING)
            server.stop()
            server.listen(_port)

func set_port(port: int):
    if port == _port:
        return

    _port = port

    server.stop()
    server.listen(_port)

func set_mode(mode: Mode):
    if _mode == mode:
        return

    _mode = mode

    match mode:
        Mode.DISCONNECT:
            disconnect_from_game()
            server.stop()

        Mode.CONNECT:
            _set_status(Status.AWAITING)
            server.listen(_port)

func poll_connections() -> Error:
    match _mode:
        Mode.DISCONNECT:
            return Error.OK

        Mode.CONNECT:
            server.poll()

            if is_connection_available():
                return connect_to_game()

            return Error.OK

        _:
            return Error.FAILED

func connect_to_game() -> Error:
    if _mode == Mode.DISCONNECT:
        return Error.FAILED

    if _peer != null:
        _peer.close()

    _peer = server.take_connection()
    if _peer == null:
        return Error.FAILED

    _set_status(Status.CONNECTED)

    return Error.OK

func disconnect_from_game() -> Error:
    if _peer:
        _peer.close()
        _peer = null

    match _mode:
        Mode.CONNECT:
            _set_status(Status.AWAITING)

        Mode.DISCONNECT:
            _set_status(Status.DISCONNECTED)

    return Error.OK

func is_connected_to_game() -> bool:
    return _peer != null and _peer.is_socket_connected()

func has_packets() -> bool:
    match _mode:
        Mode.CONNECT:
            server.poll()

            return _peer != null and _peer.get_available_packet_count() > 0

        Mode.DISCONNECT:
            return false

        _:
            return false

func fetch_packet() -> GamePacketBase:
    match _mode:
        Mode.CONNECT:
            if !is_connected_to_game():
                disconnect_from_game()
                return null

            var data = _peer.get_packet()
            var packet = GamePacketBase.from_generic_data(_game, data)

            if packet.is_end_packet():
                disconnect_from_game()

            return packet

        Mode.DISCONNECT:
            return null

        _:
            return null

func is_connection_available() -> bool:
    server.poll()

    return server.is_connection_available()
