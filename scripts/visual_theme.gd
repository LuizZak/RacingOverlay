class_name VisualTheme

static var _built_in_theme: VisualTheme

const DEFAULT_SHIFTER_FILL_COLOR := Color.BLACK
const DEFAULT_SHIFTER_OUTLINE_COLOR := Color.WHITE
const DEFAULT_PEDAL_FILL_COLOR := Color(0.082, 0.219, 0.225)

## A path to disk that represents this theme.
var path: String = ""

## An identifier for this theme. Must be unique across themes in the same collection.
var identifier: String = ""

## A display name for this theme, to be shown in user interfaces.
var display_name: String = ""

## Accompanying theme settings.
var theme_settings: ThemeSettings = ThemeSettings.make_default()

var resources: Dictionary[StringName, VisualResource] = {}

## Initializes a new visual theme, based on a given file lookup directory.
## Files will be scanned at the given path and loaded into the appropriate theme
## images.
##
## If `path` is an empty string, the files are loaded from the built-in theme
## files only, instead.
func _init(path: String) -> void:
    self.path = path
    self.identifier = path.get_file()
    self.display_name = path.get_file()

## Returns whether the current theme is empty, i.e. all resources are the default
## resource, and none were loaded from disk.
##
## Requires a call from `load_from_disk`, otherwise it always returns `true`.
func is_empty() -> bool:
    for resource in self.resources.values():
        if not resource.is_built_in:
            return false

    if not theme_settings.is_empty:
        return false

    return true

func load_from_disk() -> void:
    theme_settings = _load_theme_settings(self.path)

    for resource in VisualResourceLibrary.all_resources:
        self.resources[resource] = _load_uncached(resource, self.path)

func save_settings_to_disk() -> void:
    ## Ensure we are not attempting to save a built-in theme
    if self.path == "":
        return

    var full_path := self.path.path_join("settings.json")

    var json := theme_settings.to_json()

    var file := FileAccess.open(full_path, FileAccess.WRITE)
    file.store_string(json)

func load_resource(key: StringName) -> VisualResource:
    if self.resources.has(key):
        return self.resources[key]

    return null

func _load_theme_settings(base_path: String) -> ThemeSettings:
    if base_path == "":
        return ThemeSettings.make_default()

    var full_path := base_path.path_join("settings.json")

    if not FileAccess.file_exists(full_path):
        return ThemeSettings.make_default()

    var file := FileAccess.open(full_path, FileAccess.READ)
    var json_text := file.get_as_text()

    return ThemeSettings.from_json(json_text)

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

## Returns the built-in theme, loaded from the bundled program assets.
static func built_in_theme() -> VisualTheme:
    if _built_in_theme != null:
        return _built_in_theme

    _built_in_theme = VisualTheme.new("")
    _built_in_theme.display_name = "Built-in"
    _built_in_theme.identifier = "?built in?"
    _built_in_theme.load_from_disk()
    return _built_in_theme

## Extra theme settings.
class ThemeSettings:
    var shifter_fill_color: Color
    var shifter_outline_color: Color
    var pedal_bar_fill_color: Color
    var is_empty: bool

    func _init(
        shifter_fill_color: Color,
        shifter_outline_color: Color,
        pedal_bar_fill_color: Color,
        is_empty: bool,
    ) -> void:
        self.shifter_fill_color = shifter_fill_color
        self.shifter_outline_color = shifter_outline_color
        self.pedal_bar_fill_color = pedal_bar_fill_color
        self.is_empty = is_empty

    func to_json() -> String:
        var dictionary: Dictionary = {
            "shifter_fill_color": _color_to_string(shifter_fill_color),
            "shifter_outline_color": _color_to_string(shifter_outline_color),
            "pedal_bar_fill_color": _color_to_string(pedal_bar_fill_color)
        }

        return JSON.stringify(dictionary, "    ")

    ## Makes a default theme settings object.
    ##
    ## By default, `is_empty` is set to true on the returned object.
    static func make_default() -> ThemeSettings:
        return ThemeSettings.new(
            VisualTheme.DEFAULT_SHIFTER_FILL_COLOR,
            VisualTheme.DEFAULT_SHIFTER_OUTLINE_COLOR,
            VisualTheme.DEFAULT_PEDAL_FILL_COLOR,
            true,
        )

    static func from_json(json: String) -> ThemeSettings:
        var dictionary: Dictionary = JSON.parse_string(json)

        if dictionary == null:
            return ThemeSettings.new(
                VisualTheme.DEFAULT_SHIFTER_FILL_COLOR,
                VisualTheme.DEFAULT_SHIFTER_OUTLINE_COLOR,
                VisualTheme.DEFAULT_PEDAL_FILL_COLOR,
                true,
            )

        var shifter_fill_color: Color = VisualTheme.DEFAULT_SHIFTER_FILL_COLOR
        if dictionary.has("shifter_fill_color"):
            shifter_fill_color = _color_from_string(dictionary["shifter_fill_color"], VisualTheme.DEFAULT_SHIFTER_FILL_COLOR)

        var shifter_outline_color: Color = VisualTheme.DEFAULT_SHIFTER_OUTLINE_COLOR
        if dictionary.has("shifter_outline_color"):
            shifter_outline_color = _color_from_string(dictionary["shifter_outline_color"], VisualTheme.DEFAULT_SHIFTER_OUTLINE_COLOR)

        var pedal_bar_fill_color: Color = VisualTheme.DEFAULT_PEDAL_FILL_COLOR
        if dictionary.has("pedal_bar_fill_color"):
            pedal_bar_fill_color = _color_from_string(dictionary["pedal_bar_fill_color"], VisualTheme.DEFAULT_PEDAL_FILL_COLOR)

        return ThemeSettings.new(
            shifter_fill_color,
            shifter_outline_color,
            pedal_bar_fill_color,
            false,
        )

    static func _color_to_string(color: Color) -> String:
        return color.to_html()

    static func _color_from_string(string: String, default: Color) -> Color:
        return Color.from_string(string, default)
