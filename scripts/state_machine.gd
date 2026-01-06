class_name StateMachine

var parameters: Dictionary = {}

var current_state: State = null

## Signal fired when a state change has fully completed.
signal state_changed(new_state: State, old_state: State)

func process(delta: float) -> void:
    if current_state != null:
        current_state.process(delta, self)

func transition(new_state: State) -> void:
    if current_state != null:
        current_state.on_exit(new_state, self)

    var last_state := current_state
    current_state = new_state

    if new_state != null:
        new_state.on_enter(last_state, self)

    state_changed.emit(new_state, last_state)

#

class State:
    @warning_ignore("unused_parameter")
    func on_enter(last: State, state_machine: StateMachine) -> void:
        pass

    @warning_ignore("unused_parameter")
    func on_exit(next: State, state_machine: StateMachine) -> void:
        pass

    @warning_ignore("unused_parameter")
    func process(delta: float, state_machine: StateMachine) -> void:
        pass

    func description() -> String:
        return ""
