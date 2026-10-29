extends Node2D

const Portraits=preload("res://scripts/portraits.gd")

# Drawn in the same 390x844 logical coordinate system as the physical board.
# Everything interactive is at least 44 points high, with no hover affordances.
var main: Node2D
var styles: Dictionary = {}

func ink() -> Color:
    return Color.html(str(main.world_data.ink)) if not main.show_high_contrast else Color("#171919")

func accent() -> Color:
    return Color.html(str(main.world_data.accent))

func paper(alpha:float=.93) -> Color:
    return Color(.975,.955,.907,alpha) if not main.show_high_contrast else Color(.99,.99,.98,alpha)

func _text(s:String,x:float,y:float,size:int=15,col:Color=Color("#302E29"),center:bool=false,serif:bool=false) -> void:
    var font:Font=main.title_font if serif else main.ui_font
    if font==null:return
    var xx:float=x
    if center:
        xx-=font.get_string_size(s,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x*.5
    draw_string(font,Vector2(xx,y),s,HORIZONTAL_ALIGNMENT_LEFT,-1,size,col)

func _wrap(s:String,center_x:float,y:float,size:int=14,shade:Color=Color("#33342F")) -> void:
    var font:Font=main.ui_font
    if font==null:return
    var words:=s.split(" ")
    var line=""
    var yy=y
    for word in words:
        var trial=word if line=="" else line+" "+word
        if font.get_string_size(trial,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x>316 and line!="":
            _text(line,center_x,yy,size,shade,true)
            yy+=21
            line=word
        else:line=trial
    if line!="":_text(line,center_x,yy,size,shade,true)

func _right_text(s:String,right_x:float,y:float,size:int=15,col:Color=Color("#302E29"),serif:bool=false) -> void:
    var font:Font=main.title_font if serif else main.ui_font
    if font==null:return
    var w=font.get_string_size(s,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
    _text(s,right_x-w,y,size,col,false,serif)

func _small_caption(s:String,x:float,y:float,size:int=10) -> void:
    var words=s.split(" ")
    var rows:PackedStringArray=[]
    var current=""
    for word in words:
        var trial=word if current=="" else current+" "+word
        if main.ui_font.get_string_size(trial,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x>97 and current!="":
            rows.append(current)
            current=word
        else:current=trial
    if current!="":rows.append(current)
    for i in range(mini(rows.size(),2)):
        _text(rows[i],x,y+i*12,size,ink(),true)

func _offer_icon(kind:String, center:Vector2) -> void:
    var light=Color("#FFF3D9")
    draw_circle(center,11,Color(accent(),.94))
    match kind:
        "roof", "stall", "gate", "warehouse", "costume":
            draw_polyline(PackedVector2Array([center+Vector2(-7,0),center+Vector2(0,-6),center+Vector2(7,0)]),light,2.0,true)
            draw_rect(Rect2(center+Vector2(-5,0),Vector2(10,6)),light,false,1.5)
        "bell", "drum", "gong":
            draw_arc(center,6,PI,TAU,18,light,2.0,true)
            draw_line(center+Vector2(-6,1),center+Vector2(6,1),light,2)
            draw_circle(center+Vector2(0,5),2,light)
        "fish", "boat", "ferry":
            draw_circle(center+Vector2(-2,0),4,light)
            draw_colored_polygon(PackedVector2Array([center+Vector2(2,0),center+Vector2(7,-4),center+Vector2(7,4)]),light)
        "figure", "swords", "staff", "archer", "fan", "umbrella":
            draw_circle(center+Vector2(0,-5),2.5,light)
            draw_line(center+Vector2(0,-2),center+Vector2(0,5),light,2)
            draw_line(center+Vector2(-6,1),center+Vector2(6,-2),light,2)
            draw_line(center+Vector2(0,5),center+Vector2(-5,8),light,2)
            draw_line(center+Vector2(0,5),center+Vector2(5,8),light,2)
        "healer", "poison":
            draw_line(center+Vector2(-6,0),center+Vector2(6,0),light,3)
            draw_line(center+Vector2(0,-6),center+Vector2(0,6),light,3)
        "coins", "wheel":
            draw_arc(center,6,0,TAU,22,light,2,true)
            draw_line(center+Vector2(-4,0),center+Vector2(4,0),light,1.5)
            draw_line(center+Vector2(0,-4),center+Vector2(0,4),light,1.5)
        _:
            draw_arc(center,6,0,TAU,22,light,1.5,true)
            draw_circle(center,2.5,light)

func _panel(r:Rect2,solid:float=.94,stroke:bool=true) -> void:
    _surface(r,paper(solid),Color(ink(),.20) if stroke else Color(ink(),0),12)

func _surface(r:Rect2, fill:Color, border:Color, corner:int=10) -> void:
    var key=str(fill.to_html())+str(border.to_html())+str(corner)
    if not styles.has(key):
        var style:=StyleBoxFlat.new()
        style.bg_color=fill
        style.border_color=border
        style.set_border_width_all(1)
        style.set_corner_radius_all(corner)
        style.shadow_color=Color(.08,.11,.10,.20)
        style.shadow_size=5
        style.shadow_offset=Vector2(0,3)
        styles[key]=style
    draw_style_box(styles[key],r)

func _button(r:Rect2,label:String,primary:bool=true,enabled:bool=true,size:int=16) -> void:
    var face:Color=accent() if primary else paper()
    if not enabled:face=Color(.60,.60,.57,.85)
    _surface(r,face,Color(ink(),.15),9)
    _text(label,r.get_center().x,r.get_center().y+size*.36,size,Color.WHITE if primary or not enabled else ink(),true)

func _rule(x:float,y:float,w:float) -> void:
    draw_line(Vector2(x,y),Vector2(x+w,y),Color(ink(),.45),1.0)

func _draw() -> void:
    if main==null:return
    match main.phase:
        "menu":_draw_menu()
        "settings":_draw_settings()
        "build":
            _draw_status()
            _draw_build()
        "aim":
            _draw_status()
            _draw_aim()
        "dropping":
            _draw_status()
            _draw_dropping()
        "report":
            _draw_status()
            _draw_report()
        "tribute":
            _draw_status()
            _draw_tribute()
        "boon":
            _draw_status()
            _draw_boon()
        "victory","loss":_draw_ending()
    _draw_transient()

func _draw_menu() -> void:
    # Let the painting be the cover, with a restrained ink title plaque.
    _surface(Rect2(28,62,334,119),Color(.08,.17,.15,.84),Color(.94,.78,.51,.55),14)
    _text("DREAMING OF",195,98,14,Color("#E9D7B1"),true,true)
    _text("JIANGHU",195,151,45,Color("#FFF6E2"),true,true)

    _panel(Rect2(20,429,350,222),.89)
    _text("%02d  /  08"%(main.selected_world+1),195,464,12,accent(),true)
    var data=main.world_data
    var name:String=str(data.name)
    var size:int=25 if name.length()<23 else 21
    _text(name,195,501,size,ink(),true,true)
    _wrap(str(data.subtitle),195,529,14,ink())
    _rule(135,552,120)
    _wrap(str(data.rule),195,580,13,accent())
    _button(main.MENU_PREV_RECT,"‹",false,true,28)
    _button(main.MENU_NEXT_RECT,"›",false,true,28)
    if main.world_stamps.has(str(data.id)):
        _text("SEALED IN THE DREAM JOURNAL",195,638,11,accent(),true)

    _button(Rect2(49,682,292,60),"PLAY  ›",true,true,19)
    if FileAccess.file_exists(main.SAVE_PATH):
        _button(Rect2(82,752,226,49),"CONTINUE DREAM",false,true,15)
    else:_text("CHOOSE YOUR WORLD",195,785,11,Color("#F8EBD4"),true)
    _button(Rect2(328,49,45,44),"⚙",false,true,18)

func _draw_status() -> void:
    _surface(Rect2(12,43,366,92),Color(.09,.18,.16,.91),Color(.92,.75,.49,.45),12)
    if main.phase=="dropping":
        _text("DAY %d  ·  PEARL %d / 2"%[main.day,main.shot_number],195,66,10,Color("#E8D9B9"),true)
        _text(main.short_money(main.treasury),195,99,25,Color("#F4C785"),true,true)
        _text("TRIBUTE  %s"%main.short_money(main.current_tribute()),195,121,10,Color("#E8D9B9"),true)
        if main.rival!=null and is_instance_valid(main.rival) and not main.rival_defeated:
            _text("RIVAL  %d / %d"%[main.rival.health,main.rival.max_health],195,153,11,Color("#A34844"),true)
        return
    _text("DAY %d / 15"%main.day,27,70,12,Color("#E8D9B9"))
    _text("PEARL %d / 2"%main.shot_number,27,106,12,Color("#FFF6E2"))
    _right_text(main.short_money(main.treasury),360,83,25,Color("#F4C785"),true)
    _right_text("TRIBUTE  %s"%main.short_money(main.current_tribute()),360,111,11,Color("#E8D9B9"))
    if main.rival!=null and is_instance_valid(main.rival) and not main.rival_defeated:
        _text("RIVAL  ·  "+str(main.RivalScript.RIVALS[main.world_index].name),20,153,10,Color("#9D4037"))
        for pip in range(main.rival.max_health):
            draw_circle(Vector2(308+pip*13,150),4.0,accent() if pip<main.rival.health else Color(ink(),.18))
    else:_text("%d SEALS  ·  %d BOONS"%[main.training_seals,main.boons.size()],25,153,10,ink())

func _draw_build() -> void:
    _panel(Rect2(12,653,366,166),.965)
    _text("COMPANIONS",23,663,10,accent())
    _right_text("%d / %d PLACED"%[main.builds_today,main.build_limit()],367,663,10,ink())
    if main.offer_cards.is_empty():
        _text("The town rests until the next morning.",195,716,14,ink(),true)
    else:
        for i in range(main.offer_cards.size()):
            var data=main.Catalog.actor(main.offer_cards[i])
            var r=Rect2(20+i*119,669,109,85)
            _surface(r,Color(.91,.84,.70,.98) if main.selected_offer==i else Color(1,.98,.93,.96),accent() if main.selected_offer==i else Color(ink(),.16),8)
            var portrait:int=Portraits.index_for(str(data.id))
            if portrait>=0:
                draw_texture_rect_region(Portraits.ART,Rect2(r.get_center().x-17,670,34,32),Portraits.region(portrait))
            else:
                _offer_icon(str(data.kind),Vector2(r.get_center().x,685))
            _small_caption(str(data.name),r.get_center().x,711,10)
            var cost:int=main.purchase_cost(str(data.id))
            _text("%d"%cost,r.get_center().x,746,12,accent() if main.treasury>=cost else Color("#93554C"),true)
    var can_reroll:bool=main.treasury>=60 and main.builds_today<2
    _button(Rect2(16,762,107,47),"REROLL  60",false,can_reroll,12)
    _button(Rect2(285,762,88,47),"PLAY  ›",true,true,14)
    if main.selected_offer>=0 and main.selected_offer<main.offer_cards.size():
        var chosen=main.Catalog.actor(main.offer_cards[main.selected_offer])
        _panel(Rect2(36,588,318,61),.96)
        _text(str(chosen.name),195,606,14,ink(),true)
        var cost=main.purchase_cost(str(chosen.id))
        _text(str(chosen.short),195,623,11,ink(),true)
        _text("Tap an empty ring · %d taels"%cost if main.treasury>=cost else "Earn taels first · tap PLAY",195,643,11,accent(),true)
    elif main.selected_actor!=null and is_instance_valid(main.selected_actor):
        _draw_actor_inspect()
    elif main.chosen_writ=="":
        _panel(Rect2(28,562,334,87),.97)
        _text("OPTIONAL CHALLENGE  ·  FAILURE ADDS DEBT",195,582,10,accent(),true)
        var writs=main.CommissionCatalog.for_world(main.world_index)
        for i in range(writs.size()):
            _button(Rect2(35+i*108,589,104,50),str(writs[i].short),false,true,11)
    elif main.chosen_writ!="":
        var writ=main.CommissionCatalog.writ(main.chosen_writ)
        _panel(Rect2(28,586,334,63),.97)
        _text("WRIT  ·  "+str(writ.name),195,610,12,accent(),true)
        _text("%d / %d  ·  REWARD %d TAELS  ·  RISK %d"%[main.writ_progress,main.CommissionCatalog.target_for(main.chosen_writ,main.day),main.CommissionCatalog.reward_for(main.chosen_writ,main.day),main.CommissionCatalog.risk_for(main.day)],195,632,11,ink(),true)
    else:
        _text("Place people. Build streets. Make trouble.",195,643,12,ink(),true)

func _draw_aim() -> void:
    _panel(Rect2(14,548,362,104),.95)
    _text("STANCE",195,566,11,accent(),true)
    var styles=["crane","tiger","monkey"]
    var descriptions=["CRANE  ·  2 STARTING QI & SECOND WIND","TIGER  ·  +28% TAELS, 35 DEBT PER PEARL","MONKEY  ·  BONUS PEARL, -22% PAYOUT"]
    var chosen:int=styles.find(main.shot_stance)
    _text(str(descriptions[maxi(0,chosen)]),195,586,11,ink(),true)
    for i in range(3):
        var selected:bool=main.shot_stance==str(styles[i])
        var r:Rect2=Rect2(24+i*114,596,107,48)
        _button(r,str(styles[i]).to_upper(),selected,true,14)
        if selected:draw_rect(r.grow(2),Color("#E8AF41"),false,2.0)
    _panel(Rect2(12,656,366,163),.965)
    if main.chosen_writ!="":
        var writ=main.CommissionCatalog.writ(main.chosen_writ)
        _text("WRIT · %s  %d/%d"%[str(writ.short),main.writ_progress,main.CommissionCatalog.target_for(main.chosen_writ,main.day)],195,672,12,accent(),true)
    else:_text("AIM",195,672,11,accent(),true)
    _text("ENTRY",23,698,11,ink())
    _rule(90,691,258)
    draw_circle(Vector2(main.launch_x,691),9,accent())
    _text("ANGLE",23,743,11,ink())
    _rule(90,737,258)
    draw_circle(Vector2(195+main.aim_angle/.68*160,737),9,accent())
    _button(Rect2(42,756,306,51),"RELEASE  ›",true,true,17)

func _draw_dropping() -> void:
    _panel(Rect2(46,590,298,62),.94)
    _text("TAP A PEARL TO PARRY  ·  3 QI",195,617,12,accent(),true)
    for dot in range(9):
        draw_circle(Vector2(140+dot*14,641),4,accent() if dot<main.qi_charge else Color(ink(),.16))
    _panel(Rect2(14,658,362,158),.88)
    if main.chosen_writ!="":
        var writ=main.CommissionCatalog.writ(main.chosen_writ)
        _text("WRIT  ·  %s   %d/%d"%[str(writ.short),main.writ_progress,main.CommissionCatalog.target_for(main.chosen_writ,main.day)],195,682,14,ink(),true,true)
    else:_text("THIS PEARL",195,682,12,ink(),true)
    _text("+ %s  TAELS"%main.short_money(main.earnings_drop),195,719,26,accent(),true,true)
    if main.mayhem_timer>0:
        _text("MAYHEM ×%d  ·  COMBO %d  ·  BONUS %d%%"%[main.mayhem_tier,main.combo_count,main.mayhem_tier*12],195,743,12,Color("#C44230"),true)
    else:_text("%d COMBO"%main.combo_count,195,743,12,ink(),true)
    for i in range(12):
        var lit:bool=float(i)<float(main.combo_count)/31.0*12.0 or (main.mayhem_timer>0 and i<main.mayhem_tier*4)
        var segment=Rect2(38+i*26.0,750,20,4.0)
        draw_rect(segment,Color("#F0B835") if lit else Color(ink(),.12))
    _button(Rect2(35,759,320,48),str(main.world_data.technique) if not main.technique_used_today else "USED FOR TODAY",true,not main.technique_used_today,12)
    _button(Rect2(31,65,62,51),"1.5×" if main.fast_speed else "1×",false,true,14)
    _button(Rect2(309,65,63,51),"▶" if main.pause_sim else "Ⅱ",false,true,18)
    if main.pause_sim:
        _panel(Rect2(51,356,288,125),.98)
        _text("THE DREAM RESTS",195,406,23,ink(),true,true)
        _text("Tap the top-right to resume",195,444,14,accent(),true)

func _draw_report() -> void:
    _panel(Rect2(28,653,334,163),.96)
    _text("DAILY DAMAGE REPORT",195,681,18,ink(),true,true)
    _text("+ %s  taels earned"%main.short_money(main.earnings_today),195,713,20,accent(),true)
    var writ_suffix="  ·  WRIT "+("✓" if main.writ_result=="completed" else "×") if main.chosen_writ!="" else ""
    _text("Treasury  %s%s"%[main.short_money(main.treasury),writ_suffix],195,744,13,ink(),true)
    _button(Rect2(40,755,310,55),"TURN THE PAGE  ›",true,true,17)

func _draw_tribute() -> void:
    _panel(Rect2(28,487,334,325),.97)
    _text("THE RED LEDGER",195,527,27,ink(),true,true)
    _text("The magistrate has brought a calculator.",195,553,13,ink(),true)
    _rule(71,569,248)
    _text("OWED",195,595,11,ink(),true)
    _text("%s  taels"%main.short_money(main.current_tribute()),195,628,26,accent(),true)
    _text("IN PURSE   %s"%main.short_money(main.treasury),195,658,15,ink(),true)
    if main.treasury<main.current_tribute():
        _text("Not enough. Sell the dearest companion.",195,680,11,Color("#A34844"),true)
    _button(Rect2(53,688,284,51),"SELL A COMPANION",false,not main.active_actors.is_empty(),13)
    _button(Rect2(40,755,310,55),"PAY THE TRIBUTE" if main.treasury>=main.current_tribute() else "FACE THE MAGISTRATE",true,true,16)

func _draw_boon() -> void:
    _panel(Rect2(20,342,350,468),.97)
    _text("STEAL ONE LAW OF HEAVEN",195,384,22,ink(),true,true)
    _text("Choose one law to bend for the rest of this scroll.",195,415,12,accent(),true)
    for i in range(main.boon_cards.size()):
        var data=main.BoonCatalog.boon(main.boon_cards[i])
        var rect=Rect2(34,437+i*99,322,91)
        _panel(rect,.97)
        draw_rect(Rect2(rect.position.x,rect.position.y,5,rect.size.y),accent())
        var name_size=16 if str(data.name).length()<26 else 14
        _text(str(data.name),195,rect.position.y+28,name_size,ink(),true,true)
        _text(str(data.short),195,rect.position.y+54,11,ink(),true)
        _text("COMMON" if int(data.rarity)==1 else ("RARE" if int(data.rarity)==2 else "LEGENDARY"),195,rect.position.y+75,11,accent(),true)
    _text("TAP A FAVOR · %d ALREADY INSCRIBED"%main.boons.size(),195,778,12,ink(),true)

func _draw_ending() -> void:
    _panel(Rect2(22,294,346,522),.96)
    var won:bool=main.phase=="victory"
    _text("THE DREAM REMEMBERS" if won else "A SCROLL FALLS SILENT",195,351,26,ink(),true,true)
    _rule(80,376,230)
    _text("FIFTEEN DAYS ENDURED" if won else "THE LEDGER REMAINS",195,410,14,accent(),true)
    _text(main.short_money(main.total_earned),195,489,47,ink(),true,true)
    _text("TAELS EARNED IN ALL",195,515,12,ink(),true)
    _text("BEST COMBO   %d"%main.best_combo,195,550,15,accent(),true)
    _wrap("A jade pearl tells no truth about its own luck.",195,611,15,ink())
    _button(Rect2(84,674,223,55),"RETURN TO THE MAP",false,true,14)
    _button(Rect2(42,752,306,58),"DREAM AGAIN",true,true,19)

func _draw_settings() -> void:
    _panel(Rect2(22,179,346,633),.965)
    _text("THE QUIET CHAMBER",195,228,28,ink(),true,true)
    _text("Comfort and accessibility",195,253,13,accent(),true)
    var rows=[
        ["MUSIC",main.music_on],
        ["GENTLE HAPTICS",main.haptics_on],
        ["REDUCE MOTION",main.reduce_motion],
        ["HIGH CONTRAST",main.show_high_contrast],
        ["SPECTACLE & MAYHEM FX",main.spectacle_on]
    ]
    for i in range(rows.size()):
        var r=Rect2(39,280+i*75,315,66)
        _panel(r,.98)
        _text(str(rows[i][0]),55,r.position.y+39,15,ink())
        var state:bool=rows[i][1]
        _text("ON" if state else "OFF",327,r.position.y+39,15,accent() if state else Color("#82827C"),true)
    _button(Rect2(34,716,322,70),"RETURN TO THE SCROLLS",true,true,17)

func _draw_actor_inspect() -> void:
    var a=main.selected_actor
    if a==null or not is_instance_valid(a):return
    if main.inspect_mode=="training":
        _panel(Rect2(28,477,334,173),.975)
        _button(Rect2(37,486,76,46),"‹ BACK",false,true,11)
        _text("THE MARTIAL PATH",227,511,18,ink(),true,true)
        _text(str(a.data.name)+"  ·  %d SEALS IN PURSE"%main.training_seals,195,540,12,accent(),true)
        for j in range(4):
            var center=Vector2(118+j*51,553)
            if j<3:draw_line(center+Vector2(7,0),center+Vector2(45,0),Color(ink(),.35),2)
            draw_circle(center,8.2,accent() if j<a.training_rank else paper(),true)
            draw_arc(center,8.2,0,TAU,20,ink(),1.2)
            _text(str(j+1),center.x,center.y+3.7,10,Color.WHITE if j<a.training_rank else ink(),true)
        if a.training_rank>=4:
            _text(a.discipline.to_upper()+"  ·  THE FOURTH FORM MASTERED",195,608,13,accent(),true)
            _text("Every strike carries the teacher's signature.",195,629,11,ink(),true)
        else:
            var required:int=main.next_training_hits(a.training_rank)
            var cost:int=main.next_training_cost(a.training_rank)
            var ready:bool=main.training_seals>=cost and a.activation_count>=required
            _text("FORM %d  ·  %d SEALS  ·  %d / %d IMPACTS"%[a.training_rank+1,cost,a.activation_count,required],195,578,11,accent(),true)
            if a.training_rank==0:
                var names=["RIGHTEOUS","ROGUE","WANDERER"]
                for i in range(3):
                    _button(Rect2(35+i*108,584,104,50),names[i],false,ready,10)
            else:
                _button(Rect2(113,583,240,51),"LEARN THE NEXT FORM",true,ready,13)
        return
    _panel(Rect2(28,487,334,163),.975)
    var route=main.ChainCatalog.hint_for(str(a.data.id))
    if not route.is_empty():
        var route_steps=PackedStringArray()
        for step in route.steps:route_steps.append(str(step).to_upper())
        _text("HIDDEN ROUTE  "+" › ".join(route_steps),195,509,10,accent(),true)
    else:_text("NO SECRET ROUTE RECORDED",195,509,10,accent(),true)
    _text(str(a.data.name)+"  ·  ESTATE %d / 5"%a.building_level,195,543,16,ink(),true,true)
    _text(str(a.data.short)+" · %d IMPACTS · %s"%[a.activation_count,a.discipline.to_upper()],195,563,10,accent(),true)
    var oaths=0
    for link in main.district_links:
        if link.a==a or link.b==a:oaths+=1
    _text("%d OATHS  ·  MOVE TO EMPTY RING: 40 TAELS"%oaths,195,580,10,ink(),true)
    var upgrade_label="MAX ESTATE" if a.building_level>=5 else "UPGRADE  %d"%main.building_upgrade_cost(a)
    _button(Rect2(38,586,149,51),upgrade_label,false,a.building_level<5 and main.treasury>=main.building_upgrade_cost(a),12)
    _button(Rect2(201,586,151,51),"KUNG FU  ›",true,true,14)

func _draw_transient() -> void:
    if main.banner_timer>0 and main.phase!="menu" and main.phase!="settings":
        var alpha:float=clampf(main.banner_timer,0.0,1.0)
        var y:float=301 if main.tutorial_stage>=0 and main.tutorial_hint_timer>0 else 211
        draw_rect(Rect2(33,y,324,45),Color(.97,.96,.91,.90*alpha))
        var size:int=12 if main.banner_text.length()<40 else 10
        _text(main.banner_text,195,y+29,size,Color(accent(),alpha),true)
    if main.status_timer>0 and main.phase not in ["menu","dropping"]:
        _text(main.status_text,195,641,11,Color(ink(),clampf(main.status_timer,0,1)),true)
    if main.tutorial_stage>=0 and main.tutorial_hint_timer>0 and main.phase in ["build","aim","dropping","report"]:
        _draw_tutorial()

func _draw_tutorial() -> void:
    var stage:int=main.tutorial_stage
    var titles=["TAP PLAY TO BEGIN","AIM AND RELEASE","TAP A PEARL TO PARRY","COLLECT YOUR EARNINGS"]
    if stage<0 or stage>=titles.size():return
    var alpha:float=minf(1.0,main.tutorial_hint_timer/.5)
    var back=Color("#1D3735")
    back.a=.94*alpha
    _surface(Rect2(23,199,344,67),back,Color(.97,.76,.42,.75*alpha),10)
    _text("%d / 4"%(stage+1),39,220,10,Color(1,.81,.45,alpha))
    _text(str(titles[stage]),39,243,14,Color(1,.98,.87,alpha))
    _button(Rect2(282,209,79,47),"SKIP",false,true,12)
    var target:Rect2=Rect2(285,762,88,47)
    if main.phase=="aim":target=Rect2(42,756,306,51)
    elif main.phase=="dropping":return
    elif main.phase=="report":target=Rect2(40,755,310,55)
    var breathe:float=.0 if main.reduce_motion else (sin(main.elapsed*7.0)+1.0)*.5
    draw_rect(target.grow(2.0+breathe*2.0),Color(.96,.59,.23,(.7+breathe*.25)*alpha),false,2.5)
