class_name WindowConfigs

const FILE_PATH := "user://window_config.cfg"

static var instance := WindowConfigs.new()

var _window_size: Vector2i = Vector2i(400, 400)
@warning_ignore("integer_division")
var _window_position: Vector2i = Vector2i((1980 + 400) / 2, (1080 + 400) / 2)

func _init() -> void:
    _load_data()

func save_window_size(window_size: Vector2i) -> void:
    _window_size = window_size
    _save_data()

func load_window_size() -> Vector2i:
    return _window_size

func save_window_position(window_position: Vector2i) -> void:
    _window_position = window_position
    _save_data()

func load_window_position() -> Vector2i:
    return _window_position

func _load_data() -> void:
    var config := ConfigFile.new()
    config.load(FILE_PATH)

    _window_size = Vector2i(
        config.get_value("window_size", "width", 400),
        config.get_value("window_size", "height", 400),
    )
    @warning_ignore("integer_division")
    _window_position = Vector2i(
        config.get_value("window_position", "x", (1980 + 400) / 2),
        config.get_value("window_position", "y", (1080 + 400) / 2),
    )

func _save_data() -> void:
    var config := ConfigFile.new()

    config.set_value("window_size", "width", _window_size.x)
    config.set_value("window_size", "height", _window_size.y)

    config.set_value("window_position", "x", _window_position.x)
    config.set_value("window_position", "y", _window_position.y)

    config.save(FILE_PATH)
