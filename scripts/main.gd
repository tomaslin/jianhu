extends Node2D

const Catalog=preload("res://scripts/world_catalog.gd")
const ActorScript=preload("res://scripts/actor.gd")
const PearlScript=preload("res://scripts/pearl.gd")
const HudScript=preload("res://scripts/hud.gd")
const SoundScript=preload("res://scripts/sound_director.gd")
const CityStageScript=preload("res://scripts/city_stage.gd")
const DistrictScript=preload("res://scripts/district_system.gd")
const BoonCatalog=preload("res://scripts/boon_catalog.gd")
const ReactionCatalog=preload("res://scripts/reaction_catalog.gd")

const W:float=390.0
const H:float=844.0
const BOARD_RECT:=Rect2(26.0,174.0,338.0,474.0)
const SAVE_PATH: String="user://jianghu_save.json"

var phase:String="menu"
var world_index:int=0
var world_data:Dictionary={}
var world_art:Texture2D
var ui_font:Font
var title_font:Font
var hud:Node2D
var sound:Node
var city_stage:Node2D
var rng:=RandomNumberGenerator.new()

var selected_world:int=0
var seed_value:int=0
var day:int=1
var shot_number:int=0
var builds_today:int=0
var launch_x:float=195.0
var aim_angle:float=0.0
var selected_offer:int=-1
var offer_cards:Array[String]=[]
var boons:Array[String]=[]
var boon_cards:Array[String]=[]
var selected_actor: JianghuActor
var inspect_mode:String="home"
var active_actors:Array[JianghuActor]=[]
var scenery_pegs:Array[JianghuActor]=[]
var district_links:Array[Dictionary]=[]
var motion_segments:Array[StaticBody2D]=[]
var board_segments:Array[StaticBody2D]=[]
var board_segment_lines:Array[PackedVector2Array]=[]
var active_pearls:Array[JianghuPearl]=[]
var hit_queue:Array[Dictionary]=[]
var spawn_queue:Array[Dictionary]=[]
var children_this_drop:int=0
var bell_summoned:bool=false
var cinematic_act:int=0
var recent_hits:Dictionary={}
var fly_texts:Array[Dictionary]=[]
var ink_bursts:Array[Dictionary]=[]
var technique_used_today:bool=false
var street_event:int=0
var training_seals:int=0
var seals_earned_today:int=0

var treasury:int=0
var total_earned:int=0
var earnings_today:int=0
var earnings_drop:int=0
var debt:int=0
var rhythm_chain:int=0
var combo_count:int=0
var best_combo:int=0
var actor_trades:Dictionary={}
var owned_ids:Array[String]=[]
var board_claims:Dictionary={}
var world_stamps:Dictionary={}
var run_flags:Dictionary={}
var global_tick:int=0
var elapsed:float=0.0
var drop_started_at:float=0.0
var quiet_time:float=0.0
var beat_clock:float=0.0
var last_beat:int=-1
var current_beat:int=0
var pause_sim:bool=false
var fast_speed:bool=false
var touch_id:int=-1
var dragging:bool=false
var drag_origin:Vector2=Vector2.ZERO
var touch_moved:bool=false
var banner_text:String=""
var banner_timer:float=0.0
var status_text:String=""
var status_timer:float=0.0
var earned_policy:String=""
var active_background:Color=Color(.96,.94,.89)

var safe_top:float=50.0
var safe_bottom:float=36.0
var music_on:bool=true
var haptics_on:bool=true
var reduce_motion:bool=false
var show_high_contrast:bool=false

func _ready() -> void:
    ui_font=load("res://assets/fonts/DejaVuSans.ttf")
    title_font=load("res://assets/fonts/DejaVuSerif.ttf")
    _load_preferences()
    _refresh_world(0)
    city_stage=CityStageScript.new()
    city_stage.main=self
    add_child(city_stage)
    hud=HudScript.new()
    hud.main=self
    hud.z_index=25
    add_child(hud)
    sound=SoundScript.new()
    sound.main=self
    add_child(sound)
    set_process(true)
    set_physics_process(true)
    queue_redraw()

func _refresh_world(index:int) -> void:
    world_index=clampi(index,0,7)
    world_data=Catalog.world(world_index)
    active_background=Color.html(str(world_data.palette))
    var file="res://assets/worlds/%02d_%s.png" % [world_index+1,str(world_data.id)]
    # Art is an enhancement; a valid source build still runs with procedural ink.
    if ResourceLoader.exists(file):
        world_art=load(file)
    else:
        world_art=null
    if hud!=null:
        hud.queue_redraw()
    queue_redraw()

func _notification(what:int) -> void:
    if what==NOTIFICATION_APPLICATION_FOCUS_OUT:
        if phase!="dropping":
            save_run()

func _process(delta:float) -> void:
    elapsed+=delta
    if banner_timer>0.0:banner_timer=maxf(0.0,banner_timer-delta)
    if status_timer>0.0:status_timer=maxf(0.0,status_timer-delta)
    for entry in fly_texts:
        entry.life=float(entry.life)-delta
        entry.pos=Vector2(entry.pos)+Vector2(0,-24*delta)
    fly_texts=fly_texts.filter(func(e):return float(e.life)>0)
    for burst in ink_bursts:
        burst.life=float(burst.life)-delta
    ink_bursts=ink_bursts.filter(func(e):return float(e.life)>0.0)
    if hud!=null: hud.queue_redraw()
    if city_stage!=null and phase!="menu":city_stage.queue_redraw()

func _physics_process(delta:float) -> void:
    if phase!="dropping":return
    if pause_sim:return
    global_tick+=1
    beat_clock+=delta
    var beat_seconds:float=60.0/float(world_data.bpm)
    current_beat=int(floor(beat_clock/beat_seconds))
    if current_beat!=last_beat:
        last_beat=current_beat
        if sound!=null:sound.on_beat(current_beat)
    _animate_world_segments()
    _resolve_hit_queue()
    _flush_spawn_queue()
    for pearl in active_pearls.duplicate():
        if not is_instance_valid(pearl):
            active_pearls.erase(pearl)
            continue
        if pearl.position.y>BOARD_RECT.end.y+17 or pearl.position.y<139 or pearl.position.x<8 or pearl.position.x>W-8 or Time.get_ticks_msec()/1000.0-pearl.born_at>18.0:
            _settle_pearl(pearl)
    if active_pearls.is_empty() and spawn_queue.is_empty() and hit_queue.is_empty():
        quiet_time+=delta
        if quiet_time>.48:
            _end_drop()
    else:
        quiet_time=0.0
    queue_redraw()

func start_dream(index:int, resume:bool=false) -> void:
    _set_pause(false)
    fast_speed=false
    Engine.time_scale=1.0
    _clear_board()
    _refresh_world(index)
    if not resume:
        rng.randomize()
        seed_value=rng.randi()
        rng.seed=seed_value
        day=1
        shot_number=0
        builds_today=0
        treasury=0
        total_earned=0
        earnings_today=0
        debt=0
        owned_ids.clear()
        boons.clear()
        boon_cards.clear()
        board_claims.clear()
        run_flags.clear()
        rhythm_chain=0
        best_combo=0
        actor_trades.clear()
        technique_used_today=false
        street_event=0
        training_seals=0
        seals_earned_today=0
    _build_board()
    if not resume:
        var starter_positions: Array[Vector2i]=[Vector2i(2,0),Vector2i(1,2),Vector2i(3,3)]
        for i in range(3):
            _place_actor(str(world_data.starters[i]),starter_positions[i])
    _rebuild_district()
    selected_offer=-1
    offer_cards=Catalog.offers(world_index,owned_ids,rng)
    phase="build"
    banner_text="DAY %02d   ·   THE SCROLL UNFOLDS"%day
    banner_timer=2.2
    sound.change_world(world_index)
    save_run()
    queue_redraw()

func _clear_board() -> void:
    for p in active_pearls:
        if is_instance_valid(p):p.queue_free()
    active_pearls.clear()
    for a in active_actors:
        if is_instance_valid(a):a.queue_free()
    active_actors.clear()
    for a in scenery_pegs:
        if is_instance_valid(a):a.queue_free()
    scenery_pegs.clear()
    for s in board_segments:
        if is_instance_valid(s):s.queue_free()
    board_segments.clear()
    motion_segments.clear()
    board_segment_lines.clear()
    hit_queue.clear()
    spawn_queue.clear()
    recent_hits.clear()
    fly_texts.clear()
    ink_bursts.clear()
    district_links.clear()
    selected_actor=null

func _build_board() -> void:
    _add_segment(Vector2(27,176),Vector2(27,649))
    _add_segment(Vector2(363,176),Vector2(363,649))
    var mech:String=str(world_data.mechanic)
    match mech:
        "trade":
            _add_segment(Vector2(42,307),Vector2(95,325))
            _add_segment(Vector2(290,396),Vector2(346,376))
            _add_segment(Vector2(58,506),Vector2(110,492))
        "resonance":
            _add_segment(Vector2(51,333),Vector2(123,333))
            _add_segment(Vector2(265,446),Vector2(338,446))
            _add_segment(Vector2(105,565),Vector2(285,565))
        "masks":
            _add_segment(Vector2(45,346),Vector2(122,346),true)
            _add_segment(Vector2(272,476),Vector2(345,476),true)
        "portals":
            _add_segment(Vector2(88,321),Vector2(144,339))
            _add_segment(Vector2(246,431),Vector2(306,414))
            _add_segment(Vector2(128,556),Vector2(257,556))
        "wind":
            _add_segment(Vector2(41,348),Vector2(112,293))
            _add_segment(Vector2(280,411),Vector2(344,459))
            _add_segment(Vector2(70,545),Vector2(129,497))
        "poison":
            _add_segment(Vector2(50,382),Vector2(127,383))
            _add_segment(Vector2(251,516),Vector2(339,516))
        "cargo":
            _add_segment(Vector2(49,324),Vector2(140,352))
            _add_segment(Vector2(253,429),Vector2(342,467))
            _add_segment(Vector2(74,566),Vector2(176,604))
        "abacus":
            _add_segment(Vector2(50,302),Vector2(107,327))
            _add_segment(Vector2(282,303),Vector2(339,327))
            _add_segment(Vector2(80,539),Vector2(147,514))
            _add_segment(Vector2(245,514),Vector2(310,539))
    # Pebbles follow world-specific topologies. Actors occupy separate sockets.
    var row_count=9
    for r in range(row_count):
        for c in range(7):
            if (r+c+world_index)%11==0:continue
            var x=47.0+c*46.0+(18.0 if r%2 else 0.0)
            var y=226.0+r*46.0
            if x>351.0:continue
            var stone=ActorScript.new()
            stone.configure(Catalog.actor("stone"),self,Vector2i(-1,-1),true)
            stone.position=Vector2(x,y)
            add_child(stone)
            scenery_pegs.append(stone)
    queue_redraw()

func _add_segment(a:Vector2,b:Vector2,moving:bool=false) -> void:
    var body:=StaticBody2D.new()
    body.collision_layer=2
    body.collision_mask=1
    body.position=Vector2.ZERO
    var shape:=CollisionShape2D.new()
    var seg:=SegmentShape2D.new()
    seg.a=a
    seg.b=b
    shape.shape=seg
    body.add_child(shape)
    add_child(body)
    board_segments.append(body)
    board_segment_lines.append(PackedVector2Array([a,b]))
    if moving:
        body.set_meta("origin",Vector2.ZERO)
        body.set_meta("motion_id",motion_segments.size())
        motion_segments.append(body)

func socket_position(socket:Vector2i) -> Vector2:
    return Vector2(64.0+float(socket.x)*64.5,274.0+float(socket.y)*75.5)

func socket_for_position(point:Vector2) -> Vector2i:
    var x=clampi(roundi((point.x-64.0)/64.5),0,4)
    var y=clampi(roundi((point.y-274.0)/75.5),0,4)
    return Vector2i(x,y)

func can_place(socket:Vector2i) -> bool:
    if socket.x<0 or socket.x>4 or socket.y<0 or socket.y>4:return false
    var key="%d:%d"%[socket.x,socket.y]
    return not board_claims.has(key)

func _place_actor(actor_id:String,socket:Vector2i) -> bool:
    if not can_place(socket):return false
    var actor=ActorScript.new()
    actor.configure(Catalog.actor(actor_id),self,socket,false)
    actor.position=socket_position(socket)
    # A peg yields to a newly constructed landmark, keeping collision shapes
    # non-overlapping and improving readability on the tiny mobile playfield.
    for stone in scenery_pegs.duplicate():
        if stone.position.distance_to(actor.position)<29.0:
            scenery_pegs.erase(stone)
            stone.queue_free()
    add_child(actor)
    active_actors.append(actor)
    owned_ids.append(actor_id)
    board_claims["%d:%d"%[socket.x,socket.y]]=actor_id
    _rebuild_district()
    queue_redraw()
    return true

func _rebuild_district() -> void:
    district_links=DistrictScript.rebuild(active_actors)
    if city_stage!=null:city_stage.queue_redraw()

func _relocate_actor(actor:JianghuActor,target:Vector2i) -> bool:
    if phase!="build" or actor==null or not is_instance_valid(actor):return false
    if not can_place(target):return false
    if treasury<40:
        status_text="Moving a household costs 40 taels"
        status_timer=1.6
        return false
    var old_key="%d:%d"%[actor.socket.x,actor.socket.y]
    board_claims.erase(old_key)
    board_claims["%d:%d"%[target.x,target.y]]=str(actor.data.id)
    actor.socket=target
    actor.position=socket_position(target)
    treasury-=40
    for stone in scenery_pegs.duplicate():
        if stone.position.distance_to(actor.position)<30:
            scenery_pegs.erase(stone)
            stone.queue_free()
    _rebuild_district()
    sound.play_place()
    status_text="Household moved · new neighbors formed"
    status_timer=2.0
    save_run()
    return true

func _animate_world_segments() -> void:
    if motion_segments.is_empty():return
    for body in motion_segments:
        if not is_instance_valid(body):continue
        var n=int(body.get_meta("motion_id"))
        body.position=Vector2(sin(beat_clock*1.3+n*1.7)*29.0,0)

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO,Vector2(W,H)),active_background)
    if world_art!=null:
        var texture_size:Vector2=world_art.get_size()
        var crop:Rect2=Rect2(Vector2.ZERO,texture_size)
        var target_ratio:float=W/H
        if texture_size.x/texture_size.y>target_ratio:
            var crop_width:float=texture_size.y*target_ratio
            crop=Rect2((texture_size.x-crop_width)*.5,0,crop_width,texture_size.y)
        else:
            var crop_height:float=texture_size.x/target_ratio
            crop=Rect2(0,(texture_size.y-crop_height)*.5,texture_size.x,crop_height)
        draw_texture_rect_region(world_art,Rect2(0,0,W,H),crop,Color(1,1,1,.85 if phase=="menu" else .58))
    if phase=="menu":return
    # The translucent playfield retains painterly scenery without losing contrast.
    draw_rect(BOARD_RECT,Color(.97,.95,.87,.28))
    draw_rect(BOARD_RECT,Color(.21,.23,.20,.74),false,1.2)
    for i in range(board_segment_lines.size()):
        var segment=board_segment_lines[i]
        var offset=Vector2.ZERO
        if i>=2 and world_data.mechanic=="masks" and i-2<motion_segments.size():
            offset=motion_segments[i-2].position
        draw_line(segment[0]+offset,segment[1]+offset,Color(.24,.24,.22,.80),4.2,true)
        draw_line(segment[0]+offset+Vector2(0,-2),segment[1]+offset+Vector2(0,-2),Color(.89,.76,.57,.56),1.0,true)
    _draw_world_effects()
    if phase=="build":
        for row in range(5):
            for col in range(5):
                var socket=Vector2i(col,row)
                if not can_place(socket):continue
                var xy=socket_position(socket)
                draw_arc(xy,17,0,TAU,25,Color(.32,.42,.36,.42),1.25,true)
                draw_circle(xy,2.1,Color(.31,.42,.36,.66))
    if phase=="aim" and not reduce_motion:
        var o=Vector2(launch_x,192)
        var vector=Vector2(sin(aim_angle),cos(aim_angle))
        for i in range(1,13):
            var t=float(i)*.11
            var point=o+vector*275.0*t+Vector2(0,float(world_data.gravity)*.50*t*t)
            if BOARD_RECT.has_point(point):
                draw_circle(point,2.0,Color(.96,.66,.30,.76-float(i)*.043))
        draw_line(Vector2(launch_x,176),Vector2(launch_x,195),Color(.75,.39,.26,.9),2.5)
        draw_arc(Vector2(launch_x,180),13,0,TAU,30,Color(.96,.74,.35,.75),1.7)
    for e in fly_texts:
        if ui_font==null:continue
        var pos:Vector2=e.pos
        var col=Color(.80,.44,.20,clampf(float(e.life),0,1))
        draw_string(ui_font,pos,str(e.text),HORIZONTAL_ALIGNMENT_CENTER,-1,14,col)
    if not reduce_motion:
        for burst in ink_bursts:
            var fading:float=clampf(float(burst.life)/.54,0,1)
            var pos:Vector2=burst.pos
            var rad:float=13+(1-fading)*25
            for i in range(3):
                var theta=float(i)*TAU/3+float(burst.angle)
                draw_arc(pos,rad,theta,theta+.60,9,Color(.20,.19,.17,fading*.50),2.6,true)
            draw_circle(pos,4.3,Color.html(str(world_data.accent))*Color(1,1,1,fading*.20))

func _draw_world_effects() -> void:
    var tint=Color.html(str(world_data.accent))
    var m:String=str(world_data.mechanic)
    match m:
        "trade":
            for pos in [Vector2(55,344),Vector2(335,435),Vector2(55,558)]:
                for r in [10.0,15.5]:draw_arc(pos,r,PI*.16,PI*1.76,24,Color(tint,.23),1.6,true)
        "resonance":
            for pos in [Vector2(92,332),Vector2(298,445),Vector2(195,565)]:
                var pulse=sin(beat_clock*2.7+pos.y*.017)*2.0 if not reduce_motion else 0.0
                draw_arc(pos,22+pulse,0,TAU,36,Color(tint,.36),2.0,true)
                draw_arc(pos,31+pulse,0,TAU,36,Color(tint,.17),1.0,true)
        "masks":
            for j in range(2):
                var x=84.0 if j==0 else 308.0
                var y=344.0 if j==0 else 474.0
                var shift=sin(beat_clock*1.3+j*1.7)*27.0 if not reduce_motion else 0.0
                draw_colored_polygon(PackedVector2Array([Vector2(x+shift-11,y),Vector2(x+shift+11,y),Vector2(x+shift+62,y+67),Vector2(x+shift-62,y+67)]),Color(tint,.065))
                draw_arc(Vector2(x+shift,y+25),26,PI*.10,PI*.90,28,Color(tint,.31),2.2,true)
        "portals":
            for pos in [Vector2(53,405),Vector2(337,472)]:
                var breathe=sin(beat_clock*2.0)*3 if not reduce_motion else 0.0
                for r in [16.0,25.0]:draw_arc(pos,r+breathe,PI*.55,PI*1.45,23,Color(tint,.45),2.3,true)
        "wind":
            for k in range(5):
                var pts=PackedVector2Array()
                for s in range(28):
                    var x=42.0+s*11.2
                    var y=286.0+k*69.0+sin(x*.026+elapsed*1.0+k)*9.0
                    pts.append(Vector2(x,y))
                draw_polyline(pts,Color(tint,.13),1.6,true)
        "poison":
            draw_rect(Rect2(28,397,334,213),Color(tint,.085))
            for i in range(3):
                var points=PackedVector2Array()
                for j in range(32):
                    var x=28+j*10.6
                    points.append(Vector2(x,425+i*77+sin(j*.38+elapsed*.7+i)*5))
                draw_polyline(points,Color(tint,.24),1.4,true)
        "cargo":
            for i in range(6):
                var y=258+i*59.0
                var slide=sin(beat_clock*.63+i)*12 if not reduce_motion else 0.0
                draw_line(Vector2(42+slide,y),Vector2(113+slide,y+16),Color(tint,.23),2,true)
                draw_line(Vector2(268-slide,y+4),Vector2(338-slide,y+22),Color(tint,.23),2,true)
        "abacus":
            for c in range(3):
                var x=120.0+c*76.0
                draw_line(Vector2(x,235),Vector2(x,600),Color(tint,.19),1.4)
                for bead in range(5):
                    var y=270.0+bead*67.0+(10 if current_beat%8>=4 else 0)
                    draw_circle(Vector2(x,y),6.0,Color(tint,.20))

func _begin_aim() -> void:
    if phase!="build" and phase!="report":return
    phase="aim"
    selected_offer=-1
    launch_x=195.0
    aim_angle=0.0
    banner_text="TRACE THE PATH. RELEASE A PEARL."
    banner_timer=1.8
    save_run()
    queue_redraw()

func _launch() -> void:
    if phase!="aim":return
    phase="dropping"
    shot_number+=1
    quiet_time=0.0
    earnings_drop=0
    combo_count=0
    children_this_drop=0
    bell_summoned=false
    cinematic_act=0
    rhythm_chain=0
    beat_clock=0.0
    last_beat=-1
    current_beat=0
    hit_queue.clear()
    recent_hits.clear()
    var variant="jade"
    if world_data.mechanic=="cargo":variant="copper"
    if world_data.mechanic=="portals":variant="paper"
    _spawn_pearl(Vector2(launch_x,194),Vector2(sin(aim_angle),cos(aim_angle))*120.0,variant,true)
    drop_started_at=Time.get_ticks_msec()/1000.0
    sound.play_drop()
    queue_redraw()

func _spawn_pearl(at:Vector2,velocity:Vector2,kind:String="jade",seed:bool=false,chain:int=-1) -> void:
    if active_pearls.size()>=48:
        _award(42,at,"overflow")
        return
    var ball:JianghuPearl=PearlScript.new()
    var identity=int(rng.randi()) if chain<0 else chain
    ball.configure(self,kind,identity,seed)
    ball.position=at
    add_child(ball)
    ball.linear_velocity=velocity
    active_pearls.append(ball)

func _queue_spawn(at:Vector2,velocity:Vector2,kind:String,chain:int,origin:String="") -> void:
    if children_this_drop+spawn_queue.size()>=9:return
    spawn_queue.append({"pos":at,"vel":velocity,"kind":kind,"chain":chain,"origin":origin})

func _flush_spawn_queue() -> void:
    var n=mini(12,spawn_queue.size())
    for i in range(n):
        var item=spawn_queue.pop_front()
        children_this_drop+=1
        _spawn_pearl(item.pos,item.vel,item.kind,false,item.chain)

func apply_world_physics(pearl:JianghuPearl,delta:float) -> void:
    if phase!="dropping":return
    var m:String=str(world_data.mechanic)
    match m:
        "resonance":
            var b:float=fmod(beat_clock,60.0/float(world_data.bpm))
            if b<.11 and pearl.position.y>270 and pearl.position.y<580:
                pearl.apply_central_force(Vector2(0,-400.0*pearl.mass))
        "masks":
            if pearl.position.y>300 and pearl.position.y<570:
                pearl.apply_central_force(Vector2(sin(beat_clock*2.8)*310.0,0))
        "portals":
            if pearl.teleport_cooldown<=0 and pearl.position.y>290 and pearl.position.y<566:
                if pearl.position.x<65:
                    pearl.position=Vector2(318,clampf(565.0-pearl.position.y+300.0,294.0,586.0))
                    pearl.teleport_cooldown=1.1
                    _award(78,pearl.position,"bridge")
                    debt+=12
                    sound.play_magic()
                elif pearl.position.x>325:
                    pearl.position=Vector2(72,clampf(565.0-pearl.position.y+300.0,294.0,586.0))
                    pearl.teleport_cooldown=1.1
                    _award(78,pearl.position,"bridge")
                    debt+=12
                    sound.play_magic()
        "wind":
            var gust:float=sin(beat_clock*1.3+pearl.position.y*.015)*650.0
            pearl.apply_central_force(Vector2(gust*pearl.mass,0))
        "poison":
            if pearl.position.y>400 and pearl.position.y<580:
                pearl.linear_damp=2.2
                pearl.apply_central_force(Vector2(sin(beat_clock*3.1)*150,-120))
            else:pearl.linear_damp=.05
        "cargo":
            pearl.apply_central_force(Vector2(sin(beat_clock*.63)*530.0*pearl.mass,0))
            if pearl.statuses.has("goods"):
                pearl.mass=1.55
                pearl.linear_damp=.24
        "abacus":
            var eight: int=current_beat%8
            if eight>=4 and pearl.world_gravity_timer<=0:
                pearl.apply_central_force(Vector2(0,-pearl.mass*1350))
            pearl.apply_central_force(Vector2(sin(beat_clock*1.9)*210,0))
    _apply_boon_motion(pearl,delta)
    # Bounded velocity keeps touch trajectories legible under rare multiplier storms.
    if pearl.linear_velocity.length()>780:
        pearl.linear_velocity=pearl.linear_velocity.normalized()*780

func on_pearl_hit(pearl:JianghuPearl,body:Node) -> void:
    if phase!="dropping" or not is_instance_valid(pearl):return
    if body is JianghuActor:
        hit_queue.append({"pearl":pearl,"actor":body,"tick":global_tick})
    elif body is StaticBody2D:
        if world_data.mechanic=="cargo" and pearl.statuses.has("goods"):
            _award(12,pearl.position,"cargo slide")

func _resolve_hit_queue() -> void:
    if hit_queue.is_empty():return
    var copy=hit_queue.duplicate()
    hit_queue.clear()
    for event in copy:
        var pearl:JianghuPearl=event.pearl
        var actor:JianghuActor=event.actor
        if not is_instance_valid(pearl) or not is_instance_valid(actor):continue
        if pearl.collected:continue
        var key="%s:%s"%[pearl.get_instance_id(),actor.get_instance_id()]
        var now:float=Time.get_ticks_msec()/1000.0
        if now-float(recent_hits.get(key,-100))<.16:continue
        recent_hits[key]=now
        _activate_actor(pearl,actor)

func _activate_actor(pearl:JianghuPearl,actor:JianghuActor) -> void:
    var id:String=str(actor.data.id)
    var old_level:int=ReactionCatalog.mastery_level(actor.activation_count)
    actor.note_hit()
    if not actor.is_peg and seals_earned_today<18 and actor.activation_count%3==0:
        _grant_training_seals(1,actor.position)
    var new_level:int=ReactionCatalog.mastery_level(actor.activation_count)
    if not actor.is_peg and new_level>old_level:
        _award(90*new_level,actor.position,"martial mastery")
        banner_text=str(ReactionCatalog.REACTIONS.get(id,{}).get("ascension",str(actor.data.name))).to_upper()
        banner_timer=2.2
        sound.play_magic()
    pearl.hits+=1
    combo_count+=1
    best_combo=maxi(best_combo,combo_count)
    var beat_duration:float=60.0/float(world_data.bpm)
    var proximity:float=minf(fmod(beat_clock,beat_duration),beat_duration-fmod(beat_clock,beat_duration))
    var on_beat:bool=proximity<.11
    rhythm_chain=rhythm_chain+1 if on_beat else maxi(0,rhythm_chain-1)
    var amount:int=int(actor.data.get("earn",10))
    if actor.is_peg:
        amount=12+mini(pearl.hits,12)*3
    else:
        amount+=mini(pearl.hits,12)*4
        if pearl.statuses.has("drunk") and (id=="inn" or id=="drunken" or id=="tea"):
            amount+=78
        if pearl.statuses.has("blessed") and (id=="bell" or id=="gong" or id=="monk"):
            amount+=70
        if pearl.statuses.has("cursed") and (id=="ghost" or id=="moon" or id=="boat"):
            amount*=2
        if pearl.statuses.has("wanted") and (id=="bandit" or id=="assassin" or id=="mask"):
            amount+=110
        if pearl.statuses.has("goods") and ("trade" in actor.data.tags):
            amount+=105
        if pearl.statuses.has("poison") and id!="physician":
            amount+=40
        if pearl.statuses.has("manual") and id!="manual":amount+=86
        if on_beat:amount=int(round(float(amount)*1.35))
        _apply_actor_power(pearl,actor)
        _apply_world_hit_rule(pearl,actor,on_beat)
        amount=_apply_oath_rules(pearl,actor,amount,on_beat)
        amount+=_street_event_reward(pearl,actor,on_beat)
        amount+=_apply_boon_hit_effects(pearl,actor,on_beat)
        amount+=ReactionCatalog.apply(actor,pearl,self,on_beat)
        amount+=_apply_school_form(pearl,actor,on_beat)
        amount=int(round(float(amount)*(1.0+.18*float(new_level)+.16*float(actor.building_level-1))))
    _award(amount,actor.position,id)
    if not actor.is_peg and on_beat and rhythm_chain>=4:
        banner_text="THE PERFECT CADENCE   ×%d"%rhythm_chain
        banner_timer=1.05
        if haptics_on:Input.vibrate_handheld(14)
    if not actor.is_peg and sound!=null:
        sound.play_impact(actor.data.kind,combo_count,on_beat)
    if not actor.is_peg:
        if ink_bursts.size()>32:ink_bursts.pop_front()
        ink_bursts.append({"pos":actor.position,"life":.54,"angle":rng.randf_range(0,TAU)})
    if combo_count==10:
        var incidents=[
            "THE INNKEEPER MORTGAGED THE RAIN",
            "THE BELL HAS TAKEN A VOW OF NOISE",
            "TONIGHT THE ASSASSIN PLAYS THE BRIDE",
            "THE FERRYMAN BILLS BOTH RIVERBANKS",
            "THE WIND CLAIMS TO BE A SWORDMASTER",
            "THE DOCTOR PRESCRIBES A SECOND POISON",
            "THE CAMELS HAVE FORMED A UNION",
            "HEAVEN DEMANDS A RECEIPT FOR GRAVITY"
        ]
        banner_text=incidents[world_index]
        banner_timer=2.0
    if combo_count>=12+cinematic_act*12 and cinematic_act<3:
        _choreograph_fight(pearl)
    pearl.last_actor=id
    pearl.last_hit_at=Time.get_ticks_msec()/1000.0
    pearl.consume_statuses()
    if pearl.hits>58:
        _settle_pearl(pearl)

func _choreograph_fight(pearl:JianghuPearl) -> void:
    # A brush-stroke three-act wuxia action phrase, not a passive milestone.
    # The actual rigid body is redirected as if the town performed a move.
    var acts=[
        ["THE TABLE FLIES BEFORE THE FIGHT","THE INN GOES UP IN ARMS","THE TAB IS PASSED TO THE MOON"],
        ["THE NOVICE RUNS UP THE WALL","A HUNDRED BELLS ANSWER","THE ABBOT BREAKS HIS OWN SILENCE"],
        ["THE LEAD ACTOR LOSES HIS FACE","THE BALCONY BECOMES A DUEL","THE CURTAIN DOES NOT SURVIVE"],
        ["A GHOST SIGNS THE GUEST BOOK","THE FERRY SAILS INTO THE SKY","THE BRIDGE CHARGES ITS OWN TOLL"],
        ["A SWORD CLEAVES THE RAIN","THE BAMBOO BENDS LIKE A BOW","THE MASTER LANDS ON ONE LEAF"],
        ["THE HEALER FIGHTS WITH A LADLE","A THOUSAND HERBS TAKE FLIGHT","THE SWAMP SENDS THE BILL"],
        ["THE CARAVAN LEAVES THE ROAD","THE BANDIT STEALS THE SUNSET","THE CAMELS TAKE THE HIGH GROUND"],
        ["THE ABACUS REFUSES TO ADD UP","THE MAGISTRATE LOSES HIS SEAL","HEAVEN RECOUNTS EVERYTHING"]
    ]
    var line:String=str(acts[world_index][cinematic_act])
    cinematic_act+=1
    _grant_training_seals(2,pearl.position)
    match str(world_data.mechanic):
        "trade":pearl.apply_central_impulse(Vector2(185 if pearl.position.x<195 else -185,-195))
        "resonance":pearl.apply_central_impulse(Vector2(0,-285))
        "masks":pearl.apply_central_impulse(Vector2(-245 if pearl.linear_velocity.x>0 else 245,-175))
        "portals":
            pearl.apply_central_impulse(Vector2(215 if pearl.position.x<195 else -215,-120))
            pearl.set_status("cursed",4)
        "wind":pearl.apply_central_impulse(Vector2(290 if pearl.linear_velocity.x<0 else -290,-210))
        "poison":
            pearl.statuses.erase("poison")
            pearl.apply_central_impulse(Vector2(0,-250))
        "cargo":
            pearl.set_status("goods",5)
            pearl.apply_central_impulse(Vector2(195 if pearl.position.x<195 else -195,-155))
        "abacus":
            pearl.world_gravity_timer=1.0
            pearl.apply_central_impulse(Vector2(0,-290))
    if cinematic_act==2:
        _queue_spawn(pearl.position+Vector2(0,-17),Vector2(rng.randf_range(-100,100),-120),"paper",pearl.chain_id,"roof pursuit")
    _award(110+cinematic_act*65,pearl.position,"cinematic fight")
    ink_bursts.append({"pos":pearl.position,"life":.54,"angle":rng.randf_range(0,TAU)})
    banner_text=line
    banner_timer=1.65
    if sound!=null:sound.play_impact("swords",combo_count,true)

func _apply_oath_rules(pearl:JianghuPearl,actor:JianghuActor,base_amount:int,on_beat:bool) -> int:
    var oaths=DistrictScript.for_actor(actor,district_links)
    if oaths.is_empty():return base_amount
    var amount=base_amount+mini(3,oaths.size())*29
    for link in oaths.slice(0,3):
        # Renovations become neighborhood infrastructure: a high estate and
        # its trained resident make *other* partners in the oath more valuable.
        var neighbor:JianghuActor=link.b if link.a==actor else link.a
        amount+=maxi(0,neighbor.building_level-1)*21+neighbor.training_rank*13
        match str(link.kind):
            "banquet":
                pearl.set_status("drunk",4)
                if actor.activation_count%2==0:amount+=82
            "antidote":
                if pearl.statuses.has("poison"):
                    pearl.statuses.erase("poison")
                    debt=maxi(0,debt-38)
                    amount+=165
            "flying_school":
                if actor.activation_count%2==0:
                    pearl.apply_central_impulse(Vector2(115 if actor.position.x<195 else -115,-155))
                    amount+=76
            "freight":
                pearl.set_status("goods",5)
                if pearl.hits%3==0:amount+=135
            "night_tax":
                if pearl.statuses.has("cursed"):
                    amount+=192
                    debt+=11
            "second_face":
                pearl.set_status("wanted",4)
                if actor.activation_count%3==0:amount+=155
            "drums":
                if on_beat:
                    amount+=175
                    pearl.apply_central_impulse(Vector2(0,-80))
            "rival":
                if actor.activation_count%3==0:
                    pearl.apply_central_impulse(Vector2(130 if actor.position.x<195 else -130,-75))
                    amount+=105
            "stagecraft":
                if actor.activation_count%3==0:
                    pearl.apply_central_impulse(Vector2(0,-175))
                    amount+=110
            "crossing":
                if pearl.teleport_cooldown<=0:
                    pearl.apply_central_impulse(Vector2(180 if actor.position.x<195 else -180,-75))
                    pearl.teleport_cooldown=.8
            "oath":
                if on_beat:amount+=70
    return amount

func _apply_school_form(pearl:JianghuPearl,actor:JianghuActor,onbeat:bool) -> int:
    var rank:int=actor.training_rank
    if rank<=0:return 0
    match actor.discipline:
        "righteous":
            if onbeat or pearl.statuses.has("blessed"):
                pearl.statuses.erase("cursed")
                if rank>=2 and actor.activation_count%2==0:
                    pearl.apply_central_impulse(Vector2(0,-115))
                    pearl.set_status("blessed",4)
                if rank>=3:
                    pearl.statuses.erase("poison")
                    debt=maxi(0,debt-9)
                if rank>=4 and actor.activation_count%4==0:
                    _queue_spawn(actor.position+Vector2(0,-13),Vector2(85,-130),"paper",pearl.chain_id,"sword oath")
                return 65+rank*55
        "rogue":
            if pearl.statuses.has("wanted") or "outlaw" in actor.data.tags:
                debt+=3+rank
                if rank>=2 and actor.activation_count%2==0:pearl.set_status("wanted",5)
                if rank>=3 and actor.activation_count%3==0:
                    pearl.apply_central_impulse(Vector2(155 if actor.position.x<195 else -155,-110))
                if rank>=4 and actor.activation_count%5==0:
                    _queue_spawn(actor.position+Vector2(0,-9),Vector2(-110,-100),"iron",pearl.chain_id,"bandit disciple")
                return 90+rank*75
        "wanderer":
            if pearl.statuses.has("goods") or pearl.linear_velocity.length()>330:
                if rank>=2:pearl.apply_central_impulse(Vector2(80 if pearl.position.x<195 else -80,-90))
                if rank>=3:pearl.set_status("goods",5)
                if rank>=4 and actor.activation_count%4==0 and pearl.teleport_cooldown<=0:
                    pearl.position.x=clampf(390-pearl.position.x,47,343)
                    pearl.teleport_cooldown=1.3
                return 70+rank*65
    return 0

func next_training_cost(rank:int) -> int:
    return [3,5,8,13][clampi(rank,0,3)]

func next_training_hits(rank:int) -> int:
    return [0,6,18,40][clampi(rank,0,3)]

func _grant_training_seals(amount:int,at:Vector2) -> void:
    var granted:int=mini(maxi(0,18-seals_earned_today),amount)
    if granted<=0:return
    seals_earned_today+=granted
    training_seals+=granted
    if fly_texts.size()>30:fly_texts.pop_front()
    fly_texts.append({"pos":at+Vector2(7,-18),"text":"+%d seals"%granted,"life":1.3})

func _train_actor(actor:JianghuActor,school:String) -> bool:
    if phase!="build" or actor==null or not is_instance_valid(actor):return false
    if actor.training_rank>=4:return false
    if school not in ["righteous","rogue","wanderer"]:return false
    if actor.discipline!="none" and actor.discipline!=school:return false
    var required:int=next_training_hits(actor.training_rank)
    if actor.activation_count<required:
        status_text="Practice %d more contacts first"%(required-actor.activation_count)
        status_timer=1.6
        return false
    var cost:int=next_training_cost(actor.training_rank)
    if training_seals<cost:
        status_text="Need %d martial seals (have %d)"%[cost,training_seals]
        status_timer=1.6
        return false
    training_seals-=cost
    actor.discipline=school
    actor.training_rank+=1
    actor.queue_redraw()
    banner_text="%s SCHOOL · FORM %d / 4"%[school.to_upper(),actor.training_rank]
    banner_timer=1.8
    sound.play_place()
    save_run()
    return true

func building_upgrade_cost(actor:JianghuActor) -> int:
    if actor==null or not is_instance_valid(actor) or actor.building_level>=5:return 0
    return [0,150,300,600,1000][actor.building_level]+int(actor.data.cost)*int(actor.building_level-1)/3

func _upgrade_building(actor:JianghuActor) -> bool:
    if phase!="build" or actor==null or not is_instance_valid(actor) or actor.building_level>=5:return false
    var cost:int=building_upgrade_cost(actor)
    if treasury<cost:
        status_text="Need %d taels to expand this household"%cost
        status_timer=1.7
        return false
    treasury-=cost
    actor.grow_building(actor.building_level+1)
    banner_text="%s · %d-STOREY LEGEND"%[str(actor.data.name).to_upper(),actor.building_level]
    banner_timer=2.0
    sound.play_place()
    save_run()
    return true

func _apply_boon_hit_effects(pearl:JianghuPearl,actor:JianghuActor,onbeat:bool) -> int:
    var bonus:int=0
    var tags:Array=actor.data.get("tags",[])
    for boon_id in boons:
        var boon:Dictionary=BoonCatalog.boon(boon_id)
        if boon.is_empty():continue
        var target:String=str(boon.target)
        var value:int=int(boon.value)
        match str(boon.family):
            "sect":
                if target in tags:bonus+=value
            "status":
                if target=="fish" and pearl.variant=="fish" or pearl.statuses.has(target):bonus+=value
            "lane":
                var qualifies:bool=false
                match target:
                    "top":qualifies=actor.position.y<365
                    "bottom":qualifies=actor.position.y>465
                    "left":qualifies=actor.position.x<155
                    "right":qualifies=actor.position.x>235
                    "edge":qualifies=absf(actor.position.x-195)>115
                    "center":qualifies=absf(actor.position.x-195)<78
                    "ascending":qualifies=pearl.linear_velocity.y<0
                    "descending":qualifies=pearl.linear_velocity.y>=0
                if qualifies:bonus+=value
            "rhythm":
                var fits:bool=false
                match target:
                    "onbeat":fits=onbeat
                    "offbeat":fits=not onbeat
                    "streak3":fits=rhythm_chain>=3
                    "streak5":fits=rhythm_chain>=5
                    "oddbeat":fits=current_beat%2==1
                    "downbeat4":fits=current_beat%4==0
                    "combo15":fits=combo_count>=15
                    "combo30":fits=combo_count>=30
                if fits:bonus+=value
            "summon":
                if target in tags and actor.activation_count%maxi(1,value)==0:
                    var kind="paper"
                    if target=="trade":kind="copper"
                    if target=="spirit":kind="ghost"
                    if target=="outlaw":kind="iron"
                    if target=="water":kind="fish"
                    if target=="official":kind="jade"
                    _queue_spawn(actor.position+Vector2(0,-22),Vector2(rng.randf_range(-155,155),-170),kind,pearl.chain_id,"boon "+boon_id)
                    bonus+=70
            "motion":
                if target=="weight" and pearl.linear_velocity.y>320:bonus+=90
    return bonus

func _apply_boon_motion(pearl:JianghuPearl,_delta:float) -> void:
    for boon_id in boons:
        var boon=BoonCatalog.boon(boon_id)
        if boon.is_empty() or str(boon.family)!="motion":continue
        var value:float=float(boon.value)
        match str(boon.target):
            "east":pearl.apply_central_force(Vector2(value,0))
            "west":pearl.apply_central_force(Vector2(-value,0))
            "lift":pearl.apply_central_force(Vector2(0,-value*pearl.mass))
            "weight":pearl.apply_central_force(Vector2(0,value*pearl.mass))
            "center":pearl.apply_central_force(Vector2(signf(195-pearl.position.x)*value,0))
            "edge":pearl.apply_central_force(Vector2(signf(pearl.position.x-195)*value,0))
            "slippery":pearl.linear_damp=maxf(0.01,pearl.linear_damp-.14)
            "sticky":pearl.linear_damp+=.16

func _apply_actor_power(pearl:JianghuPearl,actor:JianghuActor) -> void:
    var id:String=str(actor.data.id)
    match id:
        "tea":pearl.set_status("drunk",5)
        "drunken":
            pearl.set_status("drunk",5)
            pearl.apply_central_impulse(Vector2(155*(-1 if pearl.linear_velocity.x>0 else 1),-225))
        "inn":
            if pearl.statuses.has("drunk"):
                pearl.apply_central_impulse(Vector2(90,-155))
        "caravan":pearl.set_status("goods",7)
        "broker":
            if pearl.statuses.has("goods"):
                pearl.statuses.erase("goods")
                _award(280,actor.position,"cargo sold")
        "rice":
            if actor.activation_count%4==0:
                _queue_spawn(actor.position+Vector2(0,-20),Vector2(rng.randf_range(-100,100),-165),"copper",pearl.chain_id,"rice")
        "bell":
            pearl.set_status("blessed",5)
            if pearl.is_seed and not bell_summoned:
                bell_summoned=true
                _queue_spawn(actor.position+Vector2(-7,-19),Vector2(-80,-120),"paper",pearl.chain_id,"bell")
                _queue_spawn(actor.position+Vector2(7,-19),Vector2(80,-120),"paper",pearl.chain_id,"bell")
        "monk":pearl.set_status("blessed",5)
        "wheel":
            pearl.world_gravity_timer=1.0
            pearl.apply_central_impulse(Vector2(0,-320))
        "gong":
            pearl.apply_central_impulse(Vector2(rng.randf_range(-85,85),-115))
        "pond":
            pearl.variant="fish"
            pearl.apply_central_impulse(Vector2(140,-150))
        "fan":pearl.apply_central_impulse(Vector2(-230 if pearl.position.x>195 else 230,-90))
        "bandit":pearl.set_status("wanted",5)
        "physician":
            var cured:bool=pearl.statuses.has("poison") or pearl.statuses.has("cursed")
            pearl.statuses.erase("poison")
            pearl.statuses.erase("cursed")
            if cured:_award(180,actor.position,"cure")
        "opera":pearl.apply_central_impulse(Vector2(rng.randf_range(-150,150),-195))
        "mask":
            if pearl.statuses.has("wanted"):
                pearl.statuses.erase("wanted")
                _award(110,actor.position,"unmasked")
            else:pearl.set_status("wanted",4)
        "assassin":
            pearl.set_status("wanted",5)
            _award(145,actor.position,"bounty")
        "official":
            var tax: int=mini(treasury,30)
            treasury-=tax
            _award(tax*2+30,actor.position,"stamped")
        "ghost":
            pearl.set_status("cursed",5)
            debt+=24
        "moon":
            pearl.set_status("cursed",3)
            if pearl.teleport_cooldown<=0:
                pearl.position=Vector2(BOARD_RECT.end.x-40 if pearl.position.x<195 else BOARD_RECT.position.x+40,clampf(670-pearl.position.y,208,613))
                pearl.teleport_cooldown=1.0
        "boat":pearl.apply_central_impulse(Vector2(180,-240))
        "bamboo":pearl.apply_central_impulse(Vector2(-260 if pearl.position.x>195 else 260,-75))
        "sword":
            _queue_spawn(actor.position+Vector2(0,-16),Vector2(rng.randf_range(-190,190),-260),"iron",pearl.chain_id,"sword")
        "poison":pearl.set_status("poison",5)
        "abacus":
            if combo_count%4==0:_award(320+combo_count*8,actor.position,"abacus")
        "cloud":
            if pearl.variant=="paper":pearl.apply_central_impulse(Vector2(0,-340))
        "lantern":
            if actor.activation_count%3==0:
                _queue_spawn(actor.position+Vector2(0,-18),Vector2(rng.randf_range(-90,90),-160),"paper",pearl.chain_id,"lantern")
        "mirror":
            if pearl.statuses.has("blessed"):
                _queue_spawn(actor.position+Vector2(8,-18),Vector2(135,-105),"jade",pearl.chain_id,"mirror")
        "noodle":
            pearl.set_status("drunk",4)
            if pearl.statuses.has("goods"):_award(115,actor.position,"noodles for traders")
        "dice":
            if pearl.hits%2==1:
                _award(165,actor.position,"crooked sixes")
            else:
                debt+=14
                pearl.apply_central_impulse(Vector2(rng.randf_range(-170,170),-70))
        "umbrella":
            pearl.apply_central_impulse(Vector2(-270 if pearl.linear_velocity.x>0 else 270,-175))
            if pearl.statuses.has("wanted"):pearl.set_status("blessed",3)
        "lion":
            pearl.apply_central_impulse(Vector2(110 if actor.position.x<195 else -110,-250))
            if actor.activation_count%3==0:
                _queue_spawn(actor.position+Vector2(0,-27),Vector2(rng.randf_range(-130,130),-170),"copper",pearl.chain_id,"lion")
        "bridge":
            if pearl.statuses.has("goods"):
                _award(115,actor.position,"cross-town delivery")
        "sleeve":
            pearl.apply_central_impulse(Vector2(240 if pearl.position.x<195 else -240,-290))
        "archer":
            if actor.activation_count%2==0:
                _queue_spawn(actor.position+Vector2(0,-22),Vector2(165 if actor.position.x<195 else -165,-170),"paper",pearl.chain_id,"archer")
        "manual":
            pearl.set_status("manual",4)
            if pearl.last_actor!="":_award(70,actor.position,"borrowed technique")
        "judge":
            if pearl.statuses.has("wanted"):
                pearl.statuses.erase("wanted")
                debt=maxi(0,debt-35)
                _award(240,actor.position,"wanted warrant")
            else:pearl.set_status("wanted",3)
        "abbot":
            pearl.set_status("blessed",4)
            pearl.apply_central_impulse(Vector2((actor.activation_count%3-1)*130,-245))
        "dummy":
            if actor.activation_count%3==0:
                pearl.apply_central_impulse(Vector2(0,-250))
                _award(170,actor.position,"third wooden strike")
        "drum":
            var period:float=60.0/float(world_data.bpm)
            var beat:float=fmod(beat_clock,period)
            if minf(beat,period-beat)<.11:
                _award(170,actor.position,"lion-dance downbeat")
                pearl.apply_central_impulse(Vector2(0,-140))
        "costume":
            if pearl.statuses.has("wanted"):
                pearl.statuses.erase("wanted")
                pearl.set_status("blessed",5)
                _award(190,actor.position,"hero in borrowed robes")
            else:pearl.set_status("wanted",3)
        "trap":
            if pearl.teleport_cooldown<=0:
                pearl.position=Vector2(clampf(actor.position.x+rng.randf_range(-60,60),57,333),230)
                pearl.linear_velocity=Vector2(rng.randf_range(-160,160),90)
                pearl.teleport_cooldown=1.0
        "ferry":
            if pearl.teleport_cooldown<=0:
                pearl.position=Vector2(325 if actor.position.x<195 else 65,clampf(actor.position.y-38,226,580))
                pearl.teleport_cooldown=.9
                _award(110,actor.position,"unlicensed ferry")
        "relic":
            if pearl.statuses.has("cursed") or pearl.statuses.has("poison"):
                pearl.statuses.erase("cursed")
                pearl.statuses.erase("poison")
                pearl.set_status("blessed",5)
                _award(190,actor.position,"jade authenticity")
        "gourd":
            var ailment=pearl.statuses.has("poison") or pearl.statuses.has("cursed")
            pearl.statuses.erase("poison")
            pearl.statuses.erase("cursed")
            pearl.apply_central_impulse(Vector2(0,-180))
            if ailment:_award(210,actor.position,"gourd medicine")
        "firework":
            for target in active_pearls:
                if not is_instance_valid(target) or target.collected:continue
                if target.position.distance_to(actor.position)>125:continue
                var direction=(target.position-actor.position).normalized()
                if direction.length_squared()<.01:direction=Vector2.UP
                target.apply_central_impulse(direction*190+Vector2(0,-85))
            if actor.activation_count%3==0:
                _queue_spawn(actor.position+Vector2(0,-24),Vector2(rng.randf_range(-200,200),-180),"copper",pearl.chain_id,"firework")
        "silk":
            pearl.set_status("goods",7)
            if pearl.hits%3==0:_award(190,actor.position,"silk sold by weight")

func _apply_world_hit_rule(pearl:JianghuPearl,actor:JianghuActor,on_beat:bool) -> void:
    var m:String=str(world_data.mechanic)
    match m:
        "trade":
            var tag:String=str(actor.data.tags[0]) if actor.data.tags.size()>0 else ""
            if tag!="" and not actor_trades.has(tag):
                actor_trades[tag]=true
                if actor_trades.size()>=3:
                    _award(230,actor.position,"three shops")
                    actor_trades.clear()
        "resonance":
            if on_beat and (actor.data.kind=="bell" or actor.data.kind=="wheel"):
                _award(135,actor.position,"resonance")
                pearl.apply_central_impulse(Vector2(0,-155))
        "masks":
            if actor.data.kind=="mask":
                _award(80,actor.position,"curtain call")
                pearl.apply_central_impulse(Vector2(0,-145))
        "portals":
            if pearl.teleport_cooldown>0.0:
                _award(95,actor.position,"bridge toll")
        "wind":
            if on_beat:
                _award(75,actor.position,"sword breeze")
        "poison":
            if pearl.statuses.has("poison") and str(actor.data.id)!="physician":
                debt+=5
            elif str(actor.data.id)=="physician":
                _award(90,actor.position,"antidote")
        "cargo":
            if pearl.statuses.has("goods") and pearl.hits%3==0:
                _award(180,actor.position,"long caravan")
        "abacus":
            if current_beat%4==0:
                _award(105,actor.position,"heavenly column")

func event_name() -> String:
    var events={
        "trade":["Night Market Opens","Wine Auction","Bandit Inspection"],
        "resonance":["Sutra Procession","Wooden Dummy Trial","Silent Bell Hour"],
        "masks":["Festival of Painted Faces","Unmasking Night","Curtain Call"],
        "portals":["Ghostly Boat Race","Eclipse Tolls","Debt Forgiveness"],
        "wind":["Bamboo Duel","Kite Wind Contest","Swordsman Pilgrimage"],
        "poison":["Apothecary Fair","The Fever Season","Herbal Amnesty"],
        "cargo":["Caravan Convoy","Bandit Horse Fair","Midnight Freight"],
        "abacus":["Heavenly Examination","The Imperial Audit","Abacus Reckoning"]
    }
    var names:Array=events[str(world_data.mechanic)]
    return str(names[clampi(street_event,0,2)])

func _street_event_reward(pearl:JianghuPearl,actor:JianghuActor,onbeat:bool) -> int:
    var tags:Array=actor.data.get("tags",[])
    var amount:int=0
    match street_event:
        0:
            if str(world_data.mechanic) in ["trade","cargo"] and "trade" in tags:amount=88
            elif str(world_data.mechanic)=="resonance" and "orthodox" in tags:amount=90
            elif str(world_data.mechanic)=="masks" and "mask" in tags:amount=95
            elif str(world_data.mechanic)=="portals" and "water" in tags:amount=80
            elif str(world_data.mechanic)=="wind" and "martial" in tags:amount=78
            elif str(world_data.mechanic)=="poison" and "heal" in tags:amount=95
            elif str(world_data.mechanic)=="abacus" and "official" in tags:amount=95
        1:
            if "outlaw" in tags:
                amount=100
                if pearl.statuses.has("wanted"):amount+=80
            elif "trade" in tags and str(world_data.mechanic) in ["trade","cargo"]:amount=70
            elif "martial" in tags:amount=55
        2:
            if onbeat:amount=115
            elif "heal" in tags and str(world_data.mechanic)=="poison":amount=55
    return amount

func _invoke_technique() -> bool:
    if phase!="dropping" or technique_used_today or pause_sim:return false
    var chosen:JianghuPearl=null
    for pearl in active_pearls:
        if not is_instance_valid(pearl) or pearl.collected:continue
        if chosen==null or (pearl.is_seed and not chosen.is_seed):chosen=pearl
    if chosen==null:return false
    technique_used_today=true
    var beat_seconds:float=60.0/float(world_data.bpm)
    var offset:float=fmod(beat_clock,beat_seconds)
    var onbeat:bool=minf(offset,beat_seconds-offset)<.12
    var force:float=1.4 if onbeat else 1.0
    match str(world_data.mechanic):
        "trade":
            chosen.set_status("goods",5)
            chosen.apply_central_impulse(Vector2(240 if chosen.position.x<195 else -240,-275)*force)
        "resonance":
            chosen.set_status("blessed",5)
            chosen.apply_central_impulse(Vector2(0,-370)*force)
        "masks":
            chosen.set_status("wanted",4)
            chosen.apply_central_impulse(Vector2(-255 if chosen.linear_velocity.x>0 else 255,-320)*force)
        "portals":
            chosen.position=Vector2(clampf(390-chosen.position.x,55,335),clampf(chosen.position.y-175,212,550))
            chosen.teleport_cooldown=1.1
            chosen.set_status("cursed",4)
            debt+=18
        "wind":
            chosen.apply_central_impulse(Vector2(280 if chosen.linear_velocity.x<0 else -280,-420)*force)
        "poison":
            chosen.statuses.erase("poison")
            chosen.statuses.erase("cursed")
            debt=maxi(0,debt-80)
            chosen.apply_central_impulse(Vector2(0,-345)*force)
        "cargo":
            chosen.set_status("goods",8)
            chosen.apply_central_impulse(Vector2(350 if chosen.position.x<195 else -350,-220)*force)
        "abacus":
            chosen.world_gravity_timer=1.7
            chosen.linear_velocity=-chosen.linear_velocity*.8+Vector2(0,-300)*force
            chosen.set_status("blessed",4)
    _award(235 if onbeat else 95,chosen.position,"martial intervention")
    ink_bursts.append({"pos":chosen.position,"life":.54,"angle":rng.randf_range(0,TAU)})
    banner_text=str(world_data.technique)+( "  ·  PERFECT BEAT" if onbeat else "")
    banner_timer=1.8
    sound.play_magic()
    if haptics_on:Input.vibrate_handheld(19)
    queue_redraw()
    return true

func _award(amount:int,at:Vector2,reason:String) -> void:
    if amount<=0:return
    # Renown lifts the economy as tribute requirements escalate. The combo
    # supplement rewards complicated bounce routes without replacing physics.
    amount=int(round(float(amount)*(1.0+float(day-1)*.18)*(1.0+float(mini(combo_count,25))*.019)))
    treasury+=amount
    total_earned+=amount
    earnings_today+=amount
    earnings_drop+=amount
    if amount>=35:
        fly_texts.append({"pos":at+Vector2(rng.randf_range(-7,7),-12),"text":"+%s"%short_money(amount),"life":1.1})
    status_text=reason.capitalize()
    status_timer=.7

func _settle_pearl(pearl:JianghuPearl) -> void:
    if not is_instance_valid(pearl):return
    pearl.collected=true
    active_pearls.erase(pearl)
    if pearl.hits>3 and pearl.is_seed:
        _award(mini(pearl.hits,24)*6,Vector2(clampf(pearl.position.x,50,337),620),"journey")
    pearl.queue_free()

func _end_drop() -> void:
    if phase!="dropping":return
    _set_pause(false)
    fast_speed=false
    Engine.time_scale=1.0
    if shot_number<2:
        phase="aim"
        status_text="First pearl earned %s taels"%short_money(earnings_drop)
        status_timer=2.0
        banner_text="ONE MORE PEARL"
        banner_timer=1.4
        save_run()
    else:
        phase="report"
        if debt>0:
            var paid=mini(treasury,debt)
            treasury-=paid
            debt-=paid
        banner_text="THE LEDGER REMEMBERS"
        banner_timer=1.7
        save_run()
    sound.on_settle()
    queue_redraw()

func _next_day() -> void:
    if day%3==0:
        phase="tribute"
    else:
        _advance_day()
    save_run()
    queue_redraw()

func _advance_day() -> void:
    day+=1
    shot_number=0
    builds_today=0
    earnings_today=0
    technique_used_today=false
    seals_earned_today=0
    street_event=(day-1)%3
    offer_cards=Catalog.offers(world_index,owned_ids,rng)
    selected_offer=-1
    actor_trades.clear()
    phase="build"
    if boons.has("tea_endowment"):_award(100,Vector2(195,220),"tea endowment")
    if boons.has("abbey_endowment"):
        var orthodox:int=0
        for actor in active_actors:
            if "orthodox" in actor.data.tags:orthodox+=1
        if orthodox>0:_award(orthodox*60,Vector2(195,220),"abbey endowment")
    banner_text="THE NEXT MORNING"
    banner_timer=1.5
    save_run()
    queue_redraw()

func current_tribute() -> int:
    var index=clampi(int((day-1)/3),0,4)
    var quotas=[350,1200,4000,12000,35000]
    var tribute=int(round(float(quotas[index])*float(world_data.quota)))
    if boons.has("royal_rebate"):tribute=int(round(tribute*.90))
    return tribute

func _pay_tribute() -> void:
    var owed=current_tribute()
    if treasury<owed:
        phase="loss"
        run_flags["last_loss"]="The red ledger could not be paid."
        _clear_save()
        sound.on_loss()
        return
    treasury-=owed
    sound.on_tribute()
    if day>=15:
        phase="victory"
        world_stamps[str(world_data.id)]=true
        _save_preferences()
        _clear_save()
        return
    boon_cards=BoonCatalog.offers(boons,rng)
    phase="boon"
    banner_text="THE MAGISTRATE OFFERS THREE FAVORS"
    banner_timer=1.8
    save_run()

func _choose_boon(index:int) -> void:
    if phase!="boon" or index<0 or index>=boon_cards.size():return
    var boon_id:String=boon_cards[index]
    if boons.has(boon_id):return
    boons.append(boon_id)
    if boon_id=="debt_amnesty":debt=int(debt*.5)
    var label=str(BoonCatalog.boon(boon_id).name)
    boon_cards.clear()
    _advance_day()
    banner_text=label.to_upper()+"  ·  RECORDED IN THE SCROLL"
    banner_timer=2.4
    sound.play_place()

func _sell_to_pay() -> void:
    if active_actors.is_empty():return
    var best:JianghuActor=active_actors[0]
    for actor in active_actors:
        if int(actor.data.cost)>int(best.data.cost):best=actor
    var refund:int=int(round(float(best.data.cost)*(.70 if boons.has("pawns_certificate") else .50)))
    treasury+=refund
    board_claims.erase("%d:%d"%[best.socket.x,best.socket.y])
    active_actors.erase(best)
    best.queue_free()
    _rebuild_district()
    banner_text="SOLD FOR %d TAELS"%refund
    banner_timer=1.6
    save_run()

func short_money(value:int) -> String:
    if value>=1000000:return "%.2fM"%(float(value)/1000000.0)
    if value>=10000:return "%.1fk"%(float(value)/1000.0)
    return str(value)

func _purchase_actor(actor_id:String,socket:Vector2i) -> bool:
    if builds_today>=build_limit():
        status_text="This morning's two building permits are spent"
        status_timer=1.7
        return false
    var cost:int=purchase_cost(actor_id)
    if not can_place(socket):
        status_text="A companion already stands there"
        status_timer=1.4
        return false
    if treasury<cost:
        status_text="Need %d taels for this companion"%cost
        status_timer=1.6
        if sound!=null:sound.play_select()
        return false
    if not _place_actor(actor_id,socket):return false
    treasury-=cost
    builds_today+=1
    return true

func build_limit() -> int:
    return 3 if boons.has("extra_permit") else 2

func purchase_cost(actor_id:String) -> int:
    var data:Dictionary=Catalog.actor(actor_id)
    var amount:float=float(data.cost)
    if boons.has("merchant_charter") and "trade" in data.tags:amount*=.75
    if boons.has("temple_charter") and "martial" in data.tags:amount*=.80
    return maxi(1,int(round(amount)))

func _set_pause(value:bool) -> void:
    pause_sim=value
    for pearl in active_pearls:
        if is_instance_valid(pearl):pearl.freeze=value

func _input(event:InputEvent) -> void:
    if event is InputEventScreenTouch:
        var touch:=event as InputEventScreenTouch
        if touch.pressed and touch_id==-1:
            touch_id=touch.index
            drag_origin=touch.position
            touch_moved=false
            dragging=true
            _press_at(touch.position)
        elif not touch.pressed and touch.index==touch_id:
            _release_at(touch.position)
            touch_id=-1
            dragging=false
    elif event is InputEventScreenDrag:
        var drag:=event as InputEventScreenDrag
        if drag.index==touch_id:
            if drag.position.distance_to(drag_origin)>15:touch_moved=true
            _drag_at(drag.position)
    elif event is InputEventMouseButton:
        var mb:=event as InputEventMouseButton
        if mb.button_index!=MOUSE_BUTTON_LEFT:return
        if mb.pressed:
            drag_origin=mb.position
            dragging=true
            touch_moved=false
            _press_at(mb.position)
        else:
            _release_at(mb.position)
            dragging=false
    elif event is InputEventMouseMotion and dragging:
        var mm:=event as InputEventMouseMotion
        if mm.position.distance_to(drag_origin)>15:touch_moved=true
        _drag_at(mm.position)
    elif event is InputEventKey and event.pressed and not event.echo:
        if event.keycode==KEY_SPACE and phase=="aim":_launch()
        elif event.keycode==KEY_ESCAPE:
            if phase=="dropping":_set_pause(not pause_sim)
            elif phase!="menu":phase="menu"

func _press_at(pos:Vector2) -> void:
    if phase=="menu":
        if Rect2(292,546,68,76).has_point(pos):
            selected_world=(selected_world+1)%8
            _refresh_world(selected_world)
        elif Rect2(28,546,68,76).has_point(pos):
            selected_world=(selected_world+7)%8
            _refresh_world(selected_world)
        elif Rect2(49,682,292,60).has_point(pos):
            start_dream(selected_world)
        elif Rect2(82,752,226,49).has_point(pos) and FileAccess.file_exists(SAVE_PATH):
            restore_run()
        elif Rect2(328,49,45,44).has_point(pos):
            phase="settings"
    elif phase=="settings":
        if Rect2(34,716,322,70).has_point(pos):
            phase="menu"
        elif Rect2(39,280,315,66).has_point(pos):music_on=!music_on
        elif Rect2(39,355,315,66).has_point(pos):haptics_on=!haptics_on
        elif Rect2(39,430,315,66).has_point(pos):reduce_motion=!reduce_motion
        elif Rect2(39,505,315,66).has_point(pos):show_high_contrast=!show_high_contrast
        _save_preferences()
        if sound!=null:sound.set_music_enabled(music_on)
    elif phase=="build":
        if selected_offer==-1 and selected_actor!=null and is_instance_valid(selected_actor) and Rect2(28,477,334,173).has_point(pos):
            if inspect_mode=="home":
                if Rect2(38,586,149,51).has_point(pos):_upgrade_building(selected_actor)
                elif Rect2(201,586,151,51).has_point(pos):inspect_mode="training"
            elif inspect_mode=="training":
                if Rect2(37,486,76,46).has_point(pos):inspect_mode="home"
                elif selected_actor.training_rank==0 and Rect2(35,584,322,50).has_point(pos):
                    var choice=clampi(int((pos.x-35)/108),0,2)
                    _train_actor(selected_actor,["righteous","rogue","wanderer"][choice])
                elif selected_actor.training_rank>0 and Rect2(113,583,240,51).has_point(pos):
                    _train_actor(selected_actor,selected_actor.discipline)
        elif Rect2(285,762,88,47).has_point(pos):
            _begin_aim()
        elif Rect2(16,762,107,47).has_point(pos):
            if treasury>=60 and builds_today<build_limit():
                treasury-=60
                offer_cards=Catalog.offers(world_index,owned_ids,rng)
                selected_offer=-1
        elif Rect2(19,669,352,85).has_point(pos):
            for i in range(offer_cards.size()):
                if Rect2(20+i*119,669,109,85).has_point(pos):
                    selected_offer=i
                    selected_actor=null
                    inspect_mode="home"
                    sound.play_select()
                    break
        elif BOARD_RECT.has_point(pos):
            if selected_offer>=0 and selected_offer<offer_cards.size():
                var slot=socket_for_position(pos)
                if _purchase_actor(offer_cards[selected_offer],slot):
                    selected_offer=-1
                    offer_cards=Catalog.offers(world_index,owned_ids,rng) if builds_today<build_limit() else []
                    status_text="Placed in the scroll"
                    status_timer=1.5
                    sound.play_place()
                    save_run()
            else:
                var tapped=_actor_at(pos)
                if tapped!=null:
                    selected_actor=tapped
                    inspect_mode="home"
                elif selected_actor!=null:
                    if _relocate_actor(selected_actor,socket_for_position(pos)):
                        selected_actor=null
    elif phase=="aim":
        if Rect2(42,756,306,51).has_point(pos):
            _launch()
        elif Rect2(35,674,321,38).has_point(pos):
            launch_x=clampf(pos.x,48,342)
        elif Rect2(35,719,321,34).has_point(pos):
            aim_angle=clampf((pos.x-195.0)/160.0,-1.0,1.0)*.68
        elif BOARD_RECT.has_point(pos):
            aim_angle=clampf((pos.x-launch_x)/220.0,-1.0,1.0)*.68
    elif phase=="dropping":
        if Rect2(35,759,320,48).has_point(pos):
            _invoke_technique()
        elif Rect2(309,65,63,51).has_point(pos):
            _set_pause(not pause_sim)
        elif Rect2(31,65,62,51).has_point(pos):
            fast_speed=!fast_speed
            Engine.time_scale=1.55 if fast_speed else 1.0
    elif phase=="report":
        if Rect2(40,755,310,55).has_point(pos):_next_day()
        elif BOARD_RECT.has_point(pos):selected_actor=_actor_at(pos)
    elif phase=="tribute":
        if Rect2(40,755,310,55).has_point(pos):_pay_tribute()
        elif Rect2(53,688,284,51).has_point(pos):_sell_to_pay()
    elif phase=="boon":
        for i in range(boon_cards.size()):
            if Rect2(34,437+i*99,322,91).has_point(pos):
                _choose_boon(i)
                break
    elif phase=="victory" or phase=="loss":
        if Rect2(42,752,306,58).has_point(pos):start_dream(world_index)
        elif Rect2(84,674,223,55).has_point(pos):phase="menu"
    queue_redraw()

func _drag_at(pos:Vector2) -> void:
    if phase=="menu":
        return
    if phase=="aim":
        if drag_origin.y>=674 and drag_origin.y<718:
            launch_x=clampf(pos.x,48,342)
        elif drag_origin.y>=718 and drag_origin.y<756:
            aim_angle=clampf((pos.x-195.0)/160.0,-1.0,1.0)*.68
        elif BOARD_RECT.has_point(drag_origin):
            aim_angle=clampf((pos.x-launch_x)/220.0,-1.0,1.0)*.68
    queue_redraw()

func _release_at(pos:Vector2) -> void:
    if phase=="menu" and touch_moved and absf(pos.x-drag_origin.x)>48:
        selected_world=(selected_world+1)%8 if pos.x<drag_origin.x else (selected_world+7)%8
        _refresh_world(selected_world)
    if phase=="build" and touch_moved and selected_offer>=0 and BOARD_RECT.has_point(pos):
        var slot=socket_for_position(pos)
        if _purchase_actor(offer_cards[selected_offer],slot):
            selected_offer=-1
            offer_cards=Catalog.offers(world_index,owned_ids,rng) if builds_today<build_limit() else []
            sound.play_place()
            save_run()
    elif phase=="build" and touch_moved and selected_actor!=null and BOARD_RECT.has_point(pos):
        if drag_origin.y<477 and _relocate_actor(selected_actor,socket_for_position(pos)):
            selected_actor=null
    queue_redraw()

func _actor_at(pos:Vector2) -> JianghuActor:
    for actor in active_actors:
        if actor.position.distance_to(pos)<29:return actor
    return null

func save_run() -> void:
    if phase=="menu" or phase=="dropping" or phase=="settings" or phase=="loss" or phase=="victory":return
    var placements:Array[Dictionary]=[]
    for actor in active_actors:
        if not is_instance_valid(actor):continue
        placements.append({"id":actor.data.id,"col":actor.socket.x,"row":actor.socket.y,"activations":actor.activation_count,"discipline":actor.discipline,"training_rank":actor.training_rank,"building_level":actor.building_level})
    var save={"format":5,"world":world_index,"seed":seed_value,"day":day,"shot":shot_number,"builds_today":builds_today,"treasury":treasury,"gross":total_earned,"earnings_today":earnings_today,"debt":debt,"boons":boons,"boon_cards":boon_cards,"technique_used":technique_used_today,"street_event":street_event,"training_seals":training_seals,"seals_earned_today":seals_earned_today,"phase":phase,"placements":placements,"offers":offer_cards,"flags":run_flags,"launch_x":launch_x,"aim_angle":aim_angle}
    var file=FileAccess.open(SAVE_PATH,FileAccess.WRITE)
    if file!=null:file.store_string(JSON.stringify(save))

func restore_run() -> void:
    if not FileAccess.file_exists(SAVE_PATH):return
    var file=FileAccess.open(SAVE_PATH,FileAccess.READ)
    if file==null:return
    var json=JSON.parse_string(file.get_as_text())
    if not json is Dictionary or int(json.get("format",0)) not in [2,3,4,5]:return
    _clear_board()
    _refresh_world(int(json.get("world",0)))
    selected_world=world_index
    seed_value=int(json.get("seed",99))
    rng.seed=seed_value
    day=int(json.get("day",1))
    shot_number=int(json.get("shot",0))
    builds_today=int(json.get("builds_today",0))
    treasury=int(json.get("treasury",0))
    total_earned=int(json.get("gross",0))
    earnings_today=int(json.get("earnings_today",0))
    debt=int(json.get("debt",0))
    technique_used_today=bool(json.get("technique_used",false))
    street_event=int(json.get("street_event",(day-1)%3))
    training_seals=int(json.get("training_seals",0))
    seals_earned_today=int(json.get("seals_earned_today",0))
    run_flags=json.get("flags",{})
    boons.clear()
    for boon_id in json.get("boons",[]):boons.append(str(boon_id))
    boon_cards.clear()
    for boon_id in json.get("boon_cards",[]):boon_cards.append(str(boon_id))
    owned_ids.clear()
    board_claims.clear()
    _build_board()
    for item in json.get("placements",[]):
        if _place_actor(str(item.id),Vector2i(int(item.col),int(item.row))):
            active_actors[-1].activation_count=int(item.get("activations",0))
            active_actors[-1].discipline=str(item.get("discipline","none"))
            active_actors[-1].training_rank=int(item.get("training_rank",1 if active_actors[-1].discipline!="none" else 0))
            active_actors[-1].grow_building(int(item.get("building_level",1)))
            active_actors[-1].queue_redraw()
    _rebuild_district()
    offer_cards.clear()
    for card in json.get("offers",[]):offer_cards.append(str(card))
    launch_x=float(json.get("launch_x",195.0))
    aim_angle=float(json.get("aim_angle",0.0))
    phase=str(json.get("phase","build"))
    inspect_mode="home"
    if phase!="build" and phase!="aim" and phase!="report" and phase!="tribute" and phase!="boon":phase="build"
    sound.change_world(world_index)
    banner_text="THE DREAM REMEMBERS"
    banner_timer=1.8
    queue_redraw()

func _clear_save() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

func _load_preferences() -> void:
    var config:=ConfigFile.new()
    if config.load("user://jianghu_settings.cfg")!=OK:return
    music_on=bool(config.get_value("audio","music",true))
    haptics_on=bool(config.get_value("touch","haptics",true))
    reduce_motion=bool(config.get_value("visual","reduced_motion",false))
    show_high_contrast=bool(config.get_value("visual","high_contrast",false))
    world_stamps=config.get_value("progress","world_stamps",{})

func _save_preferences() -> void:
    var config:=ConfigFile.new()
    config.set_value("audio","music",music_on)
    config.set_value("touch","haptics",haptics_on)
    config.set_value("visual","reduced_motion",reduce_motion)
    config.set_value("visual","high_contrast",show_high_contrast)
    config.set_value("progress","world_stamps",world_stamps)
    config.save("user://jianghu_settings.cfg")


