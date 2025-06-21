class_name FeetManager
extends StateMachine

const FM_LEFT_FOOT = "left_foot"
const FM_RIGHT_FOOT = "right_foot"

const FM_CLUTCH_PEDAL = "clutch_pedal"
const FM_BRAKE_PEDAL = "brake_pedal"
const FM_THROTTLE_PEDAL = "throttle_pedal"

const FM_FOOT_MOVE_SPEED = 300.0
const FM_FOOT_ROTATE_SPEED = deg_to_rad(540.0)

## Updates the internal state of this FeetManager instance with the normalized
## values of each pedal.
func update_with_pedals(clutch_pedal: float, break_pedal: float, throttle_pedal: float):
    var needs_clutch := clutch_pedal > 0.0
    var needs_brake := break_pedal > 0.0
    var needs_throttle := throttle_pedal > 0.0

    var has_clutch := current_state is ThrotleClutchState or current_state is ClutchBrakeState or current_state is HeelAndToeState
    var has_brake := current_state is ThrottleBrakeState or current_state is ClutchBrakeState or current_state is HeelAndToeState
    var has_throttle := current_state is ThrotleClutchState or current_state is ThrottleBrakeState or current_state is HeelAndToeState

    # No change required if no pedals are depressed
    if !needs_clutch and !needs_brake and !needs_throttle:
        return

    var requires_change := false

    if needs_clutch and !has_clutch:
        requires_change = true
    if needs_brake and !has_brake:
        requires_change = true
    if needs_throttle and !has_throttle:
        requires_change = true

    # Unfavor heel-and-toe unless required
    if has_clutch and has_brake and has_throttle and !(needs_clutch and needs_brake and needs_throttle):
        requires_change = true

    if !requires_change:
        return

    # Triple state
    if needs_clutch and needs_brake and needs_throttle:
        transition(
            HeelAndToeState.new()
        )
        return

    # Dual states
    if needs_clutch and needs_brake:
        transition(
            ClutchBrakeState.new()
        )
        return

    if needs_clutch and needs_throttle:
        transition(
            ThrotleClutchState.new()
        )
        return

    if needs_brake and needs_throttle:
        transition(
            ThrottleBrakeState.new()
        )
        return

    # Single states
    if needs_clutch:
        if has_throttle:
            transition(
                ThrotleClutchState.new()
            )
        else:
            transition(
                ClutchBrakeState.new()
            )
        return

    if needs_brake:
        transition(
            ClutchBrakeState.new()
        )
        return

    if needs_throttle:
        transition(
            ThrotleClutchState.new()
        )
        return

#

class ThrottleBrakeState extends State:
    func process(delta, state_machine):
        var left_foot := state_machine.parameters[FM_LEFT_FOOT] as Node2D
        var right_foot := state_machine.parameters[FM_RIGHT_FOOT] as Node2D

        var brake := state_machine.parameters[FM_BRAKE_PEDAL] as Node2D
        var throttle := state_machine.parameters[FM_THROTTLE_PEDAL] as Node2D

        left_foot.global_position = left_foot.global_position.move_toward(brake.global_position, FM_FOOT_MOVE_SPEED * delta)
        right_foot.global_position = right_foot.global_position.move_toward(throttle.global_position, FM_FOOT_MOVE_SPEED * delta)
        right_foot.rotation = rotate_toward(right_foot.rotation, 0.0, FM_FOOT_ROTATE_SPEED * delta)

    func description() -> String:
        return "ThrottleBrakeState"

class ThrotleClutchState extends State:
    func process(delta, state_machine):
        var left_foot := state_machine.parameters[FM_LEFT_FOOT] as Node2D
        var right_foot := state_machine.parameters[FM_RIGHT_FOOT] as Node2D

        var clutch := state_machine.parameters[FM_CLUTCH_PEDAL] as Node2D
        var throttle := state_machine.parameters[FM_THROTTLE_PEDAL] as Node2D

        left_foot.global_position = left_foot.global_position.move_toward(clutch.global_position, FM_FOOT_MOVE_SPEED * delta)
        right_foot.global_position = right_foot.global_position.move_toward(throttle.global_position, FM_FOOT_MOVE_SPEED * delta)
        right_foot.rotation = rotate_toward(right_foot.rotation, 0.0, FM_FOOT_ROTATE_SPEED * delta)

    func description() -> String:
        return "ThrotleClutchState"

class ClutchBrakeState extends State:
    func process(delta, state_machine):
        var left_foot := state_machine.parameters[FM_LEFT_FOOT] as Node2D
        var right_foot := state_machine.parameters[FM_RIGHT_FOOT] as Node2D

        var clutch := state_machine.parameters[FM_CLUTCH_PEDAL] as Node2D
        var brake := state_machine.parameters[FM_BRAKE_PEDAL] as Node2D

        left_foot.global_position = left_foot.global_position.move_toward(clutch.global_position, FM_FOOT_MOVE_SPEED * delta)
        right_foot.global_position = right_foot.global_position.move_toward(brake.global_position, FM_FOOT_MOVE_SPEED * delta)
        right_foot.rotation = rotate_toward(right_foot.rotation, 0.0, FM_FOOT_ROTATE_SPEED * delta)

    func description() -> String:
        return "ClutchBrakeState"

class HeelAndToeState extends State:
    func process(delta, state_machine):
        var left_foot := state_machine.parameters[FM_LEFT_FOOT] as Node2D
        var right_foot := state_machine.parameters[FM_RIGHT_FOOT] as Node2D

        var clutch := state_machine.parameters[FM_CLUTCH_PEDAL] as Node2D
        var brake := state_machine.parameters[FM_BRAKE_PEDAL] as Node2D
        var throttle := state_machine.parameters[FM_THROTTLE_PEDAL] as Node2D

        left_foot.global_position = left_foot.global_position.move_toward(clutch.global_position, FM_FOOT_MOVE_SPEED * delta)
        var midPoint := (brake.global_position + throttle.global_position) / 2
        right_foot.global_position = right_foot.global_position.move_toward(midPoint, FM_FOOT_MOVE_SPEED * delta)
        right_foot.rotation = rotate_toward(right_foot.rotation, 20, FM_FOOT_ROTATE_SPEED * delta)

    func description() -> String:
        return "HeelAndToeState"
