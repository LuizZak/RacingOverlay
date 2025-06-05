class_name SequentialShifterManager
extends Object

enum _GearEntry {
    GEAR_UP,
    GEAR_DOWN,
}

var _queue: Array[_GearEntry] = []

func update_inputs(input_manager: InputManagerBase):
    ## Disable sequential shifter if an H-pattern shift has been engaged.
    if input_manager.numerical_gear() != 0:
        clear_gear_change()
        return

    if Input.is_action_just_pressed("Shift_up") or Input.is_action_just_pressed("Simulated_shift_up"):
        enqueue_gear_change(true)
    elif Input.is_action_just_pressed("Shift_down") or Input.is_action_just_pressed("Simulated_shift_down"):
        enqueue_gear_change(false)

## Enqueues a new gear to be sequentially engaged.
func enqueue_gear_change(is_gear_up: bool):
    if is_gear_up:
        _queue.append(_GearEntry.GEAR_UP)
    else:
        _queue.append(_GearEntry.GEAR_DOWN)

## The current sequential shifter's sequential shift queue size.
func queue_size() -> int:
    return _queue.size()

## Removes all pending sequential shifts.
func clear_gear_change() -> void:
    _queue.clear()

## Returns `true` if there are any queued up gear changes.
func has_gear_changes() -> bool:
    return not _queue.is_empty()

## Dequeues the next gear change. Is `false` if the current queue is empty.
func dequeue_gear_change() -> bool:
    if _queue.is_empty():
        return false

    var next = _queue.pop_front()
    match next:
        _GearEntry.GEAR_UP:
            return true
        _GearEntry.GEAR_DOWN:
            return false
        _:
            return false
