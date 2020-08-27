extends jugador

onready var raycast = $"../cabeza/Camera/disparo"
export var velocidad_disparo = 0.5
export var balas_cargador = 20
export var tiempo_recarga = 1
export var respawn_s = 3
export var tiempo_recoil = 0.3
onready var balas_ui = $"/root/mundo/algo/balas"
onready var enemigo_cargado = $"/root/mundo/enemigo"
var balas = balas_cargador
var vida_maxima_enemigo = 100
var vida_enemigo = vida_maxima_enemigo
var quita_bala = 34
var se_puede_disparar = true
var recargando = false

var rng = RandomNumberGenerator.new()
var balas_ui_recursos = [balas, balas_cargador]



func _process(delta: float) -> void:
	if recargando:
		balas_ui.set_text("Recargando!")
	else:
		balas_ui.set_text("BALAS: %d / %d" % [balas, balas_cargador])

	if Input.is_action_just_pressed("disparo") and se_puede_disparar:
		if balas > 0 and not recargando:
			disparo()
		elif not recargando:
			recarga()
		
	if Input.is_action_pressed("recarga") and not recargando:
		recarga()
	
func revisar_colision():
	 
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		vida_enemigo = vida_enemigo - quita_bala
		print("GOLPEADO " + collider.name)
		
		if vida_enemigo <= 0:
			collider.queue_free()
			yield(get_tree().create_timer(tiempo_recarga), "timeout")
			var enemigo = preload("res://enemigo.tscn").instance()
			rng.randomize()
			var my_random_number = rng.randf_range(-25, 25)
			enemigo.translation = Vector3 (my_random_number, 0, my_random_number)
			add_child(enemigo)

func disparo():
	print("BANG!")
	se_puede_disparar = false     
	balas -= 1
	revisar_colision()
	yield(get_tree().create_timer(velocidad_disparo), "timeout")
	se_puede_disparar = true
	cabeza.rotate_y(deg2rad(5))
	yield(get_tree().create_timer(tiempo_recoil),"timeout")
	cabeza.rotate_y(deg2rad(-5))

func recarga():
	print("Recargando")
	recargando = true         
	yield(get_tree().create_timer(tiempo_recarga), "timeout")
	recargando = false
	balas = balas_cargador
	print("Recarga completada")
