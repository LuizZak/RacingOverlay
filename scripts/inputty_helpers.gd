class_name InputtyHelpers

static func change_clutch_axis_mode(mode: int) -> void:
    change_axis_mode("ClutchAxisMode", mode)

static func change_brake_axis_mode(mode: int) -> void:
    change_axis_mode("BrakeAxisMode", mode)

static func change_throttle_axis_mode(mode: int) -> void:
    change_axis_mode("ThrottleAxisMode", mode)

static func change_axis_mode(axis_mode_name: String, mode: int) -> void:
    assert(mode == 0 or mode == 1, "Expected pedal mode value to be 0 or 1")

    var property := Inputty.get_raw_property(axis_mode_name) as InputtyPropertyEnum
    if property == null:
        return

    property.valueIndex = mode

    Inputty.inputMap.saveToFile(Inputty.activeFilePath)
