class_name JianghuChainCatalog
extends RefCounted

# A chain is a physical route through two or three named households. These
# are ordered encounters, not simply ownership checks or passive score buffs.
# The same group of citizens can make a different story in another layout.
# Every recipe has one economic payout and one physical/status consequence.
const CHAINS:Array[Dictionary]=[
    {"id":"unpaid_banquet","name":"THE UNPAID BANQUET","steps":["tea","inn"],"action":"drunk","power":185,"silver":145},
    {"id":"cup_over_mountain","name":"A CUP OVER THE MOUNTAIN","steps":["inn","drunken"],"action":"spring","power":310,"silver":180},
    {"id":"pawn_of_the_road","name":"THE CARAVAN PAWNS THE ROAD","steps":["caravan","broker"],"action":"cargo","power":145,"silver":265},
    {"id":"rice_of_a_thousand","name":"A THOUSAND BOWLS OF RICE","steps":["rice","merchant"],"action":"copper","power":120,"silver":175},
    {"id":"bell_with_no_abbot","name":"THE BELL SUMMONS A MONK","steps":["bell","monk"],"action":"blessing","power":260,"silver":155},
    {"id":"nine_staff_answer","name":"THE NINE STAFF ANSWER","steps":["monk","abbot"],"action":"spring","power":340,"silver":235},
    {"id":"lion_drum","name":"THE LION SWALLOWS THE DRUM","steps":["gong","drum"],"action":"copper","power":170,"silver":190},
    {"id":"festival_of_legs","name":"TEN THOUSAND FESTIVAL LEGS","steps":["lantern","lion"],"action":"paper","power":150,"silver":175},
    {"id":"face_at_the_inn","name":"THE FACE LEFT AT THE THEATRE","steps":["opera","mask"],"action":"ambush","power":225,"silver":185},
    {"id":"sixth_hidden_blade","name":"THE SIXTH HIDDEN BLADE","steps":["mask","assassin"],"action":"iron","power":230,"silver":245},
    {"id":"costume_trap","name":"THE BRIDE FALLS THROUGH THE STAGE","steps":["costume","trap"],"action":"flip","power":280,"silver":240},
    {"id":"incorrect_finale","name":"THE WRONG FIREWORK FINALE","steps":["firework","opera"],"action":"rain","power":195,"silver":165},
    {"id":"door_for_unpaid_ghost","name":"A GHOST THROUGH THE MOON","steps":["ghost","moon"],"action":"teleport","power":160,"silver":210},
    {"id":"fare_for_a_ghost","name":"THE GHOST PAYS THE RETURN FARE","steps":["ferry","ghost"],"action":"spirit","power":240,"silver":205},
    {"id":"boat_to_heaven","name":"THE BOAT SAILS ABOVE THE MOON","steps":["moon","boat"],"action":"spring","power":330,"silver":205},
    {"id":"ink_on_the_warrant","name":"THE MAGISTRATE ARRESTS HIMSELF","steps":["official","judge"],"action":"exorcise","power":170,"silver":225},
    {"id":"bamboo_steel","name":"BAMBOO BECOMES A BLADE","steps":["bamboo","sword"],"action":"iron","power":220,"silver":205},
    {"id":"fan_in_the_rain","name":"THE FAN SENDS RAIN UPSTREAM","steps":["fan","bamboo"],"action":"lateral","power":290,"silver":185},
    {"id":"umbrella_arrow","name":"THE ARCHER SHOOTS THE RAIN","steps":["umbrella","archer"],"action":"paper","power":165,"silver":210},
    {"id":"stolen_last_page","name":"THE SWORD READS THE LAST PAGE","steps":["sword","manual"],"action":"blessing","power":235,"silver":220},
    {"id":"antidote_invoice","name":"AN INVOICE FOR THE SIXTH POISON","steps":["poison","physician"],"action":"exorcise","power":200,"silver":260},
    {"id":"poison_without_poison","name":"THE GOURD REVERSES THE VENOM","steps":["gourd","poison"],"action":"spirit","power":230,"silver":225},
    {"id":"carp_crossing","name":"THE CARP BUYS THE FERRY","steps":["pond","ferry"],"action":"teleport","power":145,"silver":190},
    {"id":"silk_freight","name":"THE SILK ROAD FOLDS IN HALF","steps":["silk","caravan"],"action":"cargo","power":130,"silver":260},
    {"id":"arrest_the_bandit","name":"THE BANDIT ARRESTS THE LAW","steps":["bandit","judge"],"action":"ambush","power":220,"silver":195},
    {"id":"abacus_court","name":"HEAVEN MISCOUNTS THE COURT","steps":["abacus","official"],"action":"lateral","power":275,"silver":245},
    {"id":"wooden_rebellion","name":"THE WOODEN MAN DEMANDS A MASTER","steps":["dummy","abbot"],"action":"spring","power":305,"silver":220},
    {"id":"mirrored_heaven","name":"THE CLOUD LOOKS IN THE MIRROR","steps":["mirror","cloud"],"action":"paper","power":175,"silver":220},
    {"id":"crooked_supper","name":"THE GAMBLER EATS THE DICE","steps":["noodle","dice"],"action":"drunk","power":185,"silver":205},
    {"id":"relic_for_a_ghost","name":"THE GHOST SELLS ITS OWN RELIC","steps":["relic","ghost"],"action":"spirit","power":250,"silver":245},
    {"id":"three_poison_cures","name":"THE DOCTOR DRINKS ALL SIX POISONS","steps":["poison","gourd","physician"],"action":"exorcise","power":350,"silver":510},
    {"id":"three_silk_receipts","name":"THE CARAVAN'S LAST RECEIPT","steps":["silk","caravan","broker"],"action":"copper","power":240,"silver":525},
    {"id":"three_shadows","name":"THE THREE FACES OF TREASON","steps":["opera","mask","assassin"],"action":"iron","power":320,"silver":550},
    {"id":"three_abbots","name":"THREE BELLS, NO ABBOT","steps":["bell","monk","abbot"],"action":"blessing","power":360,"silver":500},
    {"id":"the_red_ledger","name":"A RECEIPT FOR EVERY GHOST","steps":["ghost","official","judge"],"action":"exorcise","power":345,"silver":520},
    {"id":"the_last_sword","name":"A SWORD BENEATH THE BAMBOO","steps":["fan","bamboo","sword"],"action":"lateral","power":380,"silver":490}
]

static func matches(history:Array[String],completed:Dictionary) -> Array[Dictionary]:
    var result:Array[Dictionary]=[]
    for chain in CHAINS:
        if completed.has(str(chain.id)):continue
        var steps:Array=chain.steps
        if history.size()<steps.size():continue
        var good:bool=true
        for i in range(steps.size()):
            if history[history.size()-steps.size()+i]!=str(steps[i]):
                good=false
                break
        if good:result.append(chain)
    return result

static func hint_for(actor_id:String) -> Dictionary:
    for chain in CHAINS:
        if actor_id in chain.steps:return chain
    return {}

static func synergy(actor_id:String,owned:Array[String]) -> int:
    var value:int=0
    for chain in CHAINS:
        if actor_id not in chain.steps:continue
        for partner in chain.steps:
            if str(partner)!=actor_id and owned.has(str(partner)):
                value+=3
    return mini(18,value)
