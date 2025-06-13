class_name CustomResourceLoader
extends Object

const FOOT_LEFT := &"foot_left"
const FOOT_RIGHT := &"foot_right"
const EBRAKE := &"ebrake"
const EBRAKE_BASE := &"ebrake_base"
const HAND_LEFT := &"hand_left"
const HAND_RIGHT := &"hand_right"
const HAND_RIGHT_EBRAKE := &"hand_right_ebrake"
const HAND_RIGHT_FLOATING := &"hand_right_floating"
const HAND_RIGHT_SHIFTER := &"hand_right_shifter"
const HAND_RIGHT_STEERING := &"hand_right_steering"
const PEDAL_BASE := &"pedal_base"
const PEDAL_CLUTCH := &"pedal_clutch"
const PEDAL_BRAKE := &"pedal_brake"
const PEDAL_THROTTLE := &"pedal_throttle"
const PEDAL_FIXTURE := &"pedal_fixture"
const SHIFTER_BASE := &"shifter_base"
const SHIFTER_KNOB := &"shifter_knob"
const STEERING_WHEEL := &"steering_wheel"

static var instance = CustomResourceLoader.new()

func refresh():
    pass

func load_as_resource(key: StringName) -> VisualResource:
    var resource = VisualResource.new()

    resource.key = key
    resource.texture = load_texture(key)
    resource.sprite_frames = _load_file_sprite_frames(key)

    return resource

func load_texture(key: StringName) -> Texture2D:
    var local := _load_file_texture(key)
    if local != null:
        return local

    return load_default_texture(key)

func _load_file_texture(key: StringName) -> Texture2D:
    var base_path = OS.get_executable_path().get_base_dir()
    var resolved_png_path = base_path.path_join("%s.png" % [key])

    if not FileAccess.file_exists(resolved_png_path):
        return null

    var image = Image.load_from_file(resolved_png_path)
    if image == null:
        return null

    return ImageTexture.create_from_image(image)

func _load_file_sprite_frames(key: StringName) -> SpriteFrames:
    var base_path = OS.get_executable_path().get_base_dir()
    var resolved_dir_path = base_path.path_join(key)

    var anim_loader = CustomAnimationLoader.new(resolved_dir_path)
    var sprite_frames = anim_loader.make_sprite_frames()

    return sprite_frames

func load_default_texture(key: StringName) -> Texture2D:
    match key:
        FOOT_LEFT:
            return preload("res://sprites/foot_left.aseprite")
        FOOT_RIGHT:
            return preload("res://sprites/foot_right.aseprite")
        EBRAKE:
            return preload("res://sprites/ebrake.aseprite")
        EBRAKE_BASE:
            return preload("res://sprites/ebrake_base.aseprite")
        HAND_LEFT:
            return preload("res://sprites/hand_left.aseprite")
        HAND_RIGHT_EBRAKE:
            return preload("res://sprites/hand_right_ebrake.aseprite")
        HAND_RIGHT_FLOATING:
            return preload("res://sprites/hand_right_floating.aseprite")
        HAND_RIGHT_SHIFTER:
            return preload("res://sprites/hand_right_shifter.aseprite")
        HAND_RIGHT_STEERING:
            return preload("res://sprites/hand_right_steering.aseprite")
        PEDAL_BASE:
            return preload("res://sprites/pedal_base.aseprite")
        PEDAL_CLUTCH:
            return preload("res://sprites/pedal_clutch.aseprite")
        PEDAL_BRAKE:
            return preload("res://sprites/pedal_brake.aseprite")
        PEDAL_THROTTLE:
            return preload("res://sprites/pedal_throttle.aseprite")
        PEDAL_FIXTURE:
            return preload("res://sprites/pedal_fixture.aseprite")
        SHIFTER_BASE:
            return preload("res://sprites/shifter_base.aseprite")
        SHIFTER_KNOB:
            return preload("res://sprites/shifter_knob.aseprite")
        STEERING_WHEEL:
            return preload("res://sprites/steering_wheel.aseprite")
        _:
            push_error("Unknown texture key '%s'" % [key])
            return null
