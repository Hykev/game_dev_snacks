extends Node
## GameState: el único dueño del estado del jugador.
##
## Dinero, Brillos, Ecos, inventario, colección, mejoras, día y deuda viven
## aquí. Las escenas leen estos valores y PIDEN cambios con funciones
## (ej. spend_money()), que validan la operación y emiten una señal en
## EventBus para que la UI se actualice.
##
## No hace: tocar escenas 3D ni UI. Nunca debe saber que existe un HUD.

# TEMPORAL: valores de balance que se moverán a un BalanceConfig.tres cuando
# haya más números de balance. Los límites del inventario los calculará Stats
# a partir de las mejoras (Bolsillos Profundos, Bolsa de Super).
const STARTING_MONEY := 20
const INVENTORY_SLOTS := 3
const MAX_STACK := 3
# Stock por casilla cada día. Lo subirá la mejora «Resurtido Generoso».
const DAILY_STOCK := 5
# Casillas activas al empezar (GDD 5.1: solo A1 y A2). Las demás se
# activarán con la mejora «Licencia de Sabor».
const STARTING_UNLOCKED_SNACKS: Array[StringName] = [&"lzy", &"drk"]

## Resultado de intentar comprar: la UI lo usa para explicar qué pasó.
enum BuyResult { OK, UNKNOWN_SNACK, LOCKED, SOLD_OUT, NO_MONEY, NO_ROOM }

## Efectivo actual. Se lee desde fuera; para cambiarlo, usar las funciones
## de abajo (así siempre se valida y se emite la señal).
var money: int:
	get:
		return _money

var _money: int = STARTING_MONEY

# Un elemento por espacio de la barra rápida. Espacio vacío = {}.
# Espacio ocupado = {"snack_id": StringName, "count": int}. Solo ids y
# números, para que SaveManager pueda guardarlo tal cual en JSON.
var _inventory: Array[Dictionary] = []

# Máquina: qué snacks están activos y cuántos quedan hoy de cada uno.
var _unlocked_snacks: Array[StringName] = []
var _machine_stock: Dictionary[StringName, int] = {}


func _ready() -> void:
	_inventory.resize(INVENTORY_SLOTS)
	for i in INVENTORY_SLOTS:
		_inventory[i] = {}
	_unlocked_snacks = STARTING_UNLOCKED_SNACKS.duplicate()
	restock_machine()


# --- Dinero ---

func can_afford(amount: int) -> bool:
	return amount <= _money


## Resta dinero si alcanza. Devuelve false (y no cambia nada) si no alcanza.
func spend_money(amount: int) -> bool:
	if amount < 0 or not can_afford(amount):
		return false
	_money -= amount
	EventBus.money_changed.emit(_money)
	return true


func add_money(amount: int) -> void:
	if amount <= 0:
		return
	_money += amount
	EventBus.money_changed.emit(_money)


# --- Inventario ---

## Copia del inventario para mostrarlo. Es una copia a propósito: quien la
## reciba no puede cambiar el estado real sin pasar por GameState.
func get_inventory() -> Array[Dictionary]:
	return _inventory.duplicate(true)


## ¿Cabe un snack más de este tipo? (pila existente con lugar o espacio vacío)
func has_room_for(snack_id: StringName) -> bool:
	return _find_slot_for(snack_id) != -1


## Agrega un snack al inventario. Devuelve false si no hay lugar.
func add_snack(snack_id: StringName) -> bool:
	var index := _find_slot_for(snack_id)
	if index == -1:
		return false
	if _inventory[index].is_empty():
		_inventory[index] = {"snack_id": snack_id, "count": 1}
	else:
		_inventory[index]["count"] += 1
	EventBus.inventory_changed.emit()
	return true


## Saca UN snack del espacio `slot_index` (para ponerlo en la mesa).
## Devuelve su id, o &"" si el espacio está vacío o no existe.
func take_snack(slot_index: int) -> StringName:
	if slot_index < 0 or slot_index >= _inventory.size() or _inventory[slot_index].is_empty():
		return &""
	var slot := _inventory[slot_index]
	var snack_id: StringName = slot["snack_id"]
	slot["count"] -= 1
	if slot["count"] <= 0:
		_inventory[slot_index] = {}
	EventBus.inventory_changed.emit()
	return snack_id


# --- Máquina expendedora ---

func is_snack_unlocked(snack_id: StringName) -> bool:
	return snack_id in _unlocked_snacks


func get_stock(snack_id: StringName) -> int:
	return _machine_stock.get(snack_id, 0)


## Rellena todas las casillas activas. Por ahora se llama al iniciar; después
## lo llamará el flujo de "despertar a las 08:00".
func restock_machine() -> void:
	for snack_id in _unlocked_snacks:
		_machine_stock[snack_id] = DAILY_STOCK
	EventBus.machine_stock_changed.emit()


# --- Operaciones compuestas ---

## Compra un snack: valida TODO antes de tocar nada, para que nunca se cobre
## un snack agotado o que no cabe en el inventario.
func buy_snack(snack_id: StringName) -> BuyResult:
	var snack := Database.get_snack(snack_id)
	if snack == null:
		push_error("GameState: snack desconocido '%s'" % snack_id)
		return BuyResult.UNKNOWN_SNACK
	if not is_snack_unlocked(snack_id):
		return BuyResult.LOCKED
	if get_stock(snack_id) <= 0:
		return BuyResult.SOLD_OUT
	if not can_afford(snack.price):
		return BuyResult.NO_MONEY
	if not has_room_for(snack_id):
		return BuyResult.NO_ROOM
	spend_money(snack.price)
	add_snack(snack_id)
	_machine_stock[snack_id] -= 1
	EventBus.machine_stock_changed.emit()
	return BuyResult.OK


# Primero busca una pila del mismo snack con lugar; si no hay, el primer
# espacio vacío. Devuelve -1 si el inventario está lleno.
func _find_slot_for(snack_id: StringName) -> int:
	for i in _inventory.size():
		var slot := _inventory[i]
		if not slot.is_empty() and slot["snack_id"] == snack_id and slot["count"] < MAX_STACK:
			return i
	for i in _inventory.size():
		if _inventory[i].is_empty():
			return i
	return -1
