class_name EatingStation
extends Node3D
## La mesa + sofá donde se comen los snacks (GDD 5.3).
##
## - Sentarse: al usarla, anuncia por EventBus que el jugador quiere sentarse
##   y le pasa su cámara fija. El jugador decide cómo cambiar de modo.
## - Zonas: comer (derecha) y tazos (izquierda) brillan bajo el cursor.
## - Colocar: con slot_1…slot_3 saca un snack del inventario (pidiéndoselo a
##   GameState) y lo deja caer con física en la zona de comer.
##
## Solo procesa entrada y cursor mientras el jugador está sentado.

# Escena del snack físico. preload la carga al compilar el script, no a
# mitad del juego (principio 8).
const SNACK_BODY_SCENE := preload("res://scenes/eating/snack_body.tscn")
# TEMPORAL: snacks colocados a la vez. Cuida el presupuesto de física
# (~6 cuerpos). El límite del GDD es de 2 ABIERTOS; se aplicará al abrir.
const MAX_SNACKS_ON_TABLE := 4
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
		_set_hovered_zone(null)


func _physics_process(_delta: float) -> void:
	# Qué zona está bajo el cursor. Se revisa cada frame porque el cursor
	# puede moverse sin eventos (con control, el stick lo mueve solo).
	var point: Variant = _grab_controller.get_cursor_table_point()
	var zone: TableZone = null
	if point != null:
		for candidate: TableZone in [_eat_zone, _tazo_zone]:
			if candidate.contains_global_point(point):
				zone = candidate
				break
	_set_hovered_zone(zone)


func _set_hovered_zone(zone: TableZone) -> void:
	if zone == _hovered_zone:
		return
	if _hovered_zone != null:
		_hovered_zone.set_highlighted(false)
	_hovered_zone = zone
	if zone != null:
		zone.set_highlighted(true)


func _unhandled_input(event: InputEvent) -> void:
	if not _is_active:
		return
	for i in SLOT_ACTIONS.size():
		if event.is_action_pressed(SLOT_ACTIONS[i]):
			_place_snack_from_slot(i)
			get_viewport().set_input_as_handled()
			return


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
