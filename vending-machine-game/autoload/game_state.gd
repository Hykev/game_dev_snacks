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
# Casillas de la zona de tazos de la mesa (GDD 5.3). Lo subirá la mejora
# «Zona de Tazos Ampliada».
const MAX_TABLE_TAZOS := 8
# Llenura máxima (GDD 5.4). La subirá la mejora «Estómago Elástico».
const MAX_FULLNESS := 100.0
# Digestión pasiva: −1 de llenura cada 30 min de juego (GDD 5.4), lenta a
# propósito para dejar margen de mejora. La
# mejorará «Metabolismo de Colibrí».
const DIGESTION_PER_GAME_MINUTE := 1.0 / 30.0
# Parte del efectivo que se pierde al desmayarse a las 02:00 (GDD 4).
const FAINT_MONEY_LOSS := 0.10

## Dónde está la caja de envío (es un objeto único).
enum BoxLocation { TABLE, INVENTORY, DOOR }
## Cómo se marca la caja dentro de un espacio del inventario.
const SHIPPING_BOX_ITEM := &"shipping_box"

## Resultado de intentar comprar: la UI lo usa para explicar qué pasó.
enum BuyResult { OK, UNKNOWN_SNACK, LOCKED, SOLD_OUT, NO_MONEY, NO_ROOM }

## Efectivo actual. Se lee desde fuera; para cambiarlo, usar las funciones
## de abajo (así siempre se valida y se emite la señal).
var money: int:
	get:
		return _money

var _money: int = STARTING_MONEY

## Brillos (✦): moneda mágica que solo sale de reciclar tazos (GDD 7).
var shines: int:
	get:
		return _shines

var _shines: int = 0

## Día de la partida (1 = primer día). Lo avanza el flujo de dormir.
var day: int:
	get:
		return _day

var _day: int = 1
# Cifras del día en curso para el resumen al dormir (GDD 4). Se reinician
# al empezar cada día.
var _day_stats: Dictionary = {}

## Llenura del estómago (0 a MAX_FULLNESS). Es decimal porque la digestión y
## el baño la bajan poco a poco; en pantalla se muestra redondeada.
var fullness: float:
	get:
		return _fullness

var _fullness: float = 0.0

## Suerte actual (0.0 = 0 %, 0.5 = 50 %). La calculará Stats con mejoras,
## álbumes y bebidas; por ahora siempre es 0.
var luck: float:
	get:
		return _luck

var _luck: float = 0.0

# Generador aleatorio de las tiradas. Vive aquí (y no en LootSystem) para
# que más adelante su semilla se pueda guardar con la partida.
var _rng := RandomNumberGenerator.new()

# Tazos que salieron y esperan sobre la mesa a que el jugador decida
# (coleccionar, vender o reciclar), en orden de llegada. Cada uno es
# {"tazo_id", "snack_id"}: se recuerda de qué snack salió porque su precio
# de venta depende de ese snack (y el Basura puede salir de cualquiera).
var _table_tazos: Array[Dictionary] = []

# Colección: ids de los tazos que el jugador guardó en sus álbumes. Se usa
# un diccionario como "conjunto" para preguntar rápido si ya lo tiene.
var _collection: Dictionary[StringName, bool] = {}

# Snacks sueltos (en la mesa o el piso) al momento de guardar, como
# {"snack_id", "bites_left"} (bites_left = -1 si estaba cerrado). Son
# objetos con física en la escena; aquí solo viven para guardarlos y, al
# cargar, la mesa los vuelve a crear. No se guardan posiciones (GDD 14).
var _loose_snacks: Array[Dictionary] = []

# Venta (GDD 5.8): los tazos empacados van a la caja de envío como
# {"tazo_id", "price"} (el precio se fija al empacar). Dónde está la caja y
# el dinero que dejó el repartidor en la bandeja de la puerta.
var _shipping_box: Array[Dictionary] = []
var _box_location: BoxLocation = BoxLocation.TABLE
var _door_money: int = 0

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
	_rng.randomize()
	_reset_day_stats()
	# La digestión es una regla del estado del jugador: GameState escucha el
	# paso del tiempo y baja su propia llenura.
	EventBus.game_minutes_passed.connect(_on_game_minutes_passed)


func _on_game_minutes_passed(minutes: int) -> void:
	reduce_fullness(DIGESTION_PER_GAME_MINUTE * minutes)


# --- Día ---

## Cierra el día y devuelve sus cifras para la pantalla de resumen.
## `fainted` = true si terminó por desmayo (02:00).
func end_day(fainted: bool) -> Dictionary:
	var summary := _day_stats.duplicate()
	summary["day"] = _day
	summary["fainted"] = fainted
	return summary


## Empieza el día siguiente: avanza el número de día, reinicia las cifras,
## y repone la máquina (GDD 4: a las 08:00). La llenura se conserva: dormir
## no vacía el estómago (hay que ir al baño).
func start_next_day() -> void:
	_day += 1
	_reset_day_stats()
	restock_machine()


## GDD 4: a las 02:00 se desmaya y pierde el 10 % del efectivo «por la
## pizza que pidió dormido». Devuelve cuánto perdió.
func apply_faint_penalty() -> int:
	var lost := floori(_money * FAINT_MONEY_LOSS)
	if lost > 0:
		_money -= lost
		_day_stats["money_lost"] += lost
		EventBus.money_changed.emit(_money)
	return lost


func _reset_day_stats() -> void:
	_day_stats = {
		"snacks_eaten": 0,
		"tazos_found": 0,
		"money_earned": 0,
		"money_spent": 0,
		"money_lost": 0,
	}


# --- Snacks sueltos (para el guardado) ---

## La mesa informa qué snacks hay sueltos justo antes de guardar.
func set_loose_snacks(snacks: Array[Dictionary]) -> void:
	_loose_snacks = snacks.duplicate(true)


## La mesa los pide una sola vez al cargar, para volver a crearlos.
## Se vacían al entregarlos: desde ese momento vuelven a ser objetos físicos.
func take_loose_snacks() -> Array[Dictionary]:
	var snacks := _loose_snacks.duplicate(true)
	_loose_snacks.clear()
	return snacks


# --- Guardado ---
# GameState sabe QUÉ guardar (es el dueño del estado); SaveManager sabe
# CÓMO (archivo, JSON, versión, ranuras). Solo ids y números.

## Todo el estado del jugador como diccionario listo para JSON.
## Los StringName se guardan como texto; los números grandes del RNG como
## texto también, porque JSON pierde precisión con enteros de 64 bits.
func get_save_data() -> Dictionary:
	var stock := {}
	for snack_id in _machine_stock:
		stock[String(snack_id)] = _machine_stock[snack_id]
	return {
		"money": _money,
		"shines": _shines,
		"day": _day,
		"fullness": _fullness,
		"inventory": _inventory.duplicate(true),
		"collection": _collection.keys(),
		"table_tazos": _table_tazos.duplicate(true),
		"loose_snacks": _loose_snacks.duplicate(true),
		"shipping_box": _shipping_box.duplicate(true),
		"box_location": _box_location,
		"door_money": _door_money,
		"unlocked_snacks": _unlocked_snacks.duplicate(),
		"machine_stock": stock,
		"rng_seed": str(_rng.seed),
		"rng_state": str(_rng.state),
	}


## Reemplaza el estado con lo que vino del archivo. Convierte los tipos que
## JSON cambia (todos los números llegan como decimales y los ids como
## texto) e ignora ids que ya no existen en Database, para que una partida
## vieja no rompa el juego si se borró contenido.
func apply_save_data(data: Dictionary) -> void:
	_money = int(data.get("money", STARTING_MONEY))
	_shines = int(data.get("shines", 0))
	_day = int(data.get("day", 1))
	_fullness = clampf(float(data.get("fullness", 0.0)), 0.0, MAX_FULLNESS)

	_inventory.clear()
	for slot: Dictionary in data.get("inventory", []):
		if slot.has("special"):
			_inventory.append({"special": StringName(slot["special"])})
		else:
			_inventory.append(_parse_snack_entry(slot, true))
	# resize en un arreglo tipado rellena los espacios nuevos con {} (vacío).
	_inventory.resize(INVENTORY_SLOTS)

	_collection.clear()
	for tazo_id: String in data.get("collection", []):
		if Database.get_tazo(tazo_id) != null:
			_collection[StringName(tazo_id)] = true

	_table_tazos.clear()
	for entry: Dictionary in data.get("table_tazos", []):
		if Database.get_tazo(entry["tazo_id"]) != null and Database.get_snack(entry["snack_id"]) != null:
			_table_tazos.append({"tazo_id": StringName(entry["tazo_id"]), "snack_id": StringName(entry["snack_id"])})

	_loose_snacks.clear()
	for entry: Dictionary in data.get("loose_snacks", []):
		var parsed := _parse_snack_entry(entry, false)
		if not parsed.is_empty():
			_loose_snacks.append(parsed)

	# Los precios ya están fijados: se respetan aunque el tazo ya no exista.
	_shipping_box.clear()
	for item: Dictionary in data.get("shipping_box", []):
		_shipping_box.append({"tazo_id": StringName(item["tazo_id"]), "price": int(item["price"])})
	_box_location = int(data.get("box_location", BoxLocation.TABLE)) as BoxLocation
	_door_money = int(data.get("door_money", 0))
	# Si dice que la caja está en el inventario pero no está en ningún
	# espacio (partida dañada), se devuelve a la mesa para no perderla.
	if _box_location == BoxLocation.INVENTORY and not _inventory.any(
			func(slot: Dictionary) -> bool: return slot.has("special")):
		_box_location = BoxLocation.TABLE

	_unlocked_snacks.clear()
	for snack_id: String in data.get("unlocked_snacks", STARTING_UNLOCKED_SNACKS):
		if Database.get_snack(snack_id) != null:
			_unlocked_snacks.append(StringName(snack_id))

	_machine_stock.clear()
	var stock: Dictionary = data.get("machine_stock", {})
	for snack_id: String in stock:
		_machine_stock[StringName(snack_id)] = int(stock[snack_id])

	if data.has("rng_seed"):
		_rng.seed = String(data["rng_seed"]).to_int()
		_rng.state = String(data["rng_state"]).to_int()

	_reset_day_stats()
	_emit_all_changed()


# Convierte una entrada de snack del JSON ({snack_id, count?, bites_left?})
# a tipos de Godot. {} si está vacía o el snack ya no existe.
func _parse_snack_entry(entry: Dictionary, with_count: bool) -> Dictionary:
	if entry.is_empty() or Database.get_snack(entry.get("snack_id", "")) == null:
		return {}
	var parsed := {"snack_id": StringName(entry["snack_id"])}
	if with_count:
		parsed["count"] = int(entry.get("count", 1))
	if entry.has("bites_left"):
		parsed["bites_left"] = int(entry["bites_left"])
	elif not with_count:
		parsed["bites_left"] = -1
	return parsed


# Tras cargar, avisar de todo para que lo que ya esté en pantalla se
# actualice (lo que se crea después lee los valores en su _ready).
func _emit_all_changed() -> void:
	EventBus.money_changed.emit(_money)
	EventBus.shines_changed.emit(_shines)
	EventBus.fullness_changed.emit(_fullness, MAX_FULLNESS)
	EventBus.inventory_changed.emit()
	EventBus.collection_changed.emit()
	EventBus.table_tazos_changed.emit()
	EventBus.machine_stock_changed.emit()
	EventBus.shipping_changed.emit()


# --- Dinero ---

func can_afford(amount: int) -> bool:
	return amount <= _money


## Resta dinero si alcanza. Devuelve false (y no cambia nada) si no alcanza.
func spend_money(amount: int) -> bool:
	if amount < 0 or not can_afford(amount):
		return false
	_money -= amount
	_day_stats["money_spent"] += amount
	EventBus.money_changed.emit(_money)
	return true


func add_money(amount: int) -> void:
	if amount <= 0:
		return
	_money += amount
	_day_stats["money_earned"] += amount
	EventBus.money_changed.emit(_money)


# --- Llenura ---

## GDD 5.4: al llegar al tope ya no se puede comer.
func can_eat() -> bool:
	return _fullness < MAX_FULLNESS


func is_full() -> bool:
	return _fullness >= MAX_FULLNESS


## Suma llenura (un bocado). Nunca pasa del máximo.
func add_fullness(amount: float) -> void:
	_set_fullness(_fullness + amount)


## Resta llenura (baño y, más adelante, digestión). Nunca baja de 0.
func reduce_fullness(amount: float) -> void:
	_set_fullness(_fullness - amount)


func _set_fullness(value: float) -> void:
	var clamped := clampf(value, 0.0, MAX_FULLNESS)
	if is_equal_approx(clamped, _fullness):
		return
	_fullness = clamped
	EventBus.fullness_changed.emit(_fullness, MAX_FULLNESS)


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


## Guarda un snack YA ABIERTO (recogido del piso). Ocupa un espacio vacío
## completo y nunca se apila, porque cada snack abierto tiene sus propios
## bocados restantes. Devuelve false si no hay un espacio vacío.
func add_opened_snack(snack_id: StringName, bites_left: int) -> bool:
	var index := _inventory.find({})
	if index == -1:
		return false
	_inventory[index] = {"snack_id": snack_id, "count": 1, "bites_left": bites_left}
	EventBus.inventory_changed.emit()
	return true


## ¿El espacio tiene un snack abierto? (la mesa lo revisa antes de sacarlo)
func is_slot_opened(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= _inventory.size():
		return false
	return _inventory[slot_index].has("bites_left")


## Saca UN snack del espacio `slot_index` (para ponerlo en la mesa).
## Devuelve {"snack_id", "bites_left"}; bites_left = -1 si estaba cerrado.
## Devuelve {} si el espacio está vacío o no existe.
func take_snack(slot_index: int) -> Dictionary:
	if slot_index < 0 or slot_index >= _inventory.size() or _inventory[slot_index].is_empty():
		return {}
	# La caja de envío no es un snack: se maneja con put_box_on_table().
	if is_slot_box(slot_index):
		return {}
	var slot := _inventory[slot_index]
	var taken :={"snack_id": slot["snack_id"], "bites_left": slot.get("bites_left", -1)}
	slot["count"] -= 1
	if slot["count"] <= 0:
		_inventory[slot_index] = {}
	EventBus.inventory_changed.emit()
	return taken


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


# --- Tazos ---

## Copia de los tazos que esperan sobre la mesa, en orden de llegada.
## Cada uno es {"tazo_id", "snack_id"}.
func get_table_tazos() -> Array[Dictionary]:
	return _table_tazos.duplicate(true)


func has_in_collection(tazo_id: StringName) -> bool:
	return _collection.has(tazo_id)


## ¿Se puede coleccionar el tazo de la mesa `index`? Solo si no lo tienes y
## si tiene álbum (el Basura no tiene casilla en ningún álbum).
func can_collect_table_tazo(index: int) -> bool:
	var tazo := _get_table_tazo_data(index)
	return tazo != null and tazo.rarity != TazoData.Rarity.JUNK \
			and not has_in_collection(tazo.id)


## Cuánto pagaría hoy vender el tazo de la mesa `index` (para la carta).
func get_table_tazo_sale_price(index: int) -> int:
	var tazo := _get_table_tazo_data(index)
	if tazo == null:
		return 0
	var snack := Database.get_snack(_table_tazos[index]["snack_id"])
	return Economy.get_sale_price(tazo, snack.price)


## Guarda el tazo de la mesa en la colección. Devuelve false si no se puede.
func collect_table_tazo(index: int) -> bool:
	if not can_collect_table_tazo(index):
		return false
	_collection[_table_tazos[index]["tazo_id"]] = true
	_remove_table_tazo(index)
	EventBus.collection_changed.emit()
	return true


## Empaca el tazo de la mesa en la caja de envío con su precio de hoy
## (GDD 5.8). Solo se puede si la caja está junto a la mesa. El dinero
## llega cuando el repartidor se lleva la caja de la puerta.
## Devuelve el precio (-1 si no se pudo).
func pack_table_tazo(index: int) -> int:
	if _get_table_tazo_data(index) == null or not can_pack():
		return -1
	var price := get_table_tazo_sale_price(index)
	_shipping_box.append({"tazo_id": _table_tazos[index]["tazo_id"], "price": price})
	_remove_table_tazo(index)
	EventBus.shipping_changed.emit()
	return price


# --- Caja de envío, puerta y repartidor ---
# La caja es un objeto único que está en UN lugar a la vez: junto a la mesa
# (se empaca), en el inventario (se lleva) o en la puerta (espera al
# repartidor). El repartidor se lleva los tazos y deja el dinero en la
# bandeja de la puerta; la caja vacía se queda ahí para recogerla.

func get_box_location() -> BoxLocation:
	return _box_location


## Solo se empaca con la caja junto a la mesa.
func can_pack() -> bool:
	return _box_location == BoxLocation.TABLE


func get_shipping_box_count() -> int:
	return _shipping_box.size()


func get_shipping_box_total() -> int:
	return _sum_prices(_shipping_box)


func get_door_money() -> int:
	return _door_money


## Recoge la caja (de la mesa o de la puerta) al inventario: ocupa un
## espacio vacío completo. Devuelve false si no hay espacio.
func pick_up_box() -> bool:
	if _box_location == BoxLocation.INVENTORY:
		return false
	var index := _inventory.find({})
	if index == -1:
		return false
	_inventory[index] = {"special": SHIPPING_BOX_ITEM}
	_box_location = BoxLocation.INVENTORY
	EventBus.inventory_changed.emit()
	EventBus.shipping_changed.emit()
	return true


## Deja la caja (que se lleva en el inventario) junto a la puerta.
func drop_box_at_door() -> bool:
	return _drop_box(BoxLocation.DOOR)


## Devuelve la caja (que se lleva en el inventario) junto a la mesa.
func put_box_on_table() -> bool:
	return _drop_box(BoxLocation.TABLE)


## ¿El espacio del inventario tiene la caja de envío?
func is_slot_box(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= _inventory.size():
		return false
	return _inventory[slot_index].get("special", &"") == SHIPPING_BOX_ITEM


## Pasa el repartidor: si la caja está en la puerta y tiene tazos, se los
## lleva y deja el dinero en la bandeja de la puerta. Devuelve lo que dejó.
func courier_collect() -> int:
	if _box_location != BoxLocation.DOOR or _shipping_box.is_empty():
		return 0
	var total := get_shipping_box_total()
	_shipping_box.clear()
	_door_money += total
	EventBus.shipping_changed.emit()
	return total


## Recoge el dinero de la bandeja de la puerta. Devuelve cuánto era.
func collect_door_money() -> int:
	var amount := _door_money
	if amount <= 0:
		return 0
	_door_money = 0
	add_money(amount)
	EventBus.shipping_changed.emit()
	return amount


func _drop_box(location: BoxLocation) -> bool:
	if _box_location != BoxLocation.INVENTORY:
		return false
	for i in _inventory.size():
		if is_slot_box(i):
			_inventory[i] = {}
	_box_location = location
	EventBus.inventory_changed.emit()
	EventBus.shipping_changed.emit()
	return true


func _sum_prices(items: Array[Dictionary]) -> int:
	var total := 0
	for item in items:
		total += int(item["price"])
	return total


## Recicla el tazo de la mesa en Brillos. Devuelve los Brillos ganados
## (-1 si no existe).
func recycle_table_tazo(index: int) -> int:
	var tazo := _get_table_tazo_data(index)
	if tazo == null:
		return -1
	var gained := Economy.get_recycle_shines(tazo)
	_remove_table_tazo(index)
	_shines += gained
	EventBus.shines_changed.emit(_shines)
	return gained


func _get_table_tazo_data(index: int) -> TazoData:
	if index < 0 or index >= _table_tazos.size():
		return null
	return Database.get_tazo(_table_tazos[index]["tazo_id"])


func _remove_table_tazo(index: int) -> void:
	_table_tazos.remove_at(index)
	EventBus.table_tazos_changed.emit()


## Se terminó un snack: tira su premio con LootSystem y deja el tazo sobre
## la mesa. Devuelve el id del tazo que salió (&"" si el snack no existe).
## Si la zona de tazos está llena, el tazo igual se guarda (el GDD prevé una
## pila al borde de la mesa).
func resolve_finished_snack(snack_id: StringName) -> StringName:
	var snack := Database.get_snack(snack_id)
	if snack == null:
		push_error("GameState: snack desconocido '%s'" % snack_id)
		return &""
	var tazo := LootSystem.roll_tazo(snack, _luck, _rng, Database.get_junk_tazo())
	_table_tazos.append({"tazo_id": tazo.id, "snack_id": snack_id})
	_day_stats["snacks_eaten"] += 1
	# "Tazos encontrados" = premios de verdad; el Basura no cuenta.
	if tazo.rarity != TazoData.Rarity.JUNK:
		_day_stats["tazos_found"] += 1
	EventBus.tazo_found.emit(tazo.id)
	EventBus.table_tazos_changed.emit()
	return tazo.id


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
		# Un snack abierto ("bites_left") nunca recibe otros encima, ni la
		# caja de envío ("special").
		if not slot.is_empty() and not slot.has("bites_left") and not slot.has("special") \
				and slot["snack_id"] == snack_id and slot["count"] < MAX_STACK:
			return i
	for i in _inventory.size():
		if _inventory[i].is_empty():
			return i
	return -1
