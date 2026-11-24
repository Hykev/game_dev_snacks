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
# Los tazos van en subcarpetas por serie (data/tazos/lzy/…); se buscan
# de forma recursiva.
const TAZOS_DIR := "res://data/tazos/"
## Id del Tazo Basura: lo que sale cuando un snack no trae premio.
const JUNK_TAZO_ID := &"junk"

# Índices id → ficha. Diccionarios tipados: solo aceptan ese tipo.
var _snacks: Dictionary[StringName, SnackData] = {}
var _tazos: Dictionary[StringName, TazoData] = {}


func _ready() -> void:
	for resource in _load_all_resources(TAZOS_DIR):
		_register(resource as TazoData, _tazos, resource.resource_path)
	for resource in _load_all_resources(SNACKS_DIR):
		var snack := resource as SnackData
		_register(snack, _snacks, resource.resource_path)
		if snack != null and snack.series == null:
			push_warning("Database: el snack '%s' no tiene serie de tazos" % snack.id)
	if get_junk_tazo() == null:
		push_error("Database: falta el Tazo Basura (id '%s')" % JUNK_TAZO_ID)


## Devuelve la ficha del snack, o null si el id no existe.
func get_snack(id: StringName) -> SnackData:
	return _snacks.get(id)


## Todos los snacks ordenados por casilla (A1, A2…), como en la máquina.
func get_all_snacks() -> Array[SnackData]:
	var list: Array[SnackData] = []
	list.assign(_snacks.values())
	list.sort_custom(func(a: SnackData, b: SnackData) -> bool: return a.slot_code < b.slot_code)
	return list


## Devuelve la ficha del tazo, o null si el id no existe.
func get_tazo(id: StringName) -> TazoData:
	return _tazos.get(id)


func get_junk_tazo() -> TazoData:
	return _tazos.get(JUNK_TAZO_ID)


# Agrega un recurso al índice, avisando si es del tipo equivocado o si su
# id está repetido (dos fichas con el mismo id romperían el guardado).
func _register(resource: Resource, index: Dictionary, path: String) -> void:
	if resource == null:
		push_warning("Database: %s no es del tipo esperado" % path)
		return
	var id: StringName = resource.get("id")
	if index.has(id):
		push_error("Database: id repetido '%s' en %s" % [id, path])
		return
	index[id] = resource


## Carga todos los .tres de una carpeta y sus subcarpetas. Ojo: en el juego
## exportado los .tres aparecen como "archivo.tres.remap"; quitando ".remap"
## ResourceLoader encuentra el recurso igual. Sin esto, el juego exportado
## arrancaría sin contenido.
func _load_all_resources(dir_path: String) -> Array[Resource]:
	var result: Array[Resource] = []
	for file_name in DirAccess.get_files_at(dir_path):
		var clean_name := file_name.trim_suffix(".remap")
		if not clean_name.ends_with(".tres"):
			continue
		var resource := ResourceLoader.load(dir_path + clean_name)
		if resource != null:
			result.append(resource)
	for sub_dir in DirAccess.get_directories_at(dir_path):
		result.append_array(_load_all_resources(dir_path + sub_dir + "/"))
	return result
