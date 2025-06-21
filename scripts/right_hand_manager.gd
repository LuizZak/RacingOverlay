class_name RightHandManager
extends StateMachine

## Type: InputManagerBase
const RHM_INPUT_MANAGER = "input_manager"
## Type: VisualNode
const RHM_RIGHT_HAND = "right_hand"
## Type: Node2D
const RHM_SHIFTER_KNOB = "shifter_knob"
## Type: ShifterContainer
const RHM_SHIFTER_CONTAINER = "shifter_container"
## Type: Node2D
const RHM_STEERING_PIN = "steering_pin"
## Type: Node2D
const RHM_HANDBRAKE_PIN = "handbrake_pin"
## Type: Node2D. Note: Must be the common ancestor of right_hand, shifter_knob, and steering_pin.
const RHM_GLOBAL_CONTAINER = "global_container"
## Type: SequentialShifterManager
const RHM_SEQUENTIAL_SHIFTER_MANAGER = "sequential_shifter_manager"
## Type: Settings.RestHandPosition
const RHM_REST_HAND_POSITION = "rest_hand_position"

## Transition speed, in seconds, to move between shifter and steering wheel.
const TRANSITION_TIME = 0.15
## Transition speed, in seconds, to shift between gears in the shifter.
const SHIFT_TIME = 0.2

## Transitions from the current state towards the rest state of the hand, according
## to `RHM_REST_HAND_POSITION`.
##
## This is a noop if the current state is already the idle state for that
## configuration, otherwise switches to the appropriate transition state.
func transition_to_rest_state():
    match parameters[RHM_REST_HAND_POSITION]:
        Settings.RestHandPosition.STEERING_WHEEL:
            if current_state is OnSteeringWheelState:
                return

            transition(
                MovingToSteeringWheelState.new()
            )

        Settings.RestHandPosition.SHIFTER:
            if current_state is ShiftingState:
                return

            transition(
                MovingToShifterState.new()
            )

#

## Moving hand to handbrake from its current position.
class MovingToHandbrakeState extends State:
    var start_position: Vector2 = Vector2.ZERO
    var start_rotation: float = 0.0
    var elapsed: float = 0.0

    func on_enter(_last, state_machine):
        var right_hand := state_machine.parameters[RHM_RIGHT_HAND] as VisualNode
        var global_container := state_machine.parameters[RHM_GLOBAL_CONTAINER] as Node2D

        start_position = right_hand.global_position
        start_rotation = right_hand.global_rotation

        # Ensure hand is contained in the global container, so it can be moved
        # freely.
        if right_hand.get_parent():
            right_hand.get_parent().remove_child(right_hand)

        global_container.add_child(right_hand)

        right_hand.global_position = start_position
        right_hand.global_rotation = start_rotation

        right_hand.key = CustomResourceLoader.HAND_RIGHT_FLOATING

    func process(delta, state_machine):
        self.elapsed += delta

        var input_manager := state_machine.parameters[RHM_INPUT_MANAGER] as InputManagerBase
        var right_hand := state_machine.parameters[RHM_RIGHT_HAND] as VisualNode
        var handbrake_pin := state_machine.parameters[RHM_HANDBRAKE_PIN] as Node2D

        var eased := ease(elapsed / TRANSITION_TIME, -2)

        right_hand.global_position = start_position.lerp(handbrake_pin.global_position, eased)
        right_hand.global_rotation = lerpf(start_rotation, 0.0, eased)

        # Cancel back to rest state, if no handbrake is needed anymore.
        if input_manager.handbrake_amount() == 0.0:
            state_machine.transition_to_rest_state()
            return

        if self.elapsed >= TRANSITION_TIME:
            state_machine.transition(
                HandbrakingState.new()
            )

## Hand on handbrake, currently pressing the handbrake.
class HandbrakingState extends State:
    var latest_gear: int = 0

    func on_enter(_last, state_machine):
        var input_manager := state_machine.parameters[RHM_INPUT_MANAGER] as InputManagerBase
        var right_hand := state_machine.parameters[RHM_RIGHT_HAND] as VisualNode
        var handbrake_pin := state_machine.parameters[RHM_HANDBRAKE_PIN] as Node2D

        # Ensure hand is pinned to the handbrake by adding it as a child
        if right_hand.get_parent():
            right_hand.get_parent().remove_child(right_hand)

        handbrake_pin.add_child(right_hand)

        # Track gear changes
        latest_gear = input_manager.numerical_gear()

        right_hand.key = CustomResourceLoader.HAND_RIGHT_EBRAKE

        right_hand.rotation = 0.0
        right_hand.position = Vector2.ZERO

    func on_exit(_next, state_machine):
        var right_hand := state_machine.parameters[RHM_RIGHT_HAND] as VisualNode
        var global_container := state_machine.parameters[RHM_GLOBAL_CONTAINER] as Node2D

        var last_position := right_hand.global_position

        # Ensure hand is contained in the global container, so it can be moved
        # freely.
        if right_hand.get_parent():
            right_hand.get_parent().remove_child(right_hand)

        global_container.add_child(right_hand)

        right_hand.global_position = last_position

    func process(_delta, state_machine):
        var input_manager := state_machine.parameters[RHM_INPUT_MANAGER] as InputManagerBase
        var shifter_container := state_machine.parameters[RHM_SHIFTER_CONTAINER] as ShifterContainer
        var seq_shifter := state_machine.parameters[RHM_SEQUENTIAL_SHIFTER_MANAGER] as SequentialShifterManager

        # No handbrake required anymore
        if input_manager.handbrake_amount() == 0.0:
            state_machine.transition_to_rest_state()
            return

        # Deal with gear changes - we can't shift gears while holding handbrake,
        # so we just flush any gear change immediately instead.
        if seq_shifter.has_gear_changes():
            seq_shifter.clear_gear_change()

        if latest_gear != input_manager.numerical_gear():
            latest_gear = input_manager.numerical_gear()
            shifter_container.set_shifter_animation_gear(latest_gear)
            shifter_container.shifter_animation_factor = 1.0

## Hand on shifter, shifting sequentially.
class ShiftingSequentialState extends State:
    var elapsed: float = 0.0
    var is_shift_up: bool = false
    var pseudo_gear: int = 0

    func on_enter(_last, state_machine):
        var right_hand := state_machine.parameters[RHM_RIGHT_HAND] as VisualNode
        var seq_shifter := state_machine.parameters[RHM_SEQUENTIAL_SHIFTER_MANAGER] as SequentialShifterManager

        var is_shift_up := seq_shifter.dequeue_gear_change()

        if is_shift_up:
            pseudo_gear = 3
        else:
            pseudo_gear = 4

        right_hand.key = CustomResourceLoader.HAND_RIGHT_SHIFTER

    func process(delta, state_machine):
        elapsed += delta

        var input_manager := state_machine.parameters[RHM_INPUT_MANAGER] as InputManagerBase
        var right_hand := state_machine.parameters[RHM_RIGHT_HAND] as VisualNode
        var shifter_container := state_machine.parameters[RHM_SHIFTER_CONTAINER] as ShifterContainer
        var shifter_knob := state_machine.parameters[RHM_SHIFTER_KNOB] as Node2D
        var seq_shifter := state_machine.parameters[RHM_SEQUENTIAL_SHIFTER_MANAGER] as SequentialShifterManager

        right_hand.global_position = shifter_knob.global_position

        if elapsed < SHIFT_TIME / 2.0:
            # Shift towards gear
            if shifter_container.shifter_animation.numerical_gear() != pseudo_gear:
                shifter_container.set_shifter_animation_gear(pseudo_gear)

            shifter_container.shifter_animation_factor = elapsed / (SHIFT_TIME / 2.0)
        else:
            shifter_container.shifter_animation_factor = 1 - (elapsed - SHIFT_TIME / 2.0) / (SHIFT_TIME / 2.0)

        # If H-pattern has been engaged, clear sequential shifts in queue and
        # move to H-pattern shifting state
        if input_manager.numerical_gear() != 0:
            seq_shifter.clear_gear_change()
            state_machine.transition(
                ShiftingState.new()
            )
            return

        if elapsed >= SHIFT_TIME:
            # Shift again, if another shift is required.
            if seq_shifter.has_gear_changes():
                state_machine.transition(
                    ShiftingSequentialState.new()
                )
            else:
                state_machine.transition_to_rest_state()
            return

## Hand on shifter, shifting in H-pattern.
class ShiftingState extends State:
    var latest_gear: int = 0
    var is_in_neutral: bool = false
    var is_towards_neutral: bool = false
    var is_same_gear: bool = false
    var elapsed: float = 0.0

    func on_enter(_last, state_machine):
        var input_manager := state_machine.parameters[RHM_INPUT_MANAGER] as InputManagerBase
        var shifter_container := state_machine.parameters[RHM_SHIFTER_CONTAINER] as ShifterContainer
        var right_hand := state_machine.parameters[RHM_RIGHT_HAND] as VisualNode

        self.latest_gear = input_manager.numerical_gear()
        self.is_in_neutral = shifter_container.shifter_animation.numerical_gear() == 0
        self.is_towards_neutral = self.latest_gear == 0
        self.is_same_gear = shifter_container.shifter_animation.numerical_gear() == input_manager.numerical_gear()

        right_hand.key = CustomResourceLoader.HAND_RIGHT_SHIFTER

    func process(delta, state_machine):
        self.elapsed += delta

        var input_manager := state_machine.parameters[RHM_INPUT_MANAGER] as InputManagerBase
        var right_hand := state_machine.parameters[RHM_RIGHT_HAND] as VisualNode
        var shifter_container := state_machine.parameters[RHM_SHIFTER_CONTAINER] as ShifterContainer
        var shifter_knob := state_machine.parameters[RHM_SHIFTER_KNOB] as Node2D
        var seq_shifter := state_machine.parameters[RHM_SEQUENTIAL_SHIFTER_MANAGER] as SequentialShifterManager

        right_hand.global_position = shifter_knob.global_position

        # Clear any sequential shifts while H-pattern is active.
        if seq_shifter.has_gear_changes():
            seq_shifter.clear_gear_change()

        # Abrubtly stop the current gear change if another gear was engaged, and
        # immediately shift to the new gear.
        if input_manager.numerical_gear() != latest_gear:
            state_machine.transition(
                ShiftingState.new()
            )
            return

        # If shifting towards the same gear...
        if is_same_gear:
            # Do nothing, and enable state transitioning away from current state.
            # This usually means the hand is resting idly on the shifter and not
            # shifting gears.
            elapsed = SHIFT_TIME
        # If shifting from neutral...
        elif is_in_neutral:
            # Engage next gear's animation
            if shifter_container.shifter_animation.numerical_gear() != latest_gear:
                shifter_container.set_shifter_animation_gear(latest_gear)

            # Animate it forward
            shifter_container.shifter_animation_factor = elapsed / SHIFT_TIME
        # If shifting towards neutral...
        elif is_towards_neutral:
            # Animate it backwards towards neutral
            shifter_container.shifter_animation_factor = 1 - elapsed / SHIFT_TIME
        # If shifting from one gear to another...
        else:
            # Shift away from current gear
            if elapsed < SHIFT_TIME / 2:
                shifter_container.shifter_animation_factor = 1 - elapsed / (SHIFT_TIME / 2)
            # Shift towards target gear
            else:
                if shifter_container.shifter_animation.numerical_gear() != latest_gear:
                    shifter_container.set_shifter_animation_gear(latest_gear)

                shifter_container.shifter_animation_factor = (elapsed - SHIFT_TIME / 2) / (SHIFT_TIME / 2)

        if elapsed >= SHIFT_TIME:
            if self.is_towards_neutral:
                shifter_container.set_shifter_animation_gear(0)

            if input_manager.handbrake_amount() > 0.0:
                state_machine.transition(
                    MovingToHandbrakeState.new()
                )
                return

            state_machine.transition_to_rest_state()

## Moving hand towards shifter from its current position.
class MovingToShifterState extends State:
    var start_position: Vector2 = Vector2.ZERO
    var start_rotation: float = 0.0
    var elapsed: float = 0.0

    func on_enter(_last, state_machine):
        var right_hand := state_machine.parameters[RHM_RIGHT_HAND] as VisualNode
        var global_container := state_machine.parameters[RHM_GLOBAL_CONTAINER] as Node2D

        start_position = right_hand.global_position
        start_rotation = right_hand.global_rotation

        # Ensure hand is contained in the global container, so it can be moved
        # freely.
        if right_hand.get_parent():
            right_hand.get_parent().remove_child(right_hand)

        global_container.add_child(right_hand)

        right_hand.global_position = start_position
        right_hand.global_rotation = start_rotation

        right_hand.key = CustomResourceLoader.HAND_RIGHT_FLOATING

    func process(delta, state_machine):
        self.elapsed += delta

        var right_hand := state_machine.parameters[RHM_RIGHT_HAND] as VisualNode
        var shifter_knob := state_machine.parameters[RHM_SHIFTER_KNOB] as Node2D
        var seq_shifter := state_machine.parameters[RHM_SEQUENTIAL_SHIFTER_MANAGER] as SequentialShifterManager

        var eased := ease(elapsed / TRANSITION_TIME, -2)

        right_hand.global_position = start_position.lerp(shifter_knob.global_position, eased)
        right_hand.global_rotation = lerpf(start_rotation, 0.0, eased)

        if self.elapsed >= TRANSITION_TIME:
            if seq_shifter.has_gear_changes():
                state_machine.transition(
                    ShiftingSequentialState.new()
                )
            else:
                state_machine.transition(
                    ShiftingState.new()
                )

## Moving hand towards steering wheel from its current position.
class MovingToSteeringWheelState extends State:
    var latest_gear: int = 0

    var start_position: Vector2 = Vector2.ZERO
    var start_rotation: float = 0.0
    var elapsed: float = 0.0

    func on_enter(_last, state_machine):
        var input_manager := state_machine.parameters[RHM_INPUT_MANAGER] as InputManagerBase
        var right_hand := state_machine.parameters[RHM_RIGHT_HAND] as VisualNode

        self.latest_gear = input_manager.numerical_gear()

        start_position = right_hand.global_position
        start_rotation = right_hand.global_rotation

        right_hand.key = CustomResourceLoader.HAND_RIGHT_FLOATING

    func process(delta, state_machine):
        self.elapsed += delta

        var input_manager := state_machine.parameters[RHM_INPUT_MANAGER] as InputManagerBase
        var right_hand := state_machine.parameters[RHM_RIGHT_HAND] as VisualNode
        var steering_pin := state_machine.parameters[RHM_STEERING_PIN] as Node2D
        var seq_shifter := state_machine.parameters[RHM_SEQUENTIAL_SHIFTER_MANAGER] as SequentialShifterManager

        var eased = ease(elapsed / TRANSITION_TIME, -2)

        right_hand.global_position = start_position.lerp(steering_pin.global_position, eased)
        right_hand.global_rotation = lerpf(start_rotation, steering_pin.global_rotation, eased)

        if input_manager.numerical_gear() != self.latest_gear or seq_shifter.has_gear_changes():
            state_machine.transition(
                MovingToShifterState.new()
            )
            return

        if self.elapsed >= TRANSITION_TIME:
            state_machine.transition(
                OnSteeringWheelState.new()
            )
            return

## Hand on steering wheel, idling.
class OnSteeringWheelState extends State:
    var latest_gear: int = 0

    func on_enter(_last, state_machine):
        var input_manager := state_machine.parameters[RHM_INPUT_MANAGER] as InputManagerBase
        var right_hand := state_machine.parameters[RHM_RIGHT_HAND] as VisualNode
        var steering_pin := state_machine.parameters[RHM_STEERING_PIN] as Node2D

        self.latest_gear = input_manager.numerical_gear()

        # Ensure hand is pinned to the steering wheel by adding it as a child
        if right_hand.get_parent():
            right_hand.get_parent().remove_child(right_hand)

        steering_pin.add_child(right_hand)

        right_hand.key = CustomResourceLoader.HAND_RIGHT_STEERING

        right_hand.rotation = 0.0
        right_hand.position = Vector2.ZERO

    func process(_delta, state_machine):
        var input_manager := state_machine.parameters[RHM_INPUT_MANAGER] as InputManagerBase
        var seq_shifter := state_machine.parameters[RHM_SEQUENTIAL_SHIFTER_MANAGER] as SequentialShifterManager

        # Move to shifter if shifting is required.
        if input_manager.numerical_gear() != self.latest_gear or seq_shifter.has_gear_changes():
            state_machine.transition(
                MovingToShifterState.new()
            )
            return
        # Move to handbrake if its required.
        if input_manager.handbrake_amount() > 0.0:
            state_machine.transition(
                MovingToHandbrakeState.new()
            )
            return

        state_machine.transition_to_rest_state()
