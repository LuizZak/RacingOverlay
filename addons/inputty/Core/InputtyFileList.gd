extends Resource
class_name InputtyFileList

const fileLocation := "user://input_file_list.cfg"
const fileNamesSection := "file_names"

@export var activeFileName: String:
    set(value):
        if activeFileName == value:
            return

        activeFileName = value
        onActiveFileNameChanged.emit(value)

@export var fileNames: PackedStringArray:
    set(value):
        fileNames = value
        onFileNamesChanged.emit(value)

signal onActiveFileNameChanged(String)
signal onFileNamesChanged(PackedStringArray)

func addFile(newFile: String) -> void:
    fileNames.append(newFile)

    onFileNamesChanged.emit(fileNames)

func deleteFile(filePath: String) -> void:
    for i in range(fileNames.size()):
        if fileNames[i] == filePath:
            fileNames.remove_at(i)
            onFileNamesChanged.emit(fileNames)
            return

## Ensures that if the bindings list is currently empty, a new fresh entry is
## created and activated.
func ensureHasValidActiveBindingsFile() -> void:
    # TODO: Refactor to drop InputtyBindingsManager dependency
    if fileNames.is_empty():
        InputtyBindingsManager.new().create_new_binding("Bindings 1")
    elif activeFileName == "":
        activeFileName = fileNames[0]

func loadFromFile() -> Error:
    var configFile := ConfigFile.new()
    var err := configFile.load(fileLocation)
    if err != OK:
        return err

    var activeFile := configFile.get_value("static", "active_file_name", "")
    var fileNameList: PackedStringArray = []

    if fileNamesSection not in configFile.get_sections():
        return ERR_FILE_CORRUPT

    var fileKeys := configFile.get_section_keys(fileNamesSection)
    for fileKey in fileKeys:
        var split := fileKey.split("_")
        if split.size() != 2:
            return ERR_FILE_CORRUPT

        var value := configFile.get_value(fileNamesSection, fileKey)
        fileNameList.append(value)

    self.activeFileName = activeFile
    self.fileNames = fileNameList

    return OK

func saveToFile() -> Error:
    var configFile := ConfigFile.new()

    configFile.set_value("static", "active_file_name", activeFileName)

    for i in range(fileNames.size()):
        var key := "file_%d" % [i]
        configFile.set_value(fileNamesSection, key, fileNames[i])

    return configFile.save(fileLocation)
