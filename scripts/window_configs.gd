class_name WindowConfigs

const FILE_PATH := "user://window_config.cfg"

static var instance := WindowConfigs.new()

var _window_size: Vector2i = Vector2i(400, 400)

func _init() -> void:
    _load_data()

func save_window_size(window_size: Vector2i) -> void:
    _window_size = window_size
    _save_data()

func load_window_size() -> Vector2i:
    return _window_size

func _load_data() -> void:
    var config := ConfigFile.new()
    config.load(FILE_PATH)

    _window_size = Vector2i(
        config.get_value("window_size", "width", 400),
        config.get_value("window_size", "height", 400),
    )

func _save_data() -> void:
    var config := ConfigFile.new()

    config.set_value("window_size", "width", _window_size.x)
    config.set_value("window_size", "height", _window_size.y)

    config.save(FILE_PATH)
