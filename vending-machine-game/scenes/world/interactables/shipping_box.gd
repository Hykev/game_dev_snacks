extends StaticBody3D
## La caja de envío en el mundo (GDD 5.8).
##
## No guarda estado: GameState dice dónde está la caja y este nodo solo se
## coloca ahí (junto a la mesa o junto a la puerta) o se oculta si está en
## el inventario. «E · Recoger caja» la guarda en el inventario; si el
## repartidor ya viene por ella, la E solo dice a qué hora llega.

## Lugar junto a la mesa (donde se empaca).
@export var table_spot: Node3D
## Lugar junto a la puerta (donde la recoge el repartidor).
@export var door_spot: Node3D

@onready var _interactable: Interactable = $Interactable
@onready var _collision: CollisionShape3D = $CollisionShape3D
@onready var _label: Label3D = $Label3D


func _ready() -> void:
	_interactable.interacted.connect(_on_interacted)
	EventBus.shipping_changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	match GameState.get_box_location():
		GameState.BoxLocation.TABLE:
			_place(table_spot)
		GameState.BoxLocation.DOOR:
			_place(door_spot)
		GameState.BoxLocation.INVENTORY:
			_place(null)
	var count := GameState.get_shipping_box_count()
	_label.text = tr("Caja de envío (%d/%d)") % [count, GameState.SHIPPING_BOX_CAPACITY]
	if GameState.is_courier_on_the_way():
		_interactable.prompt_text = tr("Esperando al repartidor")
	else:
		_interactable.prompt_text = tr("Recoger caja (%d)") % count


# Pone la caja en `spot`, o la oculta (sin colisión ni «E») si es null.
func _place(spot: Node3D) -> void:
	var shown := spot != null
	visible = shown
	_collision.disabled = not shown
	_interactable.enabled = shown
	if shown:
		global_transform = spot.global_transform


func _on_interacted(_by: Node) -> void:
	# Con el envío pedido el paquete ya no se cambia: solo se avisa la hora.
	if GameState.is_courier_on_the_way():
		var arrival := TimeManager.get_whole_minute() + GameState.get_courier_minutes_left()
		EventBus.notification_requested.emit(
				tr("El paquete ya está pedido: el repartidor llega a las %s") % TimeManager.format_clock(arrival))
		return
	if not GameState.pick_up_box():
		EventBus.notification_requested.emit(tr("Inventario lleno: no puedes cargar la caja"))
