class_name JianghuPearl
extends RigidBody2D

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
    main.apply_world_physics(self,delta)
    if trail.is_empty() or trail[-1].distance_to(position)>3.3:
        trail.append(position)
        if trail.size()>18: trail.pop_front()
    queue_redraw()

func _on_body_entered(body:Node) -> void:
    if not collected and main!=null:
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
    var base:=Color(.48,.78,.68)
    match variant:
        "copper": base=Color(.82,.59,.32)
        "paper": base=Color(.96,.89,.76)
        "fish": base=Color(.59,.80,.9)
        "ghost": base=Color(.70,.79,.95)
        "iron": base=Color(.55,.60,.62)
    for i in range(1,trail.size()):
        if main!=null and main.reduce_motion and i<trail.size()-4:continue
        var local_a:=to_local(trail[i-1])
        var local_b:=to_local(trail[i])
        var weight=float(i)/float(trail.size())
        # The pearl writes a brush line into the world. Strokes thicken near
        # the moving nib, and their diluted ink echoes Chinese wash painting.
        draw_line(local_a,local_b,Color(.14,.15,.14,weight*.22),.8+weight*5.2,true)
        draw_line(local_a,local_b,Color(base.r,base.g,base.b,weight*.35),.55+weight*2.7,true)
    draw_circle(Vector2.ZERO,12.2,Color(base.r,base.g,base.b,.15))
    draw_circle(Vector2.ZERO,9.2,Color(.13,.19,.18,.85))
    draw_circle(Vector2.ZERO,7.8,base)
    draw_circle(Vector2(-2.4,-3.2),2.4,Color(1,1,1,.67))
    if statuses.has("drunk"):draw_arc(Vector2.ZERO,11.0,0,TAU,20,Color(.82,.37,.35),1.5)
    if statuses.has("blessed"):draw_arc(Vector2.ZERO,13.0,0,TAU,20,Color(.95,.8,.35),1.5)
    if statuses.has("cursed") or statuses.has("poison"):draw_arc(Vector2.ZERO,12.4,0,TAU,20,Color(.38,.27,.59),1.6)
    if statuses.has("wanted"):draw_circle(Vector2(7,-9),2.6,Color(.79,.26,.22))
    if main!=null and main.rhythm_chain>=3 and not main.reduce_motion:
        var glow:float=.22+.16*sin(main.beat_clock*TAU*float(main.world_data.bpm)/60.0)
        draw_arc(Vector2.ZERO,15.4,PI*.27,PI*1.68,31,Color(.84,.65,.33,glow),1.6,true)

