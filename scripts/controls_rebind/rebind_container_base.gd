class_name RebindContainerBase
extends PanelContainer

signal on_input_accepted(event: InputEvent)
signal on_cancelled()

func start_listening(_action_name: String):
    pass

func stop_listening():
    pass
