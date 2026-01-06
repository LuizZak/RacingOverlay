class_name GamePacketBase

## An enumeration of recognized game packets.
enum Game {
    DIRT_2,
    BEAMNG,
    UNKNOWN,
}

## Gets the game associated with this packet type.
func get_game() -> Game:
    return Game.UNKNOWN

#region Required

## Gets the computed roll angle of the packet's information.
func computed_roll_angle() -> float:
    return 0.0

## Gets the computed vertical velocity of the packet's information.
func computed_vertical_velocity() -> float:
    return 0.0

## Gets the computed forward velocity of the packet's information.
func computed_forward_velocity() -> float:
    return 0.0

## Returns `true` if this packet has been detected as a valid game packet.
func is_valid_game_packet() -> bool:
    return false

## Returns `true` if this is an end-of-signal packet.
func is_end_packet() -> bool:
    return false

#endregion

## Returns this packet's content, encoded in the exact same layout as the original
## game packet's format.
## Some unused packet sections may be zeroed out.
func to_data() -> PackedByteArray:
    return []

## Creates a new game packet from a given set of data.
@warning_ignore("unused_parameter")
static func from_data(data: PackedByteArray) -> GamePacketBase:
    return null

## Parses a packet from a known game, with a given data.
## If `game` is `Game.UNKNOWN`, `null` is returned, instead.
static func from_generic_data(game: Game, data: PackedByteArray) -> GamePacketBase:
    match game:
        Game.DIRT_2:
            return Dirt2GamePacket.from_data(data)
        Game.BEAMNG:
            return BeamNGGamePacket.from_data(data)
        Game.UNKNOWN:
            return null
        _:
            return null

static func game_from_game_connection_settings(game: GameConnectionSettings.Game) -> Game:
    match game:
        GameConnectionSettings.Game.DIRT_2:
            return Game.DIRT_2
        GameConnectionSettings.Game.BEAMNG:
            return Game.BEAMNG
        _:
            return Game.UNKNOWN
