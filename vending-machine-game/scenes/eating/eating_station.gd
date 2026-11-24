class_name EatingStation
extends Node3D
## La mesa + sofá donde se comen los snacks (GDD 5.3).
##
## - Sentarse: al usarla, anuncia por EventBus que el jugador quiere sentarse
##   y le pasa su cámara fija. El jugador decide cómo cambiar de modo.
## - Zonas: comer (derecha) y tazos (izquierda) brillan bajo el cursor.
## - Colocar: con slot_1…slot_3 saca un snack del inventario (pidiéndoselo a
##   GameState) y lo deja caer con física en la zona de comer.
## - Agarrar (grab), abrir (interact) y comer (eat) el snack agarrado o
##   señalado. El movimiento lo hace el GrabController.
##
## Solo procesa entrada y cursor mientras el jugador está sentado.

# Escena del snack físico. preload la carga al compilar el script, no a
# mitad del juego (principio 8).
const SNACK_BODY_SCENE := preload("res://scenes/eating/snack_body.tscn")
# TEMPORAL: snacks colocados a la vez; cuida el presupuesto de física
# (~6 cuerpos). Los dos límites los calculará Stats (Mesa Extensible).
const MAX_SNACKS_ON_TABLE := 4
const MAX_OPEN_SNACKS := 2
# Altura (sobre la zona) desde la que caen los snacks al colocarlos.
const DROP_HEIGHT := 0.35
# Acciones del Input Map para cada espacio del inventario.
const SLOT_ACTIONS: Array[StringName] = [&"slot_1", &"slot_2", &"slot_3"]

@onready var _seat_interactable: Interactable = %SeatInteractable
@onready var _view_camera: Camera3D = %ViewCamera
@onready var _grab_controller: GrabController = %GrabController
@onready var _eat_zone: TableZone = %EatZone
@onready var _tazo_zone: TableZone = %TazoZone
@onready var _snacks_root: Node3D = %Snacks

var _is_active := false
var _hovered_zone: TableZone = null
var _hovered_snack: SnackBody = null


func _ready() -> void:
	_seat_interactable.interacted.connect(_on_seat_interacted)
	EventBus.player_mode_changed.connect(_on_player_mode_changed)
	# Sin jugador sentado no hay nada que calcular cada frame.
	set_physics_process(false)


func _on_seat_interacted(_by: Node) -> void:
	EventBus.table_sit_requested.emit(_view_camera)


func _on_player_mode_changed(mode: int) -> void:
	_is_active = mode == Player.Mode.TABLE
	set_physics_process(_is_active)
	if not _is_active:
		# Al levantarse se suelta lo agarrado y se apagan los resaltados.
		_grab_controller.release()
		_set_hovered_zone(null)
		_set_hovered_snack(null)


func _physics_process(_delta: float) -> void:
	# Qué zona y qué snack están bajo el cursor. Se revisa cada frame porque
	# el cursor puede moverse sin eventos (con control, el stick lo mueve).
	var point: Variant = _grab_controller.get_cursor_table_point()
	var zone: TableZone = null
	if point != null:
		for candidate: TableZone in [_eat_zone, _tazo_zone]:
			if candidate.contains_global_point(point):
				zone = candidate
				break
	_set_hovered_zone(zone)
	_set_hovered_snack(_grab_controller.get_snack_under_cursor())


func _set_hovered_zone(zone: TableZone) -> void:
	if zone == _hovered_zone:
		return
	if _hovered_zone != null:
		_hovered_zone.set_highlighted(false)
	_hovered_zone = zone
	if zone != null:
		zone.set_highlighted(true)


func _set_hovered_snack(body: SnackBody) -> void:
	if body == _hovered_snack:
		return
	if is_instance_valid(_hovered_snack):
		_hovered_snack.set_hovered(false)
	_hovered_snack = body
	if body != null:
		body.set_hovered(true)


func _unhandled_input(event: InputEvent) -> void:
	if not _is_active:
		return
	for i in SLOT_ACTIONS.size():
		if event.is_action_pressed(SLOT_ACTIONS[i]):
			_place_snack_from_slot(i)
			get_viewport().set_input_as_handled()
			return

	if event.is_action_pressed("grab"):
		if _hovered_snack != null:
			_grab_controller.start_grab(_hovered_snack)
	elif event.is_action_released("grab"):
		_grab_controller.release()
	elif event.is_action_pressed("interact"):
		_open_snack(_get_target_snack())
	elif event.is_action_pressed("eat"):
		_eat_from(_get_eat_target())
	else:
		return
	get_viewport().set_input_as_handled()


## Saca un snack del espacio `slot_index` y lo suelta en la zona de comer.
## Primero revisa que haya lugar en la mesa, para no sacarlo del inventario
## y luego no poder ponerlo.
func _place_snack_from_slot(slot_index: int) -> void:
	if _snacks_root.get_child_count() >= MAX_SNACKS_ON_TABLE:
		return
	var snack_id := GameState.take_snack(slot_index)
	if snack_id.is_empty():
		return
	var body := SNACK_BODY_SCENE.instantiate() as SnackBody
	body.snack = Database.get_snack(snack_id)
	_snacks_root.add_child(body)
	body.global_position = _eat_zone.get_drop_point(DROP_HEIGHT)
	# Un giro al azar para que no caigan todos iguales.
	body.rotation.y = randf() * TAU


## El snack sobre el que actúan E y Espacio: el agarrado o, si no, el señalado.
func _get_target_snack() -> SnackBody:
	var held := _grab_controller.held_body
	if is_instance_valid(held):
		return held
	return _hovered_snack


## Para comer: el agarrado o señalado si está abierto; si no, el único
## snack abierto de la mesa (así no hace falta apuntar si solo hay uno).
func _get_eat_target() -> SnackBody:
	var target := _get_target_snack()
	if target != null and target.is_open:
		return target
	var open_snacks := _get_open_snacks()
	return open_snacks[0] if open_snacks.size() == 1 else null


func _get_open_snacks() -> Array[SnackBody]:
	var result: Array[SnackBody] = []
	for child in _snacks_root.get_children():
		var body := child as SnackBody
		# queue_free() borra al final del frame: un snack recién terminado
		# sigue en el árbol unos instantes y no debe contar como abierto.
		if body != null and body.is_open and not body.is_queued_for_deletion():
			result.append(body)
	return result


func _open_snack(body: SnackBody) -> void:
	if body == null or body.is_open:
		return
	# GDD 5.3: máximo de snacks abiertos a la vez (mejorable).
	if _get_open_snacks().size() >= MAX_OPEN_SNACKS:
		return
	body.open()
	EventBus.snack_opened.emit(body.snack.id)


func _eat_from(body: SnackBody) -> void:
	if body == null:
		return
	var finished := body.take_bite()
	EventBus.snack_bitten.emit(body.snack.id, body.bites_left)
	if finished:
		EventBus.snack_finished.emit(body.snack.id)
		if _grab_controller.held_body == body:
			_grab_controller.release()
		if _hovered_snack == body:
			_hovered_snack = null
		body.queue_free()
