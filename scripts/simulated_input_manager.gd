class_name SimulatedInputManager
extends InputManagerBase

@export var clutch: float = -1.0
@export var brake: float = -1.0
@export var throttle: float = -1.0
@export var handbrake: float = 0.0
@export var steering: float = 0.0

@export var is_in_1st: bool = false
@export var is_in_2nd: bool = false
@export var is_in_3rd: bool = false
@export var is_in_4th: bool = false
@export var is_in_5th: bool = false
@export var is_in_6th: bool = false
@export var is_in_reverse: bool = false

## Shifts to a numeric gear, between -1 and 6, with -1 being reverse, 0 being
## neutral, and 1-6 being the first through sixth gears.
func shift_to_gear(gear: int):
    is_in_1st = false
    is_in_2nd = false
    is_in_3rd = false
    is_in_4th = false
    is_in_5th = false
    is_in_6th = false
    is_in_reverse = false

    if gear < 0:
        is_in_reverse = true
    match gear:
        1:
            is_in_1st = true
        2:
            is_in_2nd = true
        3:
            is_in_3rd = true
        4:
            is_in_4th = true
        5:
            is_in_5th = true
        6:
            is_in_6th = true

func clutch_amount() -> float:
    return clutch

func brake_amount() -> float:
    return brake

func throttle_amount() -> float:
    return throttle

func steering_amount() -> float:
    return steering

func handbrake_amount() -> float:
    return handbrake

func shift_1st() -> bool:
    return is_in_1st

func shift_2nd() -> bool:
    return is_in_2nd

func shift_3rd() -> bool:
    return is_in_3rd

func shift_4th() -> bool:
    return is_in_4th

func shift_5th() -> bool:
    return is_in_5th

func shift_6th() -> bool:
    return is_in_6th

func shift_reverse() -> bool:
    return is_in_reverse
