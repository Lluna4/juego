extends Node
class_name arma1
onready var raycast = $"../cabeza/Camera/disparo"
export var velocidad_disparo = 0.2
export var balas_cargador = 20
export var tiempo_recarga = 1
export var respawn_s = 3
export var tiempo_kunai = 10
var F = 1
var tiempo_recoil_lvl1 = 1.5
var tiempo_recoil_lvl2 = 1.0
var tiempo_recoil_lvl3 = 1.2
var tiempo_recoil_lvl4 = 0.8
var tiempo_recoil_lvl5 = 1
var en_dolor_recoil = false
onready var recoil_animacion = $"../cabeza/Camera/recoil"
onready var lvl_ui = $"/root/mundo/algo/nivel"
onready var balas_ui = $"/root/mundo/algo/balas"
onready var enemigo_cargado = $"/root/mundo/enemigo"
onready var cabeza = $"../cabeza"
onready var xp_ui = $"/root/mundo/algo/xp"
onready var kunai = preload("res://kunai (test).tscn")
onready var mano = $"../mano"

var balas = balas_cargador
var vida_maxima_enemigo = 100
var vida_enemigo = vida_maxima_enemigo
var damage_bala = 34
var se_puede_disparar = true
var recargando = false
var disparos_seguidos = 0
var rng = RandomNumberGenerator.new()
var balas_ui_recursos = [balas, balas_cargador]

var xp = 0
var xp_siguiente_lvl2 = 65
var xp_siguiente_lvl3 = 150
var xp_siguiente_lvl4 = 245
var xp_siguiente_lvl5 = 365
var nivel = 1



func _process(delta: float) -> void:
	xp_ui.set_text("XP: %d" % xp)
	lvl_ui.set_text("NIVEL: %d" % nivel)
	if recargando:
		balas_ui.set_text("Recargando!")
	elif en_dolor_recoil == true:
		balas_ui.set_text("Demasiado recoil!")
	else:
		balas_ui.set_text("BALAS: %d / %d" % [balas, balas_cargador])
	
	

	if Input.is_action_just_pressed("disparo") and se_puede_disparar:
		if balas > 0 and not recargando:
			disparo()
		elif not recargando:
			recarga()
		
	if Input.is_action_pressed("recarga") and not recargando:
		recarga()
	if xp >= xp_siguiente_lvl2 and not xp >= xp_siguiente_lvl3:
		nivel = 2
		print(nivel)
	if xp >= xp_siguiente_lvl3 and not xp >= xp_siguiente_lvl4:
		nivel = 3
		print(nivel)
	if xp >= xp_siguiente_lvl4 and not xp >= xp_siguiente_lvl5:
		nivel = 4
		print(nivel)
	if xp >= xp_siguiente_lvl5:
		nivel = 5
		print(nivel)
	
	
func revisar_colision():
	 
	if raycast.is_colliding():
		vida_enemigo -= damage_bala
		print("vida",vida_enemigo)
		var collider = raycast.get_collider()
		
		print("GOLPEADO " + collider.name)
		xp = xp + 5
		 
		print(xp)
		if vida_enemigo <= 0:
			
			collider.queue_free()
			yield(get_tree().create_timer(tiempo_recarga), "timeout")
			var enemigo = preload("res://enemigo.tscn").instance()
			rng.randomize()
			var my_random_number = rng.randf_range(-25, 25)
			enemigo.translation = Vector3 (my_random_number, 0, my_random_number)
			add_child(enemigo)
			vida_enemigo = vida_maxima_enemigo

func disparo():
#	 if disparos_seguidos == 3 and nivel == 1:
#		print("demasiado recolil")
#		se_puede_disparar = false
#		en_dolor_recoil = true
#		yield(get_tree().create_timer(tiempo_recoil_lvl1), "timeout")
#		en_dolor_recoil = false
#		print("ya no hay tanto")
#		se_puede_disparar = true
#		disparos_seguidos = 0
#
#	if disparos_seguidos == 3 and nivel == 2:
#		print("demasiado recolil")
#		se_puede_disparar = false
#		en_dolor_recoil = true
#		yield(get_tree().create_timer(tiempo_recoil_lvl2), "timeout")
#		en_dolor_recoil = false
#		print("ya no hay tanto")
#		se_puede_disparar = true
#		disparos_seguidos = 0
#
#	if disparos_seguidos == 5 and nivel == 3:
#		print("demasiado recolil")
#		se_puede_disparar = false
#		en_dolor_recoil = true
#		yield(get_tree().create_timer(tiempo_recoil_lvl3), "timeout")
#		en_dolor_recoil = false
#		print("ya no hay tanto")
#		se_puede_disparar = true
#		disparos_seguidos = 0
#
#	if disparos_seguidos == 5 and nivel == 4:
#		print("demasiado recolil")
#		se_puede_disparar = false
#		en_dolor_recoil = true
#		yield(get_tree().create_timer(tiempo_recoil_lvl4), "timeout")
#		en_dolor_recoil = false
#		print("ya no hay tanto")
#		se_puede_disparar = true
#		disparos_seguidos = 0
#
#	if disparos_seguidos == 7 and nivel == 5:
#		print("demasiado recolil")
#		se_puede_disparar = false
#		en_dolor_recoil = true
#		yield(get_tree().create_timer(tiempo_recoil_lvl5), "timeout")
#		en_dolor_recoil = false
#		print("ya no hay tanto")
#		se_puede_disparar = true
#		disparos_seguidos = 0 
	
	
	
	disparos_seguidos = disparos_seguidos + F
	print("BANG!")
	se_puede_disparar = false     
	balas -= 1
	#recoil_animacion.play("recoil")
	
	revisar_colision()
	yield(get_tree().create_timer(velocidad_disparo), "timeout")
	se_puede_disparar = true
	
	
	

func recarga():
	print("Recargando")
	recargando = true         
	yield(get_tree().create_timer(tiempo_recarga), "timeout")
	recargando = false
	balas = balas_cargador
	print("Recarga completada")

func habilidad():
	if Input.is_action_pressed("tirar habilidad"):
		if raycast.is_colliding():
			var b = kunai.instance()
			mano.add_child(b)
			b.look_at(raycast.get_collision_point(), Vector3.UP)

