class_name JianghuDistrictSystem
extends RefCounted

# Each actor is a neighbor with allegiances, not an isolated score bumper.
# Two adjacent establishments can establish a business, martial, political,
# medicinal or theatrical relationship. This is the source of the living city's
# emergent streets and location-dependent synergies.

static func rebuild(actors:Array) -> Array[Dictionary]:
    var links:Array[Dictionary]=[]
    for i in range(actors.size()):
        var a=actors[i]
        if not is_instance_valid(a):continue
        for j in range(i+1,actors.size()):
            var b=actors[j]
            if not is_instance_valid(b):continue
            if abs(a.socket.x-b.socket.x)>1 or abs(a.socket.y-b.socket.y)>1:continue
            var kind=relation(a.data,b.data)
            if kind.is_empty():continue
            kind["a"]=a
            kind["b"]=b
            links.append(kind)
    return links

static func relation(a:Dictionary,b:Dictionary) -> Dictionary:
    var ids=[str(a.id),str(b.id)]
    ids.sort()
    var key="|".join(ids)
    match key:
        "drunken|inn", "inn|tea", "drunken|noodle":
            return {"kind":"banquet","name":"The Unpaid Banquet","mult":1.45}
        "gourd|poison", "physician|poison", "gourd|ghost":
            return {"kind":"antidote","name":"The Antidote Racket","mult":1.55}
        "bamboo|sword", "sleeve|sword", "sword|umbrella":
            return {"kind":"flying_school","name":"Flying Sword School","mult":1.5}
        "caravan|silk", "broker|caravan", "broker|silk":
            return {"kind":"freight","name":"Caravan Cartel","mult":1.5}
        "ghost|official", "judge|ghost", "abacus|ghost":
            return {"kind":"night_tax","name":"The Dead Man's Taxes","mult":1.6}
        "assassin|mask", "costume|mask", "assassin|costume":
            return {"kind":"second_face","name":"Second Face Society","mult":1.45}
        "drum|gong", "bell|drum", "drum|lion":
            return {"kind":"drums","name":"Thunder Procession","mult":1.4}
        "abbot|bandit", "assassin|monk", "bandit|monk":
            return {"kind":"rival","name":"Rival Schools","mult":1.5}
        "firework|opera", "opera|trap", "costume|firework":
            return {"kind":"stagecraft","name":"Burning Stage","mult":1.4}
        "ferry|moon", "boat|ferry", "bridge|ferry":
            return {"kind":"crossing","name":"Unlicensed Crossing","mult":1.3}
    var tags_a:Array=a.get("tags",[])
    var tags_b:Array=b.get("tags",[])
    if "outlaw" in tags_a and "orthodox" in tags_b or "orthodox" in tags_a and "outlaw" in tags_b:
        return {"kind":"rival","name":"Rival Schools","mult":1.25}
    for tag in ["trade","orthodox","martial","water","wine","wind","mask","bell","spirit","official","heal","route","cargo"]:
        if tag in tags_a and tag in tags_b:
            return {"kind":"oath","name":"%s Brotherhood"%str(tag).capitalize(),"mult":1.15}
    return {}

static func for_actor(actor:Node,links:Array[Dictionary]) -> Array[Dictionary]:
    var active:Array[Dictionary]=[]
    for link in links:
        if link.a==actor or link.b==actor:active.append(link)
    return active
