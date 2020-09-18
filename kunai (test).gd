extends RigidBody
var dispararando = false
const damage = 100
const velocidad = 70

func _ready() -> void:
	set_as_toplevel(true)
	
func _physics_process(delta: float) -> void:
	apply_impulse(transform.basis.z, -transform.basis.z)
	


func _on_Area_body_entered(body: Node) -> void:
	if body.is_in_group("enemigos"):
		body.vida -= damage
		queue_free()
	
