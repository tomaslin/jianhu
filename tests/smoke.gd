extends SceneTree

# CLI: godot --headless --path . --script res://tests/smoke.gd
const GameScene=preload("res://scenes/main.tscn")
const Catalog=preload("res://scripts/world_catalog.gd")
const District=preload("res://scripts/district_system.gd")
const BoonCatalog=preload("res://scripts/boon_catalog.gd")
const Reactions=preload("res://scripts/reaction_catalog.gd")
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
    check(Catalog.WORLDS.size()==8,"eight authored worlds")
    check(Catalog.ACTORS.size()==48,"48 authored economic/martial citizens")
    check(BoonCatalog.BOONS.size()==56,"56 authored rule-bending wuxia boons")
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
        check(str(spec.technique).length()>8,"world %d has a specific martial intervention"%i)
        check(game.event_name().length()>5,"world %d has a street event"%i)
        street_names[game.event_name()]=true
        for actor_id in spec.pool:
            check(Catalog.actor(str(actor_id)).id==actor_id,"world %d draft %s is authored"%[i,actor_id])
        var offer_id:String=game.offer_cards[0]
        var cost:int=int(Catalog.actor(offer_id).cost)
        var before:int=game.active_actors.size()
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
    game.queue_free()
    await process_frame
    await process_frame
    await process_frame
    print("JIANGHU SMOKE: ",checks," checks, ",failures," failures")
    quit(1 if failures>0 else 0)
