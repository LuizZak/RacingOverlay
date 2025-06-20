class_name Settings
extends Object

enum PedalMode {
    DUAL_AXIS,
    SINGLE_AXIS,
}
enum RestHandPosition {
    STEERING_WHEEL,
    SHIFTER,
}

const SETTINGS_PATH = "user://settings.data"

static var instance: Settings = Settings.new()

#region Settings

var pedal_mode: PedalMode = PedalMode.DUAL_AXIS:
    set(value):
        pedal_mode = value
        emit_settings_changed()

var rest_hand_position: RestHandPosition = RestHandPosition.STEERING_WHEEL:
    set(value):
        rest_hand_position = value
        emit_settings_changed()

var steering_range: float = 900:
    set(value):
        steering_range = value
        emit_settings_changed()

var smooth_textures: bool = false:
    set(value):
        smooth_textures = value
        emit_settings_changed()

var steering_wheel_progress: bool = false:
    set(value):
        steering_wheel_progress = value
        emit_settings_changed()

var shifter_shaft_fill_color: Color = Color.from_rgba8(99, 155, 255):
    set(value):
        shifter_shaft_fill_color = value
        emit_settings_changed()

var shifter_shaft_outline_color: Color = Color.WHITE:
    set(value):
        shifter_shaft_outline_color = value
        emit_settings_changed()

var pedal_bar_fill_color: Color = Color(0.082, 0.219, 0.225):
    set(value):
        pedal_bar_fill_color = value
        emit_settings_changed()

var pedal_vibration: bool = true:
    set(value):
        pedal_vibration = value
        emit_settings_changed()

var pedal_vibration_strength: float = 1.0:
    set(value):
        pedal_vibration_strength = value
        emit_settings_changed()

var pedal_sink: bool = true:
    set(value):
        pedal_sink = value
        emit_settings_changed()

var connect_to_game: bool = true:
    set(value):
        connect_to_game = value
        emit_settings_changed()

var active_game: GameConnectionSettings.Game = GameConnectionSettings.Game.DIRT_2:
    set(value):
        active_game = value
        emit_settings_changed()

var game_connections: Dictionary[GameConnectionSettings.Game, GameConnectionSettings] = {}

#endregion

## Emitted when one of the setting values has been changed.
signal on_settings_changed()

func _init():
    _populage_default_game_settings()
    load_from_disk()

func _make_settings_dictionary() -> Dictionary:
    var dict = {
        "pedal_mode": pedal_mode,
        "rest_hand_position": rest_hand_position,
        "steering_range": steering_range,
        "smooth_textures": smooth_textures,
        "steering_wheel_progress": steering_wheel_progress,
        "shifter_shaft_fill_color": shifter_shaft_fill_color,
        "shifter_shaft_outline_color": shifter_shaft_outline_color,
        "pedal_bar_fill_color": pedal_bar_fill_color,
        "pedal_vibration": pedal_vibration,
        "pedal_vibration_strength": pedal_vibration_strength,
        "pedal_sink": pedal_sink,
        "connect_to_game": connect_to_game,
        "active_game": active_game,
        "game_connections": { },
    }

    for key in game_connections.keys():
        var settings = game_connections[key]
        dict["game_connections"][key] = settings.to_dictionary()

    return dict

func _from_settings_directory(dictionary: Dictionary):
    if dictionary.has("pedal_mode"):
        self.pedal_mode = dictionary["pedal_mode"]
    if dictionary.has("rest_hand_position"):
        self.rest_hand_position = dictionary["rest_hand_position"]
    if dictionary.has("steering_range"):
        self.steering_range = dictionary["steering_range"]
    if dictionary.has("smooth_textures"):
        self.smooth_textures = dictionary["smooth_textures"]
    if dictionary.has("steering_wheel_progress"):
        self.steering_wheel_progress = dictionary["steering_wheel_progress"]
    if dictionary.has("shifter_shaft_fill_color"):
        self.shifter_shaft_fill_color = dictionary["shifter_shaft_fill_color"]
    if dictionary.has("shifter_shaft_outline_color"):
        self.shifter_shaft_outline_color = dictionary["shifter_shaft_outline_color"]
    if dictionary.has("pedal_bar_fill_color"):
        self.pedal_bar_fill_color = dictionary["pedal_bar_fill_color"]
    if dictionary.has("pedal_vibration"):
        self.pedal_vibration = dictionary["pedal_vibration"]
    if dictionary.has("pedal_vibration_strength"):
        self.pedal_vibration_strength = dictionary["pedal_vibration_strength"]
    if dictionary.has("pedal_sink"):
        self.pedal_sink = dictionary["pedal_sink"]
    if dictionary.has("connect_to_game"):
        self.connect_to_game = dictionary["connect_to_game"]
    if dictionary.has("active_game"):
        self.active_game = dictionary["active_game"]
    if dictionary.has("game_connections"):
        for key in dictionary["game_connections"].keys():
            game_connections[key] = GameConnectionSettings.from_dictionary(dictionary["game_connections"][key])

func _populage_default_game_settings():
    for value in GameConnectionSettings.Game.values():
        game_connections[value] = GameConnectionSettings.new()

func emit_settings_changed() -> void:
    on_settings_changed.emit()

func active_game_settings() -> GameConnectionSettings:
    return game_connections[active_game]

## Restores the settings from disk. Automatically done on instantiation.
func load_from_disk():
    var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
    if file == null:
        return

    var dict = file.get_var()
    _from_settings_directory(dict)
    file.close()

## Saves the settings to disk.
func save_to_disk():
    var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
    if file == null:
        return

    var dict = _make_settings_dictionary()
    file.store_var(dict)
    file.close()
