extends Node
var items_municion = Array() #dejalo estar
var items_armas = Array()

func _ready():
	var directorio = Directory.new()
	directorio.open("res//items") 
	directorio.list_dir_begin()
	
	var nombre = directorio.get_next()
	while(nombre):
		if not directorio.current_is_dir():
			items_municion.append(load("res//items/%s" % nombre))
		nombre = directorio.get_next()



