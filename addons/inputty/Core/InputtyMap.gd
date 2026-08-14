extends Resource
class_name InputtyMap

var displayName:String="default"
var version:int=1
var actions:Array[InputtyAction]=[]
var properties:Array[InputtyProperty] = []

func getAction(name:StringName)->InputtyAction:
    for a in actions:
        if a.name==name:
            return a
    return null
func getProperty(name:StringName)->InputtyProperty:
    for p in properties:
        if p.name == name:
            return p
    return null

func copyFrom(other:InputtyMap)->void:
    displayName = other.displayName
    version = other.version

    actions = []
    for a in other.actions:
        var newAction:InputtyAction = InputtyAction.new()
        newAction.copyFrom(a)
        actions.append(newAction)

    properties = []
    for p in other.properties:
        var newProperty:InputtyProperty
        if p is InputtyPropertyBool:
            newProperty = InputtyPropertyBool.new()
        elif p is InputtyPropertyFloat:
            newProperty = InputtyPropertyFloat.new()
        elif p is InputtyPropertyEnum:
            newProperty = InputtyPropertyEnum.new()
        newProperty.copyFrom(p)
        properties.append(newProperty)

func copyFromMain()->void:
    displayName = Inputty.inputMap.displayName
    version = Inputty.inputMap.version

    actions = []
    var mainActions = InputMap.get_actions()
    for actionName in mainActions:
        var newAction:InputtyAction = InputtyAction.new()
        newAction.copyFromMain(actionName)
        actions.append(newAction)

    properties = []
    for p in Inputty.inputMap.properties:
        var newProperty:InputtyProperty
        if p is InputtyPropertyBool:
            newProperty = InputtyPropertyBool.new()
        elif p is InputtyPropertyFloat:
            newProperty = InputtyPropertyFloat.new()
        elif p is InputtyPropertyEnum:
            newProperty = InputtyPropertyEnum.new()
        newProperty.copyFrom(p)
        properties.append(newProperty)

func applyToMain()->void:
    Inputty.inputMap.copyFrom(self)

    for a in actions:
        InputMap.action_erase_events(a.name)
        InputMap.action_set_deadzone(a.name, a.deadzone)
        for i in a.inputs:
            InputMap.action_add_event(a.name, a.InputCopy(i))

func saveToFile(file_path: String):
    var config:ConfigFile = ConfigFile.new()

    config.set_value("static", "display_name", displayName)
    config.set_value("static", "version", version)

    for p in properties:
        if p is InputtyPropertyEnum:
            config.set_value("property_"+p.name, "value", p.values[p.valueIndex])
        else:
            config.set_value("property_"+p.name, "value", p.value)

    for a in actions:
        a.prepSave(config)

    var base_path := file_path.get_base_dir()
    if not DirAccess.dir_exists_absolute(base_path):
        DirAccess.make_dir_recursive_absolute(base_path)

    config.save(file_path)

func loadFromFile(file_path: String) -> Error:
    var config:ConfigFile = ConfigFile.new()
    var err = config.load(file_path)
    if err!=OK:
        return err

    copyFrom(Inputty._inputMapDefault)

    #load statics
    displayName = config.get_value("static", "display_name", "default")
    version = config.get_value("static", "version", 0)

    for loadedSection in config.get_sections():
        #load properties
        if loadedSection.length()>=9 && loadedSection.substr(0,9)=="property_":
            var prop:InputtyProperty = getProperty(loadedSection.substr(9))
            if prop:
                if prop is InputtyPropertyEnum:
                    var selectedVal = config.get_value(loadedSection, "value", prop.values[prop.valueIndex])
                    for v in prop.values.size():
                        if selectedVal == prop.values[v]:
                            prop.valueIndex = v
                else:
                    prop.value = config.get_value(loadedSection, "value", prop.value)

        #load actions
        elif loadedSection.length()>=2 && loadedSection.substr(0,2)=="a_":
            var action:InputtyAction = getAction(loadedSection.substr(2))
            if action:
                var inputsSize:int = config.get_value(loadedSection, "inputs")
                action.inputs.resize(inputsSize)
                for i in inputsSize:
                    var typ = config.get_value(loadedSection, "type_"+str(i))
                    var loadedInput:InputEvent
                    if typ=="MouseButton":
                        loadedInput = InputEventMouseButton.new()
                        loadedInput.button_index = config.get_value(loadedSection, "button_"+str(i), 0)
                    elif typ=="MIDI":
                        loadedInput = InputEventMIDI.new()
                        loadedInput.channel = config.get_value(loadedSection, "channel_"+str(i), 0)
                        loadedInput.controller_number = config.get_value(loadedSection, "controller_number_"+str(i), 0)
                    elif typ=="Key":
                        loadedInput = InputEventKey.new()
                        loadedInput.keycode = config.get_value(loadedSection, "keycode_"+str(i), 0)
                        loadedInput.physical_keycode = config.get_value(loadedSection, "physical_keycode_"+str(i), 0)
                        loadedInput.unicode = config.get_value(loadedSection, "unicode_"+str(i), 0)
                    elif typ=="JoyButton":
                        loadedInput = InputEventJoypadButton.new()
                        loadedInput.button_index = config.get_value(loadedSection, "button_"+str(i), 0)
                    elif typ=="JoyMotion":
                        loadedInput = InputEventJoypadMotion.new()
                        loadedInput.axis = config.get_value(loadedSection, "axis_"+str(i), 0)
                        loadedInput.axis_value = config.get_value(loadedSection, "axis_value_"+str(i), 1)
                    else:# typ=="NULL":
                        loadedInput = null
                        pass
                    action.inputs[i] = loadedInput

    return OK
