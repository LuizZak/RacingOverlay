## A luma-chroma-hue encoded color value.
class_name LCH

## Note: 0 - 1
var luma: float
## Note: 0 - 1
var chroma: float
## Note: 0 - 360
var hue: float

func _init(
    luma: float,
    chroma: float,
    hue: float,
) -> void:
    self.luma = luma
    self.chroma = chroma
    self.hue = hue

func _s01_ff(x: float) -> int:
    var x2 := int(x * 0xFF + 0.5)
    return max(0, min(0xFF, x2))

func lerp(to: LCH, weight: float) -> LCH:
    var l1 := LCH.new(luma, chroma, hue)

    l1.chroma += (to.chroma - l1.chroma) * weight
    l1.luma += (to.luma - l1.luma) * weight

    if not is_nan(l1.hue) && not is_nan(to.hue):
        var dhue := to.hue - l1.hue
        if dhue >= 180:
            dhue -= 360
        if dhue < -180:
            dhue += 360
        l1.hue += dhue * weight
        if l1.hue < 0:
            l1.hue += 360
        elif l1.hue >= 360:
            l1.hue -= 360
    elif is_nan(l1.hue):
        l1.hue = to.hue

    return l1

func to_color() -> Color:
    return Color.hex(to_rgb() << 8 | 255)

func to_rgb() -> int:
    var r: float
    var g: float
    var b: float

    if is_nan(hue):
        r = 0.0
        g = 0.0
        b = 0.0
    else:
        var hp := fmod(hue, 360.0) / 60.0
        var hp2 := absf(fmod(hp, 2.0) - 1.0)
        var x := chroma * (1 - hp2)

        var hpi := int(hp)
        if hpi == 0:
            r = chroma
            g = x
            b = 0
        elif hpi == 1:
            r = x
            g = chroma
            b = 0
        elif hpi == 2:
            r = 0
            g = chroma
            b = x
        elif hpi == 3:
            r = 0
            g = x
            b = chroma
        elif hpi == 4:
            r = x
            g = 0
            b = chroma
        else:
            r = chroma
            g = 0
            b = x

    var m := luma - (0.3 * r + 0.59 * g + 0.11 * b)
    r += m
    g += m
    b += m

    return (_s01_ff(r) << 16) | (_s01_ff(g) << 8) | _s01_ff(b)

static func lerp_color(from: Color, to: Color, weight: float) -> Color:
    var l1 := from_color(from)
    var l2 := from_color(to)

    return l1.lerp(l2, weight).to_color()

static func from_color(color: Color) -> LCH:
    var rgb := color.to_rgba32() >> 8
    return from_rgb(rgb)

static func from_rgb(rgb: int) -> LCH:
    var r := float(rgb >> 16) / 0xFF
    var g := float((rgb >> 8) & 0xFF) / 0xFF
    var b := float(rgb & 0xFF) / 0xFF

    var luma := 0.3 * r + 0.59 * g + 0.11 * b

    var max := maxf(r, maxf(g, b))
    var min := minf(r, minf(g, b))

    var chroma := max - min

    var hue: float
    if max == min:
        hue = NAN
    else:
        var im := 1 / (max - min)
        r = (r - min) * im
        g = (g - min) * im
        b = (b - min) * im

        if r == 1:
            hue = 60 * (g - b)
            if hue < 0:
                hue += 360.0
        elif g == 1:
            hue = 120 + 60 * (b - r)
        else:
            hue = 240 + 60 * (r - g)

    return LCH.new(luma, chroma, hue)
