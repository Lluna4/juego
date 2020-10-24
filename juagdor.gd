extends KinematicBody
class_name jugador
export var velocidad = 30
export var aceleracion = 5
export var gravedad = 0.95
export var fuerza_de_salto = 30
export var sensibilidad = 0.3
export var mana = 100
export var almas = 0
export var tiempo_recoil = 0.3

var rotacion_y = 0
const movimiento_arma = 30

onready var arma = $arma
onready var cabeza = $cabeza
onready var camara = $cabeza/Camera
onready var pistola = $cabeza/mano/arma
onready var mano = $cabeza/mano
onready var headloc = $cabeza/headloc
#onready var kunai = preload("res://kunaibeta.tscn")

var velocidad_maxima = Vector3()

#func oxigeno():
#	if nivel_oxigeno < 100:
#		yield(get_tree().create_timer(1), "timeout")
#
#		nivel_oxigeno += regen_oxigeno
#		print(nivel_oxigeno)
	
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	



	
	

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion:
		cabeza.rotate_y(deg2rad(-event.relative.x * sensibilidad))
		
		var y_delta = -event.relative.y * sensibilidad
		if rotacion_y + y_delta > -90 and rotacion_y + y_delta < 90:
			camara.rotate_x(deg2rad(y_delta))
			rotacion_y += y_delta
	
func _physics_process(delta: float) -> void:
	var direccion_cabeza = cabeza.get_global_transform().basis
	var direccion = Vector3()
	if Input.is_action_pressed("delante"):
		direccion -= direccion_cabeza.z
	elif Input.is_action_pressed("atras"):
		direccion += direccion_cabeza.z
	
	if Input.is_action_pressed("derecha"):
		direccion += direccion_cabeza.x
	if Input.is_action_pressed("izquierda "):
		direccion -= direccion_cabeza.x
	velocidad_maxima = velocidad_maxima.linear_interpolate(direccion * velocidad, aceleracion * delta)
	velocidad_maxima = move_and_slide(velocidad_maxima, Vector3.UP)
	velocidad_maxima.y -= gravedad
	if Input.is_action_pressed("salto ") and is_on_floor():
		velocidad_maxima.y += fuerza_de_salto
		
	direccion = direccion.normalized()
	

