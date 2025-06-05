class_name InputManagerBase
extends Object

## Returns a value between -1 and 1, representing the amount of clutch pedal that
## is depressed.
func clutch_amount() -> float:
    match Settings.instance.pedal_mode:
        Settings.PedalMode.DUAL_AXIS:
            return Input.get_axis("Clutch_up", "Clutch_down")
        Settings.PedalMode.SINGLE_AXIS:
            return Input.get_action_strength("Clutch_down") * 2 - 1

    return Input.get_axis("Clutch_up", "Clutch_down")

## Returns a value between -1 and 1, representing the amount of brake pedal that
## is depressed.
func brake_amount() -> float:
    match Settings.instance.pedal_mode:
        Settings.PedalMode.DUAL_AXIS:
            return Input.get_axis("Brake_up", "Brake_down")
        Settings.PedalMode.SINGLE_AXIS:
            return Input.get_action_strength("Brake_down") * 2 - 1

    return Input.get_axis("Brake_up", "Brake_down")

## Returns a value between -1 and 1, representing the amount of throttle pedal
## that is depressed.
func throttle_amount() -> float:
    match Settings.instance.pedal_mode:
        Settings.PedalMode.DUAL_AXIS:
            return Input.get_axis("Throttle_up", "Throttle_down")
        Settings.PedalMode.SINGLE_AXIS:
            return Input.get_action_strength("Throttle_down") * 2 - 1

    return Input.get_axis("Throttle_up", "Throttle_down")

## Returns a value between 0 and 1, representing the amount of handbrake that is
## depressed.
func handbrake_amount() -> float:
    return Input.get_action_strength("Handbrake")

## Returns a value between 0 and 1, representing the amount of clutch pedal that
## is depressed.
func normalized_clutch_amount() -> float:
    return (clutch_amount() + 1) / 2

## Returns a value between 0 and 1, representing the amount of brake pedal that
## is depressed.
func normalized_brake_amount() -> float:
    return (brake_amount() + 1) / 2

## Returns a value between 0 and 1, representing the amount of throttle pedal that
## is depressed.
func normalized_throttle_amount() -> float:
    return (throttle_amount() + 1) / 2

## Returns a value between -1 and 1, representing the position of the steering
## wheel.
##
## A value of 0 represents dead center.
func steering_amount() -> float:
    return Input.get_axis("Steer_left", "Steer_right")

## Returns a numerical reference to the current gear.
##
## It is -1 for reverse, 0 for neutral, and 1-6 for the first through sixth gears.
func numerical_gear() -> int:
    if shift_reverse():
        return -1
    if shift_1st():
        return 1
    if shift_2nd():
        return 2
    if shift_3rd():
        return 3
    if shift_4th():
        return 4
    if shift_5th():
        return 5
    if shift_6th():
        return 6

    return 0

## Returns a short string one character long representing the currently selected
## gear.
func readable_gear() -> String:
    if shift_reverse():
        return "R"
    if shift_1st():
        return "1"
    if shift_2nd():
        return "2"
    if shift_3rd():
        return "3"
    if shift_4th():
        return "4"
    if shift_5th():
        return "5"
    if shift_6th():
        return "6"

    return "N"

## Returns a boolean indicating whether the first gear is engaged in the shifter.
func shift_1st() -> bool:
    return Input.is_action_pressed("Shift_1st")

## Returns a boolean indicating whether the second gear is engaged in the shifter.
func shift_2nd() -> bool:
    return Input.is_action_pressed("Shift_2nd")

## Returns a boolean indicating whether the third gear is engaged in the shifter.
func shift_3rd() -> bool:
    return Input.is_action_pressed("Shift_3rd")

## Returns a boolean indicating whether the fourth gear is engaged in the shifter.
func shift_4th() -> bool:
    return Input.is_action_pressed("Shift_4th")

## Returns a boolean indicating whether the fifth gear is engaged in the shifter.
func shift_5th() -> bool:
    return Input.is_action_pressed("Shift_5th")

## Returns a boolean indicating whether the sixth gear is engaged in the shifter.
func shift_6th() -> bool:
    return Input.is_action_pressed("Shift_6th")

## Returns a boolean indicating whether the reverse gear is engaged in the shifter.
func shift_reverse() -> bool:
    return Input.is_action_pressed("Shift_reverse")
