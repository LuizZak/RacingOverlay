## Gives support for detecting power trains from game packets.
class_name PowertrainDetector

# Data extracted from Assetto Corsa Rally:
#
# 'Mini Cooper S 1275' - FF
# 'FIAT 131 Abarth' - FR
# 'Lancia Delta Integrale Evo' - F4
# 'Peugeot 208 Rally4' - FF
# 'Hyundai i20N Rally2' - F4
# 'Alfa_Romeo_GTA' - FR
# 'FIAT Abarth 124 Rally' - FR
# 'Alpine_A110' - RR
# 'Lancia 037' - MR
# 'Lancia Stratos HF' - MR
# 'Citroen Xsara WRC' - F4

## Attempts to detect the power train layout from a given game packet, returning
## `null` if none could be detected.
static func detect(packet: GamePacketBase) -> PowertrainLayout:
    if packet is ACRallyGamePacket:
        match packet.car_model:
            "Mini Cooper S 1275":
                return PowertrainLayout.FF
            "FIAT 131 Abarth":
                return PowertrainLayout.FR
            "Lancia Delta Integrale Evo":
                return PowertrainLayout.F4
            "Peugeot 208 Rally4":
                return PowertrainLayout.FF
            "Hyundai i20N Rally2":
                return PowertrainLayout.F4
            "Alfa_Romeo_GTA":
                return PowertrainLayout.FR
            "FIAT Abarth 124 Rally":
                return PowertrainLayout.FR
            "Alpine_A110":
                return PowertrainLayout.RR
            "Lancia 037":
                return PowertrainLayout.MR
            "Lancia Stratos HF":
                return PowertrainLayout.MR
            "Citroen Xsara WRC":
                return PowertrainLayout.F4
            _:
                return null

    return null
