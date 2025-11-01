class_name GameConnectionPanel
extends MarginContainer

@onready
var connect_to_game_checkbox: CheckBox = %ConnectToGameCheckbox

@onready
var game_option_button: OptionButton = %GameOptionButton

@onready
var port_spin_box: SpinBox = %PortSpinBox

@onready
var roll_with_vehicle_checkbox: CheckBox = %RollWithVehicleCheckbox
@onready
var scale_with_speed_checkbox: CheckBox = %ScaleWithSpeedCheckbox
@onready
var move_vertically_checkbox: CheckBox = %MoveVerticallyCheckbox
@onready
var show_extra_game_info_checkbox: CheckBox = %ShowExtraGameInfoCheckbox

@onready
var status_label: Label = %StatusLabel

func _ready() -> void:
    _populate_games()
    # Select game in settings
    for index in game_option_button.item_count:
        var game := game_option_button.get_item_id(index)

        if game == Settings.instance.active_game:
            game_option_button.selected = index
            break

    _populate_settings()

    Networking.instance.on_status_changed.connect(_on_networking_status_changed)
    _on_networking_status_changed(Networking.instance._status)

func _populate_games() -> void:
    for key in Settings.instance.game_connections.keys():
        var title := GameConnectionSettings.game_title(key)

        game_option_button.add_item(title, key)

func _populate_settings() -> void:
    connect_to_game_checkbox.button_pressed = Settings.instance.connect_to_game

    var settings := _settings_for_selected_item()
    if !settings:
        return

    port_spin_box.value = settings.port
    roll_with_vehicle_checkbox.button_pressed = settings.roll_with_vehicle
    scale_with_speed_checkbox.button_pressed = settings.scale_with_speed
    move_vertically_checkbox.button_pressed = settings.move_vertically
    show_extra_game_info_checkbox.button_pressed = settings.show_extra_game_information

func _settings_for_selected_item() -> GameConnectionSettings:
    if game_option_button.selected == -1:
        return null

    var item := game_option_button.get_item_id(game_option_button.selected)
    return Settings.instance.game_connections[item]

func _on_game_option_button_item_selected(index: int) -> void:
    var active_game := game_option_button.get_item_id(index)

    Networking.instance.set_game(
        GamePacketBase.game_from_game_connection_settings(
            active_game
        )
    )

    Settings.instance.active_game = active_game as GameConnectionSettings.Game
    Settings.instance.save_to_disk()

    _populate_settings()

func _on_connect_to_game_checkbox_toggled(toggled_on: bool) -> void:
    Settings.instance.connect_to_game = toggled_on
    Settings.instance.save_to_disk()

func _on_port_spin_box_value_changed(value: float) -> void:
    var settings := _settings_for_selected_item()
    if !settings:
        return

    settings.port = int(value)
    Settings.instance.emit_settings_changed()
    Settings.instance.save_to_disk()

func _on_roll_with_vehicle_checkbox_toggled(toggled_on: bool) -> void:
    var settings := _settings_for_selected_item()
    if !settings:
        return

    settings.roll_with_vehicle = toggled_on
    Settings.instance.emit_settings_changed()
    Settings.instance.save_to_disk()

func _on_scale_with_speed_checkbox_toggled(toggled_on: bool) -> void:
    var settings := _settings_for_selected_item()
    if !settings:
        return

    settings.scale_with_speed = toggled_on
    Settings.instance.emit_settings_changed()
    Settings.instance.save_to_disk()

func _on_move_vertically_checkbox_toggled(toggled_on: bool) -> void:
    var settings := _settings_for_selected_item()
    if !settings:
        return

    settings.move_vertically = toggled_on
    Settings.instance.emit_settings_changed()
    Settings.instance.save_to_disk()

func _on_show_extra_game_info_checkbox_toggled(toggled_on: bool) -> void:
    var settings := _settings_for_selected_item()
    if !settings:
        return

    settings.show_extra_game_information = toggled_on
    Settings.instance.emit_settings_changed()
    Settings.instance.save_to_disk()

func _on_networking_status_changed(status: NetworkingBase.Status) -> void:
    match status:
        NetworkingBase.Status.DISCONNECTED:
            status_label.text = "Disconnected"
        NetworkingBase.Status.AWAITING:
            status_label.text = "Awaiting connection..."
        NetworkingBase.Status.CONNECTED:
            status_label.text = "Connected"
