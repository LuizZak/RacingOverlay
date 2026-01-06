class_name VisualThemeManager

const THEME_PATH := "themes"

static var instance := VisualThemeManager.new()

var themes: Array[VisualTheme] = []

func _init() -> void:
    pass

func scan_from_disk() -> void:
    self.themes = []

    # Populate built-in theme
    self.themes.append(VisualTheme.built_in_theme())

    # Populate disk themes
    var search_path := theme_lookup_folder()

    if DirAccess.dir_exists_absolute(search_path):
        var potential_themes := DirAccess.get_directories_at(search_path)

        for potential_theme in potential_themes:
            var theme_path = search_path.path_join(potential_theme)

            var theme := VisualTheme.new(theme_path)
            theme.load_from_disk()

            if theme.is_empty():
                continue

            self.themes.append(theme)

## Finds and returns a theme with a given identifier.
##
## If no loaded themes match the given identifier, `null` is returned, instead.
func find_theme(identifier: String) -> VisualTheme:
    for theme in themes:
        if theme.identifier == identifier:
            return theme

    return null

static func theme_lookup_folder() -> String:
    var base_path := OS.get_executable_path().get_base_dir()
    var search_path := base_path.path_join(THEME_PATH)

    return search_path
