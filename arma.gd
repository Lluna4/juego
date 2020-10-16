extends Node
class_name arma1
onready var raycast = $"../cabeza/Camera/disparo" #carga la carpeta del disparo
export var velocidad_disparo = 0.2 #Export significa que puedes editarlo sin entrar al codigo
export var balas_cargador = 20                  
export var tiempo_recarga = 1
export var respawn_s = 3
export var tiempo_kunai = 10
var F = 1
#var tiempo_recoil_lvl1 = 1.5    DE MOMENTO NO FUNCIONA
#var tiempo_recoil_lvl2 = 1.0
#var tiempo_recoil_lvl3 = 1.2
#var tiempo_recoil_lvl4 = 0.8
#var tiempo_recoil_lvl5 = 1
#var en_dolor_recoil = false
onready var recoil_animacion = $"../cabeza/Camera/recoil" #carga la animacion de recoil (mal implementada)
onready var lvl_ui = $"/root/mundo/algo/nivel" #carga el texto que pone en pantalla el nivel
onready var balas_ui = $"/root/mundo/algo/balas" #lo mismo que lo de la xp pero de las balas
onready var enemigo_cargado = $"/root/mundo/enemigo" #carga el modelo del enemigo
onready var cabeza = $"../cabeza" #carga la cabeza (que incluye la camara, la mano, el arma, el sistema de disparo)
onready var xp_ui = $"/root/mundo/algo/xp" #carga el texto en pantalla de los puntos de xp
#onready var kunai = preload("res://kunaibeta.tscn") ROTO
onready var mano = $"../mano" #carga la mano (sistema disparo, modelo arma)

var balas = balas_cargador #iguala las balas a las balas del cargador, porque al principio del todo las balas son las mismas que la capacidad del cargador 
var vida_maxima_enemigo = 100 
var vida_enemigo = vida_maxima_enemigo #lo mismo que las balas
var damage_bala = 34 #lo que quita cada bala
var se_puede_disparar = true 
var recargando = false
var disparos_seguidos = 0 #parte del sistema de XP, no funciona (de momento)
var rng = RandomNumberGenerator.new() #genera numero aleatorio
var balas_ui_recursos = [balas, balas_cargador] #carga las cosas que se muestran en pantalla (relacionado con las balas)

export var nivel_oxigeno = 100
export var regen_oxigeno = 3.6

var xp = 0
var xp_siguiente_lvl2 = 65   #SISTEMA XP, NO FUNCIONA (DE MOMENTO)
var xp_siguiente_lvl3 = 150
var xp_siguiente_lvl4 = 245
var xp_siguiente_lvl5 = 365
var nivel = 1


func oxigeno():
	if nivel_oxigeno < 100:
		yield(get_tree().create_timer(1), "timeout")
		nivel_oxigeno += regen_oxigeno
		print("oxigeno", nivel_oxigeno)
	if nivel_oxigeno <= 0:
		nivel_oxigeno = 0
	if nivel_oxigeno == 10:
		se_puede_disparar = false
		print("no hay oxigeno para disparar!")
	elif nivel_oxigeno > 100:
		nivel_oxigeno = 100
	else:
		se_puede_disparar = true



func _process(delta: float) -> void:
	xp_ui.set_text("XP: %d" % xp) #pone en pantalla los puntos de xp
	lvl_ui.set_text("NIVEL: %d" % nivel) #lo mismo pero el nivel de xp
	if recargando:
		balas_ui.set_text("Recargando!") #pone en pantalla cuando el pesonaje recarga
# 	elif en_dolor_recoil == true:     NO FUNCIONA
#		balas_ui.set_text("Demasiado recoil!")
	else:
		balas_ui.set_text("BALAS: %d / %d" % [balas, balas_cargador]) #pone en pantalla las balas y las balas maximas del cargador
	oxigeno()
	

	if Input.is_action_just_pressed("disparo") and se_puede_disparar: #si se presiona el boton de disparar (click izquierdo) dispara si las balas son mas que 0, sino recarga
		if balas > 0 and not recargando:
			disparo()
			nivel_oxigeno -= 10
			print("oxigeno", nivel_oxigeno)
			
		elif not recargando:
			recarga()
		
	if Input.is_action_pressed("recarga") and not recargando: #si le das al boton de recargar y no esta recargando ya, recarga el arma
		recarga()
	if xp >= xp_siguiente_lvl2 and not xp >= xp_siguiente_lvl3: #sistema nivel XP
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
	 
	if raycast.is_colliding():  #tira un rayo desde el centro de la pantalla y revisa si le ha dado a algo
		vida_enemigo -= damage_bala #le quita al enemigo el daño de la bala
		print("vida ",vida_enemigo) #para ver si de verdad le quito vida o no, ya que estaba bug
		var collider = raycast.get_collider() #le pide al rayo que diga en que ha impactado (si ha impactado)
		
		print("GOLPEADO " + collider.name) #si ha golpeado un enemigo, dice en la consola a quien a golpeado
		xp = xp + 5 # cada vez que le da a alguien le da 5 de xp al jugador
		 
		print(xp) #para saber si la XP funciona
		if vida_enemigo <= 0: #mata al enemigo si llega 0 la vida
			
			collider.queue_free() #elimina al enemigo,simplemente despareze
			yield(get_tree().create_timer(tiempo_recarga), "timeout") #cooldown para el respawn de los enemigos
			var enemigo = preload("res://enemigo.tscn").instance() # crea otro enemigo
			rng.randomize() # crea un numero aleatorio
			var my_random_number = rng.randf_range(-25, 25) #los valores entre los que tine que estar el numero aleatrio
			var my_random_number2 = rng.randf_range(-25, 25) 
			enemigo.translation = Vector3 (my_random_number, 0, my_random_number2) #tpea el enemigo a una posicion random
			add_child(enemigo) #genera el enemigo
			vida_enemigo = vida_maxima_enemigo #hace que el enemigo recupere su vida, ya que ha respawnado
 
func disparo(): 
#	 if disparos_seguidos == 3 and nivel == 1:   SISTEMA XP ROTO
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
	
	
	
	disparos_seguidos = disparos_seguidos + F #NO SIRVE PARA NADA (DE MOMENTO)
	print("BANG!") #para saber si he disparado o no, ya que habian bugs
	se_puede_disparar = false  #La arma acaba de disparar asi que no puede (de momento)  
	balas -= 1 # resta la bala que se ha gastado en el disparo
	#recoil_animacion.play("recoil") ROTO, LA ANIMACION QUE HIZE ES PESIMA
	
	revisar_colision() #La anterior funcion, la cual revisava si el rayo daba a alguien
	yield(get_tree().create_timer(velocidad_disparo), "timeout") # espera el tiempo que necesita el arma 
	se_puede_disparar = true # el tiempo ha acabado asi que ya se puede disparar
	
	
	

func recarga(): 
	print("Recargando") #para saber si funciona 
	recargando = true    #marca que el personaje esta recargando     
	yield(get_tree().create_timer(tiempo_recarga), "timeout") #el tiempo de recarga
	recargando = false #cuando acaba el tiempo, obviamente ya no esta recargando
	balas = balas_cargador #El cargador vuelve a rellenarse asi que las balas son las maximas que permite el cargador
	print("Recarga completada") #para saber si funciona

#func habilidad():
#	if Input.is_action_pressed("tirar habilidad"): ROTO
#		if raycast.is_colliding():
#			var b = kunai.instance()
#			mano.add_child(b)
#			b.look_at(raycast.get_collision_point(), Vector3.UP)

