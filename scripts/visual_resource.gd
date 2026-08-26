class_name VisualResource
extends Resource

@export
var key: String

@export
var texture: Texture2D

@export
var sprite_frames: SpriteFrames

## Whether this visual resource is a default, built-in visual resource, and not
## loaded externally.
@export
var is_built_in: bool

## Whether this visual resource doesn't have a texture or sprite frames attached.
var is_empty: bool:
    get: return texture == null and sprite_frames == null
