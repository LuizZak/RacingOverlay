class_name RightHandManager
extends StateMachine

## Type: InputManagerBase
const RHM_INPUT_MANAGER = "input_manager"
## Type: Sprite2D
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

## Transition speed, in seconds, to move between shifter and steering wheel.
const TRANSITION_SPEED = 0.15
## Transition speed, in seconds, to shift between gears in the shifter.
const SHIFT_SPEED = 0.2

#

class MovingToHandbrakeState extends State:
    var last_position: Vector2 = Vector2.ZERO
    var last_rotation: float = 0.0
    var elapsed: float = 0.0

    func on_enter(last, state_machine):
        var right_hand = state_machine.parameters[RHM_RIGHT_HAND] as Sprite2D
        var global_container = state_machine.parameters[RHM_GLOBAL_CONTAINER] as Node2D

        last_position = right_hand.global_position
        last_rotation = right_hand.global_rotation

        if right_hand.get_parent():
            right_hand.get_parent().remove_child(right_hand)

        global_container.add_child(right_hand)

        right_hand.global_position = last_position
        right_hand.global_rotation = last_rotation

        #right_hand.play("floating")
        right_hand.texture = CustomResourceLoader.instance.load_texture(
            CustomResourceLoader.HAND_RIGHT_FLOATING
        )

    func process(delta, state_machine):
        self.elapsed += delta

        var input_manager = state_machine.parameters[RHM_INPUT_MANAGER] as InputManagerBase
        var right_hand = state_machine.parameters[RHM_RIGHT_HAND] as Sprite2D
        var handbrake_pin = state_machine.parameters[RHM_HANDBRAKE_PIN] as Node2D

        var eased = ease(elapsed / TRANSITION_SPEED, -2)

        right_hand.global_position = last_position.lerp(handbrake_pin.global_position, eased)
        right_hand.global_rotation = lerpf(last_rotation, 0.0, eased)

        if input_manager.handbrake_amount() == 0.0:
            state_machine.transition(
                MovingToSteeringWheelState.new()
            )
            return

        if self.elapsed >= TRANSITION_SPEED:
            state_machine.transition(
                HandbrakingState.new()
            )

class HandbrakingState extends State:
    var latest_gear: int = 0

    func on_enter(last, state_machine):
        var input_manager = state_machine.parameters[RHM_INPUT_MANAGER] as InputManagerBase
        var right_hand = state_machine.parameters[RHM_RIGHT_HAND] as Sprite2D
        var handbrake_pin = state_machine.parameters[RHM_HANDBRAKE_PIN] as Node2D

        if right_hand.get_parent():
            right_hand.get_parent().remove_child(right_hand)

        handbrake_pin.add_child(right_hand)

        latest_gear = input_manager.numerical_gear()

        #right_hand.play("ebrake")
        right_hand.texture = CustomResourceLoader.instance.load_texture(
            CustomResourceLoader.HAND_RIGHT_EBRAKE
        )

        right_hand.rotation = 0.0
        right_hand.position = Vector2.ZERO

    func on_exit(next, state_machine):
        var right_hand = state_machine.parameters[RHM_RIGHT_HAND] as Sprite2D
        var global_container = state_machine.parameters[RHM_GLOBAL_CONTAINER] as Node2D

        var last_position = right_hand.global_position

        if right_hand.get_parent():
            right_hand.get_parent().remove_child(right_hand)

        global_container.add_child(right_hand)

        right_hand.global_position = last_position

    func process(delta, state_machine):
        var input_manager = state_machine.parameters[RHM_INPUT_MANAGER] as InputManagerBase
        var shifter_container = state_machine.parameters[RHM_SHIFTER_CONTAINER] as ShifterContainer

        if input_manager.handbrake_amount() == 0.0:
            state_machine.transition(
                MovingToSteeringWheelState.new()
            )
            return

        if latest_gear != input_manager.numerical_gear():
            latest_gear = input_manager.numerical_gear()
            shifter_container.set_shifter_animation_gear(latest_gear)
            shifter_container.shifter_animation_factor = 1.0

class ShiftingState extends State:
    var latest_gear: int = 0
    var is_in_neutral: bool = false
    var is_towards_neutral: bool = false
    var elapsed: float = 0.0

    func on_enter(last, state_machine):
        var input_manager = state_machine.parameters[RHM_INPUT_MANAGER] as InputManagerBase
        var shifter_container = state_machine.parameters[RHM_SHIFTER_CONTAINER] as ShifterContainer
        var right_hand = state_machine.parameters[RHM_RIGHT_HAND] as Sprite2D

        self.latest_gear = input_manager.numerical_gear()
        self.is_in_neutral = shifter_container.shifter_animation.numerical_gear() == 0
        self.is_towards_neutral = self.latest_gear == 0

        #right_hand.play("shifter")
        right_hand.texture = CustomResourceLoader.instance.load_texture(
            CustomResourceLoader.HAND_RIGHT_SHIFTER
        )

    func process(delta, state_machine):
        self.elapsed += delta

        var input_manager = state_machine.parameters[RHM_INPUT_MANAGER] as InputManagerBase
        var right_hand = state_machine.parameters[RHM_RIGHT_HAND] as Sprite2D
        var shifter_container = state_machine.parameters[RHM_SHIFTER_CONTAINER] as ShifterContainer
        var shifter_knob = state_machine.parameters[RHM_SHIFTER_KNOB] as Node2D

        right_hand.global_position = shifter_knob.global_position

        if input_manager.numerical_gear() != latest_gear:
            state_machine.transition(
                ShiftingState.new()
            )
            return

        if is_in_neutral:
            if shifter_container.shifter_animation.numerical_gear() != latest_gear:
                shifter_container.set_shifter_animation_gear(latest_gear)

            shifter_container.shifter_animation_factor = elapsed / SHIFT_SPEED
        elif is_towards_neutral:
            shifter_container.shifter_animation_factor = 1 - elapsed / SHIFT_SPEED
        else:
            # Shift away from current gear
            if elapsed < SHIFT_SPEED / 2:
                shifter_container.shifter_animation_factor = 1 - elapsed / (SHIFT_SPEED / 2)
            # Shift towards target gear
            else:
                if shifter_container.shifter_animation.numerical_gear() != latest_gear:
                    shifter_container.set_shifter_animation_gear(latest_gear)

                shifter_container.shifter_animation_factor = (elapsed - SHIFT_SPEED / 2) / (SHIFT_SPEED / 2)

        if elapsed >= SHIFT_SPEED:
            if self.is_towards_neutral:
                shifter_container.set_shifter_animation_gear(0)

            state_machine.transition(
                MovingToSteeringWheelState.new()
            )

class MovingToShifterState extends State:
    var last_position: Vector2 = Vector2.ZERO
    var last_rotation: float = 0.0
    var elapsed: float = 0.0

    func on_enter(last, state_machine):
        var right_hand = state_machine.parameters[RHM_RIGHT_HAND] as Sprite2D
        var global_container = state_machine.parameters[RHM_GLOBAL_CONTAINER] as Node2D

        last_position = right_hand.global_position
        last_rotation = right_hand.global_rotation

        if right_hand.get_parent():
            right_hand.get_parent().remove_child(right_hand)

        global_container.add_child(right_hand)

        right_hand.global_position = last_position
        right_hand.global_rotation = last_rotation

        #right_hand.play("floating")
        right_hand.texture = CustomResourceLoader.instance.load_texture(
            CustomResourceLoader.HAND_RIGHT_FLOATING
        )

    func process(delta, state_machine):
        self.elapsed += delta

        var right_hand = state_machine.parameters[RHM_RIGHT_HAND] as Sprite2D
        var shifter_knob = state_machine.parameters[RHM_SHIFTER_KNOB] as Node2D

        var eased = ease(elapsed / TRANSITION_SPEED, -2)

        right_hand.global_position = last_position.lerp(shifter_knob.global_position, eased)
        right_hand.global_rotation = lerpf(last_rotation, 0.0, eased)

        if self.elapsed >= TRANSITION_SPEED:
            state_machine.transition(
                ShiftingState.new()
            )

class MovingToSteeringWheelState extends State:
    var latest_gear: int = 0

    var last_position: Vector2 = Vector2.ZERO
    var last_rotation: float = 0.0
    var elapsed: float = 0.0

    func on_enter(last, state_machine):
        var input_manager = state_machine.parameters[RHM_INPUT_MANAGER] as InputManagerBase
        var right_hand = state_machine.parameters[RHM_RIGHT_HAND] as Sprite2D

        self.latest_gear = input_manager.numerical_gear()

        last_position = right_hand.global_position
        last_rotation = right_hand.global_rotation

        #right_hand.play("floating")
        right_hand.texture = CustomResourceLoader.instance.load_texture(
            CustomResourceLoader.HAND_RIGHT_FLOATING
        )

    func process(delta, state_machine):
        self.elapsed += delta

        var input_manager = state_machine.parameters[RHM_INPUT_MANAGER] as InputManagerBase
        var right_hand = state_machine.parameters[RHM_RIGHT_HAND] as Sprite2D
        var steering_pin = state_machine.parameters[RHM_STEERING_PIN] as Node2D

        var eased = ease(elapsed / TRANSITION_SPEED, -2)

        var initial_distance = last_position.distance_to(steering_pin.global_position)
        right_hand.global_position = last_position.lerp(steering_pin.global_position, eased)
        right_hand.global_rotation = lerpf(last_rotation, steering_pin.global_rotation, eased)

        if input_manager.numerical_gear() != self.latest_gear:
            state_machine.transition(
                MovingToShifterState.new()
            )
            return

        if self.elapsed >= TRANSITION_SPEED:
            state_machine.transition(
                OnSteeringWheelState.new()
            )
            return

class OnSteeringWheelState extends State:
    var latest_gear: int = 0

    func on_enter(last, state_machine):
        var input_manager = state_machine.parameters[RHM_INPUT_MANAGER] as InputManagerBase
        var right_hand = state_machine.parameters[RHM_RIGHT_HAND] as Sprite2D
        var steering_pin = state_machine.parameters[RHM_STEERING_PIN] as Node2D

        self.latest_gear = input_manager.numerical_gear()

        if right_hand.get_parent():
            right_hand.get_parent().remove_child(right_hand)

        steering_pin.add_child(right_hand)

        #right_hand.play("steering")
        right_hand.texture = CustomResourceLoader.instance.load_texture(
            CustomResourceLoader.HAND_RIGHT_STEERING
        )

        right_hand.rotation = 0.0
        right_hand.position = Vector2.ZERO

    func process(delta, state_machine):
        var input_manager = state_machine.parameters[RHM_INPUT_MANAGER] as InputManagerBase

        if input_manager.numerical_gear() != self.latest_gear:
            state_machine.transition(
                MovingToShifterState.new()
            )
        if input_manager.handbrake_amount() > 0.0:
            state_machine.transition(
                MovingToHandbrakeState.new()
            )
