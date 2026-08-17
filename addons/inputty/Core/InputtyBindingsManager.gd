class_name InputtyBindingsManager

const MAX_BINDING_FILES := 100

## Gets a collection of all binding files as [code]BindingEntry[/code] list.
func get_all_bindings() -> Array[BindingEntry]:
    var file_list := Inputty.inputFileList

    var result: Array[BindingEntry] = []

    for file_name in file_list.fileNames:
        var binding_entry := BindingEntry.from_file(file_name)
        binding_entry.is_active = binding_entry.file_name == file_list.activeFileName
        result.append(binding_entry)

    return result

## Creates a new binding entry, returning the file path to the newly created
## file, returning the file name of the newly created binding.
func create_new_binding(display_name: String = "New Bindings") -> String:
    var file_name := _next_available_file_name()

    var input_map := InputtyMap.new()
    input_map.copyFrom(Inputty._inputMapDefault)
    input_map.displayName = display_name
    input_map.saveToFile(file_name)

    if Inputty.inputFileList.activeFileName == "":
        Inputty.inputFileList.activeFileName = file_name

    Inputty.inputFileList.addFile(file_name)
    Inputty.inputFileList.saveToFile()

    return file_name

## Renames a binding entry with the given file path to a specified display name.
##
## [code]file_path[/code] must be the path of a valid file in the disk.
##
## Returns an [code]Error[/code] indicating whether the change was successful.
func rename_binding(file_path: String, display_name: String) -> Error:
    if not FileAccess.file_exists(file_path):
        return ERR_FILE_NOT_FOUND

    var input_map := InputtyMap.new()
    input_map.loadFromFile(file_path)
    input_map.displayName = display_name
    input_map.saveToFile(file_path)

    return OK

## Duplicates a binding entry with the given file path.
##
## [code]file_path[/code] must be the path of a valid file in the disk.
##
## Returns an [code]Error[/code] indicating whether the change was successful.
func duplicate_binding(file_path: String) -> Error:
    if not FileAccess.file_exists(file_path):
        return ERR_FILE_NOT_FOUND

    var new_file := _next_available_file_name()

    var input_map := InputtyMap.new()
    input_map.loadFromFile(file_path)
    input_map.saveToFile(new_file)

    Inputty.inputFileList.addFile(new_file)
    Inputty.inputFileList.saveToFile()

    return OK

## Deletes a binding entry with the given file path.
##
## [code]file_path[/code] must be the path of a valid file in the disk.
##
## Returns an [code]Error[/code] indicating whether the change was successful.
func delete_binding(file_path: String) -> Error:
    if not FileAccess.file_exists(file_path):
        return ERR_FILE_NOT_FOUND

    if Inputty.inputFileList.activeFileName == file_path:
        Inputty.inputFileList.activeFileName = ""

    Inputty.inputFileList.deleteFile(file_path)

    var deleteOp := DirAccess.remove_absolute(file_path)

    # Manage re-assigning recently-deleted active file path
    if Inputty.inputFileList.activeFileName == "" and not Inputty.inputFileList.fileNames.is_empty():
        Inputty.inputFileList.activeFileName = Inputty.inputFileList.fileNames[0]

    Inputty.inputFileList.ensureHasValidActiveBindingsFile()

    Inputty.inputFileList.saveToFile()

    return deleteOp

## Changes the active binding file path to the provided one.
##
## [code]file_path[/code] must be the path of a valid file in the disk.
##
## Returns an [code]Error[/code] indicating whether the change was successful.
func set_active_binding(file_path: String) -> Error:
    if not FileAccess.file_exists(file_path):
        return ERR_FILE_NOT_FOUND

    Inputty.inputFileList.activeFileName = file_path
    Inputty.inputFileList.saveToFile()

    return OK

## Returns a path to the next available binding file slot.
func _next_available_file_name() -> String:
    var base_path := Inputty.defaultInputMapsFolder
    var i := 0

    while i < MAX_BINDING_FILES:
        var file_name := "inputmap%d.cfg" % [i]
        var full_path := base_path.path_join(file_name)

        if not FileAccess.file_exists(full_path):
            return full_path

        i += 1

    var final_file_name := "inputmap%d.cfg" % [i]
    var final_full_path := base_path.path_join(final_file_name)

    return final_full_path

class BindingEntry:
    var file_name: String
    var display_name: String
    var is_active: bool = false

    @warning_ignore("shadowed_variable")
    func _init(file_name: String, display_name: String) -> void:
        self.file_name = file_name
        self.display_name = display_name

    static func from_file(file_name: String) -> BindingEntry:
        var input_map := InputtyMap.new()
        if input_map.loadFromFile(file_name) != OK:
            return null

        return BindingEntry.new(file_name, input_map.displayName)
