extends Node
## Database: el catálogo de todo el contenido del juego.
##
## Al iniciar carga una sola vez todos los .tres (snacks, tazos, series,
## mejoras, bebidas, capítulos) y los indexa por id, para pedirlos así:
## Database.get_snack(&"drk"). Así nadie hace load() a mitad del juego.
##
## No hace: modificar datos. Los .tres son de solo lectura en el juego;
## lo que el jugador TIENE vive en GameState.

const SNACKS_DIR := "res://data/snacks/"

# Índice id → ficha. Diccionario tipado: solo acepta SnackData.
var _snacks: Dictionary[StringName, SnackData] = {}


func _ready() -> void:
	for resource in _load_all_resources(SNACKS_DIR):
		var snack := resource as SnackData
		if snack == null:
			push_warning("Database: %s no es un SnackData" % resource.resource_path)
			continue
		# Dos fichas con el mismo id romperían el guardado: avisamos fuerte.
		if _snacks.has(snack.id):
			push_error("Database: id de snack repetido '%s'" % snack.id)
			continue
		_snacks[snack.id] = snack


## Devuelve la ficha del snack, o null si el id no existe.
func get_snack(id: StringName) -> SnackData:
	return _snacks.get(id)


## Todos los snacks ordenados por casilla (A1, A2…), como en la máquina.
func get_all_snacks() -> Array[SnackData]:
	var list: Array[SnackData] = []
	list.assign(_snacks.values())
	list.sort_custom(func(a: SnackData, b: SnackData) -> bool: return a.slot_code < b.slot_code)
	return list


## Carga todos los recursos de una carpeta. Ojo: en el juego exportado los
## .tres se convierten y aparecen como "archivo.tres.remap"; quitando ".remap"
## ResourceLoader encuentra el recurso igual. Sin esto, el juego exportado
## arrancaría sin snacks.
func _load_all_resources(dir_path: String) -> Array[Resource]:
	var result: Array[Resource] = []
	for file_name in DirAccess.get_files_at(dir_path):
		var clean_name := file_name.trim_suffix(".remap")
		if not clean_name.ends_with(".tres"):
			continue
		var resource := ResourceLoader.load(dir_path + clean_name)
		if resource != null:
			result.append(resource)
	return result
