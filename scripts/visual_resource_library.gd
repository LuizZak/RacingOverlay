class_name VisualResourceLibrary
extends Object

const FOOT_LEFT := &"foot_left"
const FOOT_RIGHT := &"foot_right"
const EBRAKE := &"ebrake"
const EBRAKE_BASE := &"ebrake_base"
const EBRAKE_EFFECT := &"ebrake_effect"
const HAND_LEFT := &"hand_left"
const HAND_RIGHT_EBRAKE := &"hand_right_ebrake"
const HAND_RIGHT_FLOATING := &"hand_right_floating"
const HAND_RIGHT_SHIFTER := &"hand_right_shifter"
const HAND_RIGHT_STEERING := &"hand_right_steering"
const PEDAL_BASE := &"pedal_base"
const PEDAL_CLUTCH := &"pedal_clutch"
const PEDAL_BRAKE := &"pedal_brake"
const PEDAL_THROTTLE := &"pedal_throttle"
const PEDAL_FIXTURE := &"pedal_fixture"
const SHIFTER_BASE := &"shifter_base"
const SHIFTER_KNOB := &"shifter_knob"
const STEERING_WHEEL := &"steering_wheel"

## An array containing all visual resource reference names available.
static var all_resources: Array[StringName] = [
    FOOT_LEFT,
    FOOT_RIGHT,
    EBRAKE,
    EBRAKE_BASE,
    EBRAKE_EFFECT,
    HAND_LEFT,
    HAND_RIGHT_EBRAKE,
    HAND_RIGHT_FLOATING,
    HAND_RIGHT_SHIFTER,
    HAND_RIGHT_STEERING,
    PEDAL_BASE,
    PEDAL_CLUTCH,
    PEDAL_BRAKE,
    PEDAL_THROTTLE,
    PEDAL_FIXTURE,
    SHIFTER_BASE,
    SHIFTER_KNOB,
    STEERING_WHEEL,
]

## Loads the default resource texture for a resource key name.
static func load_default_texture(key: StringName) -> Texture2D:
    match key:
        FOOT_LEFT:
            return preload("res://sprites/foot_left.aseprite")
        FOOT_RIGHT:
            return preload("res://sprites/foot_right.aseprite")
        EBRAKE:
            return preload("res://sprites/ebrake.aseprite")
        EBRAKE_BASE:
            return preload("res://sprites/ebrake_base.aseprite")
        EBRAKE_EFFECT:
            return preload("res://sprites/ebrake_effect.aseprite")
        HAND_LEFT:
            return preload("res://sprites/hand_left.aseprite")
        HAND_RIGHT_EBRAKE:
            return preload("res://sprites/hand_right_ebrake.aseprite")
        HAND_RIGHT_FLOATING:
            return preload("res://sprites/hand_right_floating.aseprite")
        HAND_RIGHT_SHIFTER:
            return preload("res://sprites/hand_right_shifter.aseprite")
        HAND_RIGHT_STEERING:
            return preload("res://sprites/hand_right_steering.aseprite")
        PEDAL_BASE:
            return preload("res://sprites/pedal_base.aseprite")
        PEDAL_CLUTCH:
            return preload("res://sprites/pedal_clutch.aseprite")
        PEDAL_BRAKE:
            return preload("res://sprites/pedal_brake.aseprite")
        PEDAL_THROTTLE:
            return preload("res://sprites/pedal_throttle.aseprite")
        PEDAL_FIXTURE:
            return preload("res://sprites/pedal_fixture.aseprite")
        SHIFTER_BASE:
            return preload("res://sprites/shifter_base.aseprite")
        SHIFTER_KNOB:
            return preload("res://sprites/shifter_knob.aseprite")
        STEERING_WHEEL:
            return preload("res://sprites/steering_wheel.aseprite")
        _:
            push_error("Unknown texture key '%s'" % [key])
            return null
