## Describes the layout of a car's engine and power train.
class_name PowertrainLayout

## Front-engine, front-wheel drive
static var FF := PowertrainLayout.new(EngineLayout.Front, DriveTrain.FrontWheelDrive)
## Front-engine, rear-wheel drive
static var FR := PowertrainLayout.new(EngineLayout.Front, DriveTrain.RearWheelDrive)
## Front-engine, all-wheel drive
static var F4 := PowertrainLayout.new(EngineLayout.Front, DriveTrain.AllWheelDrive)
## Mid-engine, rear-wheel drive
static var MR := PowertrainLayout.new(EngineLayout.Mid, DriveTrain.RearWheelDrive)
## Rear-engine, rear-wheel drive
static var RR := PowertrainLayout.new(EngineLayout.Rear, DriveTrain.RearWheelDrive)

enum EngineLayout {
    Front,
    Mid,
    Rear
}

enum DriveTrain {
    FrontWheelDrive,
    RearWheelDrive,
    AllWheelDrive,
}

var engine_layout: EngineLayout
var drive_train: DriveTrain

@warning_ignore("shadowed_variable")
func _init(engine_layout: EngineLayout, drive_train: DriveTrain) -> void:
    self.engine_layout = engine_layout
    self.drive_train = drive_train

## Whether this powertrain layout drives the front wheels.
func drives_front_wheels() -> bool:
    match drive_train:
        DriveTrain.FrontWheelDrive:
            return true
        DriveTrain.AllWheelDrive:
            return true
        _:
            return false

## Whether this powertrain layout drives the rear wheels.
func drives_rear_wheels() -> bool:
    match drive_train:
        DriveTrain.RearWheelDrive:
            return true
        DriveTrain.AllWheelDrive:
            return true
        _:
            return false

## Whether this powertrain layout requires a longitudinal axle running from the
## front to the back in the engine illustration.
func has_longitudinal_axle() -> bool:
    if drive_train == DriveTrain.AllWheelDrive:
        return true
    if engine_layout == EngineLayout.Front and drive_train == DriveTrain.RearWheelDrive:
        return true

    return false

func is_equal(other: PowertrainLayout) -> bool:
    return engine_layout == other.engine_layout and drive_train == other.drive_train
