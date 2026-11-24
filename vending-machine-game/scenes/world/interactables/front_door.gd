extends StaticBody3D
## La puerta principal: aquí se deja la caja de envío y pasa el repartidor
## (GDD 5.8 y 9).
##
## «E · Dejar caja» solo aparece si hay tazos vendidos en la caja. El
## repartidor pasa cada `courier_interval_minutes` de juego (10:00, 12:00…):
## si hay una caja en la puerta, se la lleva y GameState paga. El repartidor
## nunca se ve; más adelante dejará notas cada vez más raras.

## Minutos de juego entre visitas del repartidor. La mejora «Repartidor
## Puntual» lo baja a 60.
@export var courier_interval_minutes: int = 120

@onready var _interactable: Interactable = $Interactable


func _ready() -> void:
	_interactable.interacted.connect(_on_interacted)
	EventBus.shipping_changed.connect(_refresh_prompt)
	EventBus.clock_changed.connect(_on_clock_changed)
	_refresh_prompt()


## Solo se puede usar la puerta si hay algo que dejar.
func _refresh_prompt() -> void:
	var count := GameState.get_shipping_box_count()
	_interactable.enabled = count > 0
	_interactable.prompt_text = tr("Dejar caja (%d)") % count


func _on_interacted(_by: Node) -> void:
	var moved := GameState.move_box_to_door()
	if moved > 0:
		EventBus.notification_requested.emit(
				tr("Caja en la puerta: el repartidor pasa cada %d h") % (courier_interval_minutes / 60))


func _on_clock_changed(minute: int) -> void:
	# Las visitas caen en horas exactas desde las 08:00 (10:00, 12:00…).
	if minute % courier_interval_minutes != 0:
		return
	var paid := GameState.collect_door_box()
	if paid > 0:
		EventBus.notification_requested.emit(tr("El repartidor recogió la caja: +$%d") % paid)
