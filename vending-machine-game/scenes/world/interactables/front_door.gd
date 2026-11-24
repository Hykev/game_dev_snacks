extends StaticBody3D
## La puerta principal: aquí se deja la caja de envío, pasa el repartidor y
## deja el dinero en la bandeja (GDD 5.8 y 9).
##
## «E» en la puerta hace lo que toque, en este orden:
##   1. Si hay dinero en la bandeja → «Recoger $X».
##   2. Si llevas la caja en el inventario → «Dejar caja».
## Si no hay nada que hacer, la puerta no se puede usar.
## Dejar la caja con tazos «pide» el envío: el repartidor llega una hora de
## juego después (la cuenta la lleva GameState con el reloj del juego). La
## puerta solo muestra el aviso cuando llega. Nunca se le ve; más adelante
## dejará notas cada vez más raras.
## Pendiente: la bandeja animada.

@onready var _interactable: Interactable = $Interactable
# Bandeja con dinero: un plano amarillo que solo se ve si hay dinero.
@onready var _money_tray: MeshInstance3D = $MoneyTray


func _ready() -> void:
	_interactable.interacted.connect(_on_interacted)
	EventBus.shipping_changed.connect(_refresh)
	EventBus.courier_arrived.connect(_on_courier_arrived)
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
		if GameState.is_courier_on_the_way():
			var arrival := TimeManager.get_whole_minute() + GameState.get_courier_minutes_left()
			EventBus.notification_requested.emit(
					tr("Envío pedido: el repartidor llega a las %s") % TimeManager.format_clock(arrival))
		else:
			EventBus.notification_requested.emit(tr("Dejaste la caja vacía en la puerta"))


func _on_courier_arrived(amount: int, while_sleeping: bool) -> void:
	if while_sleeping:
		EventBus.notification_requested.emit(tr("Mientras dormías, el repartidor dejó $%d en la puerta") % amount)
	else:
		EventBus.notification_requested.emit(tr("El repartidor dejó $%d en la puerta") % amount)
