## A series of `PackedByteArray` helper functions for encoding/decoding data.
class_name PbaHelpers

## Encodes a fixed-length ASCII string into a given `PackedByteArray` at a given
## offset. The rest of the bytes, if `string` is shorter than `size`, are filled
## with zeroes. If `string` is longer than `size`, only the bytes up to `size`
## are encoded.
##
## Note: Assumes `data` is at least as long as `offset + size`.
static func encode_fixed_length_ascii(data: PackedByteArray, string: String, offset: int, size: int) -> void:
    var ascii := string.to_ascii_buffer().slice(0, size)

    var i := 0

    while i < ascii.size():
        var byte := ascii[i]
        data[offset + i] = byte
        i += 1

    while i < size:
        data[i] = 0
        i += 1
