class_name JianghuPearl
extends RigidBody2D

const PEARL_ART={
    "jade":preload("res://assets/pearls/jade.png"),
    "copper":preload("res://assets/pearls/copper.png"),
    "paper":preload("res://assets/pearls/paper.png"),
    "fish":preload("res://assets/pearls/fish.png"),
    "ghost":preload("res://assets/pearls/ghost.png"),
    "iron":preload("res://assets/pearls/iron.png")
}

var main: Node2D
var variant: String = "jade"
var statuses: Dictionary = {}
var trail: Array[Vector2] = []
var born_at: float = 0.0
var hits: int = 0
var chain_id: int = 0
var is_seed: bool = true
var collected: bool = false
var world_gravity_timer: float = 0.0
var teleport_cooldown: float = 0.0
var origin_actor: String = ""
var last_actor: String = ""
var last_hit_at: float = -100.0
var route_history:Array[String]=[]
var route_completed:Dictionary={}
var route_recipes:int=0
var impact_bloom:float=0.0
var pen_angle:float=0.0

func configure(host: Node2D, pearl_variant: String, family_id: int, main_pearl: bool = true) -> void:
    main=host
    variant=pearl_variant
    chain_id=family_id
    is_seed=main_pearl
    collision_layer=1
    collision_mask=2
    contact_monitor=true
    max_contacts_reported=12
    continuous_cd=RigidBody2D.CCD_MODE_CAST_SHAPE
    lock_rotation=true
    linear_damp=0.05
    mass=1.0
    gravity_scale=1.0
    var shape:=CircleShape2D.new()
    shape.radius=8.7 if variant=="jade" else (7.8 if variant=="paper" else 9.3)
    var hitbox:=CollisionShape2D.new()
    hitbox.shape=shape
    add_child(hitbox)
    var physics_material:=PhysicsMaterial.new()
    physics_material.bounce=.88 if variant!="copper" else .74
    physics_material.friction=.08 if variant!="copper" else .22
    physics_material_override=physics_material
    body_entered.connect(_on_body_entered)
    born_at=Time.get_ticks_msec()/1000.0

func _physics_process(delta: float) -> void:
    if collected or main==null:
        return
    teleport_cooldown=maxf(0.0, teleport_cooldown-delta)
    world_gravity_timer=maxf(0.0,world_gravity_timer-delta)
    impact_bloom=maxf(0.0,impact_bloom-delta*3.4)
    if linear_velocity.length_squared()>40:
        pen_angle=lerp_angle(pen_angle,linear_velocity.angle(),minf(1.0,delta*9.0))
    main.apply_world_physics(self,delta)
    if trail.is_empty() or trail[-1].distance_to(position)>3.3:
        trail.append(position)
        if trail.size()>18: trail.pop_front()
    queue_redraw()

func _on_body_entered(body:Node) -> void:
    if not collected and main!=null:
        impact_bloom=1.0
        main.on_pearl_hit(self,body)

func set_status(key:String, count:int=3) -> void:
    if statuses.size()>=3 and not statuses.has(key):
        statuses.erase(statuses.keys()[0])
    statuses[key]=count
    queue_redraw()

func consume_statuses() -> void:
    for key in statuses.keys():
        statuses[key]=int(statuses[key])-1
        if statuses[key]<=0: statuses.erase(key)

func _draw() -> void:
    var base:=Color(.49,.76,.67)
    var ink:=Color(.17,.29,.26)
    match variant:
        "copper":
            base=Color(.84,.56,.27)
            ink=Color(.49,.28,.16)
        "paper":
            base=Color(.94,.78,.62)
            ink=Color(.64,.30,.24)
        "fish":
            base=Color(.54,.79,.92)
            ink=Color(.21,.42,.63)
        "ghost":
            base=Color(.72,.70,.97)
            ink=Color(.41,.37,.63)
        "iron":
            base=Color(.66,.68,.67)
            ink=Color(.29,.32,.35)
    # The physical trail is painted with the moving pearl's own material:
    # a calligraphic wet stroke, diluted halo, then occasional pigment drops.
    for i in range(1,trail.size()):
        if main!=null and main.reduce_motion and i<trail.size()-4:continue
        var local_a:=to_local(trail[i-1])
        var local_b:=to_local(trail[i])
        var weight=float(i)/float(trail.size())
        draw_line(local_a,local_b,Color(ink,weight*.16),1.5+weight*7.2,true)
        draw_line(local_a,local_b,Color(base,weight*.36),.8+weight*3.6,true)
        if i%4==0 and (main==null or not main.reduce_motion):
            draw_circle(local_b,1.0+weight*3.4,Color(base,weight*.11))
            var dir:Vector2=(local_b-local_a).normalized().orthogonal()
            draw_line(local_b,local_b+dir*(4.0+weight*6.0),Color(ink,weight*.09),1.0,true)
    var halo:float=13.6+impact_bloom*5.0
    draw_circle(Vector2.ZERO,halo,Color(base,.11+impact_bloom*.16))
    draw_arc(Vector2.ZERO,13.3,PI*.16,PI*1.92,35,Color(ink,.33),1.15,true)
    # Expressive jewel faces remain readable at phone size and make each
    # transformation feel like a different little character.
    draw_circle(Vector2(1.5,3),11.5,Color(ink,.35))
    draw_circle(Vector2.ZERO,11.5,ink)
    draw_circle(Vector2(0,-1),10.2,base)
    draw_circle(Vector2(-4,-5),3.1,Color(1,1,1,.50))
    draw_circle(Vector2(-3,-1),1.8,ink)
    draw_circle(Vector2(3,-1),1.8,ink)
    draw_circle(Vector2(-3.4,-1.7),.55,Color.WHITE)
    draw_circle(Vector2(2.6,-1.7),.55,Color.WHITE)
    draw_arc(Vector2(0,2),3.3,.10,PI-.10,14,ink,1.7,true)
    if statuses.has("drunk"):draw_arc(Vector2.ZERO,16.0,PI*.07,TAU*.88,26,Color(.78,.31,.30,.9),1.7,true)
    if statuses.has("blessed"):draw_arc(Vector2.ZERO,17.5,0,TAU,34,Color(.94,.73,.27,.77),1.35,true)
    if statuses.has("cursed") or statuses.has("poison"):
        draw_arc(Vector2.ZERO,17.0,PI*.11,PI*1.72,31,Color(.38,.27,.59,.86),1.75,true)
    if statuses.has("wanted"):
        draw_line(Vector2(11,-14),Vector2(17,-20),Color(.79,.21,.21,.95),2.0,true)
        draw_circle(Vector2(17,-20),2.4,Color(.79,.21,.21))
    if impact_bloom>0 and (main==null or not main.reduce_motion):
        for j in range(5):
            var angle:float=float(j)*TAU/5.0+pen_angle*.27
            var tip:Vector2=Vector2.RIGHT.rotated(angle)*(21.0+(1.0-impact_bloom)*12.0)
            draw_line(tip-Vector2.RIGHT.rotated(angle)*7,tip,Color(ink,impact_bloom*.45),1.2+impact_bloom*1.6,true)
            draw_circle(tip,1.1+impact_bloom*1.6,Color(base,impact_bloom*.58))
    if main!=null and main.rhythm_chain>=3 and not main.reduce_motion:
        var glow:float=.22+.16*sin(main.beat_clock*TAU*float(main.world_data.bpm)/60.0)
        draw_arc(Vector2.ZERO,19.2,PI*.27,PI*1.68,31,Color(.84,.65,.33,glow),1.7,true)

