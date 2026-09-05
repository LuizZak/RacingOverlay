@abstract
class_name NetworkingBase

enum Status {
    DISCONNECTED,
    AWAITING,
    CONNECTED,
}

enum Mode {
    DISCONNECT,
    CONNECT,
}

@warning_ignore("unused_signal")
signal on_status_changed(status: Status)

func get_status() -> Status:
    return Status.DISCONNECTED

@warning_ignore("unused_parameter")
func set_port(port: int) -> void:
    pass

@warning_ignore("unused_parameter")
func set_mode(mode: Mode) -> void:
    pass

@warning_ignore("unused_parameter")
func set_game(game: GamePacketBase.Game) -> void:
    pass

@warning_ignore("unused_parameter")
func process(delta: float) -> void:
    pass

func poll_connections() -> Error:
    return Error.FAILED

func connect_to_game() -> Error:
    return Error.FAILED

func disconnect_from_game() -> Error:
    return Error.FAILED

func is_connected_to_game() -> bool:
    return false

func has_packets() -> bool:
    return false

func fetch_packet() -> GamePacketBase:
    return null

func is_connection_available() -> bool:
    return false
