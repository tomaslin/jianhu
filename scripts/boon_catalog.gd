class_name JianghuBoonCatalog
extends RefCounted

# Fifty-six independent rule amendments, not cosmetics. Four are offered as
# rewards across the five-tribute campaign; the selected rules can profoundly
# alter any of the 48 citizens and the routes that connect them.
# family: sect/status/lane/rhythm/summon/motion/economy.
const BOONS:Array[Dictionary]=[
    {"id":"rice_futures","name":"Rice Futures","short":"Trade hits pay 95 extra taels","family":"sect","target":"trade","value":95,"rarity":1},
    {"id":"sword_royalties","name":"A Sword for Every Receipt","short":"Martial hits pay 88 extra taels","family":"sect","target":"martial","value":88,"rarity":1},
    {"id":"abbots_favor","name":"The Abbot's Favor","short":"Orthodox hits pay 110 extra taels","family":"sect","target":"orthodox","value":110,"rarity":1},
    {"id":"bandit_union","name":"Bandit Union Dues","short":"Outlaw hits pay 125 extra taels","family":"sect","target":"outlaw","value":125,"rarity":2},
    {"id":"ancestor_receipts","name":"Ancestor Receipts","short":"Spirit hits pay 135 extra taels","family":"sect","target":"spirit","value":135,"rarity":2},
    {"id":"opera_sponsorship","name":"Opera Sponsorship","short":"Mask hits pay 115 extra taels","family":"sect","target":"mask","value":115,"rarity":1},
    {"id":"ferry_contract","name":"Ferry Contract","short":"Water hits pay 105 extra taels","family":"sect","target":"water","value":105,"rarity":1},
    {"id":"imperial_stipend","name":"Imperial Stipend","short":"Official hits pay 145 extra taels","family":"sect","target":"official","value":145,"rarity":3},

    {"id":"bottomless_flask","name":"Bottomless Flask","short":"Drunk pearls earn 96 extra on impact","family":"status","target":"drunk","value":96,"rarity":1},
    {"id":"sutra_echo","name":"Sutra Echo","short":"Blessed pearls earn 110 extra","family":"status","target":"blessed","value":110,"rarity":2},
    {"id":"ghost_dividend","name":"Ghost Dividend","short":"Cursed pearls earn 185 extra","family":"status","target":"cursed","value":185,"rarity":3},
    {"id":"wanted_poster","name":"Wanted Poster","short":"Wanted pearls earn 148 extra","family":"status","target":"wanted","value":148,"rarity":2},
    {"id":"cargo_insurance","name":"Cargo Insurance","short":"Loaded pearls earn 123 extra","family":"status","target":"goods","value":123,"rarity":1},
    {"id":"venom_dividend","name":"Venom Dividend","short":"Poisoned pearls earn 140 extra","family":"status","target":"poison","value":140,"rarity":2},
    {"id":"manual_copyright","name":"Manual Copyright Office","short":"Copied techniques earn 125 extra","family":"status","target":"manual","value":125,"rarity":2},
    {"id":"carp_king","name":"The Carp King's Tax","short":"Fish pearls earn 160 extra","family":"status","target":"fish","value":160,"rarity":3},

    {"id":"rooftop_rent","name":"Rooftop Rent","short":"Hits above the third street pay 96","family":"lane","target":"top","value":96,"rarity":1},
    {"id":"cellar_hoard","name":"Cellar Hoard","short":"Low city hits pay 135 extra","family":"lane","target":"bottom","value":135,"rarity":2},
    {"id":"west_gate","name":"West Gate Customs","short":"Left-side hits pay 100 extra","family":"lane","target":"left","value":100,"rarity":1},
    {"id":"east_gate","name":"East Gate Customs","short":"Right-side hits pay 100 extra","family":"lane","target":"right","value":100,"rarity":1},
    {"id":"border_patrol","name":"Border Patrol","short":"Hits at the rim pay 145 extra","family":"lane","target":"edge","value":145,"rarity":2},
    {"id":"central_court","name":"Central Court License","short":"Center hits pay 120 extra","family":"lane","target":"center","value":120,"rarity":2},
    {"id":"ascending_kick","name":"Ascending Kick","short":"Upward hits pay 125 extra","family":"lane","target":"ascending","value":125,"rarity":2},
    {"id":"falling_plum","name":"Falling Plum Blossom","short":"Descending hits pay 80 extra","family":"lane","target":"descending","value":80,"rarity":1},

    {"id":"thunder_downbeat","name":"Thunder Downbeat","short":"Any on-beat hit earns 128 more","family":"rhythm","target":"onbeat","value":128,"rarity":1},
    {"id":"drunk_syncopation","name":"Drunk Syncopation","short":"Off-beat hits are worth 74 more","family":"rhythm","target":"offbeat","value":74,"rarity":1},
    {"id":"third_bell","name":"Third Bell Discipline","short":"Rhythm chains of 3 earn 128 more","family":"rhythm","target":"streak3","value":128,"rarity":2},
    {"id":"fifth_palm","name":"Fifth Palm Secret","short":"Rhythm chains of 5 earn 210 more","family":"rhythm","target":"streak5","value":210,"rarity":3},
    {"id":"odd_procession","name":"Odd-Beat Procession","short":"Odd beats pay 95 extra","family":"rhythm","target":"oddbeat","value":95,"rarity":1},
    {"id":"fourth_drumming","name":"Fourth-Beat Drumming","short":"Every fourth beat pays 180 extra","family":"rhythm","target":"downbeat4","value":180,"rarity":2},
    {"id":"fifteen_strikes","name":"Fifteen Strikes","short":"Combos of 15+ earn 150 more","family":"rhythm","target":"combo15","value":150,"rarity":2},
    {"id":"thirtieth_strike","name":"Thirty Strikes of Mercy","short":"Combos of 30+ earn 240 more","family":"rhythm","target":"combo30","value":240,"rarity":3},

    {"id":"paper_martyrs","name":"Paper Martyrs","short":"Every fourth martial hit births a paper pearl","family":"summon","target":"martial","value":4,"rarity":2},
    {"id":"market_children","name":"Market Children","short":"Every fifth trade hit births a copper pearl","family":"summon","target":"trade","value":5,"rarity":2},
    {"id":"temple_echoes","name":"Temple Echoes","short":"Every fourth orthodox hit births a prayer pearl","family":"summon","target":"orthodox","value":4,"rarity":2},
    {"id":"ghost_pilgrims","name":"Ghost Pilgrims","short":"Every third spirit hit births a ghost pearl","family":"summon","target":"spirit","value":3,"rarity":3},
    {"id":"masked_understudies","name":"Masked Understudies","short":"Every fourth mask hit births a paper pearl","family":"summon","target":"mask","value":4,"rarity":2},
    {"id":"river_fry","name":"River Fry","short":"Every fourth water hit births a fish pearl","family":"summon","target":"water","value":4,"rarity":2},
    {"id":"illegal_recruits","name":"Illegal Recruits","short":"Every fifth outlaw hit births an iron pearl","family":"summon","target":"outlaw","value":5,"rarity":3},
    {"id":"imperial_copies","name":"Imperial Copies","short":"Every sixth official hit births a jade pearl","family":"summon","target":"official","value":6,"rarity":2},

    {"id":"east_wind","name":"East Wind Edict","short":"Pearls drift east throughout the day","family":"motion","target":"east","value":80,"rarity":1},
    {"id":"west_wind","name":"West Wind Edict","short":"Pearls drift west throughout the day","family":"motion","target":"west","value":80,"rarity":1},
    {"id":"feather_bones","name":"Feather-Bone Manual","short":"A continuous lightness lift","family":"motion","target":"lift","value":110,"rarity":2},
    {"id":"iron_bones","name":"Iron-Bone Manual","short":"Pearls fall harder, heavy hits pay extra","family":"motion","target":"weight","value":110,"rarity":2},
    {"id":"magnetic_court","name":"Magnetic Court","short":"Pearls drift toward the middle","family":"motion","target":"center","value":96,"rarity":3},
    {"id":"wall_runner","name":"Wall-Running Shoes","short":"Pearls drift toward the near wall","family":"motion","target":"edge","value":87,"rarity":2},
    {"id":"river_friction","name":"River-Silk Slippers","short":"Pearls glide with reduced drag","family":"motion","target":"slippery","value":28,"rarity":1},
    {"id":"stone_sandals","name":"Stone Sandals","short":"Pearls travel deliberately and slowly","family":"motion","target":"sticky","value":18,"rarity":1},

    {"id":"merchant_charter","name":"Merchant Charter","short":"Trade households cost 25% less","family":"economy","target":"discount_trade","value":25,"rarity":1},
    {"id":"temple_charter","name":"Temple Charter","short":"Martial households cost 20% less","family":"economy","target":"discount_martial","value":20,"rarity":1},
    {"id":"royal_rebate","name":"Royal Rebate","short":"All tributes cost 10% less","family":"economy","target":"tribute","value":10,"rarity":3},
    {"id":"extra_permit","name":"Extra Building Permit","short":"Build up to three homes every morning","family":"economy","target":"permit","value":1,"rarity":3},
    {"id":"pawns_certificate","name":"Pawnbroker's Certificate","short":"Selling returns 70% of an actor's cost","family":"economy","target":"sell","value":70,"rarity":2},
    {"id":"tea_endowment","name":"Tea Endowment","short":"Earn 100 taels at each new morning","family":"economy","target":"income","value":100,"rarity":1},
    {"id":"abbey_endowment","name":"Abbey Endowment","short":"Earn 60 per orthodox neighbor at dawn","family":"economy","target":"orthodox_income","value":60,"rarity":2},
    {"id":"debt_amnesty","name":"Debt Amnesty","short":"Half your accumulated debt is forgiven","family":"economy","target":"debt","value":50,"rarity":2}
]

static func boon(boon_id:String) -> Dictionary:
    for data in BOONS:
        if str(data.id)==boon_id:return data
    return {}

static func offers(owned:Array[String],rng:RandomNumberGenerator) -> Array[String]:
    var available:Array[Dictionary]=[]
    for data in BOONS:
        if not owned.has(str(data.id)):available.append(data)
    var chosen:Array[String]=[]
    while chosen.size()<3 and not available.is_empty():
        var candidates:Array[Dictionary]=[]
        var total_weight:int=0
        for data in available:
            var weight=16 if int(data.rarity)==1 else (7 if int(data.rarity)==2 else 2)
            candidates.append({"data":data,"weight":weight})
            total_weight+=weight
        var draw=rng.randi_range(0,total_weight-1)
        var found:Dictionary={}
        for entry in candidates:
            draw-=int(entry.weight)
            if draw<0:
                found=entry.data
                break
        if found.is_empty():break
        chosen.append(str(found.id))
        available.erase(found)
    return chosen
