class_name StringUtils

## Returns a copy of the input string, with the first character uppercased.
##
## In case the first character of the string is not a capitalizable character, no
## change is made and the output is the same as the input.
static func uppercased_first(value: String) -> String:
    if value.is_empty():
        return value

    return value[0].to_upper() + value.substr(1)

## Prepares an action name making it human readable by splitting at the undescores
## and re-joining with capitalization.
static func prepare_action_name(action_name: String) -> String:
    var components := action_name.split("_")
    for i in range(components.size()):
        components[i] = StringUtils.uppercased_first(components[i])

    return " ".join(components)
