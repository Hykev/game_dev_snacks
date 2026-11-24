class_name EatingStation
extends Node3D
## La mesa + sofá donde se comen los snacks (GDD 5.3).
##
## Por ahora solo permite sentarse: al usarla, anuncia por EventBus que el
## jugador quiere sentarse y le pasa su cámara fija. El jugador decide cómo
## cambiar de modo (la mesa nunca toca al jugador directamente).
##
## En los siguientes pasos tendrá las dos zonas (comer a la derecha, tazos a
## la izquierda), los snacks con física y el GrabController.

@onready var _seat_interactable: Interactable = %SeatInteractable
@onready var _view_camera: Camera3D = %ViewCamera


func _ready() -> void:
	_seat_interactable.interacted.connect(_on_seat_interacted)


func _on_seat_interacted(_by: Node) -> void:
	EventBus.table_sit_requested.emit(_view_camera)
