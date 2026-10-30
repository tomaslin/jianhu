class_name JianghuActor
extends StaticBody2D

const ReactionScript=preload("res://scripts/reaction_catalog.gd")
const Portraits=preload("res://scripts/portraits.gd")

var data: Dictionary = {}
var main: Node2D
var socket: Vector2i = Vector2i.ZERO
var is_peg: bool = false
var pulse: float = 0.0
var activation_count: int = 0
var discipline:String="none"
var training_rank:int=0
var building_level:int=1
var last_hit_time: float = -1000.0
var radius: float = 15.0
var idle_clock:float=0.0

func configure(properties: Dictionary, host: Node2D, grid_socket: Vector2i, peg: bool = false) -> void:
    data = properties.duplicate(true)
    main = host
    socket = grid_socket
    is_peg = peg
    radius = 6.0 if peg else 15.0
    collision_layer = 2
    collision_mask = 1
    var collision := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = radius
    collision.shape = circle
    add_child(collision)
    if not is_peg:
        _build_architecture_colliders(str(data.get("kind","stone")))

func _build_architecture_colliders(kind:String) -> void:
    var edges:Array[PackedVector2Array]=[]
    if kind in ["roof","stall","gate","costume","warehouse"]:
        edges=[PackedVector2Array([Vector2(-23,-17),Vector2(0,-28)]),PackedVector2Array([Vector2(0,-28),Vector2(23,-17)])]
    elif kind in ["bridge","trapdoor","ferry"]:
        edges=[PackedVector2Array([Vector2(-25,7),Vector2(25,7)])]
    elif kind=="umbrella":
        edges=[PackedVector2Array([Vector2(-23,-6),Vector2(0,-17)]),PackedVector2Array([Vector2(0,-17),Vector2(23,-6)])]
    for edge in edges:
        var shape:=CollisionShape2D.new()
        var segment:=SegmentShape2D.new()
        segment.a=edge[0]
        segment.b=edge[1]
        shape.shape=segment
        add_child(shape)

func grow_building(new_level:int) -> void:
    var goal=clampi(new_level,1,5)
    if goal<=building_level:return
    for tier in range(building_level+1,goal+1):
        var balcony:=CollisionShape2D.new()
        var ledge:=SegmentShape2D.new()
        var rise:float=-24.0-float(tier-1)*9.0
        var width:float=17.0+float(tier%2)*5.0
        ledge.a=Vector2(-width,rise)
        ledge.b=Vector2(width,rise)
        balcony.shape=ledge
        add_child(balcony)
    building_level=goal
    queue_redraw()

func note_hit() -> void:
    pulse = 1.0
    activation_count += 1
    queue_redraw()

func _process(delta: float) -> void:
    idle_clock+=delta
    if pulse > 0.0:
        pulse = maxf(0.0, pulse - delta * 3.2)
        queue_redraw()
    elif not is_peg and main!=null and not main.reduce_motion:
        # Roughly 12 rendered breaths a second, not a 60 Hz sprite update.
        if int(idle_clock*12.0)%5==0:queue_redraw()

func _draw() -> void:
    if is_peg:
        draw_circle(Vector2(1,2), radius + 2.2, Color(.10,.15,.13,.24))
        draw_circle(Vector2.ZERO, radius + 1.2, Color("#34483D"))
        draw_circle(Vector2.ZERO, radius - .2, Color("#B19260"))
        draw_circle(Vector2(-1.5,-2), radius * .46, Color("#F4DFAD"))
        return
    var accent := Color.html(str(main.world_data.accent))
    var deep := Color.html(str(main.world_data.ink))
    var school_color=accent
    match discipline:
        "righteous":school_color=Color("#5F8B9A")
        "rogue":school_color=Color("#A44B48")
        "wanderer":school_color=Color("#B28A48")
    var exterior := Color(0.97, .94, .84, .96)
    # Visual-only squash, recoil and breath. Colliders remain fixed so players
    # can still learn precise trajectories through the crowded town.
    var bob:float=0.0 if main.reduce_motion else sin(idle_clock*2.8+socket.x*.73)*1.1
    var knock:float=0.0 if main.reduce_motion else sin(idle_clock*26.0+socket.y)*pulse*.22
    var squash:float=0.0 if main.reduce_motion else pulse
    draw_set_transform(Vector2(0,bob),knock,Vector2(1.0+squash*.18,1.0-squash*.12))
    _draw_architecture(str(data.get("kind","stone")),deep,accent)
    draw_circle(Vector2(2,4), radius + 4.0, Color(.10,.15,.13,.28))
    draw_circle(Vector2.ZERO, radius + 4.0 + pulse * 6.0, Color(accent.r, accent.g, accent.b, .22 + pulse * .13))
    draw_circle(Vector2.ZERO, radius + 3.0, deep)
    draw_circle(Vector2.ZERO, radius + 1.0, Color("#C7A36A"))
    draw_circle(Vector2.ZERO, radius - .7, exterior)
    draw_arc(Vector2(-2,-3), radius - 3.0, PI*1.08, PI*1.85, 20, Color(1,1,1,.75),1.6,true)
    if discipline!="none":
        draw_arc(Vector2.ZERO,radius+3.0,0,TAU,35,Color(school_color,.88),1.6+training_rank*.42,true)
        for rank in range(training_rank):
            draw_circle(Vector2(-17+rank*10,19.0),2.2,school_color)
    draw_arc(Vector2.ZERO, radius - 1.4, -.6, PI * 1.35, 30, accent, 1.8, true)
    var portrait:int=Portraits.index_for(str(data.get("id","")))
    if portrait>=0:
        draw_texture_rect_region(Portraits.ART,Rect2(-20,-24,40,40),Portraits.region(portrait))
    else:
        _draw_motif(str(data.get("kind", "stone")), deep, accent)
    var mastery=ReactionScript.mastery_level(activation_count)
    if mastery>0:
        for rank in range(mastery):
            draw_arc(Vector2.ZERO,19.0+rank*4.0,-PI*.68,PI*.28,21,Color(accent,.44+.16*rank),1.35,true)
            draw_circle(Vector2(17+rank*3,-14-rank*3),1.9,accent)
    if pulse > 0.0:
        draw_arc(Vector2.ZERO, radius + 4.0 + pulse * 4, 0, TAU, 30, Color(accent.r,accent.g,accent.b,pulse), 1.8, true)
        # Ink impact: a visible movement phrase rather than camera shake.
        for i in range(3):
            var angle=TAU*float(i)/3.0+idle_clock*.6
            var outward=Vector2.RIGHT.rotated(angle)*(20+14*(1-pulse))
            draw_line(outward,outward+Vector2.RIGHT.rotated(angle+.26)*10,Color(deep,pulse*.61),2.2,true)
        if not main.reduce_motion:
            # A quick illustrated action mark makes each character's impact
            # visible without moving its physical collider or obscuring a pearl.
            var kind:String=str(data.get("kind",""))
            if kind in ["bell","drum","wheel"]:
                for j in range(2):
                    draw_arc(Vector2.ZERO,25.0+j*6,PI*1.08,PI*1.91,18,Color(accent,pulse*.8),2.2,true)
            elif kind in ["figure","swords","staff","fan","bamboo","umbrella"]:
                draw_arc(Vector2.ZERO,27,-PI*.9,-PI*.08,18,Color("#F5C45B",pulse*.9),3.2,true)
                draw_line(Vector2(21,-19),Vector2(32,-27),Color(deep,pulse*.8),2.0,true)
            else:
                for j in range(3):
                    var burst_angle:float=-PI*.8+j*PI*.3
                    var tip=Vector2.RIGHT.rotated(burst_angle)*(25.0+8.0*(1.0-pulse))
                    draw_circle(tip,2.8,Color(accent,pulse*.9))
    draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _draw_architecture(kind:String,deep:Color,tint:Color) -> void:
    # A companion is a *place* as much as an icon. Awnings, dojo roofs, bridges
    # and martial stances project beyond the circular physical contact mark.
    var roof_group=kind in ["roof","stall","gate","costume","warehouse"]
    for tier in range(2,building_level+1):
        var rise:float=-24.0-float(tier-1)*9.0
        var width:float=17.0+float(tier%2)*5.0
        draw_line(Vector2(-width,rise),Vector2(width,rise),Color(deep,.39+.10*tier),3.0,true)
        draw_colored_polygon(PackedVector2Array([
            Vector2(-width-4,rise),Vector2(0,rise-9),Vector2(width+4,rise)
        ]),Color(tint,.15+.04*tier))
        draw_line(Vector2(-width+4,rise+2),Vector2(-width+4,rise+7),Color(deep,.31),1.2)
        draw_line(Vector2(width-4,rise+2),Vector2(width-4,rise+7),Color(deep,.31),1.2)
    if roof_group:
        draw_rect(Rect2(-19,-18,38,31),Color(deep,.16))
        draw_colored_polygon(PackedVector2Array([Vector2(-25,-17),Vector2(0,-29),Vector2(25,-17),Vector2(20,-17),Vector2(0,-23),Vector2(-20,-17)]),Color(deep,.75))
        draw_line(Vector2(-24,-17),Vector2(24,-17),Color(tint,.72),2.1,true)
        for j in [-13,10]:
            draw_line(Vector2(j,-15),Vector2(j,14),Color(deep,.43),1.4)
        if kind in ["stall","roof"]:
            var steam=sin(idle_clock*2.7)*2 if main!=null and not main.reduce_motion else 0.0
            draw_arc(Vector2(-15+steam,-28),5,PI*.65,PI*1.62,12,Color(tint,.43),1.2)
    elif kind in ["bridge","trapdoor","ferry"]:
        draw_line(Vector2(-25,7),Vector2(25,7),Color(deep,.72),3.5,true)
        for j in [-20,-8,4,16]:
            draw_line(Vector2(j,7),Vector2(j,14),Color(tint,.60),1.4)
    elif kind in ["figure","sleeve","swords","staff","archer","umbrella","fan","bamboo"]:
        draw_arc(Vector2.ZERO,24,-2.8,-.5,27,Color(tint,.47),2.4,true)
        draw_arc(Vector2.ZERO,25,.34,1.4,17,Color(deep,.24),1.5,true)
    elif kind in ["bell","drum","dummy","wheel","lion"]:
        draw_line(Vector2(-20,-19),Vector2(20,-19),Color(deep,.55),2.1)
        draw_line(Vector2(-18,-20),Vector2(-18,15),Color(deep,.25),1.3)
        draw_line(Vector2(18,-20),Vector2(18,15),Color(deep,.25),1.3)
    else:
        draw_arc(Vector2.ZERO,23,-.3,PI*1.2,28,Color(tint,.20),1.4,true)

func _draw_motif(kind: String, ink: Color, tint: Color) -> void:
    match kind:
        "roof":
            draw_polyline(PackedVector2Array([Vector2(-10,-1),Vector2(0,-9),Vector2(10,-1)]), ink, 2.4, true)
            draw_line(Vector2(-8,0),Vector2(-8,8),ink,1.6)
            draw_line(Vector2(8,0),Vector2(8,8),ink,1.6)
            draw_line(Vector2(-8,8),Vector2(8,8),ink,1.6)
        "jar":
            draw_colored_polygon(PackedVector2Array([Vector2(-5,-5),Vector2(5,-5),Vector2(7,5),Vector2(3,9),Vector2(-3,9),Vector2(-7,5)]),tint)
            draw_line(Vector2(-6,-6),Vector2(6,-6),ink,2.6)
            draw_arc(Vector2.ZERO,3.0,0,TAU,16,Color(.98,.94,.84),1.2)
        "coins":
            for i in range(3):
                draw_arc(Vector2(-5+i*5,3-i*3),4,0,TAU,18,ink,1.8)
        "figure":
            draw_circle(Vector2(0,-6),3.5,ink)
            draw_line(Vector2(0,-2),Vector2(0,6),ink,2)
            draw_line(Vector2(-7,1),Vector2(7,-1),tint,2)
            draw_line(Vector2(0,6),Vector2(-6,10),ink,2)
            draw_line(Vector2(0,6),Vector2(7,9),ink,2)
        "bell":
            draw_arc(Vector2(0,1),7,PI,TAU,18,ink,2.2)
            draw_line(Vector2(-8,3),Vector2(8,3),ink,2)
            draw_circle(Vector2(0,7),2,tint)
        "wheel":
            draw_arc(Vector2.ZERO,9,0,TAU,28,ink,2)
            for a in range(0,360,60):
                var v:=Vector2.RIGHT.rotated(deg_to_rad(float(a))) * 8
                draw_line(Vector2.ZERO,v,tint,1.5)
        "gate":
            draw_line(Vector2(-8,10),Vector2(-8,-7),ink,2.2)
            draw_line(Vector2(8,10),Vector2(8,-7),ink,2.2)
            draw_arc(Vector2(0,-6),8,PI,TAU,18,tint,2.5)
        "mask":
            draw_colored_polygon(PackedVector2Array([Vector2(-9,-5),Vector2(9,-5),Vector2(6,7),Vector2(0,10),Vector2(-6,7)]),tint)
            draw_circle(Vector2(-4,0),2,ink)
            draw_circle(Vector2(4,0),2,ink)
        "fish":
            draw_ellipse_shape(Vector2(-2,0),Vector2(8,4),tint)
            draw_colored_polygon(PackedVector2Array([Vector2(5,0),Vector2(11,-5),Vector2(11,5)]),ink)
            draw_circle(Vector2(-6,-1),1,ink)
        "fan":
            draw_arc(Vector2(0,5),12,PI*1.12,PI*1.88,20,tint,5)
            draw_line(Vector2(0,5),Vector2(7,-5),ink,2)
            draw_line(Vector2(0,5),Vector2(-7,-5),ink,2)
        "healer":
            draw_line(Vector2(-8,0),Vector2(8,0),tint,4)
            draw_line(Vector2(0,-8),Vector2(0,8),tint,4)
        "moon":
            draw_circle(Vector2(0,0),9,tint)
            draw_circle(Vector2(4,-3),8,Color(.97,.94,.84))
        "cloud":
            draw_arc(Vector2(-5,2),6,PI,TAU,13,ink,2)
            draw_arc(Vector2(3,-2),8,PI,TAU,13,tint,2)
            draw_line(Vector2(-10,7),Vector2(11,7),ink,2)
        "lantern":
            draw_rect(Rect2(-7,-7,14,13),tint)
            draw_line(Vector2(-7,-8),Vector2(7,-8),ink,2)
            draw_line(Vector2(0,6),Vector2(0,11),ink,1.6)
        "swords":
            draw_line(Vector2(-8,9),Vector2(8,-9),ink,2.4)
            draw_line(Vector2(8,9),Vector2(-8,-9),tint,2.4)
            draw_line(Vector2(-5,3),Vector2(-9,-1),ink,2)
            draw_line(Vector2(5,3),Vector2(9,-1),ink,2)
        "seal":
            draw_rect(Rect2(-8,-8,16,16),tint,false,2)
            draw_line(Vector2(-5,-3),Vector2(5,-3),ink,1.6)
            draw_line(Vector2(-5,2),Vector2(5,2),ink,1.6)
        "ghost":
            draw_arc(Vector2.ZERO,8,PI,TAU,20,tint,3.4)
            draw_polyline(PackedVector2Array([Vector2(-8,0),Vector2(-7,8),Vector2(-2,5),Vector2(2,9),Vector2(6,5),Vector2(8,0)]),ink,1.8)
            draw_circle(Vector2(-3,-2),1.2,ink)
            draw_circle(Vector2(3,-2),1.2,ink)
        "boat":
            draw_polyline(PackedVector2Array([Vector2(-11,1),Vector2(-5,8),Vector2(7,8),Vector2(11,1)]),ink,2)
            draw_line(Vector2(0,-8),Vector2(0,1),ink,2)
            draw_line(Vector2(0,-8),Vector2(7,-1),tint,1.6)
        "bamboo":
            draw_line(Vector2(-5,-10),Vector2(-5,10),tint,3)
            draw_line(Vector2(5,-10),Vector2(5,10),ink,3)
            draw_line(Vector2(-8,-2),Vector2(-2,-2),ink,1.5)
            draw_line(Vector2(2,4),Vector2(8,4),tint,1.5)
        "poison":
            draw_circle(Vector2.ZERO,8,tint)
            for a in range(0,360,120):
                draw_line(Vector2.ZERO,Vector2.RIGHT.rotated(deg_to_rad(float(a)))*11,ink,2.0)
            draw_circle(Vector2.ZERO,3,ink)
        "beads":
            for x in [-6,0,6]:
                for y in [-5,2,9]:
                    draw_circle(Vector2(x,y),2.5,tint if (x+y)%2==0 else ink)
        "stall":
            draw_arc(Vector2(0,4),8,0,PI,16,ink,2.0)
            for j in [-4,0,4]:draw_line(Vector2(j,-2),Vector2(j+1,-8),tint,1.0)
        "dice":
            draw_rect(Rect2(-9,-7,10,10),ink,false,2)
            draw_rect(Rect2(1,-2,9,10),tint,false,2)
            draw_circle(Vector2(-5,-3),1.4,ink)
            draw_circle(Vector2(5,4),1.4,tint)
        "umbrella":
            draw_arc(Vector2(0,2),11,PI,TAU,24,tint,3)
            draw_line(Vector2(0,-9),Vector2(0,11),ink,1.9)
            draw_arc(Vector2(3,8),3,0,PI,12,ink,1.4)
        "lion":
            draw_circle(Vector2.ZERO,8,tint)
            draw_circle(Vector2(-6,-5),4,ink)
            draw_circle(Vector2(6,-5),4,ink)
            draw_circle(Vector2(-3,0),1.6,ink)
            draw_circle(Vector2(3,0),1.6,ink)
            draw_arc(Vector2(0,5),4,0,PI,15,ink,1.7)
        "bridge":
            draw_arc(Vector2(0,7),11,PI,TAU,17,ink,2.5)
            draw_line(Vector2(-12,7),Vector2(12,7),tint,1.8)
        "sleeve":
            draw_circle(Vector2(-2,-6),3,ink)
            draw_line(Vector2(-2,-2),Vector2(1,8),ink,2)
            draw_arc(Vector2(4,2),12,PI*.8,PI*1.8,18,tint,3.0)
        "archer":
            draw_arc(Vector2(-2,0),10,-PI*.45,PI*.45,19,tint,2.3)
            draw_line(Vector2(6,-8),Vector2(6,8),ink,1.4)
            draw_line(Vector2(-9,0),Vector2(11,0),ink,2.0)
            draw_colored_polygon(PackedVector2Array([Vector2(11,-4),Vector2(15,0),Vector2(11,4)]),ink)
        "manual":
            draw_colored_polygon(PackedVector2Array([Vector2(-10,-7),Vector2(0,-5),Vector2(10,-7),Vector2(10,8),Vector2(0,6),Vector2(-10,8)]),tint)
            draw_line(Vector2(0,-5),Vector2(0,7),ink,1.5)
            draw_line(Vector2(-7,-3),Vector2(-3,-2),ink,1)
        "constable":
            draw_rect(Rect2(-7,-8,14,16),ink,false,2.2)
            draw_line(Vector2(-11,9),Vector2(11,-9),tint,2)
            draw_circle(Vector2(0,0),3,ink)
        "staff":
            for x in [-7,0,7]:draw_line(Vector2(x,-10),Vector2(x+2,10),tint if x==0 else ink,2.1)
        "dummy":
            draw_line(Vector2(0,-10),Vector2(0,10),ink,5)
            draw_line(Vector2(-10,-3),Vector2(10,1),tint,2.8)
            draw_line(Vector2(-8,7),Vector2(8,4),tint,2.8)
        "drum":
            draw_circle(Vector2.ZERO,9,tint)
            draw_arc(Vector2.ZERO,9,0,TAU,23,ink,2.1)
            draw_line(Vector2(-10,-12),Vector2(4,3),ink,1.8)
            draw_line(Vector2(10,-12),Vector2(-4,3),ink,1.8)
        "costume":
            draw_colored_polygon(PackedVector2Array([Vector2(-5,-10),Vector2(5,-10),Vector2(10,-1),Vector2(7,10),Vector2(-7,10),Vector2(-10,-1)]),tint)
            draw_line(Vector2(-4,-10),Vector2(0,2),ink,1.4)
            draw_line(Vector2(4,-10),Vector2(0,2),ink,1.4)
        "trapdoor":
            draw_rect(Rect2(-10,-8,20,16),ink,false,2)
            draw_line(Vector2(-8,-6),Vector2(10,8),tint,2)
            draw_circle(Vector2(7,-4),2,ink)
        "ferry":
            draw_polyline(PackedVector2Array([Vector2(-12,2),Vector2(-5,9),Vector2(8,9),Vector2(12,2)]),ink,2.1)
            draw_line(Vector2(0,-9),Vector2(0,2),tint,2)
            draw_line(Vector2(-8,-1),Vector2(8,-1),tint,1.4)
        "relic":
            draw_colored_polygon(PackedVector2Array([Vector2(0,-10),Vector2(8,-4),Vector2(5,8),Vector2(-5,8),Vector2(-8,-4)]),tint)
            draw_line(Vector2(0,-10),Vector2(0,8),ink,1.3)
        "gourd":
            draw_circle(Vector2(0,5),6.7,tint)
            draw_circle(Vector2(0,-4),4.5,tint)
            draw_line(Vector2(0,-8),Vector2(4,-12),ink,1.5)
            draw_line(Vector2(-5,0),Vector2(5,0),ink,1.3)
        "firework":
            for angle in range(0,360,45):
                var direction=Vector2.RIGHT.rotated(deg_to_rad(float(angle)))
                draw_line(direction*5,direction*11,ink,1.6)
            draw_circle(Vector2.ZERO,3,tint)
        "warehouse":
            draw_rect(Rect2(-9,-6,8,8),tint)
            draw_rect(Rect2(1,-4,8,8),ink)
            draw_line(Vector2(-9,5),Vector2(9,5),tint,2)
        _:
            draw_circle(Vector2.ZERO,4,ink)

func draw_ellipse_shape(center:Vector2, radii:Vector2, fill:Color) -> void:
    var points:=PackedVector2Array()
    for i in range(22):
        var a:=float(i)/22.0*TAU
        points.append(center+Vector2(cos(a)*radii.x,sin(a)*radii.y))
    draw_colored_polygon(points,fill)

