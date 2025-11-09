class_name StateMachine
extends Object

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
    func on_enter(_last: State, _state_machine: StateMachine) -> void:
        pass

    func on_exit(_next: State, _state_machine: StateMachine) -> void:
        pass

    func process(_delta: float, _state_machine: StateMachine) -> void:
        pass

    func description() -> String:
        return ""
