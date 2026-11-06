extends Node2D

const FLOOR := 610.0
var p := Vector2(300, 570)
var enemy := Vector2(950, 570)
var vy := 0.0
var hp := 100
var enemy_hp := 100
var parry := 0.0
var stun := 0.0
var combo := 0
var combo_time := 0.0
var attack_cd := 0.0
var bot_cd := 0.0
var finished := false
var msg := "FROST VS BOT"
var held := {}
var arrows := false

func _input(e: InputEvent) -> void:
    if e is InputEventScreenTouch:
        if e.pressed:
            held[e.index] = e.position
            _tap(e.position)
        else:
            held.erase(e.index)
    elif e is InputEventScreenDrag:
        held[e.index] = e.position
    elif e is InputEventMouseButton and e.pressed:
        _tap(e.position)
    elif e is InputEventKey and e.pressed and not e.echo:
        match e.keycode:
            KEY_A, KEY_SPACE: jump()
            KEY_X: hit()
            KEY_Y: do_parry()
            KEY_R: reset_match()

func _tap(pos: Vector2) -> void:
    if finished:
        reset_match()
    elif pos.y < 110 and pos.x > 980:
        arrows = not arrows
    elif pos.distance_to(Vector2(1010,600)) < 65:
        jump()
    elif pos.distance_to(Vector2(1010,460)) < 65:
        hit()
    elif pos.distance_to(Vector2(1160,460)) < 65:
        do_parry()

func jump() -> void:
    if p.y >= FLOOR-40 and not finished:
        vy = -670

func do_parry() -> void:
    parry = .32
    msg = "PARRY!"

func hit() -> void:
    if finished or attack_cd > 0:
        return
    attack_cd = .17
    if stun > 0 and combo_time > 0:
        combo += 1
        if combo >= 4:
            enemy_hp -= 28
            msg = "PERFECT PUNISH x2!"
            combo = 0
            combo_time = 0
    elif abs(p.x-enemy.x) < 110:
        enemy_hp -= 7
        msg = "HIT!"
    if enemy_hp <= 0:
        finished = true
        msg = "VICTORY! TAP TO RESTART"
        if randi_range(1,600000) == 1:
            get_tree().change_scene_to_file("res://scenes/legend_unlock.tscn")

func reset_match() -> void:
    p = Vector2(300,570)
    enemy = Vector2(950,570)
    hp = 100
    enemy_hp = 100
    finished = false
    msg = "ROUND START!"

func _physics_process(d: float) -> void:
    parry = maxf(0,parry-d)
    stun = maxf(0,stun-d)
    combo_time = maxf(0,combo_time-d)
    attack_cd = maxf(0,attack_cd-d)
    bot_cd = maxf(0,bot_cd-d)
    if combo_time == 0:
        combo = 0
    if not finished:
        var direction := float(int(Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D))-int(Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_Q)))
        for v in held.values():
            if v.y > 390 and v.x < 420:
                direction = -1.0 if v.x < 205 else 1.0
        p.x = clampf(p.x+direction*330*d,40,1240)
        vy += 1500*d
        p.y = minf(FLOOR-40,p.y+vy*d)
        if p.y >= FLOOR-40:
            vy = 0
        if stun <= 0:
            enemy.x += clampf(p.x-enemy.x,-185*d,185*d)
            if abs(enemy.x-p.x)<85 and bot_cd == 0:
                bot_cd = .9
                if parry > 0:
                    stun = 1.5
                    combo_time = 1.5
                    msg = "PARRY! X X X X"
                elif not Input.is_key_pressed(KEY_B):
                    hp -= 8
                    msg = "BOT HIT!"
                if hp <= 0:
                    finished = true
                    msg = "DEFEAT! TAP TO RESTART"
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0,0,1280,720),Color("#13223c"))
    for i in range(9):
        var x := float(i)*165
        draw_rect(Rect2(x,280,30,330),Color("#36564e"))
        draw_circle(Vector2(x+15,290),72,Color("#205449"))
    draw_rect(Rect2(0,FLOOR,1280,110),Color("#3e7155"))
    draw_rect(Rect2(470,430,340,16),Color("#9475b5"))
    draw_rect(Rect2(190,515,170,14),Color("#9475b5"))
    draw_rect(Rect2(900,510,170,14),Color("#9475b5"))
    draw_rect(Rect2(p.x-24,p.y-65,48,65),Color("#68dfff"))
    draw_circle(p+Vector2(0,-80),23,Color("#a5f0ff"))
    draw_rect(Rect2(enemy.x-24,enemy.y-65,48,65),Color("#ec6479"))
    draw_circle(enemy+Vector2(0,-80),23,Color("#ffb0b8"))
    draw_rect(Rect2(30,30,360,24),Color("#07141d"))
    draw_rect(Rect2(30,30,360*clampf(hp/100.0,0,1),24),Color("#68dfff"))
    draw_rect(Rect2(850,30,360,24),Color("#07141d"))
    draw_rect(Rect2(850,30,360*clampf(enemy_hp/100.0,0,1),24),Color("#ec6479"))
    label_text(Vector2(490,50),"BATTLE LEGENDS",28)
    label_text(Vector2(440,160),msg,26)
    label_text(Vector2(1000,85),"MODE: "+("ARROWS" if arrows else "JOYSTICK"),17)
    button(Vector2(125,545),"LEFT",Color("#477bb3"))
    button(Vector2(285,545),"RIGHT",Color("#477bb3"))
    button(Vector2(1010,600),"A JUMP",Color("#31a568"))
    button(Vector2(1160,600),"B BLOCK",Color("#cc4b56"))
    button(Vector2(1010,460),"X HIT",Color("#307fc7"))
    button(Vector2(1160,460),"Y PARRY",Color("#c39a35"))

func button(pos: Vector2, title: String, color: Color) -> void:
    draw_circle(pos,61,color)
    label_text(pos+Vector2(-42,6),title,16)

func label_text(pos: Vector2, title: String, size: int) -> void:
    draw_string(ThemeDB.fallback_font,pos,title,HORIZONTAL_ALIGNMENT_LEFT,-1,size,Color.WHITE)
