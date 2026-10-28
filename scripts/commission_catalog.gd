class_name JianghuCommissionCatalog
extends RefCounted

# Optional, readable daily wagers. One may be accepted before launching;
# success is based on things that actually happened to the physical pearl.
# The three choices are different per world, not a recycled global mission.
const WRITS:Array[Dictionary]=[
    {"id":"valley_trade","world":0,"name":"THE RICE TAX","short":"TRADE 5","kind":"trade","target":5,"reward":260,"seals":2},
    {"id":"valley_wine","world":0,"name":"NO SOBER GUESTS","short":"DRUNK 4","kind":"drunk","target":4,"reward":300,"seals":2},
    {"id":"valley_route","world":0,"name":"THE MISSING BANQUET","short":"CHAIN 1","kind":"route","target":1,"reward":510,"seals":3},
    {"id":"abbey_palm","world":1,"name":"FIVE OPEN PALMS","short":"MONK 5","kind":"orthodox","target":5,"reward":280,"seals":2},
    {"id":"abbey_tempo","world":1,"name":"THE CORRECT DOWNBEAT","short":"BEATS 4","kind":"onbeat","target":4,"reward":360,"seals":2},
    {"id":"abbey_combo","world":1,"name":"A SINGLE UNBROKEN BREATH","short":"COMBO 14","kind":"combo","target":14,"reward":480,"seals":3},
    {"id":"opera_masks","world":2,"name":"THREE THOUSAND FACES","short":"MASK 5","kind":"mask","target":5,"reward":310,"seals":2},
    {"id":"opera_outlaws","world":2,"name":"THE VILLAIN IS LATE","short":"WANTED 4","kind":"wanted","target":4,"reward":355,"seals":2},
    {"id":"opera_children","world":2,"name":"A SECOND CAST OF ACTORS","short":"BIRTHS 2","kind":"offspring","target":2,"reward":505,"seals":3},
    {"id":"ghost_cursed","world":3,"name":"THE UNPAID ANCESTORS","short":"CURSED 5","kind":"cursed","target":5,"reward":300,"seals":2},
    {"id":"ghost_route","world":3,"name":"THE BRIDGE THAT MOVED","short":"CHAIN 1","kind":"route","target":1,"reward":535,"seals":3},
    {"id":"ghost_combo","world":3,"name":"TWELVE GHOSTLY DEBTS","short":"COMBO 12","kind":"combo","target":12,"reward":475,"seals":2},
    {"id":"bamboo_martial","world":4,"name":"CUT ALL THE REEDS","short":"SWORD 6","kind":"martial","target":6,"reward":330,"seals":2},
    {"id":"bamboo_beats","world":4,"name":"FOLLOW THE LEAF'S BEAT","short":"BEATS 5","kind":"onbeat","target":5,"reward":370,"seals":2},
    {"id":"bamboo_combo","world":4,"name":"A SWORD NEVER LANDS","short":"COMBO 16","kind":"combo","target":16,"reward":500,"seals":3},
    {"id":"marsh_venom","world":5,"name":"THE FIFTH PILL","short":"POISON 5","kind":"poison","target":5,"reward":350,"seals":2},
    {"id":"marsh_cures","world":5,"name":"THE HEALER'S HONOR","short":"CURES 2","kind":"cure","target":2,"reward":425,"seals":3},
    {"id":"marsh_route","world":5,"name":"THE SIXTH VENOM","short":"CHAIN 1","kind":"route","target":1,"reward":535,"seals":3},
    {"id":"dunes_cargo","world":6,"name":"CROSS THE RED ROAD","short":"GOODS 5","kind":"goods","target":5,"reward":370,"seals":2},
    {"id":"dunes_traders","world":6,"name":"A RECEIPT FOR THE SUNSET","short":"TRADE 6","kind":"trade","target":6,"reward":320,"seals":2},
    {"id":"dunes_route","world":6,"name":"THE LAST CARAVAN RECEIPT","short":"CHAIN 1","kind":"route","target":1,"reward":565,"seals":3},
    {"id":"court_seals","world":7,"name":"THE MAGISTRATE'S INK","short":"COURT 5","kind":"official","target":5,"reward":375,"seals":2},
    {"id":"court_beats","world":7,"name":"HEAVEN'S THIRD CLICK","short":"BEATS 5","kind":"onbeat","target":5,"reward":420,"seals":2},
    {"id":"court_combo","world":7,"name":"THE ABACUS LOSES COUNT","short":"COMBO 16","kind":"combo","target":16,"reward":535,"seals":3}
]

static func for_world(world_index:int) -> Array[Dictionary]:
    var result:Array[Dictionary]=[]
    for writ in WRITS:
        if int(writ.world)==world_index:result.append(writ)
    return result

static func writ(writ_id:String) -> Dictionary:
    for item in WRITS:
        if str(item.id)==writ_id:return item
    return {}

static func target_for(writ_id:String,day:int) -> int:
    var data:Dictionary=writ(writ_id)
    if data.is_empty():return 0
    return int(data.target)+int((day-1)/5)

static func reward_for(writ_id:String,day:int) -> int:
    var data:Dictionary=writ(writ_id)
    if data.is_empty():return 0
    return int(round(float(data.reward)*(1.0+.38*float(day-1))))

static func risk_for(day:int) -> int:
    return 24+maxi(0,day-1)*11
