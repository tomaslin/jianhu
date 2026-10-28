class_name WorldCatalog
extends RefCounted
const ChainCatalog=preload("res://scripts/chain_catalog.gd")

# Each scroll has a distinct physical modifier, board topology and way to earn.
# Economic values are playable first-pass tuning, never random UI decorations.
const WORLDS: Array[Dictionary] = [
    {"id":"valley", "name":"Dragon Inn Valley", "subtitle":"Commerce follows the pearl", "rule":"Deliver goods through three shops", "mechanic":"trade", "technique":"TABLE-FLIPPING PALM", "bpm":86, "gravity":660.0, "accent":"#A55B42", "ink":"#3A342B", "palette":"#EDE0C9", "quota":1.0, "starters":["inn","tea","merchant"], "pool":["inn","tea","merchant","drunken","broker","caravan","rice","gong","pond","fan","bandit","physician","noodle","dice","lion","manual","umbrella","bridge"]},
    {"id":"monastery", "name":"Hundred Bell Monastery", "subtitle":"Rituals redirect gravity", "rule":"Resonate bells on the beat", "mechanic":"resonance", "technique":"BUDDHA PALM", "bpm":72, "gravity":580.0, "accent":"#71836D", "ink":"#303C35", "palette":"#DEE6D9", "quota":1.07, "starters":["bell","monk","wheel"], "pool":["bell","monk","wheel","gong","fan","physician","mirror","rice","cloud","abacus","lantern","pond","abbot","dummy","drum","gourd","relic"]},
    {"id":"opera", "name":"City of Painted Faces", "subtitle":"Every mask changes a route", "rule":"Stage lights swap identities", "mechanic":"masks", "technique":"FLYING SILK SLEEVE", "bpm":116, "gravity":690.0, "accent":"#AF4D56", "ink":"#493238", "palette":"#ECDDDD", "quota":1.1, "starters":["opera","mask","lantern"], "pool":["opera","mask","lantern","assassin","drunken","broker","mirror","fan","gong","official","ghost","tea","lion","sleeve","costume","trap","firework","drum"]},
    {"id":"ghost", "name":"Nine Bridges Ghost Market", "subtitle":"Debt travels through portals", "rule":"Ghost crossings double and borrow", "mechanic":"portals", "technique":"GHOST STEP", "bpm":94, "gravity":610.0, "accent":"#698998", "ink":"#344550", "palette":"#D9E5E7", "quota":1.12, "starters":["ghost","moon","boat"], "pool":["ghost","moon","boat","lantern","mask","assassin","official","physician","pond","mirror","abacus","tea","ferry","judge","relic","umbrella","bridge"]},
    {"id":"bamboo", "name":"Bamboo Sea of Drifting Swords", "subtitle":"The wind is a second hand", "rule":"Bend reeds to steer pearl arcs", "mechanic":"wind", "technique":"LIGHTNESS STEP", "bpm":104, "gravity":640.0, "accent":"#5D8E78", "ink":"#33483B", "palette":"#E0EBDF", "quota":1.08, "starters":["bamboo","fan","sword"], "pool":["bamboo","fan","sword","monk","wheel","gong","physician","tea","cloud","caravan","rice","pond","umbrella","sleeve","archer","abbot","manual"]},
    {"id":"marsh", "name":"Five Poisons Marsh", "subtitle":"Every cure has a price", "rule":"Corrupt then cleanse for profit", "mechanic":"poison", "technique":"MERIDIAN CLEANSE", "bpm":98, "gravity":520.0, "accent":"#8E7E4E", "ink":"#3C4430", "palette":"#E4E5CF", "quota":1.15, "starters":["poison","physician","pond"], "pool":["poison","physician","pond","ghost","mask","moon","merchant","drunken","boat","gong","bell","abacus","gourd","ferry","relic","noodle","trap"]},
    {"id":"silkroad", "name":"Caravan of the Red Dunes", "subtitle":"Weight makes the journey", "rule":"Loaded pearls slide across shifting sand", "mechanic":"cargo", "technique":"IRON PALM", "bpm":112, "gravity":720.0, "accent":"#B78256", "ink":"#574038", "palette":"#EEDFC5", "quota":1.14, "starters":["caravan","bandit","merchant"], "pool":["caravan","bandit","merchant","inn","broker","sword","fan","rice","gong","official","lantern","drunken","silk","archer","dice","bridge","firework"]},
    {"id":"celestial", "name":"Court of the Celestial Abacus", "subtitle":"Heaven changes the rules", "rule":"The great abacus turns gravity", "mechanic":"abacus", "technique":"HEAVENLY REVERSAL", "bpm":120, "gravity":590.0, "accent":"#B18D58", "ink":"#3E3E49", "palette":"#E9E5D9", "quota":1.2, "starters":["abacus","official","cloud"], "pool":["abacus","official","cloud","mirror","moon","bell","gong","lantern","physician","ghost","sword","caravan","judge","manual","relic","drum","silk"]}
]

# Every card has an effect verb, cost, tags and visual motif. Shared effects can
# combine, but each world restricts its draft pool and introduces its own rule.
const ACTORS: Array[Dictionary] = [
    {"id":"inn","name":"Dragon Inn","short":"Drunk pearls pay double","kind":"roof","tags":["trade","wine"],"cost":120,"earn":48},
    {"id":"tea","name":"Wine Jar","short":"Makes a pearl drunk","kind":"jar","tags":["wine"],"cost":90,"earn":20},
    {"id":"merchant","name":"Rice Merchant","short":"Earns on every trade","kind":"coins","tags":["trade"],"cost":140,"earn":50},
    {"id":"drunken","name":"Drunken Master","short":"A wild returning kick","kind":"figure","tags":["wine","martial"],"cost":260,"earn":35},
    {"id":"broker","name":"Pawn Broker","short":"Cashes carried cargo","kind":"coins","tags":["trade","official"],"cost":290,"earn":65},
    {"id":"caravan","name":"Caravan Gate","short":"Loads the pearl with goods","kind":"gate","tags":["cargo","trade"],"cost":240,"earn":40},
    {"id":"rice","name":"Rice Mill","short":"Spins for a coin shower","kind":"wheel","tags":["trade","water"],"cost":180,"earn":35},
    {"id":"gong","name":"Bronze Gong","short":"Pulses on a strong beat","kind":"bell","tags":["bell","martial"],"cost":220,"earn":65},
    {"id":"pond","name":"Carp Pond","short":"Turns pearls into fish","kind":"fish","tags":["water","fish"],"cost":190,"earn":30},
    {"id":"fan","name":"Iron Fan Adept","short":"Pushes pearls sideways","kind":"fan","tags":["wind","martial"],"cost":180,"earn":42},
    {"id":"bandit","name":"Bandit Toll","short":"Banks silver for the wanted","kind":"mask","tags":["outlaw","trade"],"cost":170,"earn":50},
    {"id":"physician","name":"Traveling Physician","short":"Cures poison and curses","kind":"healer","tags":["heal","martial"],"cost":190,"earn":50},
    {"id":"bell","name":"Shaolin Bell","short":"Calls a prayer pearl","kind":"bell","tags":["bell","orthodox"],"cost":310,"earn":88},
    {"id":"monk","name":"Shaolin Monk","short":"Blesses a visiting pearl","kind":"figure","tags":["orthodox","martial"],"cost":200,"earn":45},
    {"id":"wheel","name":"Wudang Wheel","short":"Reverses a pearl's gravity","kind":"wheel","tags":["water","orthodox"],"cost":280,"earn":60},
    {"id":"mirror","name":"Moon Mirror","short":"Copies a recent blessing","kind":"moon","tags":["spirit"],"cost":330,"earn":55},
    {"id":"cloud","name":"Cloud Stair","short":"Floats paper pearls uphill","kind":"cloud","tags":["spirit","route"],"cost":290,"earn":65},
    {"id":"lantern","name":"Red Lantern","short":"Releases bright paper pearls","kind":"lantern","tags":["fire","spirit"],"cost":230,"earn":50},
    {"id":"opera","name":"Opera House","short":"Applause lifts the pearl","kind":"mask","tags":["mask","trade"],"cost":250,"earn":60},
    {"id":"mask","name":"Mask Painter","short":"Swaps a pearl's allegiance","kind":"mask","tags":["mask"],"cost":220,"earn":30},
    {"id":"assassin","name":"Masks of Death","short":"Marks a lucrative bounty","kind":"swords","tags":["outlaw","mask"],"cost":390,"earn":78},
    {"id":"official","name":"Dream Magistrate","short":"Taxes and stamps receipts","kind":"seal","tags":["official"],"cost":330,"earn":95},
    {"id":"ghost","name":"Ghost Market","short":"Doubles cursed earnings","kind":"ghost","tags":["spirit","trade"],"cost":450,"earn":80},
    {"id":"moon","name":"Moon Gate","short":"Teleports to its twin","kind":"gate","tags":["spirit","route"],"cost":390,"earn":25},
    {"id":"boat","name":"Paper Boat","short":"Ferries pearls upstream","kind":"boat","tags":["water","spirit"],"cost":260,"earn":40},
    {"id":"bamboo","name":"Bamboo Swordsman","short":"Bends wind into a spring","kind":"bamboo","tags":["wind","martial"],"cost":200,"earn":40},
    {"id":"sword","name":"Sword Pavilion","short":"Shoots a silver swordburst","kind":"swords","tags":["martial"],"cost":360,"earn":72},
    {"id":"poison","name":"Five Poisons Master","short":"Spreads rich but risky venom","kind":"poison","tags":["outlaw","poison"],"cost":350,"earn":90},
    {"id":"abacus","name":"Celestial Abacus","short":"Multiplies every fourth impact","kind":"beads","tags":["official","spirit"],"cost":480,"earn":90},
    {"id":"noodle","name":"Noodle Stall","short":"Feeds a travelling drunk","kind":"stall","tags":["trade","wine"],"cost":130,"earn":48},
    {"id":"dice","name":"Crooked Dice Den","short":"Gambles on odd-numbered hits","kind":"dice","tags":["trade","outlaw"],"cost":210,"earn":65},
    {"id":"umbrella","name":"Umbrella Swordswoman","short":"Parries toward the next rooftop","kind":"umbrella","tags":["martial","wind"],"cost":230,"earn":65},
    {"id":"lion","name":"Lion Dance Troupe","short":"Drumbeat launches a second act","kind":"lion","tags":["martial","trade"],"cost":280,"earn":55},
    {"id":"bridge","name":"Bridge Carpenter","short":"Builds an actual bouncing roof","kind":"bridge","tags":["trade","route"],"cost":180,"earn":40},
    {"id":"sleeve","name":"Silk Sleeve Acrobat","short":"Turns falling into flight","kind":"sleeve","tags":["martial","mask"],"cost":290,"earn":64},
    {"id":"archer","name":"Rooftop Archer","short":"Fires a paper arrow pearl","kind":"archer","tags":["martial","outlaw"],"cost":330,"earn":78},
    {"id":"manual","name":"Secret Manual Seller","short":"Copies the last status","kind":"manual","tags":["martial","trade"],"cost":260,"earn":50},
    {"id":"judge","name":"Masked Constable","short":"Confiscates wanted bounties","kind":"constable","tags":["official","mask"],"cost":320,"earn":78},
    {"id":"abbot","name":"Nine-Staff Abbot","short":"Strikes upward three times","kind":"staff","tags":["orthodox","martial"],"cost":320,"earn":68},
    {"id":"dummy","name":"Wooden Dummy Hall","short":"Repeated contacts ring the hall","kind":"dummy","tags":["orthodox","martial"],"cost":190,"earn":48},
    {"id":"drum","name":"War Drum Procession","short":"Rewards perfectly timed impacts","kind":"drum","tags":["bell","martial"],"cost":290,"earn":67},
    {"id":"costume","name":"Opera Costume House","short":"Changes wanted to blessed","kind":"costume","tags":["mask","trade"],"cost":240,"earn":56},
    {"id":"trap","name":"Stage Trapdoor","short":"Flings a pearl into the balcony","kind":"trapdoor","tags":["mask","route"],"cost":230,"earn":43},
    {"id":"ferry","name":"Old Ferryman","short":"Carries a pearl across town","kind":"ferry","tags":["water","trade"],"cost":220,"earn":53},
    {"id":"relic","name":"Jade Relic Dealer","short":"Blesses cursed merchandise","kind":"relic","tags":["trade","spirit"],"cost":340,"earn":83},
    {"id":"gourd","name":"Medicine Gourd","short":"Cures and grants upward lift","kind":"gourd","tags":["heal","water"],"cost":210,"earn":51},
    {"id":"firework","name":"Firecracker Alley","short":"A slapstick blast redirects all","kind":"firework","tags":["fire","trade"],"cost":290,"earn":72},
    {"id":"silk","name":"Silk Road Warehouse","short":"Doubles cargo carried through","kind":"warehouse","tags":["cargo","trade"],"cost":370,"earn":83}
]

static func world(index: int) -> Dictionary:
    return WORLDS[clampi(index, 0, WORLDS.size() - 1)]

static func actor(actor_id: String) -> Dictionary:
    for data in ACTORS:
        if data.id == actor_id:
            return data
    return {"id":"stone","name":"Stone","short":"A humble pebble","kind":"stone","tags":[],"cost":0,"earn":10}

static func offers(index: int, owned: Array[String], rng: RandomNumberGenerator) -> Array[String]:
    var options: Array[String] = []
    var pool: Array = world(index).pool.duplicate()
    # Three distinct roles in the draft: a potential partner for the town's
    # existing chain routes, a less familiar discipline, and a wild arrival.
    # This is deliberately seeded so a run is reproducible by its RNG state.
    var familiar_tags:Dictionary={}
    for owned_id in owned:
        for tag in actor(owned_id).tags:familiar_tags[str(tag)]=true
    for slot in range(mini(3,pool.size())):
        var weights:Array[int]=[]
        var sum_weights:int=0
        for candidate in pool:
            var info:Dictionary=actor(str(candidate))
            var synergy_score:int=ChainCatalog.synergy(str(candidate),owned)
            var novelty:int=0
            for tag in info.tags:
                if not familiar_tags.has(str(tag)):novelty+=1
            var weight:int=12
            if slot==0:weight+=synergy_score*5
            elif slot==1:weight+=novelty*9+synergy_score
            else:weight+=synergy_score*2+novelty*2
            if owned.has(str(candidate)):weight=maxi(2,weight/3)
            weights.append(weight)
            sum_weights+=weight
        var draw:int=rng.randi_range(0,sum_weights-1)
        var chosen_index:int=0
        for i in range(pool.size()):
            draw-=weights[i]
            if draw<0:
                chosen_index=i
                break
        options.append(str(pool[chosen_index]))
        pool.remove_at(chosen_index)
    return options

