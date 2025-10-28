class_name VisualTheme
extends Object

static var _default_theme: VisualTheme
static var _built_in_theme: VisualTheme

var path: String = ""
var display_name: String = ""

var resources: Dictionary[StringName, VisualResource] = {}

## Initializes a new visual theme, based on a given file lookup directory.
## Files will be scanned at the given path and loaded into the appropriate theme
## images.
##
## If `path` is an empty string, the files are loaded from the built-in theme
## files only, instead.
func _init(path: String) -> void:
    self.path = path
    self.display_name = path.get_file()

## Returns whether the current theme is empty, i.e. all resources are the default
## resource, and none were loaded from disk.
##
## Requires a call from `load_from_disk`, otherwise it always returns `true`.
func is_empty() -> bool:
    for resource in self.resources.values():
        if not resource.is_built_in:
            return false

    return true

func load_from_disk() -> void:
    for resource in VisualResourceLibrary.all_resources:
        self.resources[resource] = _load_uncached(resource, self.path)

func load_resource(key: StringName) -> VisualResource:
    if self.resources.has(key):
        return self.resources[key]

    return null

func _load_uncached(key: StringName, base_path: String) -> VisualResource:
    var resource := VisualResource.new()

    resource.key = key
    resource.texture = VisualResourceLibrary.load_default_texture(key)
    resource.sprite_frames = null
    resource.is_built_in = true

    # Load from disk, if a path is available
    if base_path != "":
        var local_texture := _load_file_texture(key, base_path)
        if local_texture != null:
            resource.texture = local_texture
            resource.is_built_in = false

        var sprite_frames := _load_file_sprite_frames(key, base_path)

        if sprite_frames != null:
            resource.sprite_frames = sprite_frames
            resource.is_built_in = false

    return resource

func _load_file_texture(key: StringName, base_path: String) -> Texture2D:
    var resolved_png_path := base_path.path_join("%s.png" % [key])

    if not FileAccess.file_exists(resolved_png_path):
        return null

    var image := Image.load_from_file(resolved_png_path)
    if image == null:
        return null

    return ImageTexture.create_from_image(image)

func _load_file_sprite_frames(key: StringName, base_path: String) -> SpriteFrames:
    var resolved_dir_path := base_path.path_join(key)

    var anim_loader := CustomAnimationLoader.new(resolved_dir_path)
    var sprite_frames := anim_loader.make_sprite_frames()

    return sprite_frames

## Returns the default theme, loaded from the directory the executable currently
## resides in.
static func default_theme() -> VisualTheme:
    if _default_theme != null:
        return _default_theme

    _default_theme = VisualTheme.new(OS.get_executable_path().get_base_dir())
    _default_theme.display_name = "Default"
    _default_theme.load_from_disk()
    return _default_theme

## Returns the built-in theme, loaded from the bundled program assets.
static func built_in_theme() -> VisualTheme:
    if _built_in_theme != null:
        return _built_in_theme

    _built_in_theme = VisualTheme.new("")
    _built_in_theme.display_name = "Built-in"
    _built_in_theme.load_from_disk()
    return _built_in_theme
