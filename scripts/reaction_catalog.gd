class_name JianghuReactionCatalog
extends RefCounted

# A second, independently conditional move for every one of the 48 identities.
# The first behavior is the signature action in main.gd. This "secret form"
# fires only when its authored condition occurs; it also names the actor's
# mastery evolution. Position, direction, tempo, economics and relationships
# matter in ways that an unconditional score bump cannot express.
const REACTIONS:Dictionary={
    "inn":{"title":"The Unpaid Second Floor","when":"from_below","action":"push_up","power":200,"ascension":"Inn of a Hundred Debts"},
    "tea":{"title":"The Bottomless Cellar","when":"third_hit","action":"birth","power":85,"variant":"copper","ascension":"Wine That Remembers"},
    "merchant":{"title":"The Hidden Scale","when":"goods","action":"award","power":175,"ascension":"Merchant of Three Kingdoms"},
    "drunken":{"title":"Staggering Step Number Seven","when":"combo12","action":"push_side","power":280,"ascension":"Master of the Missing Footstep"},
    "broker":{"title":"The False Silver Ingot","when":"low_treasury","action":"award","power":185,"ascension":"The Pawnshop Has the Last Word"},
    "caravan":{"title":"The Unloaded Cart","when":"from_below","action":"push_up","power":190,"ascension":"Caravan Across the Clouds"},
    "rice":{"title":"Rice for the Fallen","when":"even_hit","action":"birth","power":60,"variant":"copper","ascension":"Mill of Endless Harvests"},
    "gong":{"title":"The Wrong Funeral","when":"offbeat","action":"award","power":110,"ascension":"The Gong That Rang Twice"},
    "pond":{"title":"A Fish Knows the Way","when":"slow_speed","action":"push_side","power":210,"ascension":"The Carp Ascends the Gate"},
    "fan":{"title":"Silk Behind the Blade","when":"from_below","action":"push_up","power":220,"ascension":"Fan That Turned a River"},
    "bandit":{"title":"The Tollkeeper's Cousin","when":"wanted","action":"award","power":190,"ascension":"Most Wanted Under Heaven"},
    "physician":{"title":"The Doctor's Invoice","when":"high_debt","action":"debt_down","power":85,"ascension":"Physician of the Impossible Pulse"},
    "bell":{"title":"One Breath, Three Bells","when":"onbeat","action":"push_up","power":245,"ascension":"One Hundred Bells as One"},
    "monk":{"title":"The Iron Shirt","when":"high_speed","action":"push_up","power":190,"ascension":"Arhat of the Open Palm"},
    "wheel":{"title":"Water Walking","when":"ascending","action":"award","power":155,"ascension":"Wheel Without an Axle"},
    "mirror":{"title":"A Thousand False Moons","when":"cursed","action":"birth","power":85,"variant":"ghost","ascension":"Mirror of All Reflections"},
    "cloud":{"title":"The Ninth Cloud Stair","when":"descending","action":"push_up","power":200,"ascension":"Staircase Above Heaven"},
    "lantern":{"title":"The Festival That Never Ends","when":"third_hit","action":"birth","power":70,"variant":"paper","ascension":"Lantern of Ten Thousand Doors"},
    "opera":{"title":"A Role With No Actor","when":"wanted","action":"award","power":175,"ascension":"Opera House of Missing Faces"},
    "mask":{"title":"The Face Beneath","when":"blessed","action":"status","power":50,"status":"wanted","ascension":"Painter of a Thousand Faces"},
    "assassin":{"title":"The Sixth Hidden Blade","when":"combo12","action":"birth","power":100,"variant":"iron","ascension":"The Blade Nobody Saw"},
    "official":{"title":"A Receipt for the Moon","when":"high_debt","action":"debt_up","power":75,"ascension":"Magistrate of the Last Signature"},
    "ghost":{"title":"The Unpaid Ancestor","when":"from_below","action":"award","power":205,"ascension":"Market Open After Death"},
    "moon":{"title":"Walking Through a Door's Shadow","when":"ascending","action":"push_side","power":240,"ascension":"Moon Gate of No Return"},
    "boat":{"title":"The Fourth Oar","when":"slow_speed","action":"push_up","power":205,"ascension":"Boat That Sailed Over Land"},
    "bamboo":{"title":"The Leaf-Edge Sword","when":"onbeat","action":"birth","power":90,"variant":"iron","ascension":"Swordsman Who Weighed Nothing"},
    "sword":{"title":"The Sword Seeks Its Master","when":"from_below","action":"push_up","power":250,"ascension":"Pavilion of Wandering Blades"},
    "poison":{"title":"The Sixth Poison","when":"high_debt","action":"award","power":210,"ascension":"Master of the Poisonless Venom"},
    "abacus":{"title":"An Error in Heaven's Books","when":"combo12","action":"award","power":255,"ascension":"The Abacus Counts the Stars"},
    "noodle":{"title":"The Last Bowl Is Free","when":"drunk","action":"award","power":170,"ascension":"Noodle Shop at the End of the Road"},
    "dice":{"title":"Loaded on Both Sides","when":"even_hit","action":"award","power":225,"ascension":"The House Always Cheats"},
    "umbrella":{"title":"Shelter From Sword Rain","when":"high_speed","action":"push_side","power":300,"ascension":"Umbrella That Stopped the Storm"},
    "lion":{"title":"The Lion Swallows a Drum","when":"onbeat","action":"birth","power":100,"variant":"copper","ascension":"Lion of a Thousand Feet"},
    "bridge":{"title":"The Carpenter Has No Nails","when":"ascending","action":"push_side","power":190,"ascension":"The Bridge That Built Itself"},
    "sleeve":{"title":"A Sleeve Longer Than Heaven","when":"from_below","action":"push_up","power":290,"ascension":"The Vanishing Silk Acrobat"},
    "archer":{"title":"An Arrow Chasing Its Shadow","when":"left_lane","action":"birth","power":80,"variant":"paper","ascension":"Archer of the Last Rooftop"},
    "manual":{"title":"The Missing Final Page","when":"manual","action":"award","power":215,"ascension":"Manual Nobody Could Read"},
    "judge":{"title":"The Arresting Officer Is Wanted","when":"wanted","action":"debt_down","power":95,"ascension":"Constable of Seventy Writs"},
    "abbot":{"title":"The Staff Between Breaths","when":"onbeat","action":"push_up","power":285,"ascension":"Abbot of the Ninth Hall"},
    "dummy":{"title":"The Wooden Man Complains","when":"third_hit","action":"award","power":245,"ascension":"Dummy That Passed the Examination"},
    "drum":{"title":"A Drumbeat Fights Back","when":"offbeat","action":"push_up","power":175,"ascension":"War Drum of the Silent Army"},
    "costume":{"title":"Even the Villain Needs a Tailor","when":"wanted","action":"status","power":120,"status":"blessed","ascension":"The Costume That Chose Its Actor"},
    "trap":{"title":"The Balcony Below the Stage","when":"from_below","action":"push_up","power":300,"ascension":"Trapdoor to the Highest Floor"},
    "ferry":{"title":"The Return Fare","when":"goods","action":"award","power":200,"ascension":"Ferryman of the Nine Rivers"},
    "relic":{"title":"The Forged Jade Is Real","when":"cursed","action":"status","power":180,"status":"blessed","ascension":"Relic Dealer of a Thousand Truths"},
    "gourd":{"title":"One More Unwritten Prescription","when":"poison","action":"debt_down","power":115,"ascension":"Gourd Containing All Medicine"},
    "firework":{"title":"The Wrong Fuse","when":"combo12","action":"birth","power":120,"variant":"copper","ascension":"Alley of the Endless Festival"},
    "silk":{"title":"The Red Road to Nowhere","when":"goods","action":"award","power":250,"ascension":"Warehouse That Owned the Road"}
}

static func mastery_level(activation_count:int) -> int:
    if activation_count>=40:return 3
    if activation_count>=18:return 2
    if activation_count>=6:return 1
    return 0

static func condition(rule:String,actor:Node2D,pearl:RigidBody2D,main:Node2D,onbeat:bool) -> bool:
    match rule:
        "onbeat":return onbeat
        "offbeat":return not onbeat
        "even_hit":return int(actor.activation_count)%2==0
        "third_hit":return int(actor.activation_count)%3==0
        "combo12":return int(main.combo_count)>=12
        "from_above":return pearl.linear_velocity.y>0
        "from_below":return pearl.linear_velocity.y<0
        "ascending":return pearl.linear_velocity.y<0
        "descending":return pearl.linear_velocity.y>=0
        "left_lane":return pearl.position.x<195
        "right_lane":return pearl.position.x>=195
        "slow_speed":return pearl.linear_velocity.length()<250
        "high_speed":return pearl.linear_velocity.length()>360
        "low_treasury":return int(main.treasury)<int(main.current_tribute())
        "high_debt":return int(main.debt)>0
        "drunk","blessed","cursed","wanted","goods","poison","manual":
            return pearl.statuses.has(rule)
    return false

static func apply(actor:Node2D,pearl:RigidBody2D,main:Node2D,onbeat:bool) -> int:
    var definition:Dictionary=REACTIONS.get(str(actor.data.id),{})
    if definition.is_empty():return 0
    if not condition(str(definition.when),actor,pearl,main,onbeat):return 0
    var power:int=int(definition.power)
    var level:int=mastery_level(int(actor.activation_count))
    var boost:float=1.0+.19*level
    var value:int=int(round(power*boost))
    match str(definition.action):
        "award":return value
        "push_up":
            pearl.apply_central_impulse(Vector2(0,-value))
            return int(value*.37)
        "push_side":
            var sign=1 if pearl.position.x<195 else -1
            pearl.apply_central_impulse(Vector2(sign*value,-value*.28))
            return int(value*.34)
        "birth":
            main._queue_spawn(actor.position+Vector2(0,-22),Vector2(main.rng.randf_range(-130,130),-170),str(definition.variant),pearl.chain_id,"secret "+str(actor.data.id))
            return value
        "status":
            pearl.set_status(str(definition.status),5+level)
            return value
        "debt_down":
            main.debt=maxi(0,int(main.debt)-value)
            return int(value*.65)
        "debt_up":
            main.debt+=int(value*.24)
            return value
    return 0
