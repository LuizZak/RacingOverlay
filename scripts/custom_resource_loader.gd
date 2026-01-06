class_name CustomResourceLoader

static var instance = CustomResourceLoader.new()

var asset_lookup: Dictionary[StringName, VisualResource] = {}

func _init() -> void:
    reload()

## Reloads assets from disk or built-in assets, depending on local file availability.
func reload() -> void:
    for resource in VisualResourceLibrary.all_resources:
        asset_lookup[resource] = _load_uncached(resource)

## Loads the given asset as a `VisualResource` object, containing a non-animated
## texture, and an animated sprite frame resource, if one was found on disk.
func load_as_resource(key: StringName) -> VisualResource:
    if asset_lookup.has(key):
        return asset_lookup[key]

    return _load_uncached(key)

func _load_uncached(key: StringName) -> VisualResource:
    var resource := VisualResource.new()

    resource.key = key
    resource.texture = load_texture(key)
    resource.sprite_frames = _load_file_sprite_frames(key)

    return resource

func load_texture(key: StringName) -> Texture2D:
    var local := _load_file_texture(key)
    if local != null:
        return local

    return VisualResourceLibrary.load_default_texture(key)

func _load_file_texture(key: StringName) -> Texture2D:
    var base_path := OS.get_executable_path().get_base_dir()
    var resolved_png_path := base_path.path_join("%s.png" % [key])

    if not FileAccess.file_exists(resolved_png_path):
        return null

    var image := Image.load_from_file(resolved_png_path)
    if image == null:
        return null

    return ImageTexture.create_from_image(image)

func _load_file_sprite_frames(key: StringName) -> SpriteFrames:
    var base_path := OS.get_executable_path().get_base_dir()
    var resolved_dir_path := base_path.path_join(key)

    var anim_loader := CustomAnimationLoader.new(resolved_dir_path)
    var sprite_frames := anim_loader.make_sprite_frames()

    return sprite_frames
