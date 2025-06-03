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

var smooth_textures: bool = false:
    set(value):
        smooth_textures = value
        on_settings_changed.emit()

var pedal_vibration: bool = true:
    set(value):
        pedal_vibration = value
        on_settings_changed.emit()

var pedal_sink: bool = true:
    set(value):
        pedal_sink = value
        on_settings_changed.emit()

#endregion

## Emitted when one of the setting values has been changed.
signal on_settings_changed()

func _init():
    load_from_disk()

func _make_settings_dictionary() -> Dictionary:
    return {
        "pedal_mode": pedal_mode,
        "smooth_textures": smooth_textures,
        "pedal_vibration": pedal_vibration,
        "pedal_sink": pedal_sink,
    }

func _from_settings_directory(dictionary: Dictionary):
    if dictionary.has("pedal_mode"):
        self.pedal_mode = dictionary["pedal_mode"]
    if dictionary.has("smooth_textures"):
        self.smooth_textures = dictionary["smooth_textures"]
    if dictionary.has("pedal_vibration"):
        self.pedal_vibration = dictionary["pedal_vibration"]
    if dictionary.has("pedal_sink"):
        self.pedal_sink = dictionary["pedal_sink"]

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
