class_name RebindContainerBase
extends PanelContainer

@warning_ignore_start("unused_signal")
signal on_input_accepted(event: InputEvent)
signal on_cancelled()
@warning_ignore_restore("unused_signal")

func start_listening(_action_name: String) -> void:
    pass

func stop_listening() -> void:
    pass
