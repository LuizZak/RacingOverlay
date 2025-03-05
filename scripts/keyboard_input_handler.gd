class_name KeyboardInputHandler
extends Object

@export var pedal_change_per_second: float = 20.0
@export var handbrake_change_per_second: float = 20.0
@export var steering_change_per_second: float = 1.0

var simulated_input_manager: SimulatedInputManager

func _init(simulated_input_manager: SimulatedInputManager):
    self.simulated_input_manager = simulated_input_manager

func process(delta: float) -> void:
    # Pedals
    if Input.is_action_pressed("Simulated_clutch"):
        simulated_input_manager.clutch = move_toward(simulated_input_manager.clutch, 1.0, pedal_change_per_second * delta)
    else:
        simulated_input_manager.clutch = move_toward(simulated_input_manager.clutch, -1.0, pedal_change_per_second * delta)

    if Input.is_action_pressed("Simulated_brake"):
        simulated_input_manager.brake = move_toward(simulated_input_manager.brake, 1.0, pedal_change_per_second * delta)
    else:
        simulated_input_manager.brake = move_toward(simulated_input_manager.brake, -1.0, pedal_change_per_second * delta)

    if Input.is_action_pressed("Simulated_throttle"):
        simulated_input_manager.throttle = move_toward(simulated_input_manager.throttle, 1.0, pedal_change_per_second * delta)
    else:
        simulated_input_manager.throttle = move_toward(simulated_input_manager.throttle, -1.0, pedal_change_per_second * delta)

    # Handbrake
    if Input.is_action_pressed("Simulated_handbrake"):
        simulated_input_manager.handbrake = move_toward(simulated_input_manager.handbrake, 1.0, handbrake_change_per_second * delta)
    else:
        simulated_input_manager.handbrake = move_toward(simulated_input_manager.handbrake, 0.0, handbrake_change_per_second * delta)

    # Steering
    var steering = Input.get_axis("Simulated_left", "Simulated_right")
    simulated_input_manager.steering = move_toward(simulated_input_manager.steering, steering, steering_change_per_second * delta)

    # Shifter
    if Input.is_action_just_pressed("Simulated_1st"):
        if simulated_input_manager.numerical_gear() == 1:
            simulated_input_manager.shift_to_gear(0)
        else:
            simulated_input_manager.shift_to_gear(1)

    if Input.is_action_just_pressed("Simulated_2nd"):
        if simulated_input_manager.numerical_gear() == 2:
            simulated_input_manager.shift_to_gear(0)
        else:
            simulated_input_manager.shift_to_gear(2)

    if Input.is_action_just_pressed("Simulated_3rd"):
        if simulated_input_manager.numerical_gear() == 3:
            simulated_input_manager.shift_to_gear(0)
        else:
            simulated_input_manager.shift_to_gear(3)

    if Input.is_action_just_pressed("Simulated_4th"):
        if simulated_input_manager.numerical_gear() == 4:
            simulated_input_manager.shift_to_gear(0)
        else:
            simulated_input_manager.shift_to_gear(4)

    if Input.is_action_just_pressed("Simulated_5th"):
        if simulated_input_manager.numerical_gear() == 5:
            simulated_input_manager.shift_to_gear(0)
        else:
            simulated_input_manager.shift_to_gear(5)

    if Input.is_action_just_pressed("Simulated_6th"):
        if simulated_input_manager.numerical_gear() == 6:
            simulated_input_manager.shift_to_gear(0)
        else:
            simulated_input_manager.shift_to_gear(6)

    if Input.is_action_just_pressed("Simulated_reverse"):
        if simulated_input_manager.numerical_gear() == -1:
            simulated_input_manager.shift_to_gear(0)
        else:
            simulated_input_manager.shift_to_gear(-1)
