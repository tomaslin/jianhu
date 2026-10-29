extends RefCounted

# The atlas keeps nine illustrated people on transparent, equal-sized tiles.
const ART = preload("res://assets/companion_portraits.png")

static func index_for(id:String) -> int:
    match id:
        "noodle": return 0
        "umbrella", "fan", "bamboo", "archer": return 1
        "monk", "abbot": return 2
        "mask", "sleeve", "lion": return 3
        "ghost": return 4
        "physician", "poison": return 5
        "merchant", "broker", "manual", "relic", "ferry": return 6
        "drunken", "assassin": return 7
        "official", "judge": return 8
    return -1

static func region(index:int) -> Rect2:
    var size:Vector2=ART.get_size()/3.0
    return Rect2(Vector2(float(index%3)*size.x, float(index/3)*size.y),size)
