extends StaticBody3D
## La puerta principal: aquí se deja la caja de envío, pasa el repartidor y
## deja el dinero en la bandeja (GDD 5.8 y 9).
##
## «E» en la puerta hace lo que toque, en este orden:
##   1. Si hay dinero en la bandeja → «Recoger $X».
##   2. Si llevas la caja en el inventario → «Dejar caja».
## Si no hay nada que hacer, la puerta no se puede usar.
## El repartidor pasa cada `courier_interval_minutes` de juego (10:00,
## 12:00…): si la caja está en la puerta con tazos, se los lleva y deja el
## dinero. Nunca se ve; más adelante dejará notas cada vez más raras.
## Pendiente: la bandeja animada.

## Minutos de juego entre visitas del repartidor. La mejora «Repartidor
## Puntual» lo baja a 60.
@export var courier_interval_minutes: int = 120

@onready var _interactable: Interactable = $Interactable
# Bandeja con dinero: un plano amarillo que solo se ve si hay dinero.
@onready var _money_tray: MeshInstance3D = $MoneyTray


func _ready() -> void:
	_interactable.interacted.connect(_on_interacted)
	EventBus.shipping_changed.connect(_refresh)
	EventBus.clock_changed.connect(_on_clock_changed)
	_refresh()


func _refresh() -> void:
	var money := GameState.get_door_money()
	var carrying_box := GameState.get_box_location() == GameState.BoxLocation.INVENTORY
	_money_tray.visible = money > 0
	_interactable.enabled = money > 0 or carrying_box
	if money > 0:
		_interactable.prompt_text = tr("Recoger $%d") % money
	else:
		_interactable.prompt_text = tr("Dejar caja")


func _on_interacted(_by: Node) -> void:
	if GameState.get_door_money() > 0:
		var amount := GameState.collect_door_money()
		EventBus.notification_requested.emit(tr("Recogiste $%d de la puerta") % amount)
	elif GameState.drop_box_at_door():
		EventBus.notification_requested.emit(
				tr("Caja en la puerta: el repartidor pasa cada %d h") % (courier_interval_minutes / 60))


func _on_clock_changed(minute: int) -> void:
	# Las visitas caen en horas exactas desde las 08:00 (10:00, 12:00…).
	if minute % courier_interval_minutes != 0:
		return
	var left := GameState.courier_collect()
	if left > 0:
		EventBus.notification_requested.emit(tr("El repartidor dejó $%d en la puerta") % left)
