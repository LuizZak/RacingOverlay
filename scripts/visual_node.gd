@tool
class_name VisualNode
extends Node2D

@export
var key: StringName:
    set(value):
        key = value
        refresh_display()

@onready
var sprite: Sprite2D = $Sprite
@onready
var animated_sprite: AnimatedSprite2D = $AnimatedSprite

func _ready() -> void:
    refresh_display()

func refresh_display():
    if sprite == null or animated_sprite == null:
        return

    var visual_resource = resource_loader().load_as_resource(key)

    if visual_resource.sprite_frames != null:
        sprite.visible = false
        animated_sprite.visible = true

        animated_sprite.sprite_frames = visual_resource.sprite_frames
        animated_sprite.play("default")
    else:
        sprite.visible = true
        animated_sprite.visible = false

        sprite.texture = visual_resource.texture

func resource_loader() -> CustomResourceLoader:
    return CustomResourceLoader.new()
