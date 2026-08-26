class_name GameConnectionSettings
extends Resource

enum Game {
    ## Dirt 2.0 by Codemasters
    DIRT_2,
    ## BeamNG
    BEAMNG,
    ## ACRally
    ACRALLY,
}

var port: int = 20777
var roll_with_vehicle: bool = true
var scale_with_speed: bool = false
var move_vertically: bool = false
var show_extra_game_information: bool = false

func to_dictionary() -> Dictionary:
    return {
        "port": port,
        "roll_with_vehicle": roll_with_vehicle,
        "scale_with_speed": scale_with_speed,
        "move_vertically": move_vertically,
        "show_extra_game_information": show_extra_game_information
    }

func to_config_file(config_file: ConfigFile, game: Game) -> void:
    var game_name := game_id(game)
    var section := "game_connection_%s" % [game_name]

    config_file.set_value(section, "port", port)
    config_file.set_value(section, "roll_with_vehicle", roll_with_vehicle)
    config_file.set_value(section, "scale_with_speed", scale_with_speed)
    config_file.set_value(section, "move_vertically", move_vertically)
    config_file.set_value(section, "show_extra_game_information", show_extra_game_information)

static func from_config_file(config_file: ConfigFile, game: Game) -> GameConnectionSettings:
    var game_name := game_id(game)
    var section := "game_connection_%s" % [game_name]

    var settings := GameConnectionSettings.new()
    settings.port = config_file.get_value(section, "port", settings.port)
    settings.roll_with_vehicle = config_file.get_value(section, "roll_with_vehicle", settings.roll_with_vehicle)
    settings.scale_with_speed = config_file.get_value(section, "scale_with_speed", settings.scale_with_speed)
    settings.move_vertically = config_file.get_value(section, "move_vertically", settings.move_vertically)
    settings.show_extra_game_information = config_file.get_value(section, "show_extra_game_information", settings.show_extra_game_information)

    return settings

static func from_dictionary(dictionary: Dictionary) -> GameConnectionSettings:
    var settings := GameConnectionSettings.new()
    settings.port = dictionary.get_or_add("port", settings.port)
    settings.roll_with_vehicle = dictionary.get_or_add("roll_with_vehicle", settings.roll_with_vehicle)
    settings.scale_with_speed = dictionary.get_or_add("scale_with_speed", settings.scale_with_speed)
    settings.move_vertically = dictionary.get_or_add("move_vertically", settings.move_vertically)
    settings.show_extra_game_information = dictionary.get_or_add("show_extra_game_information", settings.show_extra_game_information)
    return settings

static func game_id(game: Game) -> String:
    match game:
        Game.DIRT_2:
            return "DIRT_2"
        Game.BEAMNG:
            return "BEAMNG"
        Game.ACRALLY:
            return "ACRALLY"
        _:
            return "UNKNOWN"

static func game_title(game: Game) -> String:
    match game:
        Game.DIRT_2:
            return "Dirt 2.0"
        Game.BEAMNG:
            return "BeamNG"
        Game.ACRALLY:
            return "AC Rally"
        _:
            return "Unknown game"
