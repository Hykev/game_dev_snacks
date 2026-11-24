class_name EatingStation
extends Node3D
## La mesa + sofá donde se comen los snacks (GDD 5.3).
##
## - Sentarse: al usarla, anuncia por EventBus que el jugador quiere sentarse
##   y le pasa su cámara fija. El jugador decide cómo cambiar de modo.
## - Zonas: comer (derecha) y tazos (izquierda) brillan bajo el cursor.
## - Colocar: con slot_1…slot_3 saca un snack del inventario (pidiéndoselo a
##   GameState) y lo deja caer con física en la zona de comer.
## - Agarrar (grab) y abrir (interact) el snack agarrado o señalado; comer
##   (eat) solo el que se sostiene. El movimiento lo hace el GrabController.
## - Recoger: un snack que cae fuera de la mesa se puede recoger caminando y
##   vuelve a la zona de comer. TableSurface avisa cuándo sale o entra.
## - Tazos: al terminar un snack le pide a GameState que tire el premio, y
##   muestra los tazos que esperan en la zona de tazos (casillas fijas).
##
## Solo procesa entrada y cursor mientras el jugador está sentado.

# Escena del snack físico. preload la carga al compilar el script, no a
# mitad del juego (principio 8).
const SNACK_BODY_SCENE := preload("res://scenes/eating/snack_body.tscn")
const TAZO_TOKEN_SCENE := preload("res://scenes/eating/tazo_token.tscn")
# Cuadrícula de casillas de la zona de tazos: 2 columnas × 4 filas = 8.
const TAZO_COLUMNS := 2
const TAZO_ROWS := 4
# Distancia (m) del cursor al centro de una ficha para considerarla señalada.
# Un poco más que su radio (0.06) para que sea fácil apuntarle.
const TAZO_PICK_RADIUS := 0.08
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
# Volumen sobre la mesa: sus señales dicen si un snack está encima o se cayó.
@onready var _table_surface: Area3D = %TableSurface

var _is_active := false
var _hovered_zone: TableZone = null
var _hovered_snack: SnackBody = null
# Grupo fijo (pool) de fichas: una por casilla de la zona de tazos.
var _tazo_tokens: Array[TazoToken] = []
# Índice de la ficha bajo el cursor (-1 si ninguna).
var _hovered_tazo_index := -1
# Mientras la carta de un tazo está abierta, la mesa no acepta entrada
# (para no agarrar ni comer "a través" de la carta).
var _is_card_open := false


func _ready() -> void:
	_seat_interactable.interacted.connect(_on_seat_interacted)
	EventBus.player_mode_changed.connect(_on_player_mode_changed)
	_table_surface.body_entered.connect(_on_table_surface_body_changed.bind(true))
	_table_surface.body_exited.connect(_on_table_surface_body_changed.bind(false))
	EventBus.table_tazos_changed.connect(_refresh_tazo_tokens)
	EventBus.tazo_card_closed.connect(func() -> void: _is_card_open = false)
	_create_tazo_tokens()
	_refresh_tazo_tokens()
	# Sin jugador sentado no hay nada que calcular cada frame.
	set_physics_process(false)


## Crea una ficha oculta por casilla, una sola vez al iniciar (pool).
func _create_tazo_tokens() -> void:
	var slot_count := TAZO_COLUMNS * TAZO_ROWS
	for i in slot_count:
		var token := TAZO_TOKEN_SCENE.instantiate() as TazoToken
		_tazo_zone.add_child(token)
		token.global_position = _tazo_zone.get_slot_position(i, TAZO_COLUMNS, TAZO_ROWS)
		token.hide()
		_tazo_tokens.append(token)


## Muestra en cada casilla el tazo que le toca (según GameState) y oculta
## las casillas libres. Se llama solo cuando llega la señal, no cada frame.
func _refresh_tazo_tokens() -> void:
	var table_tazos := GameState.get_table_tazos()
	for i in _tazo_tokens.size():
		if i < table_tazos.size():
			_tazo_tokens[i].show_tazo(Database.get_tazo(table_tazos[i]["tazo_id"]))
		else:
			_tazo_tokens[i].hide()
	# Las fichas se corrieron de lugar: el resaltado anterior ya no aplica.
	_set_hovered_tazo(-1)


## Un cuerpo entró o salió del volumen sobre la mesa. Solo nos importan los
## snacks: fuera de la mesa se pueden recoger caminando.
func _on_table_surface_body_changed(body: Node3D, on_table: bool) -> void:
	var snack_body := body as SnackBody
	# Un snack recién terminado también "sale" al borrarse: lo ignoramos.
	if snack_body == null or snack_body.is_queued_for_deletion():
		return
	snack_body.set_on_table(on_table)


## Recogieron un snack del piso: vuelve al inventario (se le PIDE a
## GameState). Cerrado se apila normal; abierto ocupa un espacio completo y
## conserva sus bocados. Si no hay lugar, se queda en el piso.
func _on_snack_pickup_requested(body: SnackBody) -> void:
	var stored: bool
	if body.is_open:
		stored = GameState.add_opened_snack(body.snack.id, body.bites_left)
	else:
		stored = GameState.add_snack(body.snack.id)
	if stored:
		body.queue_free()


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
		_set_hovered_tazo(-1)


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
	# Las fichas no tienen física: basta medir la distancia del cursor a cada
	# una sobre la mesa. Si el cursor está sobre un snack, el snack gana.
	var tazo_index := -1
	if point != null and _hovered_snack == null and _grab_controller.held_body == null:
		tazo_index = _find_tazo_token_at(point)
	_set_hovered_tazo(tazo_index)


func _find_tazo_token_at(point: Vector3) -> int:
	for i in _tazo_tokens.size():
		var token := _tazo_tokens[i]
		if not token.visible:
			continue
		var offset := token.global_position - point
		offset.y = 0.0
		if offset.length() <= TAZO_PICK_RADIUS:
			return i
	return -1


func _set_hovered_tazo(index: int) -> void:
	if index == _hovered_tazo_index:
		return
	if _hovered_tazo_index >= 0:
		_tazo_tokens[_hovered_tazo_index].set_highlighted(false)
	_hovered_tazo_index = index
	if index >= 0:
		_tazo_tokens[index].set_highlighted(true)


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
	if not _is_active or _is_card_open:
		return
	for i in SLOT_ACTIONS.size():
		if event.is_action_pressed(SLOT_ACTIONS[i]):
			_place_snack_from_slot(i)
			get_viewport().set_input_as_handled()
			return

	if event.is_action_pressed("grab"):
		if _hovered_snack != null:
			_grab_controller.start_grab(_hovered_snack)
		elif _hovered_tazo_index >= 0:
			# Clic sobre una ficha: la UI muestra su carta.
			_is_card_open = true
			EventBus.tazo_card_requested.emit(_hovered_tazo_index)
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
## Primero revisa que haya lugar en la mesa (y, si viene abierto, que no se
## pase el límite de abiertos), para no sacarlo del inventario y luego no
## poder ponerlo.
func _place_snack_from_slot(slot_index: int) -> void:
	if _snacks_root.get_child_count() >= MAX_SNACKS_ON_TABLE:
		return
	if GameState.is_slot_opened(slot_index) and _get_open_snacks().size() >= MAX_OPEN_SNACKS:
		return
	var taken := GameState.take_snack(slot_index)
	if taken.is_empty():
		return
	var body := SNACK_BODY_SCENE.instantiate() as SnackBody
	body.snack = Database.get_snack(taken["snack_id"])
	body.pickup_requested.connect(_on_snack_pickup_requested.bind(body))
	_snacks_root.add_child(body)
	# Un snack que se guardó abierto vuelve abierto, con sus bocados.
	if taken["bites_left"] >= 0:
		body.open(taken["bites_left"])
	body.global_position = _eat_zone.get_drop_point(DROP_HEIGHT)
	# Un giro al azar para que no caigan todos iguales.
	body.rotation.y = randf() * TAU


## El snack sobre el que actúan E y Espacio: el agarrado o, si no, el señalado.
func _get_target_snack() -> SnackBody:
	var held := _grab_controller.held_body
	if is_instance_valid(held):
		return held
	return _hovered_snack


## Para comer: SOLO el snack que se sostiene, y solo si está abierto.
## Señalarlo no basta (decisión de diseño: comer es "llevarlo a la boca").
func _get_eat_target() -> SnackBody:
	var held := _grab_controller.held_body
	if is_instance_valid(held) and held.is_open:
		return held
	return null


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
		# El premio lo decide GameState (con LootSystem); la mesa solo pide.
		GameState.resolve_finished_snack(body.snack.id)
		if _grab_controller.held_body == body:
			_grab_controller.release()
		if _hovered_snack == body:
			_hovered_snack = null
		body.queue_free()
