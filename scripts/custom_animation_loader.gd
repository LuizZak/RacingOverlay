class_name CustomAnimationLoader
extends Object

var base_path: String
var _animation_length: int
var _frame_duration: float

func _init(base_path: String):
    self.base_path = base_path

## Returns `true` if the directory `base_path` exists, and contains a valid animation
## with a valid `animation.json` configuration file.
func is_valid_animation() -> bool:
    var json_path = self.base_path.path_join("animation.json")
    var json = JSONInformation.from_file(json_path)
    if not json:
        return false

    var first_frame = _path_for_frame(0)
    if not FileAccess.file_exists(first_frame):
        return false

    return true

## Refreshes the animation based on the contents of base_path.
func refresh() -> Error:
    if not is_valid_animation():
        return Error.FAILED

    var json_path = self.base_path.path_join("animation.json")
    var json = JSONInformation.from_file(json_path)

    _frame_duration = json.frame_duration

    var index = 0
    while FileAccess.file_exists(_path_for_frame(index)):
        index += 1

    _animation_length = index

    return Error.OK

## The number of sequential frames, starting from '0'th frame, that were found in
## the directory.
func animation_length() -> int:
    return _animation_length

## The duration of each frame.
func frame_duration() -> float:
    return _frame_duration

## Creates a SpriteFrames instance from this animation loader's contents.
## May return `null` if `is_animation_valid()` is `false`.
func make_sprite_frames() -> SpriteFrames:
    if refresh():
        return null

    var sprite_frames = SpriteFrames.new()
    sprite_frames.set_animation_loop(&"default", true)
    sprite_frames.set_animation_speed(&"default", 1.0 / frame_duration())

    var index = 0
    while FileAccess.file_exists(_path_for_frame(index)):
        var image = Image.load_from_file(_path_for_frame(index))
        if image == null:
            return null
        var texture = ImageTexture.create_from_image(image)
        sprite_frames.add_frame(&"default", texture)
        index += 1

    return sprite_frames

func _path_for_frame(index: int) -> String:
    return self.base_path.path_join("%s_%d.png" % [_get_dir_name(), index])

func _get_dir_name() -> String:
    var effective_path = base_path.trim_suffix("/")
    var slices = effective_path.get_slice_count("/")
    var dir_name = effective_path.get_slice("/", slices - 1)

    return dir_name

class JSONInformation:
    var frame_duration: float

    func _init(
        frame_duration: float,
    ):
        self.frame_duration = frame_duration

    static func from_file(json_path: String) -> JSONInformation:
        if not FileAccess.file_exists(json_path):
            return null

        var file = FileAccess.open(json_path, FileAccess.READ)
        if file == null:
            return null

        var json = JSON.parse_string(file.get_as_text())
        if json == null:
            return null

        if not json is Dictionary:
            return null

        if not json.has("frame_duration"):
            return null

        if typeof(json["frame_duration"]) != TYPE_FLOAT and typeof(json["frame_duration"]) != TYPE_INT:
            return null

        return JSONInformation.new(
            json["frame_duration"]
        )
