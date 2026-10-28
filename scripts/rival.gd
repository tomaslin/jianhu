class_name JianghuRival
extends AnimatableBody2D

# Each fifth morning introduces a physical opponent, not an overlay. Its
# contacts challenge the town's route design, schools, estates and beat timing.
const RIVALS:Array[Dictionary]=[
    {"id":"tax_eater","name":"THE TAX-EATING EUNUCH","move":"audit","color":"#A14B34"},
    {"id":"silent_abbot","name":"THE ABBOT WHO STOLE SOUND","move":"silence","color":"#566C60"},
    {"id":"white_censor","name":"THE WHITE-FACED CENSOR","move":"unmask","color":"#9F344C"},
    {"id":"debt_ferryman","name":"THE NINTH DEBT FERRYMAN","move":"debt","color":"#607D99"},
    {"id":"reed_executioner","name":"THE REED EXECUTIONER","move":"shear","color":"#386B4E"},
    {"id":"venom_registrar","name":"THE VENOM REGISTRAR","move":"venom","color":"#766C30"},
    {"id":"sand_brigand","name":"THE BRIGAND OF SEVEN TOLLS","move":"burden","color":"#9D663C"},
    {"id":"heaven_auditor","name":"THE AUDITOR OF HEAVEN","move":"reversal","color":"#967349"}
]

var main:Node2D
var world_id:int=0
var stage:int=1
var health:int=4
var max_health:int=4
var pulse:float=0.0
var last_contact:Dictionary={}

func configure(host:Node2D,world:int,level:int) -> void:
    main=host
    world_id=clampi(world,0,7)
    stage=clampi(level,1,3)
    max_health=3+stage
    health=max_health
    collision_layer=2
    collision_mask=1
    var collision:=CollisionShape2D.new()
    var orb:=CircleShape2D.new()
    orb.radius=21.0
    collision.shape=orb
    add_child(collision)
    position=Vector2(195,379)
    queue_redraw()

func _physics_process(delta:float) -> void:
    pulse=maxf(0.0,pulse-delta*2.6)
    if main==null or main.phase!="dropping":return
    var beat:float=float(main.beat_clock)
    var sway:float=0.0 if main.reduce_motion else sin(beat*.92+world_id)*66.0
    var bob:float=0.0 if main.reduce_motion else sin(beat*1.57+world_id)*21.0
    position=Vector2(195+sway,365+bob)
    queue_redraw()

func _draw() -> void:
    var spec:Dictionary=RIVALS[world_id]
    var color:Color=Color.html(str(spec.color))
    var outline:=Color(.13,.16,.15,.92)
    draw_circle(Vector2.ZERO,27.0+pulse*8.0,Color(color,.15+pulse*.12))
    draw_line(Vector2(-25,17),Vector2(-8,-15),outline,3.4,true)
    draw_line(Vector2(25,17),Vector2(8,-15),outline,3.4,true)
    draw_colored_polygon(PackedVector2Array([
        Vector2(-19,18),Vector2(-11,-8),Vector2(-4,-24),
        Vector2(14,-25),Vector2(23,18)
    ]),Color(outline,.85))
    draw_circle(Vector2(0,-4),14.4,Color(.93,.84,.70))
    draw_arc(Vector2(0,-4),13.7,0,TAU,27,color,2.1,true)
    for eye in [-5,5]:draw_line(Vector2(eye-1,-7),Vector2(eye+1,-5),outline,2.0,true)
    draw_line(Vector2(-6,4),Vector2(6,4),color,2.5,true)
    match world_id:
        0,7:
            draw_rect(Rect2(-8,-20,16,4),color)
            draw_line(Vector2(0,6),Vector2(0,19),Color(.83,.67,.36),2)
        1,4:
            draw_line(Vector2(-28,-22),Vector2(27,20),Color(.82,.76,.51,.85),2.0,true)
        2,3:
            draw_arc(Vector2(0,-3),18,-PI*.95,PI*.12,18,Color(.94,.31,.38),2.3,true)
        5,6:
            for i in range(3):draw_circle(Vector2(-11+i*11,18),2.5,color)
    for pip in range(max_health):
        draw_circle(Vector2(-float(max_health-1)*5.5+pip*11,-36),4.0,color if pip<health else Color(.55,.54,.50,.3))
        draw_arc(Vector2(-float(max_health-1)*5.5+pip*11,-36),4.0,0,TAU,14,outline,1.0,true)
