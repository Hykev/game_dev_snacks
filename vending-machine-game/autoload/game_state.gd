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


func _ready() -> void:
	_inventory.resize(INVENTORY_SLOTS)
	for i in INVENTORY_SLOTS:
		_inventory[i] = {}


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


# --- Operaciones compuestas ---

## Compra un snack: valida dinero Y espacio antes de tocar nada, para que
## nunca se cobre un snack que no cabe en el inventario.
func buy_snack(snack_id: StringName) -> bool:
	var snack := Database.get_snack(snack_id)
	if snack == null:
		push_error("GameState: snack desconocido '%s'" % snack_id)
		return false
	if not can_afford(snack.price) or not has_room_for(snack_id):
		return false
	spend_money(snack.price)
	add_snack(snack_id)
	return true


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
