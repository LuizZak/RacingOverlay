@tool
class_name VisualNode
extends Node2D

@export
var key: StringName:
    set(value):
        key = value
        refresh_display()

var visual_theme: VisualTheme:
    set(value):
        visual_theme = value
        refresh_display()

@onready
var sprite: Sprite2D = $Sprite
@onready
var animated_sprite: AnimatedSprite2D = $AnimatedSprite

func _ready() -> void:
    refresh_display()

func refresh_display() -> void:
    if sprite == null or animated_sprite == null or key == &"":
        return

    if Engine.is_editor_hint():
        sprite.visible = true
        animated_sprite.visible = false

        sprite.texture = VisualResourceLibrary.load_default_texture(key)
        return

    var visual_resource: VisualResource

    if visual_theme != null:
        visual_resource = visual_theme.load_resource(key)
    else:
        visual_resource = VisualTheme.built_in_theme().load_resource(key)

    if visual_resource.sprite_frames != null:
        sprite.visible = false
        animated_sprite.visible = true

        animated_sprite.sprite_frames = visual_resource.sprite_frames
        animated_sprite.play(&"default")
    else:
        sprite.visible = true
        animated_sprite.visible = false

        sprite.texture = visual_resource.texture
