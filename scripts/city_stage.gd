class_name JianghuCityStage
extends Node2D

# The Jianghu is built from its margins inward. The landscape is a painted
# frame; inhabited roofs, shop awnings, patrols and district oaths are added
# only as the player places actors. No tile atlas or HTML interface is used.
var main:Node2D
var cached_world:String=""
var cached_ink:Color=Color("#302C29")
var cached_accent:Color=Color("#915A45")

func _ensure_theme() -> void:
    var ident=str(main.world_data.id)
    if cached_world==ident:return
    cached_world=ident
    cached_ink=Color.html(str(main.world_data.ink))
    cached_accent=Color.html(str(main.world_data.accent))

func _ink(alpha:float=1.0) -> Color:
    return Color(cached_ink,alpha)

func _accent(alpha:float=1.0) -> Color:
    return Color(cached_accent,alpha)

func _draw() -> void:
    if main==null or main.phase in ["menu","settings"]:return
    _ensure_theme()
    _draw_border_city()
    _draw_world_signature()
    _draw_annexes()
    _draw_oath_threads()
    _draw_townspeople()
    if main.phase=="tribute":_draw_magistrate_arrival()

func _draw_border_city() -> void:
    # Wide brackets along the physics board deliberately preserve a pale,
    # legible centre. Architecture frames the pearl instead of wallpapering it.
    var c=_ink()
    draw_rect(Rect2(0,174,42,474),Color(c,.14))
    draw_rect(Rect2(348,174,42,474),Color(c,.14))
    # Ragged black ink washes, heavier at the frame's outer lip. The city
    # creeps inward but never clouds the main trajectory channel.
    for side in [-1,1]:
        var boundary=32.0 if side<0 else 358.0
        var points=PackedVector2Array()
        points.append(Vector2(0 if side<0 else 390,174))
        for i in range(15):
            var y=174+i*33.7
            var ragged=sin(i*2.27+main.world_index)*6.0+cos(i*.9)*3.0
            points.append(Vector2(boundary+(ragged if side<0 else -ragged),y))
        points.append(Vector2(0 if side<0 else 390,648))
        draw_colored_polygon(points,_ink(.10))
    for side in [-1,1]:
        var x:float=18.0 if side<0 else 372.0
        for row in range(5):
            var y:float=220.0+row*93.0
            var width:float=34.0+float((row+main.world_index)%3)*7.0
            _pagoda_eave(Vector2(x,y),width,side,0.18+0.045*(row%2))
            var wall_x:float=x-width*.5 if side<0 else x-width*.5
            draw_rect(Rect2(wall_x,y+1,width,45),Color(c,.11))
            for k in range(2):
                draw_rect(Rect2(wall_x+7+k*(width*.44),y+8,5,12),Color(c,.24))
            draw_line(Vector2(x-side*width*.45,y+2),Vector2(x-side*width*.45,y+43),Color(c,.27),1.5)
        var edge_x=43.0 if side<0 else 347.0
        draw_line(Vector2(edge_x,180),Vector2(edge_x,640),Color(c,.27),1.3)

    # The city's ink runs into the board only at its corners. A narrow bright
    # shaft keeps both trajectory and touch sockets unmistakable.
    for i in range(5):
        var y=180+i*116.0
        draw_line(Vector2(46,y),Vector2(57,y+25),_ink(.11),1.8)
        draw_line(Vector2(344,y),Vector2(333,y+25),_ink(.11),1.8)

func _pagoda_eave(center:Vector2,width:float,side:int,opacity:float=.4) -> void:
    var x=center.x
    var y=center.y
    var deep=_ink(opacity)
    var roof=PackedVector2Array([
        Vector2(x-width*.65,y-6),Vector2(x-width*.48,y-12),
        Vector2(x,y-19),Vector2(x+width*.48,y-12),
        Vector2(x+width*.65,y-6),Vector2(x+width*.48,y-8),
        Vector2(x-width*.48,y-8)
    ])
    draw_colored_polygon(roof,deep)
    draw_line(Vector2(x-width*.65,y-6),Vector2(x+width*.65,y-6),_ink(opacity+.13),2.0,true)
    if side<0:
        draw_line(Vector2(x+width*.52,y-9),Vector2(x+width*.67,y-15),_accent(opacity+.2),1.5)
    else:
        draw_line(Vector2(x-width*.52,y-9),Vector2(x-width*.67,y-15),_accent(opacity+.2),1.5)

func _draw_world_signature() -> void:
    match str(main.world_data.mechanic):
        "trade":
            for side in [-1,1]:
                var x=36 if side<0 else 354
                for y in [257.0,448.0,568.0]:
                    _lantern(Vector2(x,y),.66)
                    _steam(Vector2(x+side*7,y+21),main.elapsed*.7)
        "resonance":
            for side in [-1,1]:
                var x=42 if side<0 else 348
                for y in [258.0,441.0,590.0]:
                    draw_arc(Vector2(x,y),15,PI,TAU,24,_ink(.36),2.3,true)
                    draw_circle(Vector2(x,y+8),5.5,_accent(.40))
                    draw_line(Vector2(x,y-14),Vector2(x,y-23),_ink(.37),1.4)
        "masks":
            draw_rect(Rect2(27,176,336,7),_accent(.32))
            for side in [-1,1]:
                var bx=34.0 if side<0 else 356.0
                for i in range(14):
                    var y=189+i*31
                    draw_line(Vector2(bx,y),Vector2(bx+side*9,y+13),_accent(.21),2.0)
                for pos in [Vector2(bx,286),Vector2(bx,499)]:
                    _mask_icon(pos)
        "portals":
            for side in [-1,1]:
                var x=46.0 if side<0 else 344.0
                for y in [315.0,515.0]:
                    draw_arc(Vector2(x,y),20,PI*.5,PI*1.5,22,_accent(.33),2.0,true)
                    _lantern(Vector2(x+side*9,y+21),.50)
        "wind":
            for side in [-1,1]:
                var bx=22.0 if side<0 else 368.0
                for i in range(6):
                    var x=bx+side*i*5
                    draw_line(Vector2(x,198),Vector2(x-side*14,633),_ink(.14+i*.022),2.0)
                    for y in [271,384,506]:
                        draw_line(Vector2(x-8,y),Vector2(x+side*17,y-13),_accent(.24),1.3)
        "poison":
            for side in [-1,1]:
                var x=37.0 if side<0 else 353.0
                for y in [264.0,401.0,551.0]:
                    _medicine_bag(Vector2(x,y))
                draw_line(Vector2(x,180),Vector2(x,638),_ink(.23),1.6)
        "cargo":
            for side in [-1,1]:
                var bx=33.0 if side<0 else 357.0
                for y in [255.0,405.0,553.0]:
                    var wave=sin(main.elapsed*.7+y*.1)*4 if not main.reduce_motion else 0.0
                    draw_line(Vector2(bx,y),Vector2(bx+side*36,y-5+wave),_ink(.42),1.5)
                    draw_colored_polygon(PackedVector2Array([Vector2(bx+side*8,y-4),Vector2(bx+side*32,y-9+wave),Vector2(bx+side*19,y+19+wave)]),_accent(.24))
        "abacus":
            for side in [-1,1]:
                var bx=44.0 if side<0 else 346.0
                for i in range(4):
                    var x=bx+side*i*8
                    draw_line(Vector2(x,203),Vector2(x,620),_ink(.28),1.1)
                    for j in range(6):
                        var y=249.0+j*64.0+(6 if main.current_beat%8>=4 else 0)
                        draw_circle(Vector2(x,y),2.2,_accent(.49))

func _draw_annexes() -> void:
    # Each installed landmark adds a sloping annex to the enclosing city, and
    # an ink-footpath connecting its own street address to the architecture.
    for i in range(main.active_actors.size()):
        var actor=main.active_actors[i]
        if not is_instance_valid(actor):continue
        var left:bool=actor.position.x<195.0
        var outer_x:float=31.0 if left else 359.0
        var y:float=clampf(actor.position.y+10.0,203.0,614.0)
        var width:float=31.0+float(i%3)*3+float(actor.building_level-1)*3
        var wave=sin(main.elapsed*2.3+float(i))*.8 if not main.reduce_motion else 0.0
        draw_line(Vector2(outer_x,y),actor.position,_ink(.18),1.0,true)
        _pagoda_eave(Vector2(outer_x,y+wave),width,-1 if left else 1,.36)
        draw_rect(Rect2(outer_x-width*.36,y+2+wave,width*.72,17),_accent(.13))
        for storey in range(2,actor.building_level+1):
            _pagoda_eave(Vector2(outer_x,y-15.0*(storey-1)),width-storey*2,-1 if left else 1,.20+.035*storey)
        draw_rect(Rect2(outer_x-4.3,y+5+wave,8.6,12),_ink(.25))
        draw_line(Vector2(outer_x,y+20),Vector2(outer_x,y+29),_ink(.42),1.2)
        draw_colored_polygon(PackedVector2Array([Vector2(outer_x-5,y+29),Vector2(outer_x+5,y+29),Vector2(outer_x+3,y+37),Vector2(outer_x-3,y+36)]),_accent(.26+.17*actor.pulse))
        if actor.pulse>.2:
            draw_arc(actor.position,23.0+actor.pulse*8,0,TAU,26,_accent(actor.pulse*.21),1.2,true)

func _draw_oath_threads() -> void:
    for link in main.district_links:
        var aa=link.a
        var bb=link.b
        if not is_instance_valid(aa) or not is_instance_valid(bb):continue
        var start:Vector2=aa.position
        var end:Vector2=bb.position
        var mid:Vector2=(start+end)*.5+Vector2(0,-13)
        var pts=PackedVector2Array()
        for i in range(13):
            var t=float(i)/12
            pts.append(start.lerp(end,t)+Vector2(0,-13*4*t*(1-t)))
        var red:bool=str(link.kind) in ["rival","night_tax","antidote"]
        draw_polyline(pts,Color(.66,.26,.23,.40) if red else _accent(.47),1.5,true)
        draw_circle(mid,3.3,_accent(.66))
        draw_circle(mid,1.4,_ink(.76))

func _draw_townspeople() -> void:
    # People live in the rim streets. Every new establishment attracts more;
    # their tiny reactions acknowledge the object that has just been struck.
    var population:int=4+mini(12,main.active_actors.size()+main.district_links.size())
    for i in range(population):
        var side:int=-1 if i%2==0 else 1
        var lane_x:float=14.0+float(i%3)*7.0 if side<0 else 376.0-float(i%3)*7.0
        var offset:float=0 if main.reduce_motion else fmod(main.elapsed*(5.0+float(i%5))+float(i)*59.0,390.0)
        var y:float=216.0+offset
        var phase:float=main.elapsed*3.0+i*1.33
        _traveller(Vector2(lane_x,y),side,phase,i)

func _traveller(at:Vector2,side:int,phase:float,identity:int) -> void:
    var tint=_ink(.46)
    var robe=_accent(.18 if identity%4 else .35)
    var gait:float=sin(phase)*2.0 if not main.reduce_motion else 0.0
    draw_colored_polygon(PackedVector2Array([
        at+Vector2(-4,0),at+Vector2(4,0),
        at+Vector2(6,14),at+Vector2(-6,14)
    ]),robe)
    draw_circle(at+Vector2(0,-4),3.0,tint)
    draw_line(at+Vector2(-3,14),at+Vector2(-5+gait,20),tint,1.5)
    draw_line(at+Vector2(3,14),at+Vector2(5-gait,20),tint,1.5)
    if identity%4==0:
        # Straw hat and a very long unlicensed travelling sword.
        draw_line(at+Vector2(-8,-7),at+Vector2(8,-7),tint,2)
        draw_line(at+Vector2(side*4,5),at+Vector2(side*12,17),_ink(.45),1.3)
    elif identity%4==1:
        draw_line(at+Vector2(-4,6),at+Vector2(-10,gait+2),tint,1.2)

func _draw_magistrate_arrival() -> void:
    draw_rect(Rect2(64,182,262,33),Color(.68,.19,.17,.11))
    for i in range(9):
        var x=78+i*29.0
        draw_line(Vector2(x,184),Vector2(x+2,210),Color(.70,.20,.16,.34),1.5)
    draw_circle(Vector2(195,208),12.0,Color(.64,.19,.18,.25))

func _lantern(center:Vector2,opacity:float) -> void:
    draw_line(center+Vector2(0,-18),center+Vector2(0,-11),_ink(opacity),1.0)
    draw_colored_polygon(PackedVector2Array([
        center+Vector2(-6,-10),center+Vector2(6,-10),
        center+Vector2(8,3),center+Vector2(0,11),center+Vector2(-8,3)
    ]),_accent(opacity*.62))
    draw_line(center+Vector2(-7,-11),center+Vector2(7,-11),_ink(opacity),1.5)
    draw_line(center+Vector2(0,10),center+Vector2(0,18),_ink(opacity),1.3)

func _steam(center:Vector2,phase:float) -> void:
    var points=PackedVector2Array()
    for i in range(8):
        var t=float(i)/7
        var wobble=0 if main.reduce_motion else sin(t*7+phase)*3
        points.append(center+Vector2(wobble-5*t,-19*t))
    draw_polyline(points,_ink(.22),1.1,true)

func _mask_icon(center:Vector2) -> void:
    draw_colored_polygon(PackedVector2Array([
        center+Vector2(-10,-9),center+Vector2(10,-9),
        center+Vector2(7,8),center+Vector2(0,13),center+Vector2(-7,8)
    ]),_accent(.29))
    draw_circle(center+Vector2(-4,0),1.5,_ink(.64))
    draw_circle(center+Vector2(4,0),1.5,_ink(.64))

func _medicine_bag(center:Vector2) -> void:
    draw_line(center+Vector2(0,-19),center+Vector2(0,-11),_ink(.31),1.0)
    draw_colored_polygon(PackedVector2Array([
        center+Vector2(-3,-11),center+Vector2(3,-11),
        center+Vector2(10,-1),center+Vector2(6,12),
        center+Vector2(-6,12),center+Vector2(-10,-1)
    ]),_accent(.32))
    draw_line(center+Vector2(-8,-4),center+Vector2(8,-4),_ink(.42),1.0)
