extends StaticBody3D
## La caja de envío en el mundo (GDD 5.8).
##
## No guarda estado: GameState dice dónde está la caja y este nodo solo se
## coloca ahí (junto a la mesa o junto a la puerta) o se oculta si está en
## el inventario. «E · Recoger caja» la guarda en el inventario.

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
	if not GameState.pick_up_box():
		EventBus.notification_requested.emit(tr("Inventario lleno: no puedes cargar la caja"))
