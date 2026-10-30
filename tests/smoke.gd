extends SceneTree

# CLI: godot --headless --path . --script res://tests/smoke.gd
const GameScene=preload("res://scenes/main.tscn")
const Catalog=preload("res://scripts/world_catalog.gd")
const District=preload("res://scripts/district_system.gd")
const BoonCatalog=preload("res://scripts/boon_catalog.gd")
const Reactions=preload("res://scripts/reaction_catalog.gd")
const Chains=preload("res://scripts/chain_catalog.gd")
const Writs=preload("res://scripts/commission_catalog.gd")
const Rivals=preload("res://scripts/rival.gd")
const WuxiaText=preload("res://scripts/wuxia_text.gd")
var failures:int=0
var checks:int=0

func _initialize() -> void:
    call_deferred("run_all")

func check(condition:bool,message:String) -> void:
    checks+=1
    if not condition:
        failures+=1
        push_error("CHECK FAILED: "+message)

func run_all() -> void:
    var game=GameScene.instantiate()
    root.add_child(game)
    await process_frame
    check(game.phase=="menu","opens on the illustrated world selector")
    check(game.chinese_font!=null,"the Chinese display font is bundled")
    for i in range(8):
        for simplified in [false,true]:
            var world_name:String=WuxiaText.world(i,simplified)
            var shout:String=WuxiaText.shout(i,simplified)
            for glyph in world_name+shout:
                check(game.chinese_font.has_char(glyph.unicode_at(0)),"Chinese world and comic glyph is available: "+glyph)
    for actor_spec in Catalog.ACTORS:
        for simplified in [false,true]:
            var actor_name:String=WuxiaText.actor(str(actor_spec.id),simplified)
            check(WuxiaText.NAMES.has(str(actor_spec.id)),"every actor has an authored Chinese name: "+str(actor_spec.id))
            for glyph in actor_name:
                check(game.chinese_font.has_char(glyph.unicode_at(0)),"Chinese actor glyph is available: "+glyph)
    game.simplified_chinese=true
    game._save_preferences()
    game.simplified_chinese=false
    game._load_preferences()
    check(game.simplified_chinese,"Chinese script preference persists")
    game.simplified_chinese=false
    game._save_preferences()
    check(Catalog.WORLDS.size()==8,"eight authored worlds")
    check(Catalog.ACTORS.size()==48,"48 authored economic/martial citizens")
    check(BoonCatalog.BOONS.size()==56,"56 authored rule-bending wuxia boons")
    check(Chains.CHAINS.size()==36,"36 ordered multi-household wuxia chain performances")
    check(Writs.WRITS.size()==24,"24 authored world-specific martial commissions")
    check(Rivals.RIVALS.size()==8,"each world has its own physical fifth-day rival")
    var rival_moves={}
    for rival_spec in Rivals.RIVALS:
        rival_moves[str(rival_spec.move)]=true
    check(rival_moves.size()==8,"all eight rivals retaliate with different physics or economic consequences")
    var writ_ids={}
    for w in Writs.WRITS:
        check(not writ_ids.has(str(w.id)),"each world writ is unique: "+str(w.id))
        writ_ids[str(w.id)]=true
        check(int(w.target)>0 and int(w.reward)>0 and int(w.seals)>0,"writ tracks actual targets and pays two resources")
    for index in range(8):
        check(Writs.for_world(index).size()==3,"each of eight worlds has three distinct commissions")
    var chain_ids={}
    var chain_actions={}
    for chain in Chains.CHAINS:
        check(not chain_ids.has(str(chain.id)),"unique authored chain: "+str(chain.id))
        chain_ids[str(chain.id)]=true
        chain_actions[str(chain.action)]=true
        check(chain.steps.size()>=2 and chain.steps.size()<=3,"each recipe has a genuine two/three-stop route")
        for piece in chain.steps:
            check(int(Catalog.actor(str(piece)).cost)>0,"chain routes reference real citizens: "+str(piece))
        check(int(chain.silver)>100 and float(chain.power)>0,"chain reward creates real economic and physical value")
    check(chain_actions.size()>=10,"chain recipes have ten different physical consequence families")
    check(Reactions.REACTIONS.size()==48,"all 48 citizens have a secondary conditional secret form")
    check(Reactions.mastery_level(5)==0,"early street rank is untrained")
    check(Reactions.mastery_level(6)==1 and Reactions.mastery_level(18)==2 and Reactions.mastery_level(40)==3,"three distinct earned mastery thresholds")
    var boon_ids={}
    var boon_families={}
    for boon in BoonCatalog.BOONS:
        check(not boon_ids.has(str(boon.id)),"boon %s is unique"%str(boon.id))
        boon_ids[str(boon.id)]=true
        boon_families[str(boon.family)]=true
    check(boon_families.size()==7,"boons cover seven materially different rule families")
    var actor_ids={}
    for info in Catalog.ACTORS:
        check(not actor_ids.has(str(info.id)),"actor %s has a unique id"%str(info.id))
        check(int(info.cost)>0,"actor %s has a meaningful purchase price"%str(info.id))
        check(Reactions.REACTIONS.has(str(info.id)),"actor %s has an authored conditional behavior"%str(info.id))
        check(str(Reactions.REACTIONS[str(info.id)].ascension).length()>8,"actor %s has a named third-stage evolution"%str(info.id))
        actor_ids[str(info.id)]=true
    check(actor_ids.size()==48,"all 48 authored entries are distinguishable")
    for color in ["jade","copper","paper","fish","ghost","iron"]:
        var sprite_path="res://assets/pearls/"+color+".png"
        check(ResourceLoader.exists(sprite_path),"a separate painted "+color+" pearl exists in the Godot resource pipeline")
        check((load(sprite_path) as Texture2D).get_width()>=128,"painted pearls retain adequate high-DPI texture detail")
    check(Chains.synergy("drunken",["inn"])>0,"dragon inn unlocks a compatible route partner")
    var draft_a=RandomNumberGenerator.new()
    var draft_b=RandomNumberGenerator.new()
    draft_a.seed=2674
    draft_b.seed=2674
    var sample_owned:Array[String]=["inn","tea","merchant"]
    var choices_a:Array[String]=Catalog.offers(0,sample_owned,draft_a)
    var choices_b:Array[String]=Catalog.offers(0,sample_owned,draft_b)
    check(choices_a==choices_b,"drafting is deterministic for a saved seed")
    check(choices_a[0]!=choices_a[1] and choices_a[0]!=choices_a[2] and choices_a[1]!=choices_a[2],"draft slots are distinct")
    check(game.city_stage!=null,"the inhabited ink border is instantiated")
    var mechanics:Dictionary={}
    var palette:Dictionary={}
    var street_names:Dictionary={}
    for i in range(8):
        var spec=Catalog.world(i)
        mechanics[spec.mechanic]=true
        palette[spec.accent]=true
        game.start_dream(i)
        await process_frame
        check(game.world_index==i,"world %d index"%i)
        check(game.phase=="build","world %d begins with construction"%i)
        check(game.active_actors.size()==3,"world %d gets three distinct starters"%i)
        check(game.scenery_pegs.size()>15,"world %d has physical pins"%i)
        check(game.board_segments.size()>=4,"world %d has unique rails"%i)
        check(game.world_art!=null,"world %d has its own art"%i)
        check(game.offer_cards.size()==3,"world %d offers choices"%i)
        var affordable:bool=false
        for candidate in game.offer_cards:
            if game.purchase_cost(candidate)<=game.treasury:affordable=true
        check(affordable,"world %d starts with an affordable piece"%i)
        check(str(spec.technique).length()>8,"world %d has a specific martial intervention"%i)
        check(game.event_name().length()>5,"world %d has a street event"%i)
        street_names[game.event_name()]=true
        for actor_id in spec.pool:
            check(Catalog.actor(str(actor_id)).id==actor_id,"world %d draft %s is authored"%[i,actor_id])
        var offer_id:String=game.offer_cards[0]
        var cost:int=int(Catalog.actor(offer_id).cost)
        var before:int=game.active_actors.size()
        game.treasury=0
        game._purchase_actor(offer_id,Vector2i(0,1))
        check(game.active_actors.size()==before,"world %d blocks unaffordable purchases"%i)
        game.treasury=cost+100
        check(game._purchase_actor(offer_id,Vector2i(0,1)),"world %d purchases a companion"%i)
        check(game.treasury==100,"world %d deducts the right cost"%i)
        game._begin_aim()
        check(game.phase=="aim","world %d enters aim"%i)
        game._launch()
        check(game.phase=="dropping","world %d begins physical simulation"%i)
        check(game.active_pearls.size()==1,"world %d spawns a physics pearl"%i)
        check(game._invoke_technique(),"world %d can trigger its wuxia move"%i)
        check(game.technique_used_today,"world %d marks the daily move spent"%i)
        check(not game._invoke_technique(),"world %d cannot spam its wuxia move"%i)
        game._set_pause(true)
        check(game.active_pearls[0].freeze,"world %d pauses its rigid body"%i)
        game._set_pause(false)
        await create_timer(.25).timeout
        for pearl in game.active_pearls.duplicate():
            game._settle_pearl(pearl)
        game._end_drop()
        check(game.phase=="aim","world %d permits a second shot"%i)
        check(game.shot_number==1,"world %d counts its first shot"%i)
    check(mechanics.size()==8,"all eight use different physics/scoring systems")
    check(palette.size()==8,"all eight have different palette identities")
    check(street_names.size()==8,"all eight streets open with different local events")
    for pair in [["inn","drunken"],["poison","physician"],["bamboo","sword"],["broker","caravan"],["official","ghost"],["mask","assassin"],["gong","drum"],["monk","bandit"],["opera","firework"],["moon","ferry"]]:
        check(not District.relation(Catalog.actor(pair[0]),Catalog.actor(pair[1])).is_empty(),"authored relationship %s / %s"%pair)

    # A city is a set of adjacent people, buildings and shared economic rules.
    game.start_dream(0)
    check(game._place_actor("drunken",Vector2i(1,0)),"a drunken master joins the inn's street")
    var banquet=false
    var master=null
    for actor in game.active_actors:
        if str(actor.data.id)=="drunken":master=actor
    for oath in game.district_links:
        if str(oath.kind)=="banquet":banquet=true
    check(banquet,"neighboring inn and drunken master create an unpaid banquet")
    var test_pearl=preload("res://scripts/pearl.gd").new()
    test_pearl.configure(game,"jade",42,true)
    game.add_child(test_pearl)
    var oath_payment:int=game._apply_oath_rules(test_pearl,game.active_actors[0],80,true)
    check(oath_payment>80,"the banquet is a working economic rule")
    check(test_pearl.statuses.has("drunk"),"the banquet changes a pearl's physical story")
    test_pearl.queue_free()
    check(master!=null,"the master exists as a physical building actor")
    if master!=null:
        game.treasury=100
        var old_treasury=game.treasury
        check(game._relocate_actor(master,Vector2i(4,0)),"households can be moved on the build phase")
        check(game.treasury==old_treasury-40,"moving a household is charged")
        check(master.socket==Vector2i(4,0),"moving updates the street address")
        banquet=false
        for oath in game.district_links:
            if str(oath.kind)=="banquet":banquet=true
        check(not banquet,"moving apart dissolves the adjacency oath")
        check(master.building_level==1,"all town buildings begin as one-storey addresses")
        game.treasury=2500
        var renovation_cost:int=game.building_upgrade_cost(master)
        var architectural_shapes:int=master.get_child_count()
        check(game._upgrade_building(master),"building upgrades can be purchased during construction")
        check(master.building_level==2,"a purchased estate adds a second storey")
        check(master.get_child_count()>architectural_shapes,"an expanded estate creates new physical collision geometry")
        check(game.treasury==2500-renovation_cost,"upgrading a building consumes the advertised silver")
        check(not game._train_actor(master,"rogue"),"school forms cannot be learned without martial credits")
        game._grant_training_seals(7,master.position)
        check(game.training_seals==7,"the player banks earned martial seals")
        check(game._train_actor(master,"rogue"),"a martial school path opens with earned seals")
        check(master.discipline=="rogue","the trained character carries a rogue identity")
        check(master.training_rank==1 and game.training_seals==4,"initial apprenticeship is charged at its first threshold")
        check(not game._train_actor(master,"rogue"),"next form needs both practice and sufficient seals")
        master.activation_count=6
        game._grant_training_seals(5,master.position)
        check(game._train_actor(master,"rogue"),"a practiced disciple can advance to the second form")
        check(master.training_rank==2,"progressive school training actually raises the form rank")
        check(not game._train_actor(master,"righteous"),"a resident cannot silently swap a chosen kung fu lineage")
        var rogue_pearl=preload("res://scripts/pearl.gd").new()
        rogue_pearl.configure(game,"jade",61,true)
        game.add_child(rogue_pearl)
        rogue_pearl.set_status("wanted",4)
        var old_debt:int=game.debt
        check(game._apply_school_form(rogue_pearl,master,false)>100,"rogue school has a contextual monetary action")
        check(game.debt>old_debt,"rogue power has a real economic drawback")
        rogue_pearl.queue_free()
        game.save_run()
        game.restore_run()
        var restored_master=false
        var restored_master_actor=null
        for citizen in game.active_actors:
            if str(citizen.data.id)=="drunken" and citizen.discipline=="rogue" and citizen.activation_count>=6 and citizen.training_rank==2 and citizen.building_level==2:
                restored_master=true
                restored_master_actor=citizen
        check(restored_master,"martial rank, mastery, and architectural upgrades survive save restore")
        check(game.training_seals==4,"remaining training currency survives save restore")
        if restored_master_actor!=null:
            game.selected_actor=restored_master_actor
            game.inspect_mode="home"
            game._press_at(Vector2(255,612))
            check(game.inspect_mode=="training","kung fu inspector opens from its accessible 151 by 51 touch button")
            game._press_at(Vector2(70,505))
            check(game.inspect_mode=="home","kung fu inspector returns via its dedicated back touch button")
            game.training_seals=50
            restored_master_actor.activation_count=18
            check(game._train_actor(restored_master_actor,"rogue"),"eighteen impacts unlock the third rogue form")
            restored_master_actor.activation_count=40
            check(game._train_actor(restored_master_actor,"rogue"),"forty impacts unlock the fourth and final form")
            check(restored_master_actor.training_rank==4,"the martial lineage has an actual fourth stage")
            check(not game._train_actor(restored_master_actor,"rogue"),"no fifth training purchase is possible")
            game.treasury=15000
            for level in range(3,6):
                check(game._upgrade_building(restored_master_actor),"an estate can rise to level %d"%level)
            check(restored_master_actor.building_level==5,"the city really reaches its fifth storey")
            check(not game._upgrade_building(restored_master_actor),"the fifth storey is the building cap")
            game.save_run()
            game.restore_run()
            var fully_cultivated=false
            for citizen in game.active_actors:
                if str(citizen.data.id)=="drunken" and citizen.training_rank==4 and citizen.building_level==5:fully_cultivated=true
            check(fully_cultivated,"fifth-storey buildings and fourth-form martial schools persist together")
        var hits_pearl=preload("res://scripts/pearl.gd").new()
        hits_pearl.configure(game,"jade",114,true)
        game.add_child(hits_pearl)
        var hit_actor=game.active_actors[0]
        var prior_seals:int=game.training_seals
        for contact in range(3):game._activate_actor(hits_pearl,hit_actor)
        check(game.training_seals>=prior_seals+1,"physical actor contact earns martial credits every third strike")
        hits_pearl.queue_free()
    check(game.active_actors[0].get_child_count()>1,"buildings provide extra physical architecture")

    # A real two-stop physical journey performs an original chain technique;
    # the outcome is capped per pearl and the discovery survives safe saves.
    game.start_dream(0)
    var route_pearl=preload("res://scripts/pearl.gd").new()
    route_pearl.configure(game,"jade",187,true)
    game.add_child(route_pearl)
    var tea_actor=game.active_actors[1]
    var inn_actor=game.active_actors[0]
    game._activate_actor(route_pearl,tea_actor)
    game._activate_actor(route_pearl,inn_actor)
    check(not game.route_trails.is_empty(),"two distinct named hits draw a visible route ribbon")
    check(game.route_trails[-1].a==tea_actor.position and game.route_trails[-1].b==inn_actor.position,"the ribbon connects the actual actors involved")
    check(route_pearl.route_recipes==1,"tea then inn triggers its ordered wuxia performance")
    check(route_pearl.route_completed.has("unpaid_banquet"),"the actual route is recorded on its pearl")
    check(game.known_chains.has("unpaid_banquet"),"the new chain is discovered for this scroll")
    check(route_pearl.statuses.has("drunk"),"an authored route changes the traveller's physical status")
    check(game.training_seals>=1,"route discoveries award spendable martial credits")
    game._activate_actor(route_pearl,tea_actor)
    game._activate_actor(route_pearl,inn_actor)
    check(route_pearl.route_recipes==1,"a chain cannot be farmed twice by one pearl")
    route_pearl.queue_free()
    game.save_run()
    game.restore_run()
    check(game.known_chains.has("unpaid_banquet"),"named chain discoveries are serialized")

    # Sound effects are independently switchable and do not change the music.
    game.sound_on=false
    game._save_preferences()
    game.sound_on=true
    game._load_preferences()
    check(not game.sound_on,"sound effects preference persists")
    var previous_voice:int=game.sound.impact_cursor
    game.sound.play_peg(4)
    check(game.sound.impact_cursor==previous_voice,"muted peg hits do not consume audio voices")
    game.sound_on=true
    game.sound.last_peg_sound_ms=-1000
    game.sound.play_peg(4)
    check(game.sound.impact_cursor==previous_voice+1,"peg hits produce musical feedback when enabled")
    game.sound.play_peg(4)
    check(game.sound.impact_cursor==previous_voice+1,"rapid simultaneous peg hits are rate limited")
    game._save_preferences()

    # Physics modifiers must be computed from status rather than compounded
    # every tick: one previously made the ball motionless on Web after seconds.
    game.start_dream(0)
    var damp_pearl=preload("res://scripts/pearl.gd").new()
    damp_pearl.configure(game,"jade",198,true)
    game.add_child(damp_pearl)
    game.boons.append("stone_sandals")
    game.phase="dropping"
    for tick in range(240):game.apply_world_physics(damp_pearl,1.0/60.0)
    check(damp_pearl.linear_damp<.5,"sticky motion boon no longer accumulates unbounded drag")
    damp_pearl.queue_free()
    game.start_dream(6)
    var cargo_pearl=preload("res://scripts/pearl.gd").new()
    cargo_pearl.configure(game,"copper",199,true)
    game.add_child(cargo_pearl)
    game.phase="dropping"
    cargo_pearl.set_status("goods",4)
    game.apply_world_physics(cargo_pearl,1.0/60.0)
    check(cargo_pearl.mass>1.4,"loaded freight has an objectively heavier physical body")
    cargo_pearl.statuses.erase("goods")
    game.apply_world_physics(cargo_pearl,1.0/60.0)
    check(is_equal_approx(cargo_pearl.mass,1.0),"selling cargo restores a normal pearl mass")
    cargo_pearl.queue_free()

    # The wager is explicitly chosen, earned by live event counters, and
    # carries a small but real failure penalty rather than passive rewards.
    game.start_dream(0)
    check(game._choose_writ(0),"players can commit to one optional morning writ")
    check(game.chosen_writ=="valley_trade","the writ choice belongs to the current city")
    check(not game._choose_writ(1),"cannot take all three commissions at once")
    for trade_hit in range(5):game._record_writ("trade")
    check(game.writ_progress==5,"real trade impact events advance the selected objective")
    game.shot_number=2
    game.phase="dropping"
    game._end_drop()
    check(game.writ_result=="completed","the two-pearl day honors a met commission")
    check(game.treasury>0,"a fulfilled commission adds spendable silver")
    game.restore_run()
    check(game.writ_result=="completed" and game.writ_progress==5,"commissions survive safe-phase save and resume")
    game._advance_day()
    check(game.chosen_writ=="" and game.writ_progress==0,"a new day offers a fresh decision")
    check(game._choose_writ(1),"players may choose a different kind of challenge the next day")
    game.treasury=0
    game.shot_number=2
    game.phase="dropping"
    game._end_drop()
    check(game.writ_result=="failed","an unmet optional wager is reported honestly")
    check(game.debt>=Writs.risk_for(game.day),"failing a wager creates a real economic liability")

    # Bosses are physics bodies with duel health, distinct counter-effects,
    # persistent damage and a reward that can finance longer training paths.
    for index in range(8):
        game.start_dream(index)
        game.day=5
        game._summon_rival()
        check(game.rival!=null,"world %d summons a tangible rival on day five"%index)
        if game.rival==null:continue
        check(game.rival.health==4 and game.rival.max_health==4,"world %d rival starts with four wounds"%index)
        game.rival.health=3
        game.phase="build"
        game.save_run()
        game.restore_run()
        check(game.rival!=null and game.rival.health==3,"world %d rival wounds persist across an interrupted dream"%index)
        var duel_pearl=preload("res://scripts/pearl.gd").new()
        duel_pearl.configure(game,"jade",225+index,true)
        game.add_child(duel_pearl)
        game.phase="dropping"
        var old_health:int=game.rival.health
        game._hit_rival(duel_pearl)
        check(game.rival!=null and game.rival.health<old_health,"world %d responds to a real pearl duel"%index)
        if index==1:check(duel_pearl.statuses.has("cursed"),"the silent abbot's retaliation curses the pearl")
        if index==5:check(duel_pearl.statuses.has("poison"),"the marsh rival uses venom rather than abstract damage")
        var old_seals:int=game.training_seals
        game.rival.health=1
        game.rival.last_contact.clear()
        game._hit_rival(duel_pearl)
        check(game.rival_defeated and game.rival==null,"world %d has a beatable, disappearing rival"%index)
        check(game.training_seals>=old_seals+2,"world %d rival pays martial training credits"%index)
        duel_pearl.queue_free()
    game.start_dream(0)
    game.day=10
    game._summon_rival()
    check(game.rival!=null and game.rival.max_health==5,"second rival appearance has more health")
    game.day=15
    game._summon_rival()
    check(game.rival!=null and game.rival.max_health==6,"final rival appearance has maximum health")
    game.treasury=0
    game.shot_number=2
    game.phase="dropping"
    game._end_drop()
    check(game.debt>=360,"an undefeated final rival creates a real toll debt")

    # First-run education is a four-scene interactive overlay, never a modal
    # text wall. The player acts through the actual build/aim/drop/report loop.
    game.tutorial_done=false
    game.start_dream(0)
    check(game.tutorial_stage==0 and game.tutorial_hint_timer>0,"the first dream opens with a visible construction tip")
    game._begin_aim()
    check(game.tutorial_stage==1,"the real play button advances the aim tutorial")
    game._launch()
    check(game.tutorial_stage==2,"launch advances into the playable action tutorial")
    for pearl in game.active_pearls.duplicate():game._settle_pearl(pearl)
    game._end_drop()
    check(game.tutorial_stage==1,"the second shot receives its own practical aim hint")
    game._launch()
    for pearl in game.active_pearls.duplicate():game._settle_pearl(pearl)
    game._end_drop()
    check(game.tutorial_stage==3 and game.phase=="report","the actual second shot teaches the day report")
    game._next_day()
    check(game.tutorial_done and game.tutorial_stage==-1,"the teaching sequence completes permanently after turning the page")
    game.tutorial_done=false
    game.start_dream(0)
    game._press_at(Vector2(306,231))
    check(game.tutorial_done and game.tutorial_stage==-1,"the tutorial can be skipped with a 79-by-47-point touch target")

    # Hitting combo milestones changes rigid-body forces, generates offspring,
    # boosts real revenue and earns martial seals. Quiet settings must not
    # secretly disable these consequences.
    game.start_dream(0)
    game._begin_aim()
    game._launch()
    var fever_pearl=game.active_pearls[0]
    var fever_actor=game.active_actors[0]
    for contact in range(5):game._activate_actor(fever_pearl,fever_actor)
    check(game.mayhem_tier==1 and game.mayhem_timer>0,"five consecutive impacts ignite active mayhem physics")
    check(game.mayhem_triggered.has("1") and not game.spawn_queue.is_empty(),"first mayhem creates a physical extra pearl")
    for contact in range(7):game._activate_actor(fever_pearl,fever_actor)
    check(game.mayhem_tier==2 and game.mayhem_triggered.has("2"),"twelve impacts amplify the riot")
    check(fever_pearl.statuses.has("blessed"),"second mayhem stage alters the pearl's combat state")
    for contact in range(10):game._activate_actor(fever_pearl,fever_actor)
    check(game.mayhem_tier==3 and game.mayhem_triggered.size()==3,"twenty-two impacts unlock the final distinct burst")
    var baseline_bank:int=game.treasury
    game._award(100,Vector2(195,350),"spectacle test")
    check(game.treasury-baseline_bank>=130,"active third-stage mayhem provides a monetary multiplier")
    check(not game.comic_stamps.is_empty() and not game.paper_confetti.is_empty(),"reactions emit real kinetic impact typography and debris")
    game.spectacle_on=false
    var old_stamp_count:int=game.comic_stamps.size()
    game._comic(Vector2(195,350),"OFF MEANS OFF",3)
    check(game.comic_stamps.size()==old_stamp_count,"the spectacle switch suppresses surplus effects")
    game.spectacle_on=true
    game.reduce_motion=true
    game.paper_confetti.clear()
    game._comic(Vector2(195,350),"CALM",3)
    check(game.paper_confetti.is_empty(),"reduced-motion mode preserves readable feedback without flying confetti")
    game.reduce_motion=false

    # Three distinct, touch-sized opening stances trade economy against
    # motion, offspring and player control. The choice persists at safe saves.
    game.start_dream(0)
    check(game.shot_stance=="crane","Crane is the predictable first-run stance")
    game._begin_aim()
    check(game._choose_stance(1) and game.shot_stance=="tiger","Tiger is an explicit alternative risk stance")
    game.restore_run()
    check(game.shot_stance=="tiger" and game.phase=="aim","stance selection survives safe-phase reload")
    game._launch()
    check(game.debt==35,"Tiger speed and profit cost 35 debt per shot")
    check(game.active_pearls[0].linear_velocity.length()>200,"Tiger launches with a materially faster physical velocity")
    var tiger_before:int=game.treasury
    game._award(100,Vector2(195,350),"stance test")
    check(game.treasury-tiger_before==128,"Tiger profit multiplier really changes scoring")
    game.qi_charge=6
    var pilot_pearl=game.active_pearls[0]
    var velocity_before:Vector2=pilot_pearl.linear_velocity
    check(game._qi_flick(pilot_pearl.position+Vector2(24,22)),"the player can touch a flying pearl to make a martial parry")
    check(game.qi_charge==3 and game.qi_spent==1,"each physical Qi flick spends exactly three earned credits")
    await create_timer(.08).timeout
    check(pilot_pearl.linear_velocity!=velocity_before,"Qi flick is a meaningful impulse, not a point popup")
    check(not game._qi_flick(pilot_pearl.position),"a short cooldown prevents touch-button spamming")
    game.qi_cooldown=0
    game._set_pause(true)
    check(not game._qi_flick(pilot_pearl.position),"pausing also disables martial steering")
    game._set_pause(false)
    game.qi_cooldown=0
    check(not game._qi_flick(Vector2(40,620)),"Qi can't be spent on an arbitrary empty part of the board")

    game.start_dream(0)
    game._begin_aim()
    game._press_at(Vector2(70,705))
    game._press_at(Vector2(296,618))
    check(game.shot_stance=="monkey","the 107-by-48 Monkey stance responds to actual UI touch")
    game.restore_run()
    check(game.shot_stance=="monkey","Monkey stance survives save and restore")
    game._launch()
    check(game.spawn_queue.size()==1,"Monkey starts each drop with an additional physical paper offspring queued")
    game._flush_spawn_queue()
    check(game.active_pearls.size()>=2,"Monkey's extra paper pearl actually exists in the physics world")
    var monkey_before:int=game.treasury
    game._award(100,Vector2(195,350),"stance test")
    check(game.treasury-monkey_before==78,"Monkey's second projectile comes at a clear economic opportunity cost")

    game.start_dream(0)
    game._begin_aim()
    game._launch()
    check(game.qi_charge==3,"Crane starts with enough Qi for a parry")
    var crane_pearl=game.active_pearls[0]
    crane_pearl.hits=2
    crane_pearl.position=Vector2(195,701)
    game._settle_pearl(crane_pearl)
    check(game.rescue_spent and game.active_pearls.has(crane_pearl),"a poor Crane drop gets exactly one physical second wind")
    check(crane_pearl.position.y<500 and crane_pearl.linear_velocity.y<0,"second wind visibly launches the seed back into the fight")
    check(game.qi_charge==4,"rescued players receive one small additional tactical Qi charge")
    game._settle_pearl(crane_pearl)
    check(not game.active_pearls.has(crane_pearl),"the same seed cannot farm infinite rescues")
    game.start_dream(0)
    game._begin_aim()
    game._launch()
    var actor_qi:int=game.qi_charge
    game._activate_actor(game.active_pearls[0],game.active_actors[0])
    check(game.qi_charge>actor_qi,"hitting named citizens earns spendable Qi")

    # Optional challenges must only capture touches when their panel is open.
    game.start_dream(0)
    game._finish_tutorial()
    game.show_writs=false
    game._press_at(Vector2(70,610))
    check(game.chosen_writ=="","hidden challenges do not intercept board touches")
    game._press_at(Vector2(310,160))
    check(game.show_writs,"challenge button opens the optional choices")
    game._press_at(Vector2(70,610))
    check(game.chosen_writ!="" and not game.show_writs,"choosing a challenge closes the choices")
    game.start_dream(0)
    game._press_at(Vector2(245,785))
    check(game.selected_actor!=null and game.inspect_mode=="training","kung fu button opens a resident's training")
    game._begin_aim()
    game._press_at(Vector2(340,705))
    check(is_equal_approx(game.launch_power,1.4),"power rail selects a stronger launch")
    game.touch_moved=false
    game._release_at(Vector2(340,705))
    game.launch_power=1.0
    game.restore_run()
    check(is_equal_approx(game.launch_power,1.4),"launch power survives a saved aim")
    game._launch()
    check(game.active_pearls[0].linear_velocity.length()>160,"power changes the physical launch speed")
    game.start_dream(0)
    game._begin_aim()
    game.drag_origin=Vector2(160,300)
    game.touch_moved=true
    game._press_at(game.drag_origin)
    game._drag_at(Vector2(220,440))
    check(game.aim_angle>0 and game.launch_power>1.0,"a board swipe sets direction and power together")
    game._release_at(Vector2(220,440))
    check(game.phase=="dropping" and game.active_pearls.size()>0,"releasing the board swipe launches the pearl")

    # Full UI-economic state transitions, serialization, tribute and ending.
    game.start_dream(0)
    game.treasury=3000
    game._begin_aim()
    game.save_run()
    var saved_treasury:int=game.treasury
    game.treasury=0
    game.restore_run()
    check(game.treasury==saved_treasury,"restore persists money")
    check(game.active_actors.size()==3,"restore persists installed companions")
    check(game.phase=="aim","restore persists the safe phase")
    game.day=3
    game.phase="report"
    game._next_day()
    check(game.phase=="tribute","third day invokes tribute")
    var owed:int=game.current_tribute()
    game.treasury=owed+55
    game._pay_tribute()
    check(game.phase=="boon","tribute rewards the player with a meaningful boon draft")
    check(game.boon_cards.size()==3,"boon draft offers three distinct laws")
    var boons_before=game.boon_cards.duplicate()
    game.restore_run()
    check(game.phase=="boon","an interrupted boon draft resumes instead of disappearing")
    check(game.boon_cards==boons_before,"the offered favors remain stable on reload")
    game._choose_boon(0)
    check(game.boons.size()==1,"selected boon becomes a persistent run rule")
    check(game.phase=="build" and game.day==4,"boon selection advances to fourth morning")
    check(game.treasury==55,"payment subtracts the tribute")
    check(not game.technique_used_today,"a new day replenishes the martial technique")
    game.start_dream(2)
    game._begin_aim()
    game._launch()
    check(game._invoke_technique(),"technique fires in the first shot")
    for pearl in game.active_pearls.duplicate():game._settle_pearl(pearl)
    game._end_drop()
    check(game.phase=="aim" and game.shot_number==1,"the half-day is a safe decision point")
    game.restore_run()
    check(game.technique_used_today,"restored half-day remembers its spent technique")
    check(game.shot_number==1,"restored half-day remembers the first shot")
    game.start_dream(0)
    game.boons.append("rice_futures")
    var boon_pearl=preload("res://scripts/pearl.gd").new()
    boon_pearl.configure(game,"jade",77,true)
    game.add_child(boon_pearl)
    var merchant_actor=game.active_actors[2]
    check(game._apply_boon_hit_effects(boon_pearl,merchant_actor,true)>=95,"the sect-patronage boon pays on a matching physical actor")
    boon_pearl.queue_free()
    game.boons.clear()
    game.boons.append_array(["merchant_charter","temple_charter","royal_rebate","extra_permit"])
    check(game.purchase_cost("merchant")<int(Catalog.actor("merchant").cost),"merchant charter reduces a genuine shop price")
    check(game.purchase_cost("abbot")<int(Catalog.actor("abbot").cost),"temple charter reduces a genuine martial price")
    check(game.current_tribute()<350,"royal rebate reduces the magistrate's demand")
    check(game.build_limit()==3,"extra permit adds a playable third building slot")
    game.boons.clear()
    game.treasury=1200
    check(game._purchase_actor("drunken",Vector2i(1,0)),"first permit builds a martial household")
    check(game._purchase_actor("noodle",Vector2i(0,0)),"second permit builds a noodle stall")
    check(game.builds_today==2,"the day's construction count is two")
    check(not game._purchase_actor("lion",Vector2i(4,0)),"a third same-day building is blocked")
    game.save_run()
    game.restore_run()
    check(game.builds_today==2,"construction permits survive a save")
    game._advance_day()
    check(game.builds_today==0,"a new morning renews building permits")
    game.start_dream(0)
    game.day=15
    game.phase="tribute"
    game.treasury=game.current_tribute()
    game._pay_tribute()
    check(game.phase=="victory","fifth tribute completes a scroll")
    check(game.world_stamps.has("valley"),"victory stamps the journal")
    game.sound.silence_all()
    game.queue_free()
    await process_frame
    await create_timer(.65).timeout
    await process_frame
    await process_frame
    print("JIANGHU SMOKE: ",checks," checks, ",failures," failures")
    quit(1 if failures>0 else 0)
