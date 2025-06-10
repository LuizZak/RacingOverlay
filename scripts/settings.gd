class_name Settings
extends Object

enum PedalMode {
    DUAL_AXIS,
    SINGLE_AXIS,
}

const SETTINGS_PATH = "user://settings.data"

static var instance: Settings = Settings.new()

#region Settings

var pedal_mode: PedalMode = PedalMode.DUAL_AXIS:
    set(value):
        pedal_mode = value
        on_settings_changed.emit()

var steering_range: float = 900:
    set(value):
        steering_range = value
        on_settings_changed.emit()

var smooth_textures: bool = false:
    set(value):
        smooth_textures = value
        on_settings_changed.emit()

var steering_wheel_progress: bool = false:
    set(value):
        steering_wheel_progress = value
        on_settings_changed.emit()

var pedal_vibration: bool = true:
    set(value):
        pedal_vibration = value
        on_settings_changed.emit()

var pedal_vibration_strength: float = 1.0:
    set(value):
        pedal_vibration_strength = value
        on_settings_changed.emit()

var pedal_sink: bool = true:
    set(value):
        pedal_sink = value
        on_settings_changed.emit()

var connect_to_game: bool = true:
    set(value):
        connect_to_game = value
        on_settings_changed.emit()

var active_game: GameConnectionSettings.Game = GameConnectionSettings.Game.DIRT_2:
    set(value):
        active_game = value
        on_settings_changed.emit()

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
        "steering_range": steering_range,
        "smooth_textures": smooth_textures,
        "steering_wheel_progress": steering_wheel_progress,
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
    if dictionary.has("steering_range"):
        self.steering_range = dictionary["steering_range"]
    if dictionary.has("smooth_textures"):
        self.smooth_textures = dictionary["smooth_textures"]
    if dictionary.has("steering_wheel_progress"):
        self.steering_wheel_progress = dictionary["steering_wheel_progress"]
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
