extends Node3D

@onready
var pitch_arrow: Node3D = %PitchArrow
@onready
var roll_arrow: Node3D = %RollArrow
@onready
var yaw_arrow: Node3D = %YawArrow
@onready
var roll_angle_label: Label = %RollAngleLabel
@onready
var rpm_label: Label = %RPMLabel
@onready
var gear_label: Label = %GearLabel

var networking: NetworkingBase = MockNetworking.new()
var saved_packets: Array[GamePacket] = []

func _ready() -> void:
    networking.begin_mock()
    networking.load_mock_data()

func _process(delta: float) -> void:
    if networking.is_connection_available():
        networking.connect_to_game()

    if networking.is_connected_to_game():
        while networking.has_packets():
            var next_packet = networking.fetch_packet()
            saved_packets.append(next_packet)
            _update_scene(next_packet)

func _reset_scene():
    roll_angle_label.text = "0°"
    rpm_label.text = "0"
    gear_label.text = "0"

func _update_scene(packet: GamePacket):
    _rotate_pitch_arrow(packet.pitch)
    _rotate_roll_arrow(packet.roll)
    var yaw = packet.roll.cross(packet.pitch)
    _rotate_yaw_arrow(yaw)

    var roll_angle = Vector3.UP.angle_to(packet.roll)

    roll_angle_label.text = "%0.2f°" % [rad_to_deg(roll_angle) - 90]

    rpm_label.text = "%0.f" % [packet.rpm * 10]
    gear_label.text = "%0.f" % [packet.gear]

func _rotate_pitch_arrow(pitch: Vector3):
    var transform = Transform3D.IDENTITY.looking_at(pitch)

    pitch_arrow.transform = transform

func _rotate_roll_arrow(roll: Vector3):
    var transform = Transform3D.IDENTITY.looking_at(roll)

    roll_arrow.transform = transform

func _rotate_yaw_arrow(yaw: Vector3):
    var transform = Transform3D.IDENTITY.looking_at(yaw)

    yaw_arrow.transform = transform

func _on_save_mock_data_button_pressed() -> void:
    var mock_network = MockNetworking.new()
    mock_network.save_mock_data(saved_packets)
