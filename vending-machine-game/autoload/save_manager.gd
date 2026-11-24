extends Node
## SaveManager: convierte GameState a JSON y de vuelta.
##
## Guarda en user:// con número de versión (para migrar partidas viejas) y
## maneja 3 ranuras. Solo sabe CÓMO guardar (archivo, formato, versión);
## QUÉ se guarda lo decide GameState con get_save_data().
##
## No hace: guardar nodos ni posiciones físicas. Solo ids y números.
##
## Pendiente: meta.json aparte para los Ecos (cuando existan) y el menú
## principal para elegir ranura. Por ahora se usa siempre la ranura 1 y se
## carga sola al iniciar si existe.

## Súbelo cuando cambie la forma de los datos guardados, y agrega en
## _migrate() cómo convertir los de versiones anteriores.
const SAVE_VERSION := 1
const SLOT_COUNT := 3
const SLOT_PATH := "user://save_slot_%d.json"

## Ranura en uso (1 a SLOT_COUNT).
var current_slot := 1


func _ready() -> void:
	# Corre después de GameState y TimeManager (orden de autoloads), así que
	# la partida ya está cargada cuando las escenas leen sus valores en _ready.
	if has_save(current_slot):
		load_game(current_slot)


## Al cerrar la ventana se guarda (GDD 14: salir a mitad del día guarda el
## estado). Godot avisa con esta notificación antes de cerrar.
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()


func has_save(slot: int) -> bool:
	return FileAccess.file_exists(SLOT_PATH % slot)


## Guarda la partida. Devuelve false si no se pudo escribir.
func save_game(slot: int = current_slot) -> bool:
	# Aviso para que la escena entregue a GameState lo que solo existe como
	# objetos físicos (snacks sueltos en la mesa o el piso).
	EventBus.save_requested.emit()
	var data := {
		"version": SAVE_VERSION,
		"saved_at": Time.get_datetime_string_from_system(),
		"clock_minute": TimeManager.get_whole_minute(),
		"game": GameState.get_save_data(),
	}
	# Se escribe primero un archivo temporal y luego se renombra: si el juego
	# se cierra a mitad de escribir, la partida anterior queda intacta.
	var path := SLOT_PATH % slot
	var temp_path := path + ".tmp"
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: no se pudo escribir %s (%s)" % [temp_path, FileAccess.get_open_error()])
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	var error := DirAccess.rename_absolute(temp_path, path)
	if error != OK:
		push_error("SaveManager: no se pudo reemplazar %s (%s)" % [path, error])
		return false
	EventBus.game_saved.emit(slot)
	return true


## Carga la partida de la ranura. Devuelve false si no existe o está dañada.
func load_game(slot: int) -> bool:
	var path := SLOT_PATH % slot
	var text := FileAccess.get_file_as_string(path)
	var data: Variant = JSON.parse_string(text)
	if not data is Dictionary:
		push_error("SaveManager: el archivo %s está dañado" % path)
		return false
	var version := int(data.get("version", 0))
	if version > SAVE_VERSION:
		push_error("SaveManager: %s es de una versión más nueva del juego" % path)
		return false
	data = _migrate(data, version)
	current_slot = slot
	GameState.apply_save_data(data["game"])
	TimeManager.set_minute(int(data.get("clock_minute", TimeManager.DAY_START_MINUTE)))
	EventBus.game_loaded.emit(slot)
	return true


func delete_save(slot: int) -> void:
	if has_save(slot):
		DirAccess.remove_absolute(SLOT_PATH % slot)


## Convierte datos de versiones anteriores a la actual. Hoy solo existe la
## versión 1; cuando cambie el formato, aquí se agrega cada conversión.
func _migrate(data: Dictionary, _from_version: int) -> Dictionary:
	return data
