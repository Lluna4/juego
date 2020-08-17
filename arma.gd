extends Node
class_name arma
onready var raycast = $"../cabeza/Camera/RayCast"
export var velocidad_disparo = 0.5
export var balas_cargador = 20
export var tiempo_recarga = 1
onready var balas_ui = $"/root/mundo/algo/balas"
var balas = balas_cargador
var se_puede_disparar = true
var recargando = false
var balas_ui_recursos = [balas, balas_cargador]
func _process(delta: float) -> void:
	if recargando:
		balas_ui.set_text("Recargando!")
	else:
		balas_ui.set_text("BALAS: %d / %d" % [balas, balas_cargador])

	if Input.is_action_just_pressed("disparo") and se_puede_disparar:
		if balas > 0 and not recargando:
			print("BANG!")
			se_puede_disparar = false      #IF para disparar
			balas -= 1
			revisar_colision()
			yield(get_tree().create_timer(velocidad_disparo), "timeout")
			se_puede_disparar = true
		elif not recargando:
			print("Recargando")
			recargando = true         #IF para recargar
			yield(get_tree().create_timer(tiempo_recarga), "timeout")
			recargando = false
			balas = balas_cargador
			print("Recarga completada")
		  
		
		
func revisar_colision():
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		
		collider.queue_free()
		print("MATADO " + collider.name)
